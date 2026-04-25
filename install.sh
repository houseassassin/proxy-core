#!/bin/bash

# Proxy-Core - Advanced VPN & Proxy Panel Auto-Installer
# Version: 2.1.1
# Author: houseassassin
# GitHub: https://github.com/houseassassin/proxy-core
#
# Supports: WireGuard, 3x-ui, Remnawave, Hysteria2, MTProxy
# Reverse Proxy: Nginx, Caddy
# Features: Selfsteal templates

set -euo pipefail

SCRIPT_VERSION="2.1.1"
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

# Create project directory first
mkdir -p "$PROJECT_DIR"

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
    [MTPROXY]="MTProxy (Telegram)"
    [SELECT_REVERSE_PROXY]="Select Reverse Proxy"
    [NGINX]="Nginx"
    [CADDY]="Caddy"
    [SELFSTEAL]="Install Selfsteal Template"
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
    [MTPROXY]="MTProxy (Telegram)"
    [SELECT_REVERSE_PROXY]="Выберите Reverse Proxy"
    [NGINX]="Nginx"
    [CADDY]="Caddy"
    [SELFSTEAL]="Установить Selfsteal шаблон"
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

# Docker management
install_docker() {
    if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
        log "Docker уже установлен"
        return 0
    fi

    log "Установка Docker..."
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sh /tmp/get-docker.sh
    rm /tmp/get-docker.sh

    systemctl enable docker
    systemctl start docker

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
                grep gawk python3-pip cron nginx
            ;;
        centos|rhel|fedora)
            yum update -y
            yum install -y curl wget git sudo firewalld certbot \
                ca-certificates jq openssl tar net-tools qrencode nginx
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

# WireGuard installation
install_wireguard() {
    log "Установка WireGuard..."

    case $OS in
        ubuntu|debian)
            apt-get install -y wireguard wireguard-tools qrencode
            ;;
        centos|rhel|fedora)
            yum install -y wireguard-tools qrencode
            ;;
    esac

    mkdir -p /etc/wireguard
    cd /etc/wireguard
    wg genkey | tee server_private.key | wg pubkey > server_public.key
    chmod 600 server_private.key

    SERVER_PRIVATE_KEY=$(cat server_private.key)
    SERVER_PUBLIC_KEY=$(cat server_public.key)
    SERVER_IP=$(get_server_ip)
    WG_PORT=$(get_random_port 51820 51900)

    cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = $SERVER_PRIVATE_KEY
Address = 10.0.0.1/24
ListenPort = $WG_PORT
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
EOF

    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p >/dev/null 2>&1

    systemctl enable wg-quick@wg0
    systemctl start wg-quick@wg0

    ufw allow $WG_PORT/udp 2>/dev/null || firewall-cmd --permanent --add-port=$WG_PORT/udp 2>/dev/null

    success "WireGuard установлен на порту $WG_PORT"

    read -p "Создать первого клиента? (Y/n): " create_client
    if [[ "$create_client" != "n" && "$create_client" != "N" ]]; then
        bash "$PROJECT_DIR/wg-manager.sh" 2>/dev/null || log "Запустите wg-manager.sh для создания клиентов"
    fi
}

# 3x-ui installation
install_3xui() {
    log "Установка 3x-ui..."
    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
    success "3x-ui установлен"
}

# Remnawave installation
install_remnawave() {
    log "Установка Remnawave..."

    install_docker

    cd /opt
    if [ -d "remnawave" ]; then
        warn "Remnawave уже установлен, обновляем..."
        cd remnawave
        docker compose down
        cd /opt
        rm -rf remnawave
    fi

    git clone https://github.com/remnawave/backend.git remnawave
    cd remnawave

    DB_PASSWORD=$(openssl rand -base64 32)
    ADMIN_PASSWORD=$(openssl rand -base64 16)

    cat > .env <<EOF
DATABASE_URL="postgresql://remnawave:${DB_PASSWORD}@postgres:5432/remnawave"
ADMIN_USERNAME=admin
ADMIN_PASSWORD=${ADMIN_PASSWORD}
JWT_SECRET=$(openssl rand -base64 32)
EOF

    docker compose up -d

    success "Remnawave установлен"
    echo ""
    log "Админ логин: admin"
    log "Админ пароль: $ADMIN_PASSWORD"
    warn "Сохраните эти данные!"
}

