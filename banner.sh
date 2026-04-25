#!/bin/bash

# Proxy-Core Beautiful Banner
# Version: 2.1.1
# Author: houseassassin

# Colors
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

# Gradient effect
show_gradient_banner() {
    clear
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${MAGENTA}  ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗      ██████╗ ██████╗  ${CYAN}║${NC}"
    echo -e "${CYAN}║${MAGENTA}  ██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝     ██╔════╝██╔═══██╗ ${CYAN}║${NC}"
    echo -e "${CYAN}║${BLUE}  ██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝█████╗██║     ██║   ██║ ${CYAN}║${NC}"
    echo -e "${CYAN}║${BLUE}  ██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝ ╚════╝██║     ██║   ██║ ${CYAN}║${NC}"
    echo -e "${CYAN}║${CYAN}  ██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║        ╚██████╗╚██████╔╝ ${CYAN}║${NC}"
    echo -e "${CYAN}║${CYAN}  ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝         ╚═════╝ ╚═════╝  ${CYAN}║${NC}"
    echo -e "${CYAN}║                                                                       ║${NC}"
    echo -e "${CYAN}║${WHITE}           🚀 Advanced VPN & Proxy Panel Auto-Installer 🚀          ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${GREEN}┌─────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "  ${GREEN}│${NC} ${YELLOW}Version:${NC} ${WHITE}2.1.1${NC}                                                  ${GREEN}│${NC}"
    echo -e "  ${GREEN}│${NC} ${YELLOW}Author:${NC}  ${WHITE}houseassassin${NC}                                         ${GREEN}│${NC}"
    echo -e "  ${GREEN}│${NC} ${YELLOW}GitHub:${NC}  ${BLUE}https://github.com/houseassassin/proxy-core${NC}      ${GREEN}│${NC}"
    echo -e "  ${GREEN}└─────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# Animated loading
show_loading() {
    local text="$1"
    local duration=${2:-2}
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local end=$((SECONDS + duration))

    while [ $SECONDS -lt $end ]; do
        for frame in "${frames[@]}"; do
            echo -ne "\r  ${CYAN}${frame}${NC} ${text}"
            sleep 0.1
        done
    done
    echo -ne "\r  ${GREEN}✓${NC} ${text}\n"
}

# Progress bar
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))

    echo -ne "\r  ${CYAN}["
    printf "%${completed}s" | tr ' ' '█'
    printf "%${remaining}s" | tr ' ' '░'
    echo -ne "]${NC} ${WHITE}${percentage}%${NC}"

    if [ $current -eq $total ]; then
        echo ""
    fi
}

# Success box
show_success() {
    local message="$1"
    echo ""
    echo -e "  ${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${GREEN}║${NC}  ${WHITE}✓${NC} ${message}${GREEN}"
    echo -e "  ${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Error box
show_error() {
    local message="$1"
    echo ""
    echo -e "  ${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${RED}║${NC}  ${WHITE}✗${NC} ${message}${RED}"
    echo -e "  ${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Info box
show_info() {
    local message="$1"
    echo ""
    echo -e "  ${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${BLUE}║${NC}  ${WHITE}ℹ${NC} ${message}${BLUE}"
    echo -e "  ${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Warning box
show_warning() {
    local message="$1"
    echo ""
    echo -e "  ${YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${YELLOW}║${NC}  ${WHITE}⚠${NC} ${message}${YELLOW}"
    echo -e "  ${YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Menu header
show_menu_header() {
    local title="$1"
    echo ""
    echo -e "  ${MAGENTA}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${MAGENTA}║${NC}  ${WHITE}${title}${MAGENTA}"
    echo -e "  ${MAGENTA}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Menu item
show_menu_item() {
    local number="$1"
    local icon="$2"
    local text="$3"
    local description="$4"

    echo -e "  ${CYAN}${number}.${NC} ${icon} ${WHITE}${text}${NC}"
    if [ -n "$description" ]; then
        echo -e "     ${GRAY}${description}${NC}"
    fi
}

# Separator
show_separator() {
    echo -e "  ${GRAY}─────────────────────────────────────────────────────────────────${NC}"
}

# Export functions
export -f show_gradient_banner show_loading show_progress
export -f show_success show_error show_info show_warning
export -f show_menu_header show_menu_item show_separator

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    show_gradient_banner
fi
