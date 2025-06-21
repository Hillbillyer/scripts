#!/bin/bash

# Define variables
mkdir -p "$HOME/hillbillyer"
LOGFILE="$HOME/hillbillyer/ubuntu-updates.log"
ERRFILE=$(mktemp)
NTFY_TOPIC="https://ntfy.hillbillyer.dev/machine-updates"
HOSTNAME=$(hostname)

{
    echo "===== $(date '+%Y-%m-%d %H:%M:%S') ====="
    echo "Running apt update && full-upgrade on $HOSTNAME"
} >> "$LOGFILE"

# Run update steps
{
    apt update
    apt list --upgradable
    apt full-upgrade -y
    apt autoremove -y
    apt clean
} >> "$LOGFILE" 2>>"$ERRFILE"

# Check if any part failed
if [ $? -eq 0 ]; then
    MESSAGE="✅ $HOSTNAME updated successfully."
    curl -s -X POST -H "Title: Server Update" -d "$MESSAGE" "$NTFY_TOPIC" >/dev/null
else
    ERROR_MSG=$(<"$ERRFILE")
    MESSAGE="❌ $HOSTNAME update failed: $ERROR_MSG"
    curl -s -X POST -H "Title: Server Update" -d "$MESSAGE" "$NTFY_TOPIC" >/dev/null
fi

# Append outcome to log
{
    echo "$MESSAGE"
    echo ""
} >> "$LOGFILE"

rm -f "$ERRFILE"
