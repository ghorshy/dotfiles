#!/bin/bash
~/.config/hypr/scripts/mic.sh --save
~/.config/hypr/scripts/mic.sh --mute
hyprlock
~/.config/hypr/scripts/mic.sh --restore
