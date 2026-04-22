#!/bin/bash

# VPN Panel Management Script
# Version: 2.0.0
# Author: houseassassin
# GitHub: https://github.com/houseassassin/proxy-core
# Управление установленными панелями

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# WireGuard Management
manage_wireguard() {
    if ! systemctl is-active --quiet wg-quick@wg0; then
        error "WireGuard не установлен или не запущен"
        return 1
    fi

    while true; do
        clear
        echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║   WireGuard Management                ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}1.${NC} Показать статус"
        echo -e "${YELLOW}2.${NC} Добавить клиента"
        echo -e "${YELLOW}3.${NC} Список клиентов"
        echo -e "${YELLOW}4.${NC} Удалить клиента"
        echo -e "${YELLOW}5.${NC} Показать QR-код"
        echo -e "${YELLOW}6.${NC} Перезапустить сервис"
        echo -e "${YELLOW}0.${NC} Назад"
        echo ""
        read -p "Выберите опцию: " choice

        case $choice in
            1)
                echo ""
                systemctl status wg-quick@wg0 --no-pager
                wg show
                read -p "Нажмите Enter..."
                ;;
            2)
                add_wireguard_client
                ;;
            3)
                list_wireguard_clients
                ;;
            4)
                remove_wireguard_client
                ;;
            5)
                show_wireguard_qr
                ;;
            6)
                systemctl restart wg-quick@wg0
                success "WireGuard перезапущен"
                sleep 2
                ;;
            0)
                return 0
                ;;
            *)
                warn "Неверный выбор"
                sleep 1
                ;;
        esac
    done
}

add_wireguard_client() {
    read -p "Введите имя клиента: " CLIENT_NAME

    if [ -z "$CLIENT_NAME" ]; then
        error "Имя не может быть пустым"
        return 1
    fi

    CLIENT_DIR="/etc/wireguard/clients/$CLIENT_NAME"

    if [ -d "$CLIENT_DIR" ]; then
        error "Клиент $CLIENT_NAME уже существует"
        return 1
    fi

    mkdir -p "$CLIENT_DIR"
    cd "$CLIENT_DIR"

    # Generate keys
    wg genkey | tee private.key | wg pubkey > public.key
    chmod 600 private.key

    CLIENT_PRIVATE_KEY=$(cat private.key)
    CLIENT_PUBLIC_KEY=$(cat public.key)
    SERVER_PUBLIC_KEY=$(cat /etc/wireguard/server_public.key)
    SERVER_IP=$(curl -s ifconfig.me)
    SERVER_PORT=$(grep ListenPort /etc/wireguard/wg0.conf | awk '{print $3}')

    # Get next available IP
    LAST_IP=$(grep "AllowedIPs" /etc/wireguard/wg0.conf | grep -oE "10\.0\.0\.[0-9]+" | sort -t . -k 4 -n | tail -1)
    if [ -z "$LAST_IP" ]; then
        CLIENT_IP="10.0.0.2"
    else
        LAST_NUM=$(echo $LAST_IP | cut -d. -f4)
        NEXT_NUM=$((LAST_NUM + 1))
        CLIENT_IP="10.0.0.$NEXT_NUM"
    fi

    # Add peer to server config
    cat >> /etc/wireguard/wg0.conf <<EOF

[Peer]
# $CLIENT_NAME
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = $CLIENT_IP/32
EOF

    # Create client config
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

    success "Клиент $CLIENT_NAME создан"
    log "IP адрес: $CLIENT_IP"
    log "Конфигурация: $CLIENT_DIR/client.conf"

    echo ""
    log "QR-код для мобильных устройств:"
    qrencode -t ansiutf8 < client.conf

    echo ""
    read -p "Нажмите Enter..."
}