# Hysteria2 installation
install_hysteria2() {
    log "Установка Hysteria2..."

    HYSTERIA_VERSION=$(curl -s https://api.github.com/repos/apernet/hysteria/releases/latest | grep tag_name | cut -d '"' -f 4)
    wget -O /tmp/hysteria "https://github.com/apernet/hysteria/releases/download/${HYSTERIA_VERSION}/hysteria-linux-amd64"
    chmod +x /tmp/hysteria
    mv /tmp/hysteria /usr/local/bin/hysteria

    mkdir -p /etc/hysteria

    HYSTERIA_PASSWORD=$(openssl rand -base64 32)
    HYSTERIA_PORT=$(get_random_port 36712 36800)

    cat > /etc/hysteria/config.yaml <<EOF
listen: :$HYSTERIA_PORT

tls:
  cert: /etc/hysteria/cert.pem
  key: /etc/hysteria/key.pem

auth:
  type: password
  password: $HYSTERIA_PASSWORD

masquerade:
  type: proxy
  proxy:
    url: https://www.bing.com
    rewriteHost: true
EOF

    openssl req -x509 -nodes -newkey rsa:4096 -keyout /etc/hysteria/key.pem \
        -out /etc/hysteria/cert.pem -days 365 -subj "/CN=www.example.com" 2>/dev/null

    cat > /etc/systemd/system/hysteria-server.service <<EOF
[Unit]
Description=Hysteria Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/hysteria server -c /etc/hysteria/config.yaml
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable hysteria-server
    systemctl start hysteria-server

    ufw allow $HYSTERIA_PORT/udp 2>/dev/null || firewall-cmd --permanent --add-port=$HYSTERIA_PORT/udp 2>/dev/null

    success "Hysteria2 установлен"
    echo ""
    log "Порт: $HYSTERIA_PORT"
    log "Пароль: $HYSTERIA_PASSWORD"
    warn "Сохраните эти данные!"
}

# MTProxy installation
install_mtproxy() {
    log "Установка MTProxy для Telegram..."

    case $OS in
        ubuntu|debian)
            apt-get install -y git build-essential libssl-dev zlib1g-dev
            ;;
        centos|rhel|fedora)
            yum install -y git gcc make openssl-devel zlib-devel
            ;;
    esac

    cd /opt
    if [ -d "MTProxy" ]; then
        rm -rf MTProxy
    fi
    git clone https://github.com/TelegramMessenger/MTProxy.git
    cd MTProxy

    make

    curl -s https://core.telegram.org/getProxySecret -o proxy-secret
    curl -s https://core.telegram.org/getProxyConfig -o proxy-multi.conf

    SECRET=$(head -c 16 /dev/urandom | xxd -ps)

    read -p "Введите порт для MTProxy (по умолчанию 8443): " MTPROXY_PORT
    MTPROXY_PORT=${MTPROXY_PORT:-8443}

    cat > /etc/systemd/system/mtproxy.service <<EOF
[Unit]
Description=MTProxy Telegram Proxy
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/MTProxy
ExecStart=/opt/MTProxy/objs/bin/mtproto-proxy -u nobody -p $MTPROXY_PORT -H $MTPROXY_PORT -S $SECRET --aes-pwd proxy-secret proxy-multi.conf -M 1
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable mtproxy
    systemctl start mtproxy

    ufw allow $MTPROXY_PORT/tcp 2>/dev/null || firewall-cmd --permanent --add-port=$MTPROXY_PORT/tcp 2>/dev/null

    cat > /opt/MTProxy/.config <<EOF
MTPROXY_PORT=$MTPROXY_PORT
SECRET=$SECRET
EOF
    chmod 600 /opt/MTProxy/.config

    SERVER_IP=$(get_server_ip)

    success "MTProxy установлен!"
    echo ""
    log "Ссылка для подключения:"
    echo -e "${CYAN}tg://proxy?server=${SERVER_IP}&port=${MTPROXY_PORT}&secret=${SECRET}${NC}"
    echo ""
    log "Или используйте в Telegram:"
    echo -e "${YELLOW}Server: ${SERVER_IP}${NC}"
    echo -e "${YELLOW}Port: ${MTPROXY_PORT}${NC}"
    echo -e "${YELLOW}Secret: ${SECRET}${NC}"

    if command -v qrencode &> /dev/null; then
        echo ""
        log "QR-код для быстрого подключения:"
        qrencode -t ansiutf8 "tg://proxy?server=${SERVER_IP}&port=${MTPROXY_PORT}&secret=${SECRET}"
    fi
}

# Reverse Proxy selection
select_reverse_proxy() {
    echo ""
    echo -e "${GREEN}$(L SELECT_REVERSE_PROXY)${NC}"
    echo ""
    echo -e "${YELLOW}1.${NC} $(L NGINX)"
    echo -e "${YELLOW}2.${NC} $(L CADDY)"
    echo ""
    read -p "Выберите / Select [1-2]: " PROXY_CHOICE

    case $PROXY_CHOICE in
        1)
            REVERSE_PROXY="nginx"
            install_nginx
            ;;
        2)
            REVERSE_PROXY="caddy"
            install_caddy
            ;;
        *)
            warn "Неверный выбор, используется Nginx"
            REVERSE_PROXY="nginx"
            install_nginx
            ;;
    esac
}

