for d in hypr waybar kitty dunst rofi; do
  find "$d" -mindepth 1 -maxdepth 1 ! -name '.config' -exec rm -rf {} +
done