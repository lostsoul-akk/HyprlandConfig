#!/usr/bin/env bash
# Feeds the lockscreen music disc while hyprlock is running. Started by a hidden label in
# hyprlock.conf (--autostart), so it works however you lock the screen.
#
#  * watches the media player (playerctl) about twice a second
#  * on a new track, renders the album art as a round disc and pre-renders one full turn
#    of it as FRAMES pictures (cached; the previous track's frames are deleted)
#  * writes a tiny state file that scripts/lock-disc.sh (hyprlock's reload_cmd) reads
#  * sends hyprlock SIGUSR2 ~25 times a second, which makes it reload the image widget
#
# Needs: playerctl, ImageMagick (magick or convert), curl (only for art that comes from a URL)
#
#   lock-disc-daemon.sh --prepare    only make sure the placeholder image exists, then exit
#   lock-disc-daemon.sh --autostart  start the daemon detached and return at once (used by hyprlock.conf)

# hyprlock waits for the label command to finish, so detach completely and return at once
if [ "$1" = "--autostart" ]; then
    setsid -f "$0" >/dev/null 2>&1 </dev/null
    exit 0
fi

# ---- knobs ----
TURN_SECONDS=5      # time for one complete rotation
FPS=24              # frames pre-rendered per second of rotation (more = smoother, bigger cache)
SIZE=300            # px, keep in sync with `size` of the image widget in hyprlock.conf

FRAMES=$(( TURN_SECONDS * FPS ))
TURN_MS=$(( TURN_SECONDS * 1000 ))
PUMP_INTERVAL=0.04  # seconds between reload signals to hyprlock (~25 per second)

dir="${XDG_CACHE_HOME:-$HOME/.cache}/hypr/disc"
state="$dir/state"
mkdir -p "$dir/frames"

IM="$(command -v magick || command -v convert)"
[ -n "$IM" ] || exit 0

c=$(( SIZE / 2 ))
hole=$(( SIZE / 10 ))

ensure_empty() {
    [ -f "$dir/empty.png" ] || "$IM" -size "${SIZE}x${SIZE}" xc:none PNG32:"$dir/empty.png"
}
ensure_empty
[ "$1" = "--prepare" ] && exit 0

# only one daemon at a time
if command -v flock >/dev/null 2>&1; then
    exec 9>"$dir/daemon.lock"
    flock -n 9 || exit 0
fi

now_ms() { local t="${EPOCHREALTIME/[.,]/}"; echo $(( t / 1000 )); }

write_state() {   # key status t0 phase0(permille)
    printf '%s %s %s %s %s %s\n' "$1" "$2" "$3" "$4" "$TURN_MS" "$FRAMES" > "$state.tmp" \
        && mv -f "$state.tmp" "$state"
}

# Round disc from the album art (or a plain grooved disc when there is none)
render_base() {   # src out
    local src="$1" out="$2"
    if [ -n "$src" ] && [ -s "$src" ]; then
        "$IM" "$src" -resize "${SIZE}x${SIZE}^" -gravity center -extent "${SIZE}x${SIZE}" +repage \
            \( -size "${SIZE}x${SIZE}" xc:black -fill white -draw "circle $c,$c $c,1" \) \
            -alpha off -compose CopyOpacity -composite \
            \( -size "${SIZE}x${SIZE}" xc:none -fill white -draw "circle $c,$c $c,$(( c - hole ))" \) \
            -compose DstOut -composite \
            -fill none -stroke "rgba(0,0,0,0.55)" -strokewidth 3 -draw "circle $c,$c $c,$(( c - hole ))" \
            PNG32:"$out" 2>/dev/null
    fi
    if [ ! -s "$out" ]; then
        "$IM" -size "${SIZE}x${SIZE}" xc:none -fill "#303638" -draw "circle $c,$c $c,1" \
            -fill none -stroke "#40484c" -strokewidth 2 \
            -draw "circle $c,$c $c,$(( c * 80 / 100 ))" \
            -draw "circle $c,$c $c,$(( c * 60 / 100 ))" \
            -draw "circle $c,$c $c,$(( c * 40 / 100 ))" \
            -fill "#88d1ec" -stroke none -draw "circle $c,$(( c * 18 / 100 )) $c,$(( c * 18 / 100 - 10 ))" \
            \( -size "${SIZE}x${SIZE}" xc:none -fill white -draw "circle $c,$c $c,$(( c - hole ))" \) \
            -compose DstOut -composite \
            PNG32:"$out"
    fi
}

