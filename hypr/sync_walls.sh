#!/bin/bash

# Define your paths
SOURCE_DIR="$HOME/Pictures/wallpapers"
COLLECTION_DIR="$HOME/Pictures/wallpapers/all_wallpapers"

# 1. Create the collection folder if it doesn't exist
mkdir -p "$COLLECTION_DIR"

# 2. Clear existing symlinks to avoid broken links or duplicates
find "$COLLECTION_DIR" -type l -delete

# 3. Find all images in subfolders and link them to the collection folder
# This ignores the collection folder itself to avoid infinite loops
find "$SOURCE_DIR" -path "$COLLECTION_DIR" -prune -o -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" -o -name "*.jpeg" \) -exec ln -s {} "$COLLECTION_DIR" \;

echo "Wallpaper collection synced! Total images: $(ls "$COLLECTION_DIR" | wc -l)"
