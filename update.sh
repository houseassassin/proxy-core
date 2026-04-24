#!/bin/bash

# Скрипт обновления панелей
# Version: 2.0.0
# Author: houseassassin
# GitHub: https://github.com/houseassassin/proxy-core

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

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

update_3xui() {
    print_msg "Обновление 3x-ui..."
    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
    print_msg "3x-ui обновлен"
}

update_remnawave() {
    print_msg "Обновление Remnawave..."

    if [ ! -d "/opt/remnawave" ]; then
        print_error "Remnawave не установлен"
        return
    fi

    cd /opt/remnawave
    docker compose pull
    docker compose up -d
    docker image prune -f

    print_msg "Remnawave обновлен"
}

backup_configs() {
    print_msg "Создание резервной копии конфигураций..."

    BACKUP_DIR="/root/vpn-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    [ -d "/etc/wireguard" ] && cp -r /etc/wireguard "$BACKUP_DIR/"
    [ -d "/opt/remnawave" ] && cp -r /opt/remnawave/config "$BACKUP_DIR/remnawave-config"
    [ -d "/usr/local/x-ui" ] && cp -r /usr/local/x-ui "$BACKUP_DIR/"

    print_msg "Резервная копия создана: $BACKUP_DIR"
}

show_menu() {
    clear
    echo "╔════════════════════════════════════════╗"
    echo "║   VPN Panel Updater                   ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "1) Обновить 3x-ui"
    echo "2) Обновить Remnawave"
    echo "3) Обновить все"
    echo "4) Создать резервную копию"
    echo "5) Выход"
    echo ""
    read -p "Ваш выбор [1-5]: " choice
}

main() {
    check_root
    show_menu

    case $choice in
        1)
            update_3xui
            ;;
        2)
            update_remnawave
            ;;
        3)
            update_3xui
            update_remnawave
            ;;
        4)
            backup_configs
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
}

main
