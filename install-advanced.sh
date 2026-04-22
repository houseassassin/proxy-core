#!/bin/bash

# Proxy-Core - Advanced VPN & Proxy Panel Auto-Installer
# Version: 2.0.0
# Author: houseassassin
# GitHub: https://github.com/houseassassin/proxy-core
# Supports: WireGuard, 3x-ui, Remnawave, Hysteria2
# Based on: 3dp-manager, remnawave-reverse-proxy, remnawave-scripts, RemnaSetup

set -euo pipefail

SCRIPT_VERSION="2.0.0"
PROJECT_DIR="/opt/proxy-core"
LANG_FILE="${PROJECT_DIR}/.selected_language"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Logging
LOGFILE="${PROJECT_DIR}/installer.log"

log() { echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOGFILE"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOGFILE"; }
error() { echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOGFILE"; exit 1; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOGFILE"; }

# Spinner animation
spinner() {
    local pid=$1
    local text=$2
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

    while kill -0 "$pid" 2>/dev/null; do
        for (( i=0; i<${#spinstr}; i++ )); do
            printf "\r${GREEN}[%s]${NC} %s" "${spinstr:$i:1}" "$text"
            sleep 0.1
        done
    done
    printf "\r\033[K"
}

# Language support
declare -A LANG_EN=(
    [MENU_TITLE]="VPN Panel Installer"
    [MENU_INSTALL]="Install Panel"
    [MENU_MANAGE]="Manage Services"
    [MENU_BACKUP]="Backup & Restore"
    [MENU_UPDATE]="Update Components"
    [MENU_UNINSTALL]="Uninstall"
    [MENU_EXIT]="Exit"
    [SELECT_PANEL]="Select panel to install"
    [WIREGUARD]="WireGuard VPN"
    [3XUI]="3x-ui Panel"
    [REMNAWAVE]="Remnawave Panel"
    [HYSTERIA2]="Hysteria2 Proxy"
    [ALL]="Install All"
)

declare -A LANG_RU=(
    [MENU_TITLE]="Установщик VPN панелей"
    [MENU_INSTALL]="Установить панель"
    [MENU_MANAGE]="Управление сервисами"
    [MENU_BACKUP]="Резервное копирование"
    [MENU_UPDATE]="Обновить компоненты"
    [MENU_UNINSTALL]="Удалить"
    [MENU_EXIT]="Выход"
    [SELECT_PANEL]="Выберите панель для установки"
    [WIREGUARD]="WireGuard VPN"
    [3XUI]="Панель 3x-ui"
    [REMNAWAVE]="Панель Remnawave"
    [HYSTERIA2]="Прокси Hysteria2"
    [ALL]="Установить всё"
)

MENU_LANG="en"

load_language() {
    if [ -f "$LANG_FILE" ]; then
        MENU_LANG=$(cat "$LANG_FILE" 2>/dev/null | tr -d '[:space:]')
    fi
}

save_language() {
    mkdir -p "$(dirname "$LANG_FILE")"
    echo "$1" > "$LANG_FILE"
    MENU_LANG="$1"
}

L() {
    local key="$1"
    local var_name="LANG_${MENU_LANG^^}_${key}"
    echo "${!var_name:-$key}"
}

# System checks
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "Этот скрипт должен быть запущен с правами root"
    fi
}

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    else
        error "Не удалось определить операционную систему"
    fi
    log "Обнаружена ОС: $OS $VER"
}

check_memory() {
    local mem_mb=$(free -m | grep Mem: | awk '{print $2}')
    if [ $mem_mb -lt 2000 ]; then
        local swap_mb=$(free -m | grep Swap: | awk '{print $2}')
        if [ $swap_mb -eq 0 ]; then
            warn "Мало RAM ($mem_mb MB), создаём swap 2GB..."
            fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048
            chmod 600 /swapfile
            mkswap /swapfile
            swapon /swapfile
            echo '/swapfile none swap sw 0 0' >> /etc/fstab
            success "Swap создан"
        fi
    fi
}

# Network utilities
get_server_ip() {
    curl -s -4 ifconfig.me || curl -s -4 api.ipify.org || curl -s -4 ipinfo.io/ip
}

get_random_port() {
    local MIN=${1:-3000}
    local MAX=${2:-6999}

    while :; do
        PORT=$(shuf -i "$MIN-$MAX" -n 1)
        if ! ss -ltun | awk '{print $4}' | grep -q ":$PORT\$"; then
            echo "$PORT"
            return
        fi
    done
}

check_domain() {
    local domain="$1"
    local domain_ip=$(dig +short A "$domain" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1)
    local server_ip=$(get_server_ip)

    if [ -z "$domain_ip" ] || [ -z "$server_ip" ]; then
        warn "Не удалось проверить DNS домена $domain"
        return 1
    fi

    if [ "$domain_ip" = "$server_ip" ]; then
        return 0
    fi

    warn "IP домена ($domain_ip) не совпадает с IP сервера ($server_ip)"
    return 1
}

# Docker management
resolve_compose_cmd() {
    if docker compose version >/dev/null 2>&1; then
        COMPOSE_CMD=("docker" "compose")
        return 0
    fi

    if command -v docker-compose >/dev/null 2>&1; then
        COMPOSE_CMD=("docker-compose")
        return 0
    fi

    warn "Docker Compose не найден, устанавливаем..."
    apt-get update
    apt-get install -y docker-compose-plugin || apt-get install -y docker-compose

    if docker compose version >/dev/null 2>&1; then
        COMPOSE_CMD=("docker" "compose")
        return 0
    fi

    error "Не удалось установить Docker Compose"
}

install_docker() {
    if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
        log "Docker уже установлен"
        resolve_compose_cmd
        return 0
    fi

    log "Установка Docker..."
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sh /tmp/get-docker.sh
    rm /tmp/get-docker.sh

    systemctl enable docker
    systemctl start docker

    resolve_compose_cmd
    success "Docker установлен"
}

# System packages
install_packages() {
    log "Установка системных пакетов..."

    case $OS in
        ubuntu|debian)
            apt-get update -y
            apt-get install -y curl wget git sudo ufw certbot \
                ca-certificates jq openssl tar net-tools \
                qrencode python3-certbot-dns-cloudflare \
                unattended-upgrades locales dnsutils coreutils \
                grep gawk python3-pip cron
            ;;
        centos|rhel|fedora)
            yum update -y
            yum install -y curl wget git sudo firewalld certbot \
                ca-certificates jq openssl tar net-tools qrencode
            ;;
        *)
            error "Неподдерживаемая ОС: $OS"
            ;;
    esac

    # BBR
    if ! grep -q "net.core.default_qdisc = fq" /etc/sysctl.conf; then
        echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
    fi
    if ! grep -q "net.ipv4.tcp_congestion_control = bbr" /etc/sysctl.conf; then
        echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
    fi
    sysctl -p >/dev/null

    # UFW
    if command -v ufw >/dev/null 2>&1; then
        ufw allow 22/tcp comment 'SSH' >/dev/null 2>&1
        ufw allow 443/tcp comment 'HTTPS' >/dev/null 2>&1
        ufw --force enable >/dev/null 2>&1
    fi

    success "Системные пакеты установлены"
}

