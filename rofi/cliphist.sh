#!/usr/bin/env bash
# Clipboard history picker: cliphist + rofi, text and image entries.
# Image entries get a thumbnail. Picking an entry puts it back on the clipboard.
# Needs: cliphist, wl-clipboard, rofi (wayland). Launched by SUPER+V.

theme="${CLIPHIST_ROFI_THEME:-$HOME/.config/rofi/clipboard.rasi}"
thumbs="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist-thumbs"
mkdir -p "$thumbs"

# Drop thumbnails older than a week so the cache doesn't grow forever
find "$thumbs" -type f -mtime +7 -delete 2>/dev/null

history="$(cliphist list)"
if [ -z "$history" ]; then
    command -v notify-send >/dev/null && notify-send "Clipboard" "History is empty"
    exit 0
fi

img_re='\[\[ binary data .* (png|jpe?g|bmp|gif|webp) [0-9]+x[0-9]+ \]\]'

build_rows() {
    local line id ext img
    while IFS= read -r line; do
        if [[ $line =~ $img_re ]]; then
            id="${line%%$'\t'*}"
            ext="${BASH_REMATCH[1]}"
            img="$thumbs/$id.$ext"
            # decode each image once, reuse the file afterwards
            [ -s "$img" ] || printf '%s\n' "$line" | cliphist decode > "$img" 2>/dev/null
            printf '%s\0icon\x1f%s\n' "$line" "$img"
        else
            printf '%s\n' "$line"
        fi
    done <<< "$history"
}

choice="$(build_rows | rofi -dmenu -i -p "Clipboard" \
    -show-icons -display-columns 2 \
    -matching normal -no-sort \
    -theme "$theme")"

[ -n "$choice" ] && printf '%s\n' "$choice" | cliphist decode | wl-copy
