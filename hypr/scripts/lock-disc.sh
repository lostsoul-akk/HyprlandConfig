#!/usr/bin/env bash
# hyprlock calls this ~25 times a second (reload_cmd). It only prints the path of the
# frame that matches "now"; all the real work is done by lock-disc-daemon.sh.

dir="${XDG_CACHE_HOME:-$HOME/.cache}/hypr/disc"

read -r key status t0 phase0 turn_ms frames < "$dir/state" 2>/dev/null || { echo "$dir/empty.png"; exit 0; }
if [ "$status" = "None" ]; then echo "$dir/empty.png"; exit 0; fi

t="${EPOCHREALTIME/[.,]/}"
now=$(( t / 1000 ))
if [ "$status" = "Playing" ]; then
    frac=$(( (phase0 + (now - t0) * 1000 / turn_ms) % 1000 ))
else
    frac=$phase0
fi

printf -v f '%s/frames/%s/f-%03d.png' "$dir" "$key" $(( frac * frames / 1000 ))
if [ -f "$f" ]; then
    echo "$f"
elif [ -f "$dir/frames/$key/base.png" ]; then
    echo "$dir/frames/$key/base.png"          # frames not ready yet: show the still disc
else
    echo "$dir/empty.png"
fi
