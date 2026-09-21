#!/usr/bin/env bash
#
# wallpaper-switch.sh
# Picks a wallpaper (via wofi/rofi menu or random) and applies it live
# through hyprpaper's IPC, on all connected monitors.
#
# Requirements: hyprpaper running, jq, and wofi (or rofi -- see NOTE below)
#
# Usage:
#   ./wallpaper-switch.sh          # opens a picker menu
#   ./wallpaper-switch.sh random   # picks a random wallpaper
#   ./wallpaper-switch.sh /path/to/image.jpg   # sets a specific wallpaper

set -euo pipefail

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"

# --- pick the wallpaper -----------------------------------------------
choose_wallpaper() {
    local mode="${1:-menu}"

    if [[ "$mode" != "menu" && "$mode" != "random" && -f "$mode" ]]; then
        echo "$mode"
        return
    fi

    mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \))

    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        notify-send "Wallpaper" "No images found in $WALLPAPER_DIR" -u critical
        exit 1
    fi

    if [[ "$mode" == "random" ]]; then
        echo "${wallpapers[RANDOM % ${#wallpapers[@]}]}"
        return
    fi

    # Menu mode: show basenames in wofi, map back to full path.
    # NOTE: swap 'wofi --dmenu' for 'rofi -dmenu' if that's your launcher.
    local choice
    choice=$(printf '%s\n' "${wallpapers[@]}" | xargs -n1 basename | \
        wofi --dmenu --prompt "Wallpaper" --width 500 --height 400)

    [[ -z "$choice" ]] && exit 0

    for wp in "${wallpapers[@]}"; do
        [[ "$(basename "$wp")" == "$choice" ]] && { echo "$wp"; return; }
    done

    notify-send "Wallpaper" "Could not resolve selection" -u critical
    exit 1
}

# --- apply it to every monitor -----------------------------------------
apply_wallpaper() {
    local wp="$1"
    local fit_mode="${FIT_MODE:-cover}"

    if ! pgrep -x hyprpaper >/dev/null; then
        notify-send "Wallpaper" "hyprpaper is not running" -u critical
        exit 1
    fi

    # hyprpaper >= 0.8.0 dropped preload/unload from IPC — one command
    # per monitor now both loads and applies the image.
    local monitors
    monitors=$(hyprctl monitors -j | jq -r '.[].name')

    while read -r mon; do
        hyprctl hyprpaper wallpaper "$mon,$wp,$fit_mode" >/dev/null
    done <<< "$monitors"

    notify-send "Wallpaper" "Set to $(basename "$wp")" -i "$wp"
}

main() {
    local wp
    wp=$(choose_wallpaper "${1:-menu}")
    apply_wallpaper "$wp"
}

main "$@"
