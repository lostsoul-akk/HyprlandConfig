---------------------
---- MY PROGRAMS ----
---------------------

-- See https://wiki.hypr.land/Configuring/Keywords/

-- Set programs that you use.
-- This file returns a table so other modules (e.g. keybindings.lua)
-- can require it: local programs = require("programs")

local M = {}

M.terminal       = "kitty"
M.fileManager    = "yazi"          -- TUI, needs a terminal wrapper: terminal .. " " .. fileManager
M.menu           = "anyrun"	   -- NOTE: What's this here for? Figure out since I don't have anyrun on here.
M.browser        = "zen-browser"
M.launcher       = "rofi -show drun"
M.music          = "spotify-launcher"
M.codeEditor     = "nvim" -- Get to using neovim
M.lock      	 = "hyprlock"
M.changeWallpaper = "~/.config/hypr/scripts/wallpaper-switch.sh"

return M
