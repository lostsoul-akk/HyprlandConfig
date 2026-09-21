#!/usr/bin/env bash
# Toggle a rofi picker with the same key.
#   toggle.sh <name> <command...>
# - nothing open            -> run <command>
# - same picker is open     -> close it (hide)
# - a different rofi is open -> close it and open this one
name="$1"; shift
state="${XDG_RUNTIME_DIR:-/tmp}/rofi-toggle-current"

if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    # wait (max ~1s) for the old window to actually go away
    for _ in $(seq 50); do
        pgrep -x rofi >/dev/null || break
        sleep 0.02
    done
    if [ "$(cat "$state" 2>/dev/null)" = "$name" ]; then
        rm -f "$state"
        exit 0
    fi
fi

echo "$name" > "$state"
exec "$@"
