#!/usr/bin/env bash
# migrate.sh — populates ~/dotfiles from your CURRENT live config.
# Does NOT delete or symlink anything in place. It only COPIES.
# Run it, then `cd ~/dotfiles && git diff --stat` (after git init) to sanity check,
# then follow the stow instructions it prints at the end.

set -euo pipefail
REPO="${1:-$HOME/dotfiles}"
mkdir -p "$REPO"

copy_full() {
  # copy_full <app-name-under-.config>
  local app="$1"
  local src="$HOME/.config/$app"
  [ -d "$src" ] || { echo "skip (not found): $app"; return; }
  mkdir -p "$REPO/$app/.config"
  cp -a "$src" "$REPO/$app/.config/"
  echo "copied: .config/$app"
}

copy_file() {
  # copy_file <relative-path-from-\$HOME> <package-name>
  local rel="$1" pkg="$2"
  local src="$HOME/$rel"
  [ -e "$src" ] || { echo "skip (not found): $rel"; return; }
  local dest="$REPO/$pkg/$(dirname "$rel")"
  mkdir -p "$dest"
  cp -a "$src" "$dest/"
  echo "copied: $rel -> pkg:$pkg"
}

echo "== Full-directory app configs =="
FULL_APPS=(hypr waybar kitty dunst rofi wlogout btop cava nvim openrazer nwg-displays yay fastfetch)
for app in "${FULL_APPS[@]}"; do copy_full "$app"; done

echo
echo "== fish (excluding runtime state) =="
if [ -d "$HOME/.config/fish" ]; then
  mkdir -p "$REPO/fish/.config/fish"
  # copy everything except fish_variables / fish_history (those are runtime state, not config)
  find "$HOME/.config/fish" -mindepth 1 -maxdepth 1 \
    ! -name 'fish_variables' ! -name 'fish_history' \
    -exec cp -a {} "$REPO/fish/.config/fish/" \;
  echo "copied: .config/fish (minus fish_variables/fish_history)"
fi

echo
echo "== GTK settings.ini only (gtk-4.0 has symlinks into .themes — don't copy those) =="
for gtkver in gtk-3.0 gtk-4.0; do
  src="$HOME/.config/$gtkver/settings.ini"
  if [ -f "$src" ]; then
    mkdir -p "$REPO/$gtkver/.config/$gtkver"
    cp -a "$src" "$REPO/$gtkver/.config/$gtkver/"
    echo "copied: .config/$gtkver/settings.ini"
  fi
done

echo
echo "== spicetify (settings only, not the Themes symlink to /opt) =="
if [ -f "$HOME/.config/spicetify/config-xpui.ini" ]; then
  mkdir -p "$REPO/spicetify/.config/spicetify"
  cp -a "$HOME/.config/spicetify/config-xpui.ini" "$REPO/spicetify/.config/spicetify/"
  echo "copied: .config/spicetify/config-xpui.ini"
fi

echo
echo "== Loose files directly in ~/.config =="
LOOSE=(mimeapps.list starship.toml user-dirs.dirs user-dirs.locale QtProject.conf)
for f in "${LOOSE[@]}"; do copy_file ".config/$f" "config-misc"; done

echo
echo "== Home dotfiles (shell/git) =="
HOME_FILES=(.bashrc .zshrc .profile .bash_profile .bash_logout .gitconfig)
for f in "${HOME_FILES[@]}"; do copy_file "$f" "shell"; done

echo
echo "== ~/.local/bin scripts (excluding downloaded binaries + pipx symlink) =="
for f in env env.fish; do copy_file ".local/bin/$f" "local-bin"; done
echo "  (skipped: uv, uvx — 61MB downloaded binaries, not config)"
echo "  (skipped: git-filter-repo — symlink into a pipx venv, reinstall via pipx instead)"

echo
echo "== GTK icon/cursor theme selection =="
if [ -d "$HOME/.icons" ]; then
  mkdir -p "$REPO/icons-cursor/.icons"
  cp -a "$HOME/.icons/default" "$REPO/icons-cursor/.icons/" 2>/dev/null || true
  echo "copied: .icons/default (cursor theme pointer)"
fi

echo
echo "== Gruvbox GTK theme (small, self-authored variant — worth committing as bytes) =="
if [ -d "$HOME/.themes" ]; then
  mkdir -p "$REPO/gtk-theme/.themes"
  cp -a "$HOME/.themes/Gruvbox-Teal-Dark-Soft" "$REPO/gtk-theme/.themes/" 2>/dev/null || true
  cp -a "$HOME/.themes/Gruvbox-Teal-Dark-Soft-hdpi" "$REPO/gtk-theme/.themes/" 2>/dev/null || true
  cp -a "$HOME/.themes/Gruvbox-Teal-Dark-Soft-xhdpi" "$REPO/gtk-theme/.themes/" 2>/dev/null || true
  echo "copied: .themes/Gruvbox-Teal-Dark-Soft*"
fi

echo
echo "=============================================="
echo "Done. Nothing on your live system was touched."
echo
echo "Next steps:"
echo "  1. cd $REPO && git init && git add -A && git commit -m 'Initial dotfiles import'"
echo "  2. Review: git show --stat HEAD"
echo "  3. Install stow if needed: sudo pacman -S stow"
echo "  4. Symlink everything back in (safe — adopts identical content, no data loss):"
echo "       cd $REPO"
echo "       stow -t \"\$HOME\" --adopt */"
echo "       git diff   # should be EMPTY or trivial — if adopt pulled in a live-drifted"
echo "                  # version, this diff shows exactly what changed; git checkout . to"
echo "                  # discard live drift and keep the repo's version, or commit it."
echo "  5. Confirm symlinks landed:  ls -la ~/.config/hypr"
