-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- HYPRLAND CONFIG                                       --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Split config files are required below — edit each one independently:
--   programs.lua      → app variables (terminal, browser, etc.)
--   environments.lua  → environment variables
--   autostart.lua     → startup commands
--   appearance.lua    → look & feel, animations, layouts, noctalia layer rule
--   keybindings.lua   → all key/mouse binds


------------------
---- MONITORS ----
------------------
require("monitors")


---------------------
---- MY PROGRAMS ----
---------------------

require("programs")


-------------------
---- AUTOSTART ----
-------------------

require("autostart")


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

require("environments")


-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")


-----------------------
---- LOOK AND FEEL ----
-----------------------

require("appearance")


---------------
---- INPUT ----
---------------

require("input")


---------------------
---- KEYBINDINGS ----
---------------------

require("keybindings")


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- For Noctalia Color templates
require("noctalia")