# SSL Certificates
get_ssl_certificate() {
    local domain="$1"
    local email="$2"
    local method="${3:-standalone}"

    log "Получение SSL сертификата для $domain..."

    case $method in
        standalone)
            ufw allow 80/tcp >/dev/null 2>&1
            certbot certonly --standalone \
                -d "$domain" \
                --email "$email" \
                --agree-tos \
                --non-interactive \
                --http-01-port 80 \
                --key-type ecdsa \
                --elliptic-curve secp384r1
            ufw delete allow 80/tcp >/dev/null 2>&1
            ;;
        cloudflare)
            if [ -z "$CLOUDFLARE_API_KEY" ]; then
                read -p "Введите Cloudflare API Token: " CLOUDFLARE_API_KEY
            fi

            mkdir -p ~/.secrets/certbot
            cat > ~/.secrets/certbot/cloudflare.ini <<EOL
dns_cloudflare_api_token = $CLOUDFLARE_API_KEY
EOL
            chmod 600 ~/.secrets/certbot/cloudflare.ini

            certbot certonly \
                --dns-cloudflare \
                --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini \
                --dns-cloudflare-propagation-seconds 60 \
                -d "$domain" \
                -d "*.$domain" \
                --email "$email" \
                --agree-tos \
                --non-interactive \
                --key-type ecdsa \
                --elliptic-curve secp384r1
            ;;
    esac

    if [ -d "/etc/letsencrypt/live/$domain" ]; then
        success "SSL сертификат получен для $domain"
        return 0
    else
        error "Не удалось получить SSL сертификат"
    fi
}

