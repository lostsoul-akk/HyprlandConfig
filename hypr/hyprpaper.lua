-------------------
---- WALLPAPERS ----
-------------------

-- Required from hyprland.lua as require("hyprpaper").
--
-- All the wallpaper logic lives in scripts/wallpaper.sh. This file only:
--   1. writes a hyprpaper.conf that points at the active-wallpaper soft link, and
--   2. starts scripts/wallpaper.sh on login. That script resets the link to the first
--      wallpaper in the folder, launches hyprpaper, and switches wallpapers on a timer.
--
-- hyprpaper is NOT started from here, the script does it, so there's only ever one.
-- To change the folder or the interval, edit the settings at the top of wallpaper.sh.
-- NOTE: Don't edit hyprpaper.conf by hand: it is regenerated from this file.

local M = {}

local home = os.getenv("HOME")

M.link      = home .. "/Pictures/Wallpapers/current"       -- keep in sync with LINK in wallpaper.sh
M.fit_mode  = "cover"
M.conf_path = home .. "/.config/hypr/hyprpaper.conf"
M.script    = home .. "/.config/hypr/scripts/wallpaper.sh"

function M.write_conf()
    local content = table.concat({
        "wallpaper {",
        "    monitor = ",
        "    path = " .. M.link,
        "    fit_mode = " .. M.fit_mode,
        "}",
        "",
    }, "\n")

    -- Skip the write if nothing changed (this file runs again on every config reload)
    local f = io.open(M.conf_path, "r")
    if f then
        local existing = f:read("*a")
        f:close()
        if existing == content then
            return true
        end
    end

    f = io.open(M.conf_path, "w")
    if not f then
        return false
    end
    f:write(content)
    f:close()
    return true
end

M.write_conf()

hl.on("hyprland.start", function()
    hl.exec_cmd(M.script .. " start")
end)

return M
