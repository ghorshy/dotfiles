#!/bin/bash

STATE_FILE="/tmp/mic_state"

toggle_mic() {
  pamixer --default-source -t
}

mute_mic() {
  pamixer --default-source --mute
}

unmute_mic() {
  pamixer --default-source --unmute
}

save_mic_state() {
  if pamixer --default-source --get-mute | grep -q "true"; then
    echo "muted" >"$STATE_FILE"
  else
    echo "unmuted" >"$STATE_FILE"
  fi
}

restore_mic_state() {
  if [[ -f "$STATE_FILE" ]]; then
    state=$(cat "$STATE_FILE")
    if [[ "$state" == "muted" ]]; then
      mute_mic
    else
      unmute_mic
    fi
    rm "$STATE_FILE"
  fi
}

case "$1" in
--toggle) toggle_mic ;;
--mute) mute_mic ;;
--unmute) unmute_mic ;;
--save) save_mic_state ;;
--restore) restore_mic_state ;;
esac
