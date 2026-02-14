#!/bin/bash

# Setup
mkdir -p "$HOME/hillbillyer"
LOGFILE="$HOME/hillbillyer/ubuntu-updates.log"
ERRFILE=$(mktemp)
UPGRADES_TMP=$(mktemp)
NTFY_TOPIC="https://ntfy.hillbillyer.dev/machine-updates"
HOSTNAME=$(hostname)
touch $HOME/hillbillyer/custom-commands.sh
CUSTOM_SCRIPT="$HOME/hillbillyer/custom-commands.sh"
UPDATE_PATH="$HOME/update.sh"
HEALTH_PATH="$HOME/hillbillyer/health-check/health-check.sh"

# Logging start
{
    echo "===== $(date '+%Y-%m-%d %H:%M:%S') ====="
    echo "Running apt update && full-upgrade on $HOSTNAME"
} >> "$LOGFILE"

# Refresh package list
apt update >> "$LOGFILE" 2>>"$ERRFILE"

# ==============================
# Update health-check folder from GitHub
# ==============================

apt install unzip -y
REPO_ZIP="https://github.com/hillbillyer/scripts/archive/refs/heads/main.zip"
TARGET_DIR="$HOME/hillbillyer"
FOLDER_NAME="health-check"
TMP_DIR=$(mktemp -d)

# Download the repo ZIP into a temporary folder
curl -L -o "$TMP_DIR/repo.zip" "$REPO_ZIP"

# Extract only the health-check folder from the ZIP
unzip -q "$TMP_DIR/repo.zip" "scripts-main/$FOLDER_NAME/*" -d "$TMP_DIR"

# Remove existing health-check folder on the server
rm -rf "$TARGET_DIR/$FOLDER_NAME"

# Move the new health-check folder into place
mv "$TMP_DIR/scripts-main/$FOLDER_NAME" "$TARGET_DIR/"

# Clean up temp folder
rm -rf "$TMP_DIR"

echo "Updated $TARGET_DIR/$FOLDER_NAME from GitHub."

# Capture list of upgradable packages BEFORE full-upgrade
UPGRADES=$(apt list --upgradable 2>/dev/null | awk -F/ 'NR>1 {print $1}' | paste -sd, -)
echo "Will upgrade: ${UPGRADES:-<none>}" >> "$LOGFILE"

# Run upgrades
{
    apt full-upgrade -y
    apt autoremove -y
    apt clean
} >> "$LOGFILE" 2>>"$ERRFILE"

APT_SUCCESS=$?

# Custom Commands Section
CUSTOM_SUCCESS=0
CUSTOM_OUTPUT=""

if [ -f "$CUSTOM_SCRIPT" ]; then
    echo "Running custom update script: $CUSTOM_SCRIPT" >> "$LOGFILE"
    CUSTOM_OUTPUT=$(bash "$CUSTOM_SCRIPT" 2>&1)
    CUSTOM_SUCCESS=$?
    {
        echo "Custom script output:"
        echo "$CUSTOM_OUTPUT"
    } >> "$LOGFILE"
fi

# Compose NTFY message
if [ $APT_SUCCESS -eq 0 ] && [ $CUSTOM_SUCCESS -eq 0 ]; then
    if [ -n "$UPGRADES" ]; then
        MESSAGE="✅ $HOSTNAME updated successfully. Updated: $UPGRADES"
    else
        MESSAGE="✅ $HOSTNAME updated successfully. No packages were updated."
    fi
    if [ -f "$CUSTOM_SCRIPT" ]; then
        MESSAGE="$MESSAGE (Custom script ran successfully.)"
    fi
elif [ $APT_SUCCESS -ne 0 ]; then
    ERROR_MSG=$(<"$ERRFILE")
    MESSAGE="❌ $HOSTNAME apt update/upgrade failed: $ERROR_MSG"
elif [ $CUSTOM_SUCCESS -ne 0 ]; then
    MESSAGE="❌ $HOSTNAME custom update script failed."
fi

# Send notification
curl -s -X POST -H "Title: Server Update" -d "$MESSAGE" "$NTFY_TOPIC" >/dev/null

# Run Health Check
bash $HOME/hillbillyer/health-check/health-check.sh

# Update Cronjobs

UPDATE_JOB="0 3 * * * /usr/bin/bash $UPDATE_PATH # HILLBILLYER_UPDATE"
HEALTH_JOB="*/5 * * * * /usr/bin/bash $HEALTH_PATH # HILLBILLYER_HEALTH"

TMP_FILE=$(mktemp)

# Get current crontab (ignore error if none exists)
crontab -l 2>/dev/null | \
grep -v -F "update.sh" | \
grep -v -F "health-check.sh" > "$TMP_FILE"

# Add fresh entries
echo "$UPDATE_JOB" >> "$TMP_FILE"
echo "$HEALTH_JOB" >> "$TMP_FILE"

# Install new crontab
crontab "$TMP_FILE"

rm "$TMP_FILE"

echo "Cron jobs replaced successfully."


# Append result to log
{
    echo "$MESSAGE"
    echo ""
} >> "$LOGFILE"

# Clean up
rm -f "$ERRFILE" "$UPGRADES_TMP"
