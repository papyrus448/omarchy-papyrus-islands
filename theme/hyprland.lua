-- Papyrus Islands: Hyprland overrides shipped with the theme.
-- Loaded by Omarchy after the stock defaults and before the user's
-- ~/.config/hypr/looknfeel.lua. The installer also writes the rounding block
-- into looknfeel.lua so these values win over personal overrides.

local active_border_color = "#89b4fa"
local inactive_border_color = "rgba(595959aa)"

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },

  decoration = {
    rounding = 8,
    dim_inactive = true,
    dim_strength = 0.15,
  },
})
