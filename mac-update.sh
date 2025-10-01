#!/bin/zsh
# Interactive arrow-key menu for choosing a macOS full installer version.
# Works on Apple Silicon & Intel. No external deps (stock macOS tools only).
# - Lists only versions >= your current macOS.
# - Shows details (Title/Build/Size) in footer.
# - On major upgrades, robustly fetches the installer (tries version & build)
#   using ONLY valid "softwareupdate --fetch-full-installer" forms,
#   then runs startosinstall.

set -euo pipefail
export LC_ALL=C

# --- normalize versions into X.Y.Z ---
normalize_ver() {
  local v="${1//[^0-9.]/}"
  local -a p
  p=(${(s/./)v})
  printf "%d.%d.%d" "${p[1]:-0}" "${p[2]:-0}" "${p[3]:-0}"
}

# --- compare versions: prints 1 if v1>v2, 0 if equal, -1 if v1<v2 ---
version_cmp() {
  local v1="$(normalize_ver "$1")"
  local v2="$(normalize_ver "$2")"
  local -a A B
  A=(${(s/./)v1}); B=(${(s/./)v2})
  for i in 1 2 3; do
    (( ${A[i]} > ${B[i]} )) && { echo 1; return; }
    (( ${A[i]} < ${B[i]} )) && { echo -1; return; }
  done
  echo 0
}
version_ge() { [[ "$(version_cmp "$1" "$2")" != "-1" ]]; }
version_gt() { [[ "$(version_cmp "$1" "$2")" == "1"  ]]; }

# Current OS version
current_version_raw=$(sw_vers -productVersion)
current_version=$(normalize_ver "$current_version_raw")

autoload -Uz colors && colors

hide_cursor() { printf '\e[?25l'; }
show_cursor() { printf '\e[?25h'; }
clear_screen() { printf '\e[2J\e[H'; }
cleanup() { stty "$_STTY_ORIG" 2>/dev/null || true; show_cursor; printf '\e[0m'; }
trap cleanup EXIT INT TERM

if [[ -t 0 && -t 1 ]]; then
  _STTY_ORIG=$(stty -g)
  stty -echo -icanon min 1 time 0
fi

