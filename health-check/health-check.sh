#!/bin/bash

# ==============================
# Configuration
# ==============================

NTFY_URL="https://ntfy.hillbillyer.dev/health-alert"
DISK_THRESHOLD=95
RAM_THRESHOLD=90
STATE_FILE="$HOME/hillbillyer/health-check/proxmox_health_state"

HOSTNAME=$(hostname)

# ==============================
# Disk Check (Ignore tmpfs, etc.)
# ==============================

disk_alert=0
disk_message=""

while read -r source fstype size used avail pcent mount; do
    usage_percent=$(echo "$pcent" | sed 's/%//')

    # Skip unwanted filesystem types
    if [[ "$fstype" =~ ^(tmpfs|devtmpfs|overlay|squashfs)$ ]]; then
        continue
    fi

    if [ "$usage_percent" -ge "$DISK_THRESHOLD" ]; then
        disk_alert=1
        disk_message+="Disk alert on $HOSTNAME: $mount ($fstype) is ${pcent} full\n"
    fi
done < <(df -hT | tail -n +2)

# ==============================
# RAM Check
# ==============================

ram_used_percent=$(free | awk '/Mem:/ {printf("%.0f"), $3/$2 * 100}')

ram_alert=0
ram_message=""

if [ "$ram_used_percent" -ge "$RAM_THRESHOLD" ]; then
    ram_alert=1
    ram_message="RAM alert on $HOSTNAME: Memory usage is ${ram_used_percent}%\n"
fi

# ==============================
# State Handling (Prevent Spam)
# ==============================

previous_state=""
[ -f "$STATE_FILE" ] && previous_state=$(cat "$STATE_FILE")

current_state="disk:$disk_alert ram:$ram_alert"

if [ "$current_state" != "$previous_state" ]; then
    if [ "$disk_alert" -eq 1 ] || [ "$ram_alert" -eq 1 ]; then
        message="${disk_message}${ram_message}"
        echo -e "$message" | curl -s \
            -H "Title: Usage Alert on $HOSTNAME" \
            -H "Priority: urgent" \
            -d @- "$NTFY_URL"
    fi
    echo "$current_state" > "$STATE_FILE"
fi
