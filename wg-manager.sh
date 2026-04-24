#!/bin/bash

# Утилита для управления клиентами WireGuard
# Version: 2.0.0
# Author: houseassassin
# GitHub: https://github.com/houseassassin/proxy-core

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

WG_DIR="/etc/wireguard"
WG_CONF="$WG_DIR/wg0.conf"

print_msg() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Требуются права root"
        exit 1
    fi
}

get_next_ip() {
    if [ ! -f "$WG_CONF" ]; then
        echo "10.0.0.2"
        return
    fi

    LAST_IP=$(grep "AllowedIPs" "$WG_CONF" | grep -oE "10\.0\.0\.[0-9]+" | sort -t . -k 4 -n | tail -1)

    if [ -z "$LAST_IP" ]; then
        echo "10.0.0.2"
    else
        LAST_NUM=$(echo $LAST_IP | cut -d. -f4)
        NEXT_NUM=$((LAST_NUM + 1))
        echo "10.0.0.$NEXT_NUM"
    fi
}

add_client() {
    read -p "Введите имя клиента: " CLIENT_NAME

    if [ -z "$CLIENT_NAME" ]; then
        print_error "Имя клиента не может быть пустым"
        exit 1
    fi

    CLIENT_DIR="$WG_DIR/clients/$CLIENT_NAME"

    if [ -d "$CLIENT_DIR" ]; then
        print_error "Клиент $CLIENT_NAME уже существует"
        exit 1
    fi

    mkdir -p "$CLIENT_DIR"
    cd "$CLIENT_DIR"

    wg genkey | tee private.key | wg pubkey > public.key
    chmod 600 private.key

    CLIENT_PRIVATE_KEY=$(cat private.key)
    CLIENT_PUBLIC_KEY=$(cat public.key)
    SERVER_PUBLIC_KEY=$(cat $WG_DIR/server_public.key)
    SERVER_IP=$(curl -s ifconfig.me)
    SERVER_PORT=$(grep ListenPort $WG_CONF | awk '{print $3}')
    CLIENT_IP=$(get_next_ip)

    cat >> $WG_CONF <<EOF

[Peer]
# $CLIENT_NAME
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = $CLIENT_IP/32
EOF

    cat > client.conf <<EOF
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = $CLIENT_IP/24
DNS = 8.8.8.8, 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_IP:$SERVER_PORT
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF

    systemctl restart wg-quick@wg0

    print_msg "Клиент $CLIENT_NAME создан"
    print_msg "IP адрес: $CLIENT_IP"
    print_msg "Конфигурация: $CLIENT_DIR/client.conf"

    echo ""
    print_msg "QR-код для мобильных устройств:"
    qrencode -t ansiutf8 < client.conf

    echo ""
    print_msg "Конфигурация клиента:"
    cat client.conf
}

list_clients() {
    print_msg "Список клиентов WireGuard:"
    echo ""

    if [ ! -d "$WG_DIR/clients" ]; then
        print_msg "Клиенты не найдены"
        return
    fi

    for client in $WG_DIR/clients/*; do
        if [ -d "$client" ]; then
            CLIENT_NAME=$(basename "$client")
            CLIENT_IP=$(grep -A 2 "# $CLIENT_NAME" $WG_CONF | grep AllowedIPs | awk '{print $3}' | cut -d/ -f1)
            echo "- $CLIENT_NAME ($CLIENT_IP)"
        fi
    done
}

remove_client() {
    read -p "Введите имя клиента для удаления: " CLIENT_NAME

    if [ -z "$CLIENT_NAME" ]; then
        print_error "Имя клиента не может быть пустым"
        exit 1
    fi

    CLIENT_DIR="$WG_DIR/clients/$CLIENT_NAME"

    if [ ! -d "$CLIENT_DIR" ]; then
        print_error "Клиент $CLIENT_NAME не найден"
        exit 1
    fi

    sed -i "/# $CLIENT_NAME/,+2d" $WG_CONF
    rm -rf "$CLIENT_DIR"

    systemctl restart wg-quick@wg0

    print_msg "Клиент $CLIENT_NAME удален"
}

show_client() {
    read -p "Введите имя клиента: " CLIENT_NAME

    if [ -z "$CLIENT_NAME" ]; then
        print_error "Имя клиента не может быть пустым"
        exit 1
    fi

    CLIENT_DIR="$WG_DIR/clients/$CLIENT_NAME"

    if [ ! -d "$CLIENT_DIR" ]; then
        print_error "Клиент $CLIENT_NAME не найден"
        exit 1
    fi

    print_msg "Конфигурация клиента $CLIENT_NAME:"
    cat "$CLIENT_DIR/client.conf"

    echo ""
    print_msg "QR-код:"
    qrencode -t ansiutf8 < "$CLIENT_DIR/client.conf"
}

show_menu() {
    clear
    echo "╔════════════════════════════════════════╗"
    echo "║   WireGuard Client Manager            ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "1) Добавить клиента"
    echo "2) Список клиентов"
    echo "3) Показать конфигурацию клиента"
    echo "4) Удалить клиента"
    echo "5) Выход"
    echo ""
    read -p "Ваш выбор [1-5]: " choice
}

main() {
    check_root

    if [ ! -f "$WG_CONF" ]; then
        print_error "WireGuard не установлен или не настроен"
        exit 1
    fi

    while true; do
        show_menu

        case $choice in
            1)
                add_client
                ;;
            2)
                list_clients
                read -p "Нажмите Enter..."
                ;;
            3)
                show_client
                ;;
            4)
                remove_client
                ;;
            5)
                print_msg "Выход..."
                exit 0
                ;;
            *)
                print_error "Неверный выбор"
                sleep 1
                ;;
        esac
    done
}

main
