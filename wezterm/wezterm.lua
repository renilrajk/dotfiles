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
config.window_close_confirmation = "AlwaysPrompt"
config.scrollback_lines = 900000
config.default_workspace = "home"
config.color_scheme = "Catppuccin Mocha" --or Mocha, Macchiato, Frappe, Latte" --"Solar Flare (base16)" --"Gogh (Gogh)" --"Solar Flare (base16)" --"Sandcastle (base16)"
config.enable_tab_bar = false
config.use_fancy_tab_bar = false
config.status_update_interval = 1000
-- config.default_cwd = "$HOME/VMware/dsm"

-- Dim inactive panes
config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.9,
}

-- leader key
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

-- key bindings
config.keys = {
	-- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
	{ key = "a", mods = "LEADER", action = wezterm.action.SendKey({ key = "a", mods = "CTRL" }) },
	{ key = "|", mods = "LEADER|SHIFT ", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "h", mods = "CTRL", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "CTRL", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "CTRL", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "CTRL", action = act.ActivatePaneDirection("Down") },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "s", mods = "LEADER", action = act.RotatePanes("Clockwise") },
	{ key = "i", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },

	-- Tab keybindings
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
	{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
	{ key = "w", mods = "LEADER", action = act.ShowTabNavigator },

	-- move tabs around
	{ key = "m", mods = "LEADER", action = act.ActivateKeyTable({ name = "move_tab", one_shot = false }) },

	-- workspaces
	{ key = "S", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
}

for i = 1, 9 do
	table.insert(config.keys, { key = tostring(i), mods = "LEADER", action = act.ActivateTab(i - 1) })
end

config.key_tables = {
	resize_pane = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 5 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 3 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 3 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 5 }) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
	move_tab = {
		{ key = "h", action = act.MoveTabRelative(-1) },
		{ key = "j", action = act.MoveTabRelative(-1) },
		{ key = "k", action = act.MoveTabRelative(1) },
		{ key = "l", action = act.MoveTabRelative(1) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
}

wezterm.on("update-right-status", function(window, pane)
	local stat = window:active_workspace()
	if window:active_key_table() then
		stat = window:active_key_table()
	end
	if window:leader_is_active() then
		stat = "LDR"
	end

	local time = wezterm.strftime("%H:%M")

	window:set_right_status(wezterm.format({
		{ Text = wezterm.nerdfonts.oct_table .. " " .. stat },
		{ Text = " | " },
		{ Text = wezterm.nerdfonts.md_clock .. " " .. time },
	}))
end)

-- and finally, return the configuration to wezterm
return config
