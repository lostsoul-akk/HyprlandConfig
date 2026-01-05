#!/bin/bash
if pgrep -x "rofi" > /dev/null
then
	killall rofi
else
	rofi -show drun \
		-modes "drun,filebrowser,window" \
		-theme ~/.config/rofi/sleek.rasi \
		-show-icons
fi
