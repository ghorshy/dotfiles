local STATE_FILE = "/tmp/mic_state"

local function mute_mic()
	os.execute("pamixer --default-source --mute")
end

local function unmute_mic()
	os.execute("pamixer --default-source --unmute")
end

local function toggle_mic()
	os.execute("pamixer --default-source -t")
end

local function save_mic_state()
	local handle = io.popen("pamixer --default-source --get-mute")
	if not handle then return end
	local result = handle:read("*a")
	handle:close()
	local f = io.open(STATE_FILE, "w")
	if not f then return end
	f:write(result:match("true") and "muted" or "unmuted")
	f:close()
end

local function restore_mic_state()
	local f = io.open(STATE_FILE, "r")
	if not f then
		return
	end
	local state = f:read("*a")
	f:close()
	os.remove(STATE_FILE)
	if state == "muted" then
		mute_mic()
	else
		unmute_mic()
	end
end

local function lock()
	local handle = io.popen("pamixer --default-source --get-mute")
	if not handle then return end
	local result = handle:read("*a")
	handle:close()
	local restore = result:match("true") and "pamixer --default-source --mute" or "pamixer --default-source --unmute"
	os.execute("pamixer --default-source --mute")
	hl.exec_cmd("hyprlock; " .. restore)
end

local function read_cmd(cmd)
	local handle = io.popen(cmd)
	if not handle then return "" end
	local result = handle:read("*a")
	handle:close()
	return result
end

local function shell_quote(s)
	return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function audio_switch()
	local sinks = {}
	for name in read_cmd("pactl list short sinks"):gmatch("%f[^\n]%d+\t([^\t]+)") do
		if name:match("^alsa_output%.usb%-FiiO_") or name:match("^alsa_output%.usb%-PreSonus_") then
			table.insert(sinks, name)
		end
	end
	if #sinks == 0 then return end

	local current = read_cmd("pactl get-default-sink"):gsub("%s+$", "")
	local next_sink = sinks[1]
	for i, name in ipairs(sinks) do
		if name == current then
			next_sink = sinks[i % #sinks + 1]
			break
		end
	end

	os.execute("pactl set-default-sink " .. shell_quote(next_sink))
	for input in read_cmd("pactl list short sink-inputs"):gmatch("%f[^\n](%d+)\t") do
		os.execute("pactl move-sink-input " .. input .. " " .. shell_quote(next_sink))
	end

	local desc = next_sink
	local in_sink = false
	for line in read_cmd("pactl list sinks"):gmatch("[^\n]+") do
		local name = line:match("^%s*Name: (.+)$")
		if name then in_sink = name == next_sink end
		local d = in_sink and line:match("^%s*Description: (.+)$")
		if d then
			desc = d
			break
		end
	end
	hl.exec_cmd(
		"notify-send -a Audio -h string:x-canonical-private-synchronous:audio-switch -i audio-speakers 'Audio output' "
			.. shell_quote(desc)
	)
end

return {
	toggle_mic = toggle_mic,
	mute_mic = mute_mic,
	unmute_mic = unmute_mic,
	save_mic_state = save_mic_state,
	restore_mic_state = restore_mic_state,
	lock = lock,
	audio_switch = audio_switch,
}
