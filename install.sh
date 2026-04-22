#!/bin/bash

# VPN Panel Auto-Installer
# Supports: WireGuard, 3x-ui, Remnawave

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_msg() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Этот скрипт должен быть запущен с правами root"
        exit 1
    fi
}

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    else
        print_error "Не удалось определить операционную систему"
        exit 1
    fi

    print_msg "Обнаружена ОС: $OS $VER"
}

update_system() {
    print_msg "Обновление системы..."

    case $OS in
        ubuntu|debian)
            apt-get update -y
            apt-get upgrade -y
            apt-get install -y curl wget git sudo ufw
            ;;
        centos|rhel|fedora)
            yum update -y
            yum install -y curl wget git sudo firewalld
            ;;
        *)
            print_error "Неподдерживаемая ОС: $OS"
            exit 1
            ;;
    esac
}

install_docker() {
    if command -v docker &> /dev/null; then
        print_msg "Docker уже установлен"
        return
    fi

    print_msg "Установка Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl enable docker
    systemctl start docker
    rm get-docker.sh

    if ! command -v docker-compose &> /dev/null; then
        print_msg "Установка Docker Compose..."
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi
}

install_wireguard() {
    print_msg "Установка WireGuard..."

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
    SERVER_IP=$(curl -s ifconfig.me)

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

    print_msg "WireGuard установлен на порту $WG_PORT"
    print_msg "Конфигурация: /etc/wireguard/wg0.conf"
}

install_3xui() {
    print_msg "Установка 3x-ui..."

    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

    print_msg "3x-ui установлен"
    print_msg "Панель доступна по адресу: http://$(curl -s ifconfig.me):2053"
    print_msg "Логин по умолчанию: admin"
    print_msg "Пароль по умолчанию: admin"
}

install_remnawave() {
    print_msg "Установка Remnawave..."

    install_docker

    mkdir -p /opt/remnawave
    cd /opt/remnawave

    read -p "Введите домен для Remnawave (например, vpn.example.com): " DOMAIN
    read -p "Введите email для SSL сертификата: " EMAIL
    read -p "Введите порт панели (по умолчанию 8080): " PANEL_PORT
    PANEL_PORT=${PANEL_PORT:-8080}

    cat > docker-compose.yml <<EOF
version: '3.8'

services:
  remnawave:
    image: remnawave/remnawave:latest
    container_name: remnawave
    restart: unless-stopped
    ports:
      - "$PANEL_PORT:8080"
    volumes:
      - ./data:/app/data
      - ./config:/app/config
    environment:
      - DOMAIN=$DOMAIN
      - PANEL_PORT=$PANEL_PORT
    networks:
      - remnawave-network

  nginx:
    image: nginx:alpine
    container_name: remnawave-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - remnawave
    networks:
      - remnawave-network

networks:
  remnawave-network:
    driver: bridge
EOF

    cat > nginx.conf <<EOF
events {
    worker_connections 1024;
}

http {
    upstream remnawave {
        server remnawave:8080;
    }

    server {
        listen 80;
        server_name $DOMAIN;
        return 301 https://\$server_name\$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name $DOMAIN;

        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;

        location / {
            proxy_pass http://remnawave;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOF

    mkdir -p ssl

    if [ ! -z "$DOMAIN" ] && [ ! -z "$EMAIL" ]; then
        print_msg "Получение SSL сертификата..."
        docker run --rm -v "$(pwd)/ssl:/etc/letsencrypt" certbot/certbot certonly --standalone -d $DOMAIN --email $EMAIL --agree-tos --non-interactive || print_warning "Не удалось получить SSL сертификат автоматически"
    fi

    docker-compose up -d

    print_msg "Remnawave установлен"
    print_msg "Панель доступна по адресу: https://$DOMAIN"
}

show_menu() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   VPN Panel Auto-Installer v1.0       ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "Выберите панель для установки:"
    echo ""
    echo "1) WireGuard"
    echo "2) 3x-ui"
    echo "3) Remnawave"
    echo "4) Установить все"
    echo "5) Выход"
    echo ""
    read -p "Ваш выбор [1-5]: " choice
}

main() {
    check_root
    detect_os

    show_menu

    case $choice in
        1)
            update_system
            install_wireguard
            ;;
        2)
            update_system
            install_3xui
            ;;
        3)
            update_system
            install_remnawave
            ;;
        4)
            update_system
            install_wireguard
            install_3xui
            install_remnawave
            ;;
        5)
            print_msg "Выход..."
            exit 0
            ;;
        *)
            print_error "Неверный выбор"
            exit 1
            ;;
    esac

    print_msg "Установка завершена!"
}

main
