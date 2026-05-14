local programs = require("programs")
local utils = require("utils")
local mainMod = "SUPER"

hl.bind(mainMod .. "+ return", hl.dsp.exec_cmd(programs.terminal))
hl.bind(mainMod .. "+ Q", hl.dsp.window.close())
hl.bind(mainMod .. "+ E", hl.dsp.exec_cmd(programs.fileManager))
hl.bind(mainMod .. "+ F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. "+ SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(
	mainMod .. "+ M",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)
hl.bind(mainMod .. "+ P", hl.dsp.window.pseudo())
hl.bind(mainMod .. "+ J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. "+ L", utils.lock)
hl.bind(mainMod .. "+ space", hl.dsp.exec_cmd(programs.menu))
hl.bind(mainMod .. "+ escape", hl.dsp.exec_cmd(programs.powermenu))

-- Screenshot
hl.bind("CTRL + P", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind(
	mainMod .. "+ ALT + P",
	hl.dsp.exec_cmd(
		[[bash -c "hyprctl -j activewindow | jq -r '\"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])\"' | xargs -I{} grim -g {} - | wl-copy"]]
	)
)
hl.bind(mainMod .. "+ SHIFT + P", hl.dsp.exec_cmd("bash -c 'slurp | grim -g - - | wl-copy'"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. "+ left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. "+ right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. "+ up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. "+ down", hl.dsp.focus({ direction = "down" }))

-- # Switch workspaces with mainMod + [0-5]
local smw = hl.plugin.split_monitor_workspaces
for i = 1, 5 do
	local key = tostring(i)
	hl.bind(mainMod .. " + " .. key, function()
		return smw.workspace(i)
	end)
	hl.bind(mainMod .. " + SHIFT + " .. key, function()
		return smw.move_to_workspace_silent(i)
	end)
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. "+ S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Swap windows
hl.bind(mainMod .. "+ SHIFT + left", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. "+ SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. "+ SHIFT + up", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. "+ SHIFT + down", hl.dsp.window.swap({ direction = "down" }))

-- # Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. "+ mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. "+ mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Multimedia audio binds
-- code:62 = RIGHT SHIFT
-- code:105 = RIGHT CTRL
hl.bind(mainMod .. "+ Z", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind(mainMod .. "+ X", hl.dsp.exec_cmd("playerctl previous"))
hl.bind(mainMod .. "+ C", hl.dsp.exec_cmd("playerctl next"))
-- hl.bind("code:105 + code:62 + UP", hl.dsp.exec_cmd("playerctl volume 0.05+"))
-- hl.bind("code:105 + code:62 + DOWN", hl.dsp.exec_cmd("playerctl volume 0.05-"))

-- Microphone toggler
hl.bind(mainMod .. "+ F1", utils.toggle_mic)
