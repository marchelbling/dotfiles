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
	-- font = wezterm.font("AnonymicePro Nerd Font", { weight = "Regular", stretch = "Expanded", style = "Normal" }),
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
		{ mods = "CTRL|SHIFT", key = "h", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ mods = "CTRL|SHIFT", key = "v", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ mods = "CTRL|SHIFT", key = "x", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
		{ mods = "CTRL|SHIFT", key = "w", action = wezterm.action.ActivatePaneDirection("Next") },
		{ mods = "CTRL|SHIFT", key = "LeftArrow", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
		{ mods = "CTRL|SHIFT", key = "RightArrow", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
		{ mods = "CTRL|SHIFT", key = "UpArrow", action = wezterm.action.AdjustPaneSize({ "Up", 3 }) },
		{ mods = "CTRL|SHIFT", key = "DownArrow", action = wezterm.action.AdjustPaneSize({ "Down", 3 }) },

		-- "standard" app shortcuts based on cmd key
		{ mods = "SUPER", key = "-", action = wezterm.action.DecreaseFontSize },
		{ mods = "SUPER", key = "+", action = wezterm.action.IncreaseFontSize },
		{ mods = "SUPER", key = "q", action = wezterm.action.QuitApplication },
		{ mods = "SUPER", key = "c", action = wezterm.action.CopyTo("Clipboard") },
		{ mods = "SUPER", key = "v", action = wezterm.action.PasteFrom("Clipboard") },

		{ key = "L", mods = "SHIFT|CTRL", action = wezterm.action.ShowDebugOverlay },
		{ key = "f", mods = "SUPER", action = wezterm.action.Search("CurrentSelectionOrEmptyString") },
	},
}
