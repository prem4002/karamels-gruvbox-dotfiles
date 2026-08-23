#!/usr/bin/env bash
# Toggles blur + animations off/on at runtime via hyprctl eval.
# Bind this to a Waybar button (or a keybind) to get a one-click "game mode".

STATE_FILE="/tmp/hypr-gamemode-state"

if [[ -f "$STATE_FILE" ]]; then
    # currently in game mode -> turn eye candy back on
    hyprctl eval 'hl.config({ decoration = { blur = { enabled = true }, active_opacity = 0.92, inactive_opacity = 0.82 }, animations = { enabled = true } })' >/dev/null
    rm -f "$STATE_FILE"
else
    # not in game mode -> turn eye candy off, and flatten opacity so windows
    # don't render as raw see-through with no blur behind them
    hyprctl eval 'hl.config({ decoration = { blur = { enabled = false }, active_opacity = 1.0, inactive_opacity = 1.0 }, animations = { enabled = false } })' >/dev/null
    touch "$STATE_FILE"
fi

# Tell Waybar to re-run the status script immediately instead of waiting for its interval
pkill -RTMIN+8 waybar