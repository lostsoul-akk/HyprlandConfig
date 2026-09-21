#!/usr/bin/env bash
# Music disc for the lockscreen. Prints the path of the current disc image, for hyprlock's
# image widget (reload_cmd). Each call renders the album art as a round disc, turned a bit
# further while music is playing, and stays still when paused. Nothing playing -> an empty
# (transparent) image, so no disc is shown.
#
# Needs: playerctl, ImageMagick (magick or convert), curl (only for art that comes from a URL)

SIZE=300            # px, keep in sync with `size` of the image widget in hyprlock.conf
DEG_PER_SEC=2      # spin speed while playing (hyprlock refreshes about once a second)

dir="${XDG_CACHE_HOME:-$HOME/.cache}/hypr/disc"
mkdir -p "$dir"

IM="$(command -v magick || command -v convert)"
[ -n "$IM" ] || exit 0                                   # no ImageMagick: show nothing

c=$(( SIZE / 2 ))
hole=$(( SIZE / 10 ))

emit_empty() {
    [ -f "$dir/empty.png" ] || "$IM" -size "${SIZE}x${SIZE}" xc:none PNG32:"$dir/empty.png"
    echo "$dir/empty.png"
    exit 0
}

command -v playerctl >/dev/null 2>&1 || emit_empty
status="$(playerctl status 2>/dev/null)"
case "$status" in Playing|Paused) ;; *) emit_empty ;; esac

art="$(playerctl metadata mpris:artUrl 2>/dev/null)"
title="$(playerctl metadata xesam:title 2>/dev/null)"
key="$(printf '%s|%s' "$art" "$title" | md5sum | cut -d' ' -f1)"
base="$dir/base-$key.png"

# Build the round disc once per track
if [ ! -f "$base" ]; then
    src=""
    case "$art" in
        file://*)
            src="${art#file://}"
            src="$(printf '%b' "${src//%/\\x}")"         # undo %20 etc.
            ;;
        http://*|https://*)
            src="$dir/art-$key.img"
            [ -s "$src" ] || curl -fsSL --max-time 5 "$art" -o "$src" 2>/dev/null || rm -f "$src"
            ;;
    esac

    if [ -n "$src" ] && [ -s "$src" ]; then
        # album art -> circle -> hole in the middle -> thin dark ring around the hole
        "$IM" "$src" -resize "${SIZE}x${SIZE}^" -gravity center -extent "${SIZE}x${SIZE}" +repage \
            \( -size "${SIZE}x${SIZE}" xc:black -fill white -draw "circle $c,$c $c,1" \) \
            -alpha off -compose CopyOpacity -composite \
            \( -size "${SIZE}x${SIZE}" xc:none -fill white -draw "circle $c,$c $c,$(( c - hole ))" \) \
            -compose DstOut -composite \
            -fill none -stroke "rgba(0,0,0,0.55)" -strokewidth 3 -draw "circle $c,$c $c,$(( c - hole ))" \
            PNG32:"$base" 2>/dev/null
    fi

    if [ ! -s "$base" ]; then
        # no usable art: plain disc with grooves and a marker dot so the spin is visible
        "$IM" -size "${SIZE}x${SIZE}" xc:none -fill "#303638" -draw "circle $c,$c $c,1" \
            -fill none -stroke "#40484c" -strokewidth 2 \
            -draw "circle $c,$c $c,$(( c * 80 / 100 ))" \
            -draw "circle $c,$c $c,$(( c * 60 / 100 ))" \
            -draw "circle $c,$c $c,$(( c * 40 / 100 ))" \
            -fill "#88d1ec" -stroke none -draw "circle $c,$(( c * 18 / 100 )) $c,$(( c * 18 / 100 - 10 ))" \
            \( -size "${SIZE}x${SIZE}" xc:none -fill white -draw "circle $c,$c $c,$(( c - hole ))" \) \
            -compose DstOut -composite \
            PNG32:"$base"
    fi
fi

# Spin: the angle only advances while playing
state="$dir/angle"
now="$(date +%s%3N)"
angle=0; last="$now"
[ -f "$state" ] && read -r angle last < "$state"
dt=$(( now - last ))
[ "$dt" -gt 2000 ] && dt=2000
[ "$dt" -lt 0 ] && dt=0
[ "$status" = "Playing" ] && angle=$(( (angle + DEG_PER_SEC * dt / 1000) % 360 ))
echo "$angle $now" > "$state"

# hyprlock only reloads when the path changes, so every frame gets a new file name
frame="$dir/frame-$now.png"
"$IM" "$base" -background none -rotate "$angle" +repage -gravity center -extent "${SIZE}x${SIZE}" PNG32:"$frame" 2>/dev/null \
    || emit_empty

# keep the last few frames, drop the rest
find "$dir" -name 'frame-*.png' -mmin +1 -delete 2>/dev/null
echo "$frame"
