hl.window_rule({ match = { class = "org.kde.kdeconnect.app" }, float = true })
hl.window_rule({ match = { class = "blueman-manager" }, float = true })
hl.window_rule({ match = { class = "thunar" }, float = true })
hl.window_rule({ match = { class = "nm-connection-editor" }, float = true })
hl.window_rule({ match = { class = "engrampa" }, float = true })
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" }, float = true })
hl.window_rule({ match = { class = "org.gnome.Calendar" }, float = true })
hl.window_rule({ match = { class = "xdg-desktop-portal-gtk", title = "(?i).*pick files.*" }, float = true })
hl.window_rule({ match = { class = "nm-openconnect-auth-dialog" }, float = true })
hl.window_rule({ match = { class = "steam", title = "Friends List" }, float = true })

hl.window_rule({
	name = "thunar-noscreenshare",
	match = { class = "thunar" },
	no_screen_share = true,
})

hl.window_rule({ match = { class = "discord", workspace = "8 silent" } })
hl.window_rule({ match = { class = "steam", workspace = "9 silent" } })

local suppressMaximizeRule = hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})
suppressMaximizeRule:is_enabled(true)

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, rounding = 0 })
