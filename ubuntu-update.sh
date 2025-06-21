#!/bin/bash

# Setup
mkdir -p "$HOME/hillbillyer"
LOGFILE="$HOME/hillbillyer/ubuntu-updates.log"
ERRFILE=$(mktemp)
UPGRADES_TMP=$(mktemp)
NTFY_TOPIC="https://ntfy.hillbillyer.dev/machine-updates"
HOSTNAME=$(hostname)

# Logging start
{
    echo "===== $(date '+%Y-%m-%d %H:%M:%S') ====="
    echo "Running apt update && full-upgrade on $HOSTNAME"
} >> "$LOGFILE"

# Refresh package list
apt update >> "$LOGFILE" 2>>"$ERRFILE"

# Capture list of upgradable packages BEFORE full-upgrade
UPGRADES=$(apt list --upgradable 2>/dev/null | awk -F/ 'NR>1 {print $1}' | paste -sd, -)
echo "Will upgrade: ${UPGRADES:-<none>}" >> "$LOGFILE"

# Run upgrades
{
    apt full-upgrade -y
    apt autoremove -y
    apt clean
} >> "$LOGFILE" 2>>"$ERRFILE"

# Compose NTFY message
if [ $? -eq 0 ]; then
    if [ -n "$UPGRADES" ]; then
        MESSAGE="✅ $HOSTNAME updated successfully. Updated: $UPGRADES"
    else
        MESSAGE="✅ $HOSTNAME updated successfully. No packages were updated."
    fi
    curl -s -X POST -H "Title: Server Update" -d "$MESSAGE" "$NTFY_TOPIC" >/dev/null
else
    ERROR_MSG=$(<"$ERRFILE")
    MESSAGE="❌ $HOSTNAME update failed: $ERROR_MSG"
    curl -s -X POST -H "Title: Server Update" -d "$MESSAGE" "$NTFY_TOPIC" >/dev/null
fi

# Append result to log
{
    echo "$MESSAGE"
    echo ""
} >> "$LOGFILE"

# Clean up
rm -f "$ERRFILE" "$UPGRADES_TMP"