# One full turn, all frames in a single ImageMagick run: base.png + f-000.png ... f-(FRAMES-1).png
gen_frames() {   # key art
    local key="$1" art="$2" fdir="$dir/frames/$1" src=""
    [ -f "$fdir/.done" ] && return 0
    mkdir "$fdir.lock" 2>/dev/null || return 0        # someone is already generating this one
    mkdir -p "$fdir"

    case "$art" in
        file://*)
            src="${art#file://}"
            src="$(printf '%b' "${src//%/\\x}")"         # undo %20 etc.
            ;;
        http://*|https://*)
            src="$fdir/art.img"
            curl -fsSL --max-time 5 "$art" -o "$src" 2>/dev/null || rm -f "$src"
            ;;
    esac

    render_base "$src" "$fdir/base.png"
    "$IM" "$fdir/base.png" -background none -virtual-pixel transparent \
        -duplicate $(( FRAMES - 1 )) -distort SRT "%[fx:t*360/$FRAMES]" +repage \
        PNG32:"$fdir/f-%03d.png" 2>/dev/null
    touch "$fdir/.done"
    rmdir "$fdir.lock"
}

# ---- wait for hyprlock ----
pid=""
for _ in $(seq 100); do
    pid="$(pgrep -x hyprlock | head -n1)"
    [ -n "$pid" ] && break
    sleep 0.1
done
[ -n "$pid" ] || exit 0

# SIGUSR2 kills a process that has no handler for it yet, and hyprlock installs its handler
# a moment after it starts. Only poke it once /proc says the signal is caught (bit 0x800).
sigusr2_caught() {
    local k v
    while read -r k v; do
        if [ "$k" = "SigCgt:" ]; then (( 16#$v & 0x800 )); return; fi
    done < "/proc/$1/status" 2>/dev/null
    return 1
}
ready=""
for _ in $(seq 200); do
    kill -0 "$pid" 2>/dev/null || exit 0
    if sigusr2_caught "$pid"; then ready=1; break; fi
    sleep 0.05
done
[ -n "$ready" ] || exit 0

# ---- slow loop: player state, frame generation, state file ----
poll_loop() {
    local prev_key="" prev_status="" t0 phase0=0 out status rest art title key now frac
    t0="$(now_ms)"
    while kill -0 "$pid" 2>/dev/null; do
        out="$(playerctl metadata --format '{{status}}|{{mpris:artUrl}}|{{xesam:title}}' 2>/dev/null)"
        status="${out%%|*}"
        rest="${out#*|}"; art="${rest%%|*}"; title="${rest#*|}"
        case "$status" in Playing|Paused) ;; *) status="None" ;; esac

        if [ "$status" = "None" ]; then
            key="-"
        else
            key="$(printf '%s|%s' "$art" "$title" | md5sum | cut -d' ' -f1)"
        fi

        if [ "$key" != "$prev_key" ] || [ "$status" != "$prev_status" ]; then
            now="$(now_ms)"
            if [ "$key" != "$prev_key" ]; then
                phase0=0                                              # new track: start at the top
            elif [ "$prev_status" = "Playing" ]; then
                phase0=$(( (phase0 + (now - t0) * 1000 / TURN_MS) % 1000 ))   # freeze where it is
            fi
            t0="$now"

            if [ "$key" != "$prev_key" ] && [ "$key" != "-" ]; then
                # drop frames of other tracks, then render this one in the background
                find "$dir/frames" -mindepth 1 -maxdepth 1 -type d ! -name "$key" ! -name "$key.lock" -exec rm -rf {} + 2>/dev/null
                ( gen_frames "$key" "$art" ) &
            fi
            write_state "$key" "$status" "$t0" "$phase0"
            prev_key="$key"; prev_status="$status"
        fi
        sleep 0.5
    done
}

poll_loop &
poll_pid=$!
trap 'kill "$poll_pid" 2>/dev/null' EXIT

# ---- fast loop: tell hyprlock to reload the image (reload_time = 0 means "on SIGUSR2") ----
while kill -0 "$pid" 2>/dev/null; do
    kill -USR2 "$pid" 2>/dev/null
    sleep "$PUMP_INTERVAL"
done
