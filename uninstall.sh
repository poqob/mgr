#!/usr/bin/env bash
# ==============================================================================
# mgr Uninstaller
# ==============================================================================

set -eo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root (or with sudo)."
    exit 1
fi

rm -f /usr/local/bin/mgr
rm -f /etc/cron.d/mgr-watchdog

echo "mgr binary and cron watchdog removed successfully."
echo "Note: Configuration files at /etc/mgr were kept. Run 'rm -rf /etc/mgr' if you wish to remove them."
