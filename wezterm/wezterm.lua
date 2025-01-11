-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

-- This will hold the configuration.
local config = wezterm.config_builder()

config.font_size = 14
config.font = wezterm.font_with_fallback({
	{ family = "JetBrainsMono Nerd Font", scale = 1 },
})
config.window_background_opacity = 1
config.window_decorations = "RESIZE"
config.scrollback_lines = 900000
config.default_workspace = "home"
config.color_scheme = "Catppuccin Mocha" --or Mocha, Macchiato, Frappe, Latte" --"Solar Flare (base16)" --"Gogh (Gogh)" --"Solar Flare (base16)" --"Sandcastle (base16)"
config.hide_tab_bar_if_only_one_tab = true
config.status_update_interval = 1000
config.max_fps = 120
config.default_cwd = "$HOME/VMware"
config.front_end = "WebGpu"
config.native_macos_fullscreen_mode = false

-- Dim inactive panes
config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.8,
}

-- leader key
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

-- key bindings
config.keys = {
	-- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
	{ key = "a", mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },
	{ key = "|", mods = "LEADER|SHIFT ", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "h", mods = "CTRL", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "CTRL", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "CTRL", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "CTRL", action = act.ActivatePaneDirection("Down") },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "s", mods = "LEADER", action = act.RotatePanes("Clockwise") },
	{ key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
	{ key = "A", mods = "CTRL|SHIFT", action = act.QuickSelect },

	-- Tab keybindings
	{ key = "w", mods = "LEADER", action = act.ShowTabNavigator },

	-- move tabs around
	{ key = "m", mods = "LEADER", action = act.ActivateKeyTable({ name = "move_tab", one_shot = false }) },

	-- workspaces
	{ key = "W", mods = "LEADER|SHIFT", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
}

config.key_tables = {
	resize_pane = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 5 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 3 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 3 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 5 }) },
		{ key = "Escape", action = "PopKeyTable" },
	},
	move_tab = {
		{ key = "h", action = act.MoveTabRelative(-1) },
		{ key = "j", action = act.MoveTabRelative(-1) },
		{ key = "k", action = act.MoveTabRelative(1) },
		{ key = "l", action = act.MoveTabRelative(1) },
		{ key = "Escape", action = "PopKeyTable" },
	},
}

-- and finally, return the configuration to wezterm
return config
