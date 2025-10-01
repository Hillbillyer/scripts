#!/bin/zsh
# Interactive arrow-key menu for choosing a macOS full installer version.
# Works on Apple Silicon & Intel, no extra deps.

set -euo pipefail
export LC_ALL=C

# --- normalize versions into X.Y.Z ---
normalize_ver() {
  local v="${1//[^0-9.]/}"   # strip non-numeric/dots
  local -a p
  p=(${(s/./)v})
  printf "%d.%d.%d" "${p[1]:-0}" "${p[2]:-0}" "${p[3]:-0}"
}

# --- compare versions: returns 1 if v1>v2, 0 if equal, -1 if v1<v2 ---
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

# --- current version ---
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

# --- fetch list ---
raw=$(/usr/sbin/softwareupdate --list-full-installers 2>/dev/null)
lines=("${(@f)$(printf "%s\n" "$raw" | grep -E '^\* Title: ')}")
(( ${#lines[@]} == 0 )) && { echo "No installers found."; exit 1; }

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
(( ${#versions[@]} == 0 )) && { echo "No newer/equal versions found."; exit 1; }

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

make_divider() {
  # nice clean ASCII divider
  printf '%*s' "$COLUMNS" '' | tr ' ' '-'
}

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
          A) (( pos > 1 )) && (( pos-- )) ;;
          B) (( pos < count )) && (( pos++ )) ;;
          H) pos=1 ;;
          F) pos=$count ;;
        esac
      fi
      ;;
  esac
done

show_cursor
selected_version="${versions[pos]}"
selected_version_norm="${versions_norm[pos]}"
echo "$selected_version"

# Final sanity check
if ! version_ge "$selected_version" "$current_version"; then
  print -P "%F{red}Selected version ($selected_version) is older than current ($current_version_raw). Aborting.%f"
  exit 3
fi

# Major vs minor
selected_major="${${(s/./)selected_version_norm}[1]}"
current_major="${${(s/./)current_version}[1]}"

if [[ "$selected_major" == "$current_major" ]]; then
  print -P "%F{green}Minor update to $selected_version...%f"
  sudo softwareupdate --install --all --force --restart
else
  print -P "%F{cyan}Major upgrade to $selected_version...%f"
  sudo softwareupdate --fetch-full-installer --full-installer-version "$selected_version"
  sudo "/Applications/Install macOS"*/Contents/Resources/startosinstall --agreetolicense --nointeraction --rebootdelay 10 --forcequitapps
fi