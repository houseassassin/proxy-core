#!/bin/bash

# WireGuard common functions library
# Version: 2.1.1
# Author: houseassassin

# Source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

WG_DIR="${WG_DIR:-/etc/wireguard}"
WG_CONF="$WG_DIR/wg0.conf"

# Get next available IP for WireGuard client
get_next_wg_ip() {
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

# Add WireGuard client
add_wireguard_client() {
    local client_name=$1

    if [ -z "$client_name" ]; then
        read -p "Введите имя клиента: " client_name
    fi

    if ! validate_name "$client_name"; then
        return 1
    fi

    local CLIENT_DIR="$WG_DIR/clients/$client_name"

    if [ -d "$CLIENT_DIR" ]; then
        error "Клиент $client_name уже существует"
        return 1
    fi

    mkdir -p "$CLIENT_DIR"
    cd "$CLIENT_DIR"

    # Generate keys
    wg genkey | tee private.key | wg pubkey > public.key
    chmod 600 private.key

    CLIENT_PRIVATE_KEY=$(cat private.key)
    CLIENT_PUBLIC_KEY=$(cat public.key)
    SERVER_PUBLIC_KEY=$(cat $WG_DIR/server_public.key)
    SERVER_IP=$(get_server_ip)
    SERVER_PORT=$(grep ListenPort $WG_CONF | awk '{print $3}')
    CLIENT_IP=$(get_next_wg_ip)

    # Add peer to server config
    cat >> $WG_CONF <<EOF

[Peer]
# $client_name
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

    success "Клиент $client_name создан"
    log "IP адрес: $CLIENT_IP"
    log "Конфигурация: $CLIENT_DIR/client.conf"

    echo ""
    log "QR-код для мобильных устройств:"
    if command_exists qrencode; then
        qrencode -t ansiutf8 < client.conf
    else
        warn "qrencode не установлен, QR-код недоступен"
    fi

    echo ""
    log "Конфигурация клиента:"
    cat client.conf
}

# List WireGuard clients
list_wireguard_clients() {
    log "Список клиентов WireGuard:"
    echo ""

    if [ ! -d "$WG_DIR/clients" ]; then
        warn "Клиенты не найдены"
        return
    fi

    for client in $WG_DIR/clients/*; do
        if [ -d "$client" ]; then
            CLIENT_NAME=$(basename "$client")
            CLIENT_IP=$(grep -A 2 "# $CLIENT_NAME" $WG_CONF | grep AllowedIPs | awk '{print $3}' | cut -d/ -f1)
            echo -e "${GREEN}•${NC} $CLIENT_NAME ${BLUE}($CLIENT_IP)${NC}"
        fi
    done
}

# Remove WireGuard client
remove_wireguard_client() {
    local client_name=$1

    if [ -z "$client_name" ]; then
        read -p "Введите имя клиента для удаления: " client_name
    fi

    if ! validate_name "$client_name"; then
        return 1
    fi

    local CLIENT_DIR="$WG_DIR/clients/$client_name"

    if [ ! -d "$CLIENT_DIR" ]; then
        error "Клиент $client_name не найден"
        return 1
    fi

    if ! confirm "Удалить клиента $client_name?"; then
        log "Отменено"
        return 0
    fi

    sed -i "/# $client_name/,+2d" $WG_CONF
    rm -rf "$CLIENT_DIR"

    systemctl restart wg-quick@wg0

    success "Клиент $client_name удален"
}

# Show WireGuard client QR code
show_wireguard_qr() {
    local client_name=$1

    if [ -z "$client_name" ]; then
        read -p "Введите имя клиента: " client_name
    fi

    if ! validate_name "$client_name"; then
        return 1
    fi

    local CLIENT_DIR="$WG_DIR/clients/$client_name"

    if [ ! -d "$CLIENT_DIR" ]; then
        error "Клиент $client_name не найден"
        return 1
    fi

    echo ""
    log "Конфигурация клиента $client_name:"
    cat "$CLIENT_DIR/client.conf"

    echo ""
    log "QR-код:"
    if command_exists qrencode; then
        qrencode -t ansiutf8 < "$CLIENT_DIR/client.conf"
    else
        error "qrencode не установлен"
        return 1
    fi
}

# Export functions
export -f get_next_wg_ip add_wireguard_client list_wireguard_clients
export -f remove_wireguard_client show_wireguard_qr
