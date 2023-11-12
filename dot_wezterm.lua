local wezterm = require("wezterm")
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

return {
	-- colorscheme
	color_scheme = "nord",

	-- font configuration
	font = wezterm.font("Anonymice Nerd Font", { weight = "Regular", stretch = "Expanded", style = "Normal" }),
	font_size = 14,
	use_ime = true,
	audible_bell = "Disabled",

	disable_default_key_bindings = true,
	keys = {
		-- line word navigation using "alt"+left/right
		{ key = "LeftArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bb" }) },
		{ key = "RightArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bf" }) },

		-- tab navigation
		{ key = "t", mods = "SUPER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
		{ key = "Tab", mods = "CTRL", action = wezterm.action.ActivateTabRelative(1) },
		{ key = "Tab", mods = "SHIFT|CTRL", action = wezterm.action.ActivateTabRelative(-1) },
		{ key = "Enter", mods = "ALT", action = wezterm.action.ToggleFullScreen },

		-- pane navigation (bind on cltr+shift to avoid conflicts with common editing actions
		{ key = "t", mods = "CTRL|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "x", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
		{ key = "w", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Next") },

		-- "standard" app shortcuts based on cmd key
		{ key = "-", mods = "SUPER", action = wezterm.action.DecreaseFontSize },
		{ key = "+", mods = "SUPER", action = wezterm.action.IncreaseFontSize },
		{ key = "q", mods = "SUPER", action = wezterm.action.QuitApplication },
		{ key = "c", mods = "SUPER", action = wezterm.action.CopyTo("Clipboard") },
		{ key = "v", mods = "SUPER", action = wezterm.action.PasteFrom("Clipboard") },

		{ key = "L", mods = "SHIFT|CTRL", action = wezterm.action.ShowDebugOverlay },
		{ key = "f", mods = "SUPER", action = wezterm.action.Search("CurrentSelectionOrEmptyString") },
	},
}
