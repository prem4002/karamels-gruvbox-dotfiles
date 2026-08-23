#!/usr/bin/env bash
# Reports current game-mode state as JSON for Waybar's custom module.

STATE_FILE="/tmp/hypr-gamemode-state"

if [[ -f "$STATE_FILE" ]]; then
    echo '{"text":"🎮","class":"active","tooltip":"Game mode: ON — click to restore blur/animations"}'
else
    echo '{"text":"🎮","class":"inactive","tooltip":"Game mode: OFF — click to disable blur/animations"}'
fi