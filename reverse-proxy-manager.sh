#!/bin/bash

# Reverse Proxy Manager for Proxy-Core
# Version: 2.1.1
# Author: houseassassin
# Supports: Nginx, Caddy, HAProxy

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
NGINX_DIR="/etc/nginx"
CADDY_DIR="/etc/caddy"
HAPROXY_DIR="/etc/haproxy"

# Detect installed reverse proxies
detect_installed_proxies() {
    local proxies=()

    if command_exists nginx; then
        proxies+=("nginx")
    fi

    if command_exists caddy; then
        proxies+=("caddy")
    fi

    if command_exists haproxy; then
        proxies+=("haproxy")
    fi

    echo "${proxies[@]}"
}

# Install Nginx
install_nginx() {
    log "Установка Nginx..."

    case $OS in
        ubuntu|debian)
            apt-get update -y
            apt-get install -y nginx nginx-extras certbot python3-certbot-nginx
            ;;
        centos|rhel|fedora)
            yum install -y nginx certbot python3-certbot-nginx
            ;;
    esac

    systemctl enable nginx
    systemctl start nginx

    success "Nginx установлен"
}

# Install Caddy
install_caddy() {
    log "Установка Caddy..."

    case $OS in
        ubuntu|debian)
            apt-get install -y debian-keyring debian-archive-keyring apt-transport-https
            curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
            curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
            apt-get update
            apt-get install -y caddy
            ;;
        centos|rhel|fedora)
            yum install -y yum-plugin-copr
            yum copr enable @caddy/caddy -y
            yum install -y caddy
            ;;
    esac

    systemctl enable caddy
    systemctl start caddy

    success "Caddy установлен"
}

# Install HAProxy
install_haproxy() {
    log "Установка HAProxy..."

    case $OS in
        ubuntu|debian)
            apt-get update -y
            apt-get install -y haproxy certbot
            ;;
        centos|rhel|fedora)
            yum install -y haproxy certbot
            ;;
    esac

    systemctl enable haproxy
    systemctl start haproxy

    success "HAProxy установлен"
}

# Configure Nginx for 3x-ui
configure_nginx_3xui() {
    log "Настройка Nginx для 3x-ui..."

    read -p "Введите домен (например, vpn.example.com): " DOMAIN
    read -p "Введите порт 3x-ui (по умолчанию 2053): " XRAY_PORT
    XRAY_PORT=${XRAY_PORT:-2053}

    cat > "$NGINX_DIR/sites-available/3xui" <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        return 301 https://\$server_name\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://127.0.0.1:$XRAY_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

    ln -sf "$NGINX_DIR/sites-available/3xui" "$NGINX_DIR/sites-enabled/"

    log "Получение SSL сертификата..."
    certbot certonly --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN

    nginx -t && systemctl reload nginx

    success "Nginx настроен для 3x-ui на домене $DOMAIN"
}

# Configure Caddy for 3x-ui
configure_caddy_3xui() {
    log "Настройка Caddy для 3x-ui..."

    read -p "Введите домен (например, vpn.example.com): " DOMAIN
    read -p "Введите порт 3x-ui (по умолчанию 2053): " XRAY_PORT
    XRAY_PORT=${XRAY_PORT:-2053}

    cat > "$CADDY_DIR/Caddyfile" <<EOF
$DOMAIN {
    reverse_proxy localhost:$XRAY_PORT {
        header_up Host {host}
        header_up X-Real-IP {remote}
        header_up X-Forwarded-For {remote}
        header_up X-Forwarded-Proto {scheme}
    }

    encode gzip

    tls {
        protocols tls1.2 tls1.3
    }
}
EOF

    caddy validate --config "$CADDY_DIR/Caddyfile"
    systemctl reload caddy

    success "Caddy настроен для 3x-ui на домене $DOMAIN"
}

# Configure HAProxy for load balancing
configure_haproxy_loadbalancer() {
    log "Настройка HAProxy для балансировки нагрузки..."

    read -p "Введите количество backend серверов: " BACKEND_COUNT

    echo ""
    log "Введите IP адреса backend серверов:"
    declare -a BACKENDS
    for ((i=1; i<=BACKEND_COUNT; i++)); do
        read -p "Backend $i IP:PORT: " backend
        BACKENDS+=("$backend")
    done

    cat > "$HAPROXY_DIR/haproxy.cfg" <<EOF
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log global
    mode tcp
    option tcplog
    option dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000

frontend vpn_frontend
    bind *:443
    mode tcp
    default_backend vpn_backend

backend vpn_backend
    mode tcp
    balance roundrobin
EOF

    for i in "${!BACKENDS[@]}"; do
        echo "    server backend$((i+1)) ${BACKENDS[$i]} check" >> "$HAPROXY_DIR/haproxy.cfg"
    done

    haproxy -c -f "$HAPROXY_DIR/haproxy.cfg"
    systemctl reload haproxy

    success "HAProxy настроен для балансировки нагрузки"
}

# Configure Nginx + Caddy (hybrid)
configure_hybrid_nginx_caddy() {
    log "Настройка гибридной конфигурации Nginx + Caddy..."

    echo ""
    echo -e "${CYAN}Гибридная конфигурация:${NC}"
    echo "• Nginx - обработка статики и кэширование"
    echo "• Caddy - автоматический SSL и проксирование"
    echo ""

    read -p "Введите домен: " DOMAIN

    # Nginx для статики
    cat > "$NGINX_DIR/sites-available/hybrid" <<EOF
server {
    listen 8080;
    server_name $DOMAIN;

    root /var/www/html;
    index index.html;

    location /static/ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location / {
        proxy_pass http://127.0.0.1:8081;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
    }
}
EOF

    ln -sf "$NGINX_DIR/sites-available/hybrid" "$NGINX_DIR/sites-enabled/"
    nginx -t && systemctl reload nginx

    # Caddy для SSL
    cat > "$CADDY_DIR/Caddyfile" <<EOF
$DOMAIN {
    reverse_proxy localhost:8080
    encode gzip
}
EOF

    caddy validate --config "$CADDY_DIR/Caddyfile"
    systemctl reload caddy

    success "Гибридная конфигурация настроена"
}

# Show configuration tips
show_tips() {
    clear
    echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║   Подсказки по настройке Reverse Proxy                    ║${NC}"
    echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    echo -e "${CYAN}📌 Nginx${NC}"
    echo "  ✓ Лучший выбор для высоких нагрузок"
    echo "  ✓ Отличное кэширование и обработка статики"
    echo "  ✓ Гибкая конфигурация"
    echo "  ✗ Требует ручной настройки SSL"
    echo ""

    echo -e "${CYAN}📌 Caddy${NC}"
    echo "  ✓ Автоматический SSL из коробки"
    echo "  ✓ Простая конфигурация"
    echo "  ✓ HTTP/3 поддержка"
    echo "  ✗ Меньше производительность чем Nginx"
    echo ""

    echo -e "${CYAN}📌 HAProxy${NC}"
    echo "  ✓ Лучший для балансировки нагрузки"
    echo "  ✓ TCP и HTTP режимы"
    echo "  ✓ Продвинутые health checks"
    echo "  ✗ Не обрабатывает SSL (нужен Nginx/Caddy)"
    echo ""

    echo -e "${CYAN}📌 Гибридные решения${NC}"
    echo "  • Nginx + Caddy: статика + автоSSL"
    echo "  • HAProxy + Nginx: балансировка + кэш"
    echo "  • Caddy + HAProxy: автоSSL + балансировка"
    echo ""

    echo -e "${YELLOW}Рекомендации:${NC}"
    echo "  1. Для простых VPN панелей: Caddy"
    echo "  2. Для высоких нагрузок: Nginx"
    echo "  3. Для кластера серверов: HAProxy + Nginx"
    echo "  4. Для максимальной автоматизации: Caddy"
    echo ""

    read -p "Нажмите Enter для продолжения..."
}

# Main menu
show_main_menu() {
    clear
    echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║   Reverse Proxy Manager                                   ║${NC}"
    echo -e "${MAGENTA}║   Version: 2.1.1                                          ║${NC}"
    echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    local installed=$(detect_installed_proxies)
    echo -e "${CYAN}Установлено:${NC} ${installed:-нет}"
    echo ""

    echo -e "${YELLOW}Установка:${NC}"
    echo "  1) Установить Nginx"
    echo "  2) Установить Caddy"
    echo "  3) Установить HAProxy"
    echo ""

    echo -e "${YELLOW}Настройка:${NC}"
    echo "  4) Настроить Nginx для 3x-ui"
    echo "  5) Настроить Caddy для 3x-ui"
    echo "  6) Настроить HAProxy (балансировка)"
    echo "  7) Настроить Nginx + Caddy (гибрид)"
    echo ""

    echo -e "${YELLOW}Информация:${NC}"
    echo "  8) Показать подсказки"
    echo "  9) Статус сервисов"
    echo ""

    echo "  0) Выход"
    echo ""
}

# Show services status
show_status() {
    clear
    echo -e "${CYAN}Статус сервисов:${NC}"
    echo ""

    if command_exists nginx; then
        echo -n "Nginx: "
        if service_running nginx; then
            echo -e "${GREEN}✓ Работает${NC}"
        else
            echo -e "${RED}✗ Остановлен${NC}"
        fi
    fi

    if command_exists caddy; then
        echo -n "Caddy: "
        if service_running caddy; then
            echo -e "${GREEN}✓ Работает${NC}"
        else
            echo -e "${RED}✗ Остановлен${NC}"
        fi
    fi

    if command_exists haproxy; then
        echo -n "HAProxy: "
        if service_running haproxy; then
            echo -e "${GREEN}✓ Работает${NC}"
        else
            echo -e "${RED}✗ Остановлен${NC}"
        fi
    fi

    echo ""
    read -p "Нажмите Enter..."
}

# Main function
main() {
    check_root
    detect_os

    while true; do
        show_main_menu
        read -p "Выберите опцию: " choice

        case $choice in
            1)
                install_nginx
                read -p "Нажмите Enter..."
                ;;
            2)
                install_caddy
                read -p "Нажмите Enter..."
                ;;
            3)
                install_haproxy
                read -p "Нажмите Enter..."
                ;;
            4)
                if ! command_exists nginx; then
                    error "Nginx не установлен. Установите сначала (опция 1)"
                else
                    configure_nginx_3xui
                fi
                read -p "Нажмите Enter..."
                ;;
            5)
                if ! command_exists caddy; then
                    error "Caddy не установлен. Установите сначала (опция 2)"
                else
                    configure_caddy_3xui
                fi
                read -p "Нажмите Enter..."
                ;;
            6)
                if ! command_exists haproxy; then
                    error "HAProxy не установлен. Установите сначала (опция 3)"
                else
                    configure_haproxy_loadbalancer
                fi
                read -p "Нажмите Enter..."
                ;;
            7)
                if ! command_exists nginx || ! command_exists caddy; then
                    error "Требуются Nginx и Caddy. Установите сначала (опции 1 и 2)"
                else
                    configure_hybrid_nginx_caddy
                fi
                read -p "Нажмите Enter..."
                ;;
            8)
                show_tips
                ;;
            9)
                show_status
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

main
