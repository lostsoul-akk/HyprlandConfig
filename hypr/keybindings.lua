---------------------
---- KEYBINDINGS ----
---------------------

-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local programs = require("programs")
local mainMod  = "SUPER" -- Sets "Windows" key as main modifier


-- ── System ────────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
hl.bind(mainMod .. " + N",         hl.dsp.exit())
-- With the use of Noctalia, there's no need to have a custom waybar, hence no need for a script to restart it.
-- Free Keybind: mainMod .. " + SHIFT + B"

-- ── Apps ──────────────────────────────────────────────────────────────────────

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(programs.terminal))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(programs.browser))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(programs.codeEditor))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(programs.music))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(programs.terminal .. " " .. programs.fileManager))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(programs.menu))


-- ── Screenshots ───────────────────────────────────────────────────────────────

-- Windows Snipping Tool equivalent: SUPER + SHIFT + S
--
-- Flow:
--   1. slurp   → draw a region on screen
--   2. grim    → capture that region to a temp file
--   3. wl-copy → immediately copy to clipboard (it's already there when satty opens)
--   4. satty   → annotation window — draw, highlight, save, or copy the edited version
--
-- Requires: grim, slurp, satty, wl-clipboard
-- sudo pacman -S grim slurp satty wl-clipboard
-- Install satty: https://github.com/gabm/satty

hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(
    [[sh -c 'FILE=$(mktemp /tmp/screenshot-XXXXXX.png) && grim -g "$(slurp)" "$FILE" && wl-copy < "$FILE" && satty --filename "$FILE" --copy-command "wl-copy"']]
))

-- ── Window management ─────────────────────────────────────────────────────────

hl.bind(mainMod .. " + W", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + I", hl.dsp.window.pin())
hl.bind(mainMod .. " + Z", hl.dsp.window.pseudo())       -- dwindle pseudotile toggle

-- Move focus — arrow keys (Commented out: Gotta master vim's key bindings).
-- hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left"  }))
-- hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
-- hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up"    }))
-- hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down"  }))

-- Move focus — vim keys
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down"  }))

-- Move/resize windows with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })


-- ── Workspaces ────────────────────────────────────────────────────────────────

-- Switch to workspace 1–9, and 0 → workspace 10
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + 0",         hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Cycle through workspaces (Commented out: Gotta master vim's key bindings).
-- hl.bind(mainMod .. " + CONTROL + right", hl.dsp.focus({ workspace = "e+1" }))
-- hl.bind(mainMod .. " + CONTROL + left",  hl.dsp.focus({ workspace = "e-1" }))

-- Cycle through workspaces - vim keys
hl.bind(mainMod .. " + CONTROL + l", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + CONTROL + h",  hl.dsp.focus({ workspace = "e-1" }))



-- Move active window to adjacent workspace (and follow)
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind(mainMod .. " + SHIFT + h",  hl.dsp.window.move({ workspace = "e-1" }))

-- Scratchpad (special workspace)
-- NOTE: moved from SHIFT+S → CTRL+S to free up SHIFT+S for screenshots
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S",  hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces with mouse wheel
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))


-- ── Media & hardware keys ─────────────────────────────────────────────────────

-- Volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),    { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Playback (requires playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
