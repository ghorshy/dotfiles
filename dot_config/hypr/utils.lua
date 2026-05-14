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

return {
	toggle_mic = toggle_mic,
	mute_mic = mute_mic,
	unmute_mic = unmute_mic,
	save_mic_state = save_mic_state,
	restore_mic_state = restore_mic_state,
	lock = lock,
}
