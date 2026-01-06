#!/bin/bash

# 1. Path to your symlink folder
WALL_DIR="$HOME/Pictures/wallpapers/all_wallpapers"

# 2. Pick a random wallpaper from that folder
RANDOM_WALL=$(find "$WALL_DIR" -type l | shuf -n 1)

# 3. Preload the new wallpaper
hyprctl hyprpaper preload "$RANDOM_WALL"

# 4. Set the wallpaper (using "" for the monitor field applies it to all)
hyprctl hyprpaper wallpaper ",$RANDOM_WALL"

# 5. Unload unused wallpapers to save RAM
# (Optional, but recommended for hyprpaper)
hyprctl hyprpaper unload all
