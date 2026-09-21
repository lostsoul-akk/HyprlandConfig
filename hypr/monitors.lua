------------------
---- MONITORS ----
------------------

-- Primary Laptop Display
hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "0x0",
    scale    = 1,
})

-- Fallback for external/unspecified monitors
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
