#!/bin/bash

dir="$HOME/.config/rofi/themes"
theme='powermenu'

# Options
shutdown=''
reboot=''
lock=''
suspend='󰏤'
logout='󰗽'
yes='󰸞'
no=''

rofi_cmd() {
  rofi -dmenu \
    -theme ${dir}/${theme}.rasi
}

confirm_cmd() {
  rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 200px;}' \
    -theme-str 'mainbox {children: [ "message", "listview" ];}' \
    -theme-str 'listview {columns: 2; lines: 1;}' \
    -theme-str 'element-text {horizontal-align: 0.5;}' \
    -theme-str 'textbox {horizontal-align: 0.5;}' \
    -dmenu \
    -p 'Confirmation' \
    -mesg 'Are you sure?' \
    -theme ${dir}/${theme}.rasi \
    -click-to-exit
}

confirm_exit() {
  echo -e "$yes\n$no" | confirm_cmd
}

run_rofi() {
  echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
  selected="$(confirm_exit)"
  if [[ "$selected" == "$yes" ]]; then
    if [[ $1 == '--shutdown' ]]; then
      systemctl poweroff
    elif [[ $1 == '--reboot' ]]; then
      systemctl reboot
    elif [[ $1 == '--suspend' ]]; then
      mpc -q pause
      amixer set Master mute
      hyprlock --display DP-2 &
      sleep 0.2
      systemctl suspend
    elif [[ $1 == '--logout' ]]; then
      hyprctl dispatch exit
    fi
  else
    exit 0
  fi
}

chosen="$(run_rofi)"
case ${chosen} in
$shutdown)
  run_cmd --shutdown
  ;;
$reboot)
  run_cmd --reboot
  ;;
$lock)
  hyprlock
  ;;
$suspend)
  run_cmd --suspend
  ;;
$logout)
  run_cmd --logout
  ;;
esac
