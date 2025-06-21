#!/bin/bash

# Define variables
mkdir -p "$HOME/hillbillyer"
LOGFILE="$HOME/hillbillyer/ubuntu-updates.log"
ERRFILE=$(mktemp)
UPGRADES_TMP=$(mktemp)
NTFY_TOPIC="https://ntfy.hillbillyer.dev/machine-updates"
HOSTNAME=$(hostname)

{
    echo "===== $(date '+%Y-%m-%d %H:%M:%S') ====="
    echo "Running apt update && full-upgrade on $HOSTNAME"
} >> "$LOGFILE"

# Fetch upgradeable package list before upgrading
apt update >> "$LOGFILE" 2>>"$ERRFILE"
apt list --upgradable 2>/dev/null | awk -F/ 'NR>1 {print $1}' > "$UPGRADES_TMP"

# Save list for logging
cat "$UPGRADES_TMP" >> "$LOGFILE"

# Run upgrade steps
{
    apt full-upgrade -y
    apt autoremove -y
    apt clean
} >> "$LOGFILE" 2>>"$ERRFILE"

# Compose message
if [ $? -eq 0 ]; then
    UPDATED=$(paste -sd, "$UPGRADES_TMP")
    if [ -n "$UPDATED" ]; then
        MESSAGE="✅ $HOSTNAME updated successfully. Updated: $UPDATED"
    else
        MESSAGE="✅ $HOSTNAME updated successfully. No packages were updated."
    fi
    curl -s -X POST -H "Title: Server Update" -d "$MESSAGE" "$NTFY_TOPIC" >/dev/null
else
    ERROR_MSG=$(<"$ERRFILE")
    MESSAGE="❌ $HOSTNAME update failed: $ERROR_MSG"
    curl -s -X POST -H "Title: Server Update" -d "$MESSAGE" "$NTFY_TOPIC" >/dev/null
fi

# Final log write
{
    echo "$MESSAGE"
    echo ""
} >> "$LOGFILE"

# Clean up
rm -f "$ERRFILE" "$UPGRADES_TMP"
