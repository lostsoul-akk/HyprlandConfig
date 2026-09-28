------------------
---- MONITORS ----
------------------

-- Primary Laptop Display
hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "0x0",
    scale    = 1,
    disabled = false,
})


-- My monitor, MSI
hl.monitor({
    output   = "desc:Microstep MAG 255F E20 BC2M506300578",
    mode     = "1920x1080@60",
    position = "auto",
    scale    = "auto",
})

-- Modes:
-- preferred - use the display’s preferred size and refresh rate.
-- highres - use the highest supported resolution.
-- highrr - use the highest supported refresh rate.
-- maxwidth - use the widest supported resolution.

-- Fallback for external/unspecified monitors
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
