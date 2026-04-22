#!/bin/bash

# MTProxy Manager
# Author: houseassassin

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

MTPROXY_DIR="/opt/MTProxy"

check_installed() {
    if [ ! -d "$MTPROXY_DIR" ]; then
        error "MTProxy не установлен"
        exit 1
    fi
}

get_connection_link() {
    if [ ! -f "$MTPROXY_DIR/.config" ]; then
        error "Конфигурация не найдена"
        return 1
    fi

    source "$MTPROXY_DIR/.config"
    SERVER_IP=$(curl -s ifconfig.me)

    echo ""
    log "Ссылка для подключения:"
    echo -e "${CYAN}tg://proxy?server=${SERVER_IP}&port=${MTPROXY_PORT}&secret=${SECRET}${NC}"
    echo ""
    log "Или используйте в Telegram:"
    echo -e "${YELLOW}Server: ${SERVER_IP}${NC}"
    echo -e "${YELLOW}Port: ${MTPROXY_PORT}${NC}"
    echo -e "${YELLOW}Secret: ${SECRET}${NC}"
    echo ""

    # QR код
    if command -v qrencode &> /dev/null; then
        log "QR-код для быстрого подключения:"
        qrencode -t ansiutf8 "tg://proxy?server=${SERVER_IP}&port=${MTPROXY_PORT}&secret=${SECRET}"
    fi
}

regenerate_secret() {
    check_installed

    warn "Это изменит секрет и все текущие подключения будут разорваны!"
    read -p "Продолжить? (y/N): " confirm

    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        log "Отменено"
        return 0
    fi

    NEW_SECRET=$(head -c 16 /dev/urandom | xxd -ps)

    # Обновляем конфигурацию
    sed -i "s/SECRET=.*/SECRET=$NEW_SECRET/" "$MTPROXY_DIR/.config"

    # Перезапускаем сервис
    systemctl restart mtproxy

    success "Новый секрет сгенерирован: $NEW_SECRET"
    get_connection_link
}

change_port() {
    check_installed

    read -p "Введите новый порт: " NEW_PORT

    if [ -z "$NEW_PORT" ]; then
        error "Порт не может быть пустым"
        return 1
    fi

    # Проверяем, что порт свободен
    if ss -ltun | grep -q ":$NEW_PORT "; then
        error "Порт $NEW_PORT уже используется"
        return 1
    fi

    # Обновляем конфигурацию
    sed -i "s/MTPROXY_PORT=.*/MTPROXY_PORT=$NEW_PORT/" "$MTPROXY_DIR/.config"

    # Обновляем systemd сервис
    source "$MTPROXY_DIR/.config"

    cat > /etc/systemd/system/mtproxy.service <<EOF
[Unit]
Description=MTProxy Telegram Proxy
After=network.target

[Service]
Type=simple
WorkingDirectory=$MTPROXY_DIR
ExecStart=$MTPROXY_DIR/objs/bin/mtproto-proxy -u nobody -p $NEW_PORT -H $NEW_PORT -S $SECRET --aes-pwd proxy-secret proxy-multi.conf -M 1
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl restart mtproxy

    # Обновляем firewall
    ufw delete allow $MTPROXY_PORT/tcp 2>/dev/null
    ufw allow $NEW_PORT/tcp 2>/dev/null

    success "Порт изменен на $NEW_PORT"
    get_connection_link
}

update_config() {
    check_installed

    log "Обновление конфигурации Telegram..."

    cd "$MTPROXY_DIR"
    curl -s https://core.telegram.org/getProxySecret -o proxy-secret
    curl -s https://core.telegram.org/getProxyConfig -o proxy-multi.conf

    systemctl restart mtproxy

    success "Конфигурация обновлена"
}

show_stats() {
    check_installed

    echo ""
    log "Статистика MTProxy:"
    echo ""

    # Статус сервиса
    if systemctl is-active --quiet mtproxy; then
        echo -e "${GREEN}Статус: Работает${NC}"
    else
        echo -e "${RED}Статус: Остановлен${NC}"
    fi

    # Использование ресурсов
    echo ""
    log "Использование ресурсов:"
    ps aux | grep mtproto-proxy | grep -v grep | awk '{printf "CPU: %s%% | RAM: %s MB\n", $3, $6/1024}'

    # Количество подключений
    echo ""
    log "Активные подключения:"
    ss -tn | grep -c ":$(source $MTPROXY_DIR/.config && echo $MTPROXY_PORT) " || echo "0"

    echo ""
}

show_logs() {
    check_installed

    echo ""
    log "Последние 50 строк логов:"
    echo ""
    journalctl -u mtproxy -n 50 --no-pager
    echo ""
    read -p "Нажмите Enter для продолжения..."
}

uninstall_mtproxy() {
    check_installed

    warn "Это полностью удалит MTProxy!"
    read -p "Продолжить? (y/N): " confirm

    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        log "Отменено"
        return 0
    fi

    # Остановка и удаление сервиса
    systemctl stop mtproxy
    systemctl disable mtproxy
    rm -f /etc/systemd/system/mtproxy.service
    systemctl daemon-reload

    # Удаление файлов
    rm -rf "$MTPROXY_DIR"

    # Удаление правила firewall
    source "$MTPROXY_DIR/.config" 2>/dev/null
    ufw delete allow $MTPROXY_PORT/tcp 2>/dev/null

    success "MTProxy удален"
    exit 0
}

main_menu() {
    while true; do
        clear
        echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║   MTProxy Management                  ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}1.${NC} Показать ссылку подключения"
        echo -e "${YELLOW}2.${NC} Сгенерировать новый секрет"
        echo -e "${YELLOW}3.${NC} Изменить порт"
        echo -e "${YELLOW}4.${NC} Обновить конфигурацию Telegram"
        echo -e "${YELLOW}5.${NC} Показать статистику"
        echo -e "${YELLOW}6.${NC} Показать логи"
        echo -e "${YELLOW}7.${NC} Перезапустить сервис"
        echo -e "${YELLOW}8.${NC} Удалить MTProxy"
        echo -e "${YELLOW}0.${NC} Выход"
        echo ""
        read -p "Выберите опцию: " choice

        case $choice in
            1)
                get_connection_link
                read -p "Нажмите Enter..."
                ;;
            2)
                regenerate_secret
                read -p "Нажмите Enter..."
                ;;
            3)
                change_port
                read -p "Нажмите Enter..."
                ;;
            4)
                update_config
                read -p "Нажмите Enter..."
                ;;
            5)
                show_stats
                read -p "Нажмите Enter..."
                ;;
            6)
                show_logs
                ;;
            7)
                systemctl restart mtproxy
                success "MTProxy перезапущен"
                sleep 2
                ;;
            8)
                uninstall_mtproxy
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