# WireGuard installation
install_wireguard() {
    log "Установка WireGuard..."

    case $OS in
        ubuntu|debian)
            apt-get install -y wireguard wireguard-tools qrencode
            ;;
        centos|rhel|fedora)
            yum install -y epel-release
            yum install -y wireguard-tools qrencode
            ;;
    esac

    mkdir -p /etc/wireguard
    cd /etc/wireguard

    if [ ! -f server_private.key ]; then
        wg genkey | tee server_private.key | wg pubkey > server_public.key
        chmod 600 server_private.key
    fi

    read -p "Введите порт WireGuard (по умолчанию 51820): " WG_PORT
    WG_PORT=${WG_PORT:-51820}

    SERVER_PRIVATE_KEY=$(cat server_private.key)
    SERVER_IP=$(get_server_ip)

    cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = 10.0.0.1/24
ListenPort = $WG_PORT
PrivateKey = $SERVER_PRIVATE_KEY
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
EOF

    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p

    systemctl enable wg-quick@wg0
    systemctl start wg-quick@wg0

    ufw allow $WG_PORT/udp 2>/dev/null || firewall-cmd --permanent --add-port=$WG_PORT/udp 2>/dev/null

    success "WireGuard установлен на порту $WG_PORT"
    log "Конфигурация: /etc/wireguard/wg0.conf"
}

# 3x-ui installation
install_3xui() {
    log "Установка 3x-ui..."

    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

    success "3x-ui установлен"
    log "Панель доступна: http://$(get_server_ip):2053"
    log "Логин: admin | Пароль: admin (СМЕНИТЕ!)"
}