# --- fetch list once ---
raw=$(/usr/sbin/softwareupdate --list-full-installers 2>/dev/null)
lines=("${(@f)$(printf "%s\n" "$raw" | grep -E '^\* Title: ')}")
(( ${#lines[@]} == 0 )) && { echo "No macOS full installers found."; exit 1; }

# Parse into TSV: version \t title \t build \t sizeKiB
parsed=$(
  printf "%s\n" "${lines[@]}" | /usr/bin/awk '
  /^\* Title:/ {
    version=""; title=""; build=""; size="";
    if (match($0, /^\* Title: [^,]*/))        { title = substr($0, RSTART+9, RLENGTH-9) }
    if (match($0, /Version: [0-9][0-9.]*/))   { version = substr($0, RSTART+9, RLENGTH-9) }
    if (match($0, /Build: [^,]*/))            { build = substr($0, RSTART+7, RLENGTH-7) }
    if (match($0, /Size: [0-9]+KiB/))         { size = substr($0, RSTART+6, RLENGTH-6) }
    printf("%s\t%s\t%s\t%s\n", version, title, build, size);
  }'
)

typeset -a versions versions_norm titles builds sizes
for row in "${(@f)parsed}"; do
  IFS=$'\t' read -r v t b s <<< "$row"
  [[ -n "$v" ]] || continue
  if ! version_ge "$v" "$current_version"; then
    continue
  fi
  versions+=("$v")
  versions_norm+=("$(normalize_ver "$v")")
  titles+=("$t")
  builds+=("$b")
  sizes+=("$s")
done
(( ${#versions[@]} == 0 )) && { echo "No versions ≥ current ($current_version_raw)."; exit 1; }

# KiB -> GiB (two decimals)
human_gib() {
  local in="$1" n
  [[ "$in" == *KiB ]] && n="${in%KiB}" || n="$in"
  [[ "$n" == <-> ]] || { printf "%s" "$in"; return; }
  /usr/bin/awk -v kib="$n" 'BEGIN { printf("%.2f GiB", kib/1048576) }'
}

# --- UI state ---
pos=1; count=${#versions[@]}
: ${LINES:=24}; : ${COLUMNS:=80}
min_visible=5; visible=$(( LINES - 6 ))
(( visible < min_visible )) && visible=$min_visible
(( visible > count )) && visible=$count
start=1

make_divider() { printf '%*s' "$COLUMNS" '' | tr ' ' '-'; }

draw() {
  clear_screen
  local divider="$(make_divider)"

  print -P "%F{yellow} Current macOS: ${current_version_raw} | Select macOS version | ↑/↓ move | Enter select | q quit %f"
  print -r -- "$divider"

  (( pos < start )) && start=$pos
  (( pos >= start + visible )) && start=$(( pos - visible + 1 ))
  (( start < 1 )) && start=1

  local end=$(( start + visible - 1 ))
  (( end > count )) && end=$count

  for ((i=start; i<=end; i++)); do
    if (( i == pos )); then
      printf "\e[7m➤ %-*s\e[0m\n" $((COLUMNS-4)) "${versions[i]}"
    else
      printf "  %-*s\n" $((COLUMNS-4)) "${versions[i]}"
    fi
  done

  print -r -- "$divider"
  local sg=$(human_gib "${sizes[pos]}")
  print -P "%F{yellow}Version:%f ${versions[pos]}   %F{yellow}Title:%f ${titles[pos]}   %F{yellow}Build:%f ${builds[pos]}   %F{yellow}Size:%f ${sg}"
}

# --- robust fetch helpers ---
# Use ONLY valid forms of "softwareupdate --fetch-full-installer":
#   --full-installer-version <ver>
#   --productVersion <ver>
#   --productBuildVersion <build>
fetch_installer() {
  local ver="$1" build="$2"
  local got="" rc=1

  echo "Attempting to fetch full installer for version ${ver}..."

  if /usr/sbin/softwareupdate --help 2>&1 | grep -q -- '--full-installer-version'; then
    if sudo /usr/sbin/softwareupdate --fetch-full-installer --full-installer-version "$ver"; then
      got="--full-installer-version"; rc=0
    fi
  fi

  if (( rc != 0 )) && /usr/sbin/softwareupdate --help 2>&1 | grep -q -- '--productVersion'; then
    if sudo /usr/sbin/softwareupdate --fetch-full-installer --productVersion "$ver"; then
      got="--productVersion"; rc=0
    fi
  fi

  if (( rc != 0 )) && /usr/sbin/softwareupdate --help 2>&1 | grep -q -- '--productBuildVersion'; then
    if [[ -n "$build" ]]; then
      echo "Trying build-based fetch (${build})..."
      if sudo /usr/sbin/softwareupdate --fetch-full-installer --productBuildVersion "$build"; then
        got="--productBuildVersion"; rc=0
      fi
    fi
  fi

  if (( rc != 0 )); then
    echo "❌ Update not found for version ${ver} (build ${build})."
    return 1
  fi

  echo "✅ Fetched via ${got}"
  return 0
}

find_installer_app() {
  ls -1t /Applications/Install\ macOS*.app 2>/dev/null | head -n1
}

# --- interactive loop ---
hide_cursor
while true; do
  draw
  read -k 1 key || key=""
  case "$key" in
    $'\n'|$'\r') break ;;
    q|Q) cleanup; echo "No selection."; exit 2 ;;
    k) (( pos > 1 )) && (( pos-- )) ;;
    j) (( pos < count )) && (( pos++ )) ;;
    $'\e')
      read -k 1 -t 0.05 key2 || key2=""
      if [[ "$key2" == "[" ]]; then
        read -k 1 -t 0.05 key3 || key3=""
        case "$key3" in
          A) (( pos > 1 )) && (( pos-- )) ;;  # up
          B) (( pos < count )) && (( pos++ )) ;;  # down
          H) pos=1 ;; F) pos=$count ;;
        esac
      fi ;;
  esac
done
show_cursor

# Final selection
selected_version="${versions[pos]}"
selected_version_norm="${versions_norm[pos]}"
selected_build="${builds[pos]}"
echo "$selected_version"

# Final sanity check (normalized compare)
if ! version_ge "$selected_version" "$current_version"; then
  print -P "%F{red}Selected version ($selected_version) is older than current ($current_version_raw). Aborting.%f"
  exit 3
fi

# Major vs minor
selected_major="${${(s/./)selected_version_norm}[1]}"
current_major="${${(s/./)current_version}[1]}"

if [[ "$selected_major" == "$current_major" ]]; then
  print -P "%F{green}Minor/point update to $selected_version...%f"
  # Uncomment to perform minor update:
  # sudo /usr/sbin/softwareupdate --install --all --force --restart
else
  print -P "%F{cyan}Major upgrade to $selected_version...%f"

  if ! fetch_installer "$selected_version" "$selected_build"; then
    print -P "%F{red}Install failed: Apple catalog returned 'Update not found' for version $selected_version (build $selected_build).%f"
    print -P "%F{yellow}Tips:%f Ensure this Mac model is supported for ${selected_version}, try again later, or on another network/catalog."
    exit 10
  fi

  installer_app="$(find_installer_app)"
  if [[ -z "${installer_app}" ]]; then
    print -P "%F{red}Installer app not found in /Applications after fetch.%f"
    exit 11
  fi

  print -P "%F{green}Launching startosinstall from:%f $installer_app"
  sudo "$installer_app/Contents/Resources/startosinstall" \
    --agreetolicense --nointeraction --rebootdelay 10 --forcequitapps
fi