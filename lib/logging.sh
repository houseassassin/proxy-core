#!/bin/bash

# Logging library for Proxy-Core
# Version: 2.1.1
# Author: houseassassin

LOGDIR="/var/log/proxy-core"
mkdir -p "$LOGDIR" 2>/dev/null

# Source common for colors
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh" 2>/dev/null || true

log_to_file() {
    local level=$1
    local message=$2
    local script=$(basename "${BASH_SOURCE[2]}" 2>/dev/null || echo "unknown")
    local logfile="${LOGDIR}/$(date +%Y-%m-%d).log"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$script] [$level] $message" >> "$logfile" 2>/dev/null
}

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
    log_to_file "INFO" "$1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    log_to_file "ERROR" "$1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    log_to_file "WARN" "$1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    log_to_file "SUCCESS" "$1"
}

debug() {
    if [ "${DEBUG:-0}" = "1" ]; then
        echo -e "${GRAY}[DEBUG]${NC} $1"
        log_to_file "DEBUG" "$1"
    fi
}

# Rotate logs older than 30 days
rotate_logs() {
    find "$LOGDIR" -name "*.log" -mtime +30 -delete 2>/dev/null
}

# Export functions
export -f log_to_file log error warn success debug rotate_logs
