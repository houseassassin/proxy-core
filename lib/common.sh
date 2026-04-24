#!/bin/bash

# Common functions library for Proxy-Core
# Version: 2.1.1
# Author: houseassassin

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Logging functions
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Validation functions
validate_port() {
    local port=$1
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        error "Неверный порт: $port (должен быть 1-65535)"
        return 1
    fi
    return 0
}

validate_name() {
    local name=$1
    if [ -z "$name" ]; then
        error "Имя не может быть пустым"
        return 1
    fi
    if ! [[ "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        error "Неверное имя: $name (только буквы, цифры, _ и -)"
        return 1
    fi
    return 0
}

check_port_available() {
    local port=$1
    if ss -ltun | awk '{print $4}' | grep -q ":$port\$"; then
        error "Порт $port уже используется"
        return 1
    fi
    return 0
}

validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 0
    else
        error "Неверный IP адрес: $ip"
        return 1
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
        if check_port_available "$PORT"; then
            echo "$PORT"
            return
        fi
    done
}

# System checks
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "Этот скрипт должен быть запущен с правами root"
        exit 1
    fi
}

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    else
        error "Не удалось определить операционную систему"
        exit 1
    fi
}

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

# Confirmation prompt
confirm() {
    local prompt="${1:-Продолжить?}"
    local default="${2:-n}"

    if [ "$default" = "y" ]; then
        read -p "$prompt (Y/n): " response
        response=${response:-y}
    else
        read -p "$prompt (y/N): " response
        response=${response:-n}
    fi

    [[ "$response" =~ ^[Yy]$ ]]
}

# Generate random password
generate_password() {
    local length=${1:-16}
    openssl rand -base64 $length | tr -d "=+/" | cut -c1-$length
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if service is running
service_running() {
    systemctl is-active --quiet "$1"
}

# Wait for service to start
wait_for_service() {
    local service=$1
    local timeout=${2:-30}
    local counter=0

    while [ $counter -lt $timeout ]; do
        if service_running "$service"; then
            return 0
        fi
        sleep 1
        ((counter++))
    done

    return 1
}

# Export all functions
export -f log warn error success
export -f validate_port validate_name check_port_available validate_ip
export -f get_server_ip get_random_port
export -f check_root detect_os spinner confirm
export -f generate_password command_exists service_running wait_for_service
