#!/usr/bin/env bash
# Lock the screen with hyprlock (does nothing if it is already locked).
# hyprlock.conf is a normal config now, so plain `hyprlock` works too; this is just the
# entry point for keybinds / hypridle. It renders the disc once first so the file that
# hyprlock.conf uses as its first image already exists.

pgrep -x hyprlock >/dev/null && exit 0

"$(dirname "${BASH_SOURCE[0]}")/lock-disc.sh" >/dev/null 2>&1

exec hyprlock "$@"
