#!/bin/bash
mkdir -p "$HOME/hillbillyer"
touch "$HOME/hillbillyer/ubuntu-updates.log"
LOGFILE="$HOME/hillbillyer/ubuntu-updates.log"
{
    echo "===== $(date '+%Y-%m-%d %H:%M:%S') ====="
    echo "Running apt update && full-upgrade"
    apt update
    apt list --upgradable
    apt full-upgrade -y
    apt autoremove -y
    apt clean
    echo "===== Update complete ====="
    echo ""
} >> "$LOGFILE" 2>&1
