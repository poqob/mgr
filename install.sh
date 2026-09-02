#!/usr/bin/env bash
# ==============================================================================
# mgr Installer
# GitHub: https://github.com/poqob/mgr
# ==============================================================================

set -eo pipefail

INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/mgr"
REPO_URL="https://raw.githubusercontent.com/poqob/mgr/main"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${CYAN}Installing mgr (Systemd Service Manager & Watchdog)...${NC}"

# Check for root / sudo
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root (or with sudo)."
    exit 1
fi

# Download or copy mgr script
if [[ -f "./mgr" ]]; then
    cp ./mgr "$INSTALL_DIR/mgr"
else
    echo "Downloading mgr from GitHub..."
    curl -fsSL "$REPO_URL/mgr" -o "$INSTALL_DIR/mgr"
fi

chmod +x "$INSTALL_DIR/mgr"

# Create /etc/mgr directory and default config if not exists
mkdir -p "$CONFIG_DIR"
if [[ ! -f "$CONFIG_DIR/mgr.conf" && ! -f "/etc/mgr.conf" ]]; then
    if [[ -f "./mgr.conf.example" ]]; then
        cp ./mgr.conf.example "$CONFIG_DIR/mgr.conf"
    else
        curl -fsSL "$REPO_URL/mgr.conf.example" -o "$CONFIG_DIR/mgr.conf" 2>/dev/null || true
    fi
    echo -e "Created starter configuration at ${BOLD}$CONFIG_DIR/mgr.conf${NC}"
fi

# Install watchdog cron by default
"$INSTALL_DIR/mgr" install-watchdog >/dev/null 2>&1 || true

echo -e "${GREEN}✓ Successfully installed mgr to $INSTALL_DIR/mgr${NC}"
echo ""
echo "Usage:"
echo "  mgr                   # Status and auto-heal overview"
echo "  mgr up [services]     # Start or restart services"
echo "  mgr down [services]   # Stop services"
echo "  mgr logs <service>    # Tail live logs"
echo ""
echo "Configuration:"
echo "  Edit $CONFIG_DIR/mgr.conf (or place a mgr.conf in your working directory)."
