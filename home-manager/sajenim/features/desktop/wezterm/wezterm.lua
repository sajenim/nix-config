-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Log warnings or generate errors if we define an invalid configuration option
local config = wezterm.config_builder()

--
-- General configuration options.
--

-- Do not check for or show window with update information
config.check_for_updates = false

-- Improve wezterm graphical performance 
config.front_end = "OpenGL"
config.max_fps = 144
config.animation_fps = 144

-- Font configuration
config.font = wezterm.font("Fisa Code")
config.font_size = 10.0

-- Enable gruvbox colour scheme
config.color_scheme = "gruvbox_material_dark_medium"

-- Pad window borders
config.window_padding = {
	left = 10,
	right = 10,
	top = 10,
	bottom = 10,
}

--
-- Tab bar configuration options.
--

-- Disable modern tab bar
config.use_fancy_tab_bar = false
config.tab_max_width = 32

-- Tab bar colors
config.colors = {
	tab_bar = {
		background = "#32302f",
		active_tab = {
			bg_color = "#32302f",
			fg_color = "#7daea3",
			intensity = "Bold",
			italic = true,
		},
		inactive_tab = {
			bg_color = "#32302f",
			fg_color = "#a89984",
			intensity = "Bold",
			italic = true,
		},
		inactive_tab_hover = {
			bg_color = "#32302f",
			fg_color = "#a89984",
			intensity = "Bold",
			italic = true,
		},
		new_tab = {
			bg_color = "#32302f",
			fg_color = "#a89984",
			intensity = "Bold",
			italic = true,
		},
		new_tab_hover = {
			bg_color = "#32302f",
			fg_color = "#a89984",
			intensity = "Bold",
			italic = true,
		},
	},
}

--
-- Keymaps configuration.
--

-- Disable the default keybindings
config.disable_default_key_bindings = true

-- Setup leader key
config.leader = { key = "a", mods = "ALT", timeout_milliseconds = 2000 }

-- General keymaps
config.keys = {
	--
	-- Enter key table modes
	--

	{ -- Enter tab management mode
		key = "t",
		mods = "LEADER",
		action = wezterm.action.ActivateKeyTable({
			name = "tab_mode",
			one_shot = true,
		}),
	},

	{ -- Enter pane management mode
		key = "p",
		mods = "LEADER",
		action = wezterm.action.ActivateKeyTable({
			name = "pane_mode",
			one_shot = true,
		}),
	},

	--
	-- Navigation
	--

	{ -- Focus previous tab
		key = "LeftArrow",
		mods = "ALT",
		action = wezterm.action.ActivateTabRelative(-1),
	},

	{ -- Focus next tab
		key = "RightArrow",
		mods = "ALT",
		action = wezterm.action.ActivateTabRelative(1),
	},

	{ -- Focus previous pane
		key = "UpArrow",
		mods = "ALT",
		action = wezterm.action.ActivatePaneDirection("Prev"),
	},

	{ -- Focus next pane
		key = "DownArrow",
		mods = "ALT",
		action = wezterm.action.ActivatePaneDirection("Next"),
	},

	{ -- Rotate panes counter-clockwise
		key = "PageUp",
		mods = "ALT",
		action = wezterm.action.RotatePanes("CounterClockwise"),
	},

	{ -- Rotate panes clockwise
		key = "PageDown",
		mods = "ALT",
		action = wezterm.action.RotatePanes("Clockwise"),
	},

	--
	-- Copy / Paste
	--

	{ -- Enter copy mode
		key = "Escape",
		mods = "LEADER",
		action = wezterm.action.ActivateCopyMode,
	},

	{ -- Paste from clipboard
		key = "v",
		mods = "CTRL|SHIFT",
		action = wezterm.action.PasteFrom("Clipboard"),
	},

	--
	-- Miscellaneous
	--

	{ -- This lets us unify delete word across programs
		key = "Backspace",
		mods = "CTRL",
		action = wezterm.action.SendKey({ key = "w", mods = "CTRL" }),
	},
}

--
-- Key table definitions for modal keybinding namespaces
--

config.key_tables = {
	-- Tab management mode (LEADER + t)
	tab_mode = {
		{ -- Create new tab
			key = "n",
			action = wezterm.action.SpawnTab("CurrentPaneDomain"),
		},
		{ -- Close current tab
			key = "q",
			action = wezterm.action.CloseCurrentTab({ confirm = false }),
		},
		{ -- Rename current tab
			key = "r",
			action = wezterm.action_callback(function(window, pane)
				local success, stdout, stderr = wezterm.run_child_process({
					"dmenu",
					"-fn",
					"Fisa Code-10",
					"-p",
					"Tab name:",
				})
				if success and stdout then
					local name = stdout:gsub("\n", "")
					if name ~= "" then
						window:active_tab():set_title(name)
					end
				end
			end),
		},
	},

	-- Pane management mode (LEADER + p)
	pane_mode = {
		{ -- Split pane vertically (bottom, 30%)
			key = "s",
			action = wezterm.action.SplitPane({
				direction = "Down",
				size = { Percent = 30 },
			}),
		},
		{ -- Split pane horizontally (left, 28%)
			key = "v",
			action = wezterm.action.SplitPane({
				direction = "Left",
				size = { Percent = 28 },
			}),
		},
		{ -- Close current pane
			key = "q",
			action = wezterm.action.CloseCurrentPane({ confirm = false }),
		},
		{ -- Maximize/zoom pane
			key = "m",
			action = wezterm.action.TogglePaneZoomState,
		},
	},
}

-- Jump to specific tabs by number (ALT + 1-9)
for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "ALT",
		action = wezterm.action.ActivateTab(i - 1),
	})
end

return config
