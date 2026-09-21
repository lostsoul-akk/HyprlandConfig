-------------------
---- WALLPAPERS ----
-------------------

-- hyprpaper >= 0.8.0 rewrote its config to a block syntax and dropped
-- preload/reload from its IPC — it's now a single "wallpaper" command.
-- hyprpaper still has no native `hl` primitive, so this writes a plain
-- hyprpaper.conf from Lua, then autostarts the daemon.
-- Required from hyprland.lua as require("hyprpaper").
--
-- The active wallpaper is a soft link (M.active_wallpaper) that points at a real
-- image. hyprpaper.conf always uses the link, and scripts/wallpaper.sh moves the
-- link when you cycle wallpapers, so the last wallpaper you picked survives a reboot.
-- Don't edit hyprpaper.conf by hand: it is regenerated from this file on every start.

local M = {}

M.wallpaper_dir = os.getenv("HOME") .. "/Pictures/Wallpapers"

-- Default wallpaper: only used when the link doesn't exist yet (or is broken).
M.default_wallpaper = M.wallpaper_dir .. "/wallhaven/6lyj1q.png"

-- Soft link to the wallpaper that is currently active.
M.active_wallpaper = M.wallpaper_dir .. "/current"

M.fit_mode = "cover"

M.conf_path = os.getenv("HOME") .. "/.config/hypr/hyprpaper.conf"

local function sh_quote(s)
    return "'" .. s:gsub("'", "'\\''") .. "'"
end

-- Makes sure the link exists and points at a real file; otherwise points it at the default.
function M.ensure_link()
    local f = io.open(M.active_wallpaper, "r") -- follows the link, nil if missing/broken
    if f then
        f:close()
        return true
    end
    return os.execute("ln -sfn " .. sh_quote(M.default_wallpaper) .. " " .. sh_quote(M.active_wallpaper)) == true
end

-- Regenerates hyprpaper.conf so it points at the active-wallpaper link. hyprpaper reads
-- this file itself on launch, so this just needs to run before hl.exec_cmd("hyprpaper").
function M.write_conf()
    local file = io.open(M.conf_path, "w")
    if not file then
        return false
    end

    file:write("wallpaper {\n")
    file:write("    monitor = \n")
    file:write("    path = " .. M.active_wallpaper .. "\n")
    file:write("    fit_mode = " .. M.fit_mode .. "\n")
    file:write("}\n")
    file:close()
    return true
end

M.ensure_link()
M.write_conf()

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
end)

return M