# Hysteria2 installation
install_hysteria2() {
    log "Установка Hysteria2..."

    if systemctl cat hysteria-server.service &> /dev/null; then
        log "Hysteria2 уже установлен"
        return 0
    fi

    bash <(curl -fsSL https://get.hy2.sh/)

    local HY2_PORT=$(get_random_port 10000 20000)
    local HY2_PASSWORD=$(openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | cut -c1-16)
    local HY2_OBFS=$(openssl rand -base64 16 | tr -dc 'A-Za-z0-9' | cut -c1-16)

    read -p "Введите домен для Hysteria2: " HY2_DOMAIN
    read -p "Введите email для Let's Encrypt: " HY2_EMAIL

    cat > /etc/hysteria/config.yaml <<EOF
listen: :$HY2_PORT

acme:
  domains:
    - $HY2_DOMAIN
  email: $HY2_EMAIL

auth:
  type: password
  password: $HY2_PASSWORD

obfs:
  type: salamander
  salamander:
    password: $HY2_OBFS

masquerade:
  type: proxy
  proxy:
    url: https://www.google.com/
    rewriteHost: true
EOF

    systemctl daemon-reload
    systemctl enable --now hysteria-server.service
    systemctl restart hysteria-server.service

    success "Hysteria2 установлен на порту $HY2_PORT"
    log "Пароль: $HY2_PASSWORD"
    log "Obfs: $HY2_OBFS"
}

# Remnawave installation
install_remnawave() {
    log "Установка Remnawave..."

    install_docker

    mkdir -p /opt/remnawave
    cd /opt/remnawave

    read -p "Введите домен для Remnawave: " REMNA_DOMAIN
    read -p "Введите email для SSL: " REMNA_EMAIL

    local DB_PASS=$(openssl rand -base64 12)
    local JWT_SECRET=$(openssl rand -base64 32)
    local ADMIN_USER=$(openssl rand -base64 8)
    local ADMIN_PASS=$(openssl rand -base64 12)

    cat > .env <<EOF
DB_HOST=postgres
DB_PORT=5432
DB_USERNAME=admin
DB_PASSWORD=${DB_PASS}
DB_NAME=remnawave
JWT_SECRET=${JWT_SECRET}
ADMIN_LOGIN=${ADMIN_USER}
ADMIN_PASSWORD=${ADMIN_PASS}
PORT=3100
EOF

    get_ssl_certificate "$REMNA_DOMAIN" "$REMNA_EMAIL" "standalone"

    cat > docker-compose.yml <<EOF
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: remnawave-postgres
    restart: always
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: ${DB_PASS}
      POSTGRES_DB: remnawave
    volumes:
      - pg_data:/var/lib/postgresql/data
    networks:
      - remnawave-network

  backend:
    image: ghcr.io/remnawave/backend:latest
    container_name: remnawave-backend
    restart: always
    depends_on:
      - postgres
    env_file:
      - .env
    networks:
      - remnawave-network

  frontend:
    image: nginx:alpine
    container_name: remnawave-frontend
    restart: always
    depends_on:
      - backend
    ports:
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - /etc/letsencrypt/live/${REMNA_DOMAIN}/fullchain.pem:/etc/nginx/ssl/fullchain.pem:ro
      - /etc/letsencrypt/live/${REMNA_DOMAIN}/privkey.pem:/etc/nginx/ssl/privkey.pem:ro
    networks:
      - remnawave-network

volumes:
  pg_data:

networks:
  remnawave-network:
    driver: bridge
EOF

    cat > nginx.conf <<EOF
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend:3100;
    }

    server {
        listen 443 ssl http2;
        server_name ${REMNA_DOMAIN};

        ssl_certificate /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/privkey.pem;

        location / {
            proxy_pass http://backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOF

    "${COMPOSE_CMD[@]}" up -d

    success "Remnawave установлен"
    log "Панель: https://${REMNA_DOMAIN}"
    log "Логин: ${ADMIN_USER}"
    log "Пароль: ${ADMIN_PASS}"
}

# Main menu
show_main_menu() {
    clear
    echo -e "${MAGENTA}╔════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║   $(L MENU_TITLE)                    ║${NC}"
    echo -e "${MAGENTA}║   Version: ${SCRIPT_VERSION}                      ║${NC}"
    echo -e "${MAGENTA}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}1.${NC} $(L MENU_INSTALL)"
    echo -e "${YELLOW}2.${NC} $(L MENU_MANAGE)"
    echo -e "${YELLOW}3.${NC} $(L MENU_BACKUP)"
    echo -e "${YELLOW}4.${NC} $(L MENU_UPDATE)"
    echo -e "${YELLOW}5.${NC} $(L MENU_UNINSTALL)"
    echo -e "${YELLOW}9.${NC} Сменить язык / Change language"
    echo -e "${YELLOW}0.${NC} $(L MENU_EXIT)"
    echo ""
}

show_install_menu() {
    clear
    echo -e "${GREEN}$(L SELECT_PANEL)${NC}"
    echo ""
    echo -e "${YELLOW}1.${NC} $(L WIREGUARD)"
    echo -e "${YELLOW}2.${NC} $(L 3XUI)"
    echo -e "${YELLOW}3.${NC} $(L REMNAWAVE)"
    echo -e "${YELLOW}4.${NC} $(L HYSTERIA2)"
    echo -e "${YELLOW}5.${NC} $(L ALL)"
    echo -e "${YELLOW}0.${NC} Назад / Back"
    echo ""
}

main() {
    check_root
    detect_os
    check_memory

    mkdir -p "$PROJECT_DIR"
    load_language

    while true; do
        show_main_menu
        read -p "Выберите опцию / Select option: " choice

        case $choice in
            1)
                show_install_menu
                read -p "Выберите / Select: " install_choice
                case $install_choice in
                    1) install_packages; install_wireguard ;;
                    2) install_packages; install_3xui ;;
                    3) install_packages; install_remnawave ;;
                    4) install_packages; install_hysteria2 ;;
                    5)
                        install_packages
                        install_wireguard
                        install_3xui
                        install_hysteria2
                        ;;
                    0) continue ;;
                    *) warn "Неверный выбор / Invalid choice" ;;
                esac
                read -p "Нажмите Enter / Press Enter..."
                ;;
            9)
                if [ "$MENU_LANG" = "en" ]; then
                    save_language "ru"
                else
                    save_language "en"
                fi
                ;;
            0)
                log "Выход / Exit"
                exit 0
                ;;
            *)
                warn "Неверный выбор / Invalid choice"
                sleep 1
                ;;
        esac
    done
}

main