list_wireguard_clients() {
    echo ""
    log "Список клиентов WireGuard:"
    echo ""

    if [ ! -d "/etc/wireguard/clients" ]; then
        warn "Клиенты не найдены"
        read -p "Нажмите Enter..."
        return
    fi

    for client in /etc/wireguard/clients/*; do
        if [ -d "$client" ]; then
            CLIENT_NAME=$(basename "$client")
            CLIENT_IP=$(grep -A 2 "# $CLIENT_NAME" /etc/wireguard/wg0.conf | grep AllowedIPs | awk '{print $3}' | cut -d/ -f1)
            echo -e "${GREEN}•${NC} $CLIENT_NAME ${BLUE}($CLIENT_IP)${NC}"
        fi
    done

    echo ""
    read -p "Нажмите Enter..."
}

remove_wireguard_client() {
    read -p "Введите имя клиента для удаления: " CLIENT_NAME

    if [ -z "$CLIENT_NAME" ]; then
        error "Имя не может быть пустым"
        return 1
    fi

    CLIENT_DIR="/etc/wireguard/clients/$CLIENT_NAME"

    if [ ! -d "$CLIENT_DIR" ]; then
        error "Клиент $CLIENT_NAME не найден"
        return 1
    fi

    sed -i "/# $CLIENT_NAME/,+2d" /etc/wireguard/wg0.conf
    rm -rf "$CLIENT_DIR"

    systemctl restart wg-quick@wg0

    success "Клиент $CLIENT_NAME удален"
    sleep 2
}

show_wireguard_qr() {
    read -p "Введите имя клиента: " CLIENT_NAME

    if [ -z "$CLIENT_NAME" ]; then
        error "Имя не может быть пустым"
        return 1
    fi

    CLIENT_DIR="/etc/wireguard/clients/$CLIENT_NAME"

    if [ ! -d "$CLIENT_DIR" ]; then
        error "Клиент $CLIENT_NAME не найден"
        return 1
    fi

    echo ""
    log "Конфигурация клиента $CLIENT_NAME:"
    cat "$CLIENT_DIR/client.conf"

    echo ""
    log "QR-код:"
    qrencode -t ansiutf8 < "$CLIENT_DIR/client.conf"

    echo ""
    read -p "Нажмите Enter..."
}

# 3x-ui Management
manage_3xui() {
    if ! command -v x-ui &> /dev/null; then
        error "3x-ui не установлен"
        return 1
    fi

    while true; do
        clear
        echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║   3x-ui Management                    ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}1.${NC} Показать статус"
        echo -e "${YELLOW}2.${NC} Запустить"
        echo -e "${YELLOW}3.${NC} Остановить"
        echo -e "${YELLOW}4.${NC} Перезапустить"
        echo -e "${YELLOW}5.${NC} Показать логи"
        echo -e "${YELLOW}6.${NC} Обновить"
        echo -e "${YELLOW}7.${NC} Сбросить пароль"
        echo -e "${YELLOW}0.${NC} Назад"
        echo ""
        read -p "Выберите опцию: " choice

        case $choice in
            1)
                x-ui status
                read -p "Нажмите Enter..."
                ;;
            2)
                x-ui start
                success "3x-ui запущен"
                sleep 2
                ;;
            3)
                x-ui stop
                success "3x-ui остановлен"
                sleep 2
                ;;
            4)
                x-ui restart
                success "3x-ui перезапущен"
                sleep 2
                ;;
            5)
                x-ui log
                ;;
            6)
                bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
                success "3x-ui обновлен"
                sleep 2
                ;;
            7)
                x-ui reset
                ;;
            0)
                return 0
                ;;
            *)
                warn "Неверный выбор"
                sleep 1
                ;;
        esac
    done
}

# Remnawave Management
manage_remnawave() {
    if [ ! -d "/opt/remnawave" ]; then
        error "Remnawave не установлен"
        return 1
    fi

    while true; do
        clear
        echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║   Remnawave Management                ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}1.${NC} Показать статус"
        echo -e "${YELLOW}2.${NC} Запустить все сервисы"
        echo -e "${YELLOW}3.${NC} Остановить все сервисы"
        echo -e "${YELLOW}4.${NC} Перезапустить все сервисы"
        echo -e "${YELLOW}5.${NC} Показать логи"
        echo -e "${YELLOW}6.${NC} Обновить"
        echo -e "${YELLOW}7.${NC} Резервное копирование"
        echo -e "${YELLOW}8.${NC} Восстановить из бэкапа"
        echo -e "${YELLOW}0.${NC} Назад"
        echo ""
        read -p "Выберите опцию: " choice

        case $choice in
            1)
                cd /opt/remnawave
                docker compose ps
                read -p "Нажмите Enter..."
                ;;
            2)
                cd /opt/remnawave
                docker compose up -d
                success "Сервисы запущены"
                sleep 2
                ;;
            3)
                cd /opt/remnawave
                docker compose down
                success "Сервисы остановлены"
                sleep 2
                ;;
            4)
                cd /opt/remnawave
                docker compose restart
                success "Сервисы перезапущены"
                sleep 2
                ;;
            5)
                cd /opt/remnawave
                docker compose logs -f
                ;;
            6)
                cd /opt/remnawave
                docker compose pull
                docker compose up -d
                success "Remnawave обновлен"
                sleep 2
                ;;
            7)
                backup_remnawave
                ;;
            8)
                restore_remnawave
                ;;
            0)
                return 0
                ;;
            *)
                warn "Неверный выбор"
                sleep 1
                ;;
        esac
    done
}

backup_remnawave() {
    local BACKUP_DIR="/root/remnawave-backups"
    local TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    local BACKUP_FILE="$BACKUP_DIR/remnawave_backup_$TIMESTAMP.tar.gz"

    mkdir -p "$BACKUP_DIR"

    log "Создание резервной копии..."

    cd /opt/remnawave
    docker compose down

    tar -czf "$BACKUP_FILE" \
        -C /opt remnawave \
        --exclude='remnawave/logs' \
        --exclude='remnawave/node_modules'

    docker compose up -d

    success "Резервная копия создана: $BACKUP_FILE"
    read -p "Нажмите Enter..."
}

restore_remnawave() {
    local BACKUP_DIR="/root/remnawave-backups"

    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR)" ]; then
        error "Резервные копии не найдены"
        read -p "Нажмите Enter..."
        return 1
    fi

    echo ""
    log "Доступные резервные копии:"
    echo ""

    local i=1
    declare -A backups
    for backup in "$BACKUP_DIR"/*.tar.gz; do
        echo -e "${YELLOW}$i.${NC} $(basename $backup)"
        backups[$i]="$backup"
        ((i++))
    done

    echo ""
    read -p "Выберите номер резервной копии: " choice

    if [ -z "${backups[$choice]}" ]; then
        error "Неверный выбор"
        return 1
    fi

    local BACKUP_FILE="${backups[$choice]}"

    warn "Это удалит текущую установку Remnawave!"
    read -p "Продолжить? (y/N): " confirm

    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        log "Отменено"
        return 0
    fi

    log "Восстановление из резервной копии..."

    cd /opt/remnawave
    docker compose down

    rm -rf /opt/remnawave
    tar -xzf "$BACKUP_FILE" -C /opt

    cd /opt/remnawave
    docker compose up -d

    success "Восстановление завершено"
    read -p "Нажмите Enter..."
}

# Hysteria2 Management
manage_hysteria2() {
    if ! systemctl cat hysteria-server.service &> /dev/null; then
        error "Hysteria2 не установлен"
        return 1
    fi

    while true; do
        clear
        echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║   Hysteria2 Management                ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}1.${NC} Показать статус"
        echo -e "${YELLOW}2.${NC} Запустить"
        echo -e "${YELLOW}3.${NC} Остановить"
        echo -e "${YELLOW}4.${NC} Перезапустить"
        echo -e "${YELLOW}5.${NC} Показать конфигурацию"
        echo -e "${YELLOW}6.${NC} Редактировать конфигурацию"
        echo -e "${YELLOW}0.${NC} Назад"
        echo ""
        read -p "Выберите опцию: " choice

        case $choice in
            1)
                systemctl status hysteria-server.service --no-pager
                read -p "Нажмите Enter..."
                ;;
            2)
                systemctl start hysteria-server.service
                success "Hysteria2 запущен"
                sleep 2
                ;;
            3)
                systemctl stop hysteria-server.service
                success "Hysteria2 остановлен"
                sleep 2
                ;;
            4)
                systemctl restart hysteria-server.service
                success "Hysteria2 перезапущен"
                sleep 2
                ;;
            5)
                cat /etc/hysteria/config.yaml
                read -p "Нажмите Enter..."
                ;;
            6)
                ${EDITOR:-nano} /etc/hysteria/config.yaml
                systemctl restart hysteria-server.service
                success "Конфигурация обновлена"
                sleep 2
                ;;
            0)
                return 0
                ;;
            *)
                warn "Неверный выбор"
                sleep 1
                ;;
        esac
    done
}

# Main menu
main_menu() {
    while true; do
        clear
        echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║   VPN Panel Management                ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}1.${NC} Управление WireGuard"
        echo -e "${YELLOW}2.${NC} Управление 3x-ui"
        echo -e "${YELLOW}3.${NC} Управление Remnawave"
        echo -e "${YELLOW}4.${NC} Управление Hysteria2"
        echo -e "${YELLOW}5.${NC} Системная информация"
        echo -e "${YELLOW}0.${NC} Выход"
        echo ""
        read -p "Выберите опцию: " choice

        case $choice in
            1) manage_wireguard ;;
            2) manage_3xui ;;
            3) manage_remnawave ;;
            4) manage_hysteria2 ;;
            5)
                clear
                echo -e "${GREEN}Системная информация:${NC}"
                echo ""
                echo -e "${BLUE}IP адрес:${NC} $(curl -s ifconfig.me)"
                echo -e "${BLUE}ОС:${NC} $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
                echo -e "${BLUE}Ядро:${NC} $(uname -r)"
                echo -e "${BLUE}Uptime:${NC} $(uptime -p)"
                echo -e "${BLUE}RAM:${NC} $(free -h | grep Mem: | awk '{print $3 "/" $2}')"
                echo -e "${BLUE}Disk:${NC} $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 ")"}')"
                echo ""
                read -p "Нажмите Enter..."
                ;;
            0)
                log "Выход"
                exit 0
                ;;
            *)
                warn "Неверный выбор"
                sleep 1
                ;;
        esac
    done
}

# Check root
if [[ $EUID -ne 0 ]]; then
    error "Этот скрипт должен быть запущен с правами root"
    exit 1
fi

main_menu