# Nginx installation
install_nginx() {
    if command -v nginx >/dev/null 2>&1; then
        log "Nginx уже установлен"
        return 0
    fi

    log "Установка Nginx..."

    case $OS in
        ubuntu|debian)
            apt-get install -y nginx
            ;;
        centos|rhel|fedora)
            yum install -y nginx
            ;;
    esac

    systemctl enable nginx
    systemctl start nginx

    success "Nginx установлен"
}

# Caddy installation
install_caddy() {
    if command -v caddy >/dev/null 2>&1; then
        log "Caddy уже установлен"
        return 0
    fi

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

# Selfsteal template installation
install_selfsteal() {
    log "Установка Selfsteal шаблона..."

    # Определяем директорию
    if [ -d "/opt/remnawave" ]; then
        INSTALL_DIR="/opt/remnawave"
    elif [ -d "/opt/remnanode" ]; then
        INSTALL_DIR="/opt/remnanode"
    else
        error "Remnawave или Remnanode должны быть установлены для selfsteal"
        return 1
    fi

    # Устанавливаем REVERSE_PROXY если не задан
    if [ -z "${REVERSE_PROXY:-}" ]; then
        if command -v nginx >/dev/null 2>&1; then
            REVERSE_PROXY="nginx"
            log "Используется установленный Nginx"
        elif command -v caddy >/dev/null 2>&1; then
            REVERSE_PROXY="caddy"
            log "Используется установленный Caddy"
        else
            warn "Reverse proxy не найден, устанавливаем Nginx..."
            install_nginx
            REVERSE_PROXY="nginx"
        fi
    fi

    echo ""
    echo -e "${GREEN}Выберите тип selfsteal шаблона:${NC}"
    echo ""
    echo -e "${YELLOW}1.${NC} Случайный сайт"
    echo -e "${YELLOW}2.${NC} Пользовательский URL"
    echo -e "${YELLOW}3.${NC} Локальный HTML файл"
    echo ""
    read -p "Выберите [1-3]: " SELFSTEAL_TYPE

    case $SELFSTEAL_TYPE in
        1)
            # Список популярных сайтов
            SITES=(
                "https://www.wikipedia.org"
                "https://www.github.com"
                "https://www.stackoverflow.com"
                "https://www.reddit.com"
                "https://www.medium.com"
            )
            RANDOM_SITE=${SITES[$RANDOM % ${#SITES[@]}]}
            log "Используется случайный сайт: $RANDOM_SITE"

            # Скачиваем страницу
            curl -sL "$RANDOM_SITE" > "$INSTALL_DIR/selfsteal.html"
            ;;
        2)
            read -p "Введите URL сайта: " CUSTOM_URL
            log "Скачивание $CUSTOM_URL..."
            curl -sL "$CUSTOM_URL" > "$INSTALL_DIR/selfsteal.html"
            ;;
        3)
            read -p "Введите путь к HTML файлу: " HTML_PATH
            if [ -f "$HTML_PATH" ]; then
                cp "$HTML_PATH" "$INSTALL_DIR/selfsteal.html"
            else
                error "Файл не найден: $HTML_PATH"
            fi
            ;;
        *)
            warn "Неверный выбор"
            return 1
            ;;
    esac

    # Настройка Nginx для selfsteal
    if [ "$REVERSE_PROXY" = "nginx" ]; then
        cat > /etc/nginx/sites-available/selfsteal <<EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root $INSTALL_DIR;
    index selfsteal.html;

    location / {
        try_files \$uri \$uri/ /selfsteal.html;
    }
}
EOF
        ln -sf /etc/nginx/sites-available/selfsteal /etc/nginx/sites-enabled/
        nginx -t && systemctl reload nginx
    fi

    success "Selfsteal шаблон установлен"
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
    echo -e "${YELLOW}6.${NC} $(L SELFSTEAL)"
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
    echo -e "${YELLOW}5.${NC} $(L MTPROXY)"
    echo -e "${YELLOW}6.${NC} $(L ALL)"
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
                    1)
                        install_packages
                        install_wireguard
                        ;;
                    2)
                        install_packages
                        install_3xui
                        ;;
                    3)
                        install_packages
                        select_reverse_proxy
                        install_remnawave
                        ;;
                    4)
                        install_packages
                        install_hysteria2
                        ;;
                    5)
                        install_packages
                        install_mtproxy
                        ;;
                    6)
                        install_packages
                        select_reverse_proxy
                        install_wireguard
                        install_3xui
                        install_remnawave
                        install_hysteria2
                        install_mtproxy
                        ;;
                    0) continue ;;
                    *) warn "Неверный выбор / Invalid choice" ;;
                esac
                read -p "Нажмите Enter / Press Enter..."
                ;;
            6)
                # Проверка перед вызовом
                if [ ! -d "/opt/remnawave" ] && [ ! -d "/opt/remnanode" ]; then
                    error "Сначала установите Remnawave (опция 1 -> 3)"
                    read -p "Нажмите Enter / Press Enter..."
                else
                    install_selfsteal
                    read -p "Нажмите Enter / Press Enter..."
                fi
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
