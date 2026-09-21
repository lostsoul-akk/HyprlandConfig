#!/usr/bin/env bash
# Wallpaper cycler for hyprpaper.
# The active wallpaper is a soft link ($LINK) pointing at the real image, so
# hyprpaper.conf, lock.sh and anything else can just use $LINK.
#
#   wallpaper.sh init         make sure the link exists (default wallpaper) and apply it
#   wallpaper.sh next | prev  cycle through the wallpapers folder
#   wallpaper.sh random       jump to a random one
#   wallpaper.sh set <file>   use a specific image

WALL_DIR="${WALL_DIR:-$HOME/Pictures/Wallpapers/wallhaven}"
LINK="${WALLPAPER_LINK:-$HOME/Pictures/Wallpapers/current}"
DEFAULT="${WALLPAPER_DEFAULT:-$HOME/Pictures/Wallpapers/wallhaven/6lyj1q.png}"   # same default as hyprpaper.lua
FIT="${WALLPAPER_FIT:-cover}"

# Re-scan every time, so new files in the folder are picked up automatically
mapfile -t walls < <(find -L "$WALL_DIR" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) 2>/dev/null | sort)
n=${#walls[@]}
if [ "$n" -eq 0 ]; then
    echo "No wallpapers found in $WALL_DIR" >&2
    exit 1
fi

current="$(readlink -f "$LINK" 2>/dev/null)"
idx=-1
for i in "${!walls[@]}"; do
    if [ "$(readlink -f "${walls[$i]}")" = "$current" ]; then idx=$i; break; fi
done

case "${1:-next}" in
    init)
        if [ -f "$current" ]; then
            target="$current"                       # link is fine, keep it
        elif [ -n "$DEFAULT" ] && [ -f "$DEFAULT" ]; then
            target="$(readlink -f "$DEFAULT")"
        else
            target="${walls[0]}"                    # first wallpaper in the folder
        fi
        ;;
    next)
        target="${walls[$(( (idx + 1) % n ))]}"
        ;;
    prev)
        [ "$idx" -lt 0 ] && idx=0
        target="${walls[$(( (idx - 1 + n) % n ))]}"
        ;;
    random)
        target="${walls[$(( RANDOM % n ))]}"
        if [ "$n" -gt 1 ]; then
            while [ "$(readlink -f "$target")" = "$current" ]; do
                target="${walls[$(( RANDOM % n ))]}"
            done
        fi
        ;;
    set)
        target="$(readlink -f "${2:-}" 2>/dev/null)"
        if [ ! -f "$target" ]; then echo "Not a file: ${2:-}" >&2; exit 1; fi
        ;;
    *)
        echo "Usage: ${0##*/} [init|next|prev|random|set <file>]" >&2
        exit 1
        ;;
esac

target="$(readlink -f "$target")"
mkdir -p "$(dirname "$LINK")"
ln -sfn "$target" "$LINK"

# Apply. The real path is sent (not the link) so hyprpaper always sees a new path and reloads.
if pgrep -x hyprpaper >/dev/null 2>&1; then
    hyprctl hyprpaper wallpaper ",$target,$FIT" >/dev/null
else
    hyprpaper >/dev/null 2>&1 &
    disown
fi

command -v notify-send >/dev/null 2>&1 && notify-send -t 1500 "Wallpaper" "$(basename "$target")"
exit 0
