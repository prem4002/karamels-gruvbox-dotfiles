#wallswitch.sh
#!/usr/bin/env bash
MONITOR="eDP-2"
STATE_FILE="$HOME/.cache/hyprpaper_wallpaper_index"

# Detect the external monitor dynamically (anything that isn't eDP-2)
EXTERNAL_MONITOR=$(hyprctl monitors -j | jq -r --arg laptop "$MONITOR" '.[] | select(.name != $laptop) | .name' | head -n1)

# =================== wallpaper =============================
edp_wallpapers=(
  "/home/prem/Pictures/Wallpapers/Pokemon/reshiram_cropped.jpg"
  "/home/prem/Pictures/Wallpapers/Pokemon/Ho-Oh.jpg"
  "/home/prem/Pictures/Wallpapers/Gruvbox/leaves-hard-pixelated.png"
  "/home/prem/Pictures/Wallpapers/Gruvbox/secluded-grove-pixel.png"
  "/home/prem/Pictures/Wallpapers/Gruvbox/mit_asteroiden_treiben.jpeg"
  "/home/prem/Pictures/Wallpapers/Gruvbox/black-hole.png"
)

# External screen wallpapers (used for whatever monitor is detected — HDMI-A-1, DP-2, etc.)
external_wallpapers=(
  "/home/prem/Pictures/Wallpapers/Pokemon/Ho-Oh.jpg"
  "/home/prem/Pictures/Wallpapers/Pokemon/reshiram_cropped.jpg"
  "/home/prem/Pictures/Wallpapers/Gruvbox/secluded-grove-pixel.png"
  "/home/prem/Pictures/Wallpapers/Gruvbox/leaves-hard-pixelated.png"
  "/home/prem/Pictures/Wallpapers/Gruvbox/black-hole.png"
  "/home/prem/Pictures/Wallpapers/Gruvbox/mit_asteroiden_treiben.jpeg"
)
# ===========================================================

# Init state file
[[ ! -f "$STATE_FILE" ]] && echo 0 > "$STATE_FILE"
index=$(<"$STATE_FILE")
count=${#edp_wallpapers[@]}

# Next wallpaper
index=$(( (index + 1) % count ))
echo "$index" > "$STATE_FILE"

edp_wallpaper="${edp_wallpapers[$index]}"
external_wallpaper="${external_wallpapers[$index]}"

# Preload laptop wallpaper always
hyprctl hyprpaper preload "$edp_wallpaper"
hyprctl hyprpaper wallpaper "$MONITOR,$edp_wallpaper"

# Only touch external monitor if one is actually connected
if [[ -n "$EXTERNAL_MONITOR" ]]; then
  hyprctl hyprpaper preload "$external_wallpaper"
  hyprctl hyprpaper wallpaper "$EXTERNAL_MONITOR,$external_wallpaper"
fi

# Cleanup
hyprctl hyprpaper unload unused
