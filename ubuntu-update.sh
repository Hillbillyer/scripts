#!/bin/bash

# Set up paths and log
mkdir -p "$HOME/hillbillyer"
LOGFILE="$HOME/hillbillyer/ubuntu-updates.log"
NTFY_TOPIC="https://ntfy.hillbillyer.dev/ubuntu-update"

# Create a temp file to capture errors
ERRFILE=$(mktemp)

{
    echo "===== $(date '+%Y-%m-%d %H:%M:%S') ====="
    echo "Running apt update && full-upgrade"
} >> "$LOGFILE"

# Run updates and capture errors
{
    apt update
    apt list --upgradable
    apt full-upgrade -y
    apt autoremove -y
    apt clean
} >> "$LOGFILE" 2>>"$ERRFILE"

# Check exit status of the last command group
if [ $? -eq 0 ]; then
    MESSAGE="✅ Ubuntu update successful"
    curl -s -X POST -H "Title: Ubuntu Update" -d "$MESSAGE" "$NTFY_TOPIC" >/dev/null
else
    ERROR_MSG=$(<"$ERRFILE")
    MESSAGE="❌ Ubuntu update failed: $ERROR_MSG"
    curl -s -X POST -H "Title: Ubuntu Update Failed" -d "$MESSAGE" "$NTFY_TOPIC" >/dev/null
fi

# Append status to log
{
    echo "$MESSAGE"
    echo ""
} >> "$LOGFILE"

# Clean up
rm -f "$ERRFILE"
