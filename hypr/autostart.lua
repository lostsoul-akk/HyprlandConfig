-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- All commands here run once when Hyprland starts,
-- equivalent to exec-once in the old .conf format.

hl.on("hyprland.start", function()
    -- Clipboard daemon (text + images)
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Noctalia
    hl.exec_cmd("noctalia")

    -- Udiskie
    hl.exec_cmd("udiskie")

    -- Custom Script
    hl.exec_cmd("~/.local/bin/battery-notify.sh")


    -- -- lockscreen.
    -- hl.exec_cmd("sleep 4 && noctalia msg session lock")
end)

