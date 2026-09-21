#!/usr/bin/env bash
# Lock the screen with hyprlock (does nothing if it is already locked).
# Optional: plain `hyprlock` works just as well. The music disc is started by hyprlock.conf
# itself, so it turns however you lock.

pgrep -x hyprlock >/dev/null && exit 0

# placeholder image hyprlock.conf starts with (lock-disc-daemon.sh creates it if missing)
"$(dirname "${BASH_SOURCE[0]}")/lock-disc-daemon.sh" --prepare

exec hyprlock "$@"
