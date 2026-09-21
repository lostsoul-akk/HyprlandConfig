local wallpaper_settings = {
    preload = "~/Pictures/Wallpapers/wallhaven/212gkg.jpg",
    wallpaper = "eDP-1,~/Pictures/Wallpapers/wallhaven/212gkg.jpg",
    splash = false,
}

-- Write settings to hyprpaper.conf dynamically
local config_path = os.getenv("HOME") .. "/.config/hypr/hyprpaper.conf"
local file = io.open(config_path, "w")

if file then
    file:write("preload = " .. wallpaper_settings.preload .. "\n")
    file:write("wallpaper = " .. wallpaper_settings.wallpaper .. "\n")
    file:write("splash = " .. tostring(wallpaper_settings.splash) .. "\n")
    file:close()
end

-- Start hyprpaper daemon
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
end)
