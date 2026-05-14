hl.config({
	plugin = {
		split_monitor_workspaces = {
			count = 5,
		},
	},
})

local smw = hl.plugin.split_monitor_workspaces
smw.monitor_priority({ "DP-1", "DP-2" })
