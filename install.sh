#!/usr/bin/env bash
# install.sh — rebuild this rice on a fresh Arch install.
# Run from inside the cloned dotfiles repo: ./install.sh
# Safe-ish but not silent: it asks before anything destructive (sudo cp into /boot, /etc).

set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "== 1/5: Native packages =="
sudo pacman -S --needed - < "$REPO/packages/pacman.txt"

echo
echo "== 2/5: AUR packages =="
if ! command -v yay >/dev/null; then
  echo "yay not found. Bootstrapping it from AUR first (chicken-and-egg step)..."
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
  (cd "$tmpdir/yay" && makepkg -si)
  rm -rf "$tmpdir"
fi
yay -S --needed - < "$REPO/packages/aur.txt"

echo
echo "== 3/5: Stow all packages =="
if ! command -v stow >/dev/null; then
  sudo pacman -S --noconfirm stow
fi
cd "$REPO"
stow -t "$HOME" */
echo "Symlinked. Check with: ls -la ~/.config/hypr"

echo
echo "== 4/5: System-level bits (boot theme, sddm) — REVIEW BEFORE CONFIRMING =="
if [ -d "$REPO/system/boot/grub/themes" ]; then
  read -rp "Copy GRUB theme(s) into /boot/grub/themes and update /etc/default/grub? [y/N] " ans
  if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
    sudo cp -a "$REPO/system/boot/grub/themes/." /boot/grub/themes/
    if [ -f "$REPO/system/etc/default/grub" ]; then
      echo "Diff against your current /etc/default/grub — merge manually, don't blind-overwrite:"
      diff "$REPO/system/etc/default/grub" /etc/default/grub || true
    fi
    sudo grub-mkconfig -o /boot/grub/grub.cfg
  fi
fi
if [ -d "$REPO/system/etc/sddm.conf.d" ]; then
  read -rp "Copy sddm theme config into /etc/sddm.conf.d? [y/N] " ans
  if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
    sudo cp -a "$REPO/system/etc/sddm.conf.d/." /etc/sddm.conf.d/
  fi
fi

echo
echo "== 5/5: Services + misc setup =="
systemctl --user enable --now wireplumber.service pipewire.socket pipewire-pulse.socket p11-kit-server.socket xdg-user-dirs.service
sudo systemctl enable --now sddm.service NetworkManager
# This machine's original config had gnome-keyring-daemon's user service/socket masked
# (symlinked to /dev/null) — meaning keyring was deliberately disabled. Re-mask if you
# want that behavior again; skip if you'd rather have gnome-keyring active this time.
read -rp "Mask gnome-keyring-daemon (service+socket -> /dev/null), matching the old machine? [y/N] " ans
if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
  systemctl --user mask gnome-keyring-daemon.service gnome-keyring-daemon.socket
fi

echo
echo "Done. Log out/reboot into Hyprland via uwsm/sddm and check waybar, hyprpaper, etc."
echo "Spotify theming: run 'spicetify apply' once spotify + spicetify-cli are installed."
echo "Icon/cursor theme: whitesur-icon-theme (AUR) + phinger-cursors (AUR) — already selected"
echo "  via ~/.icons/default and gtk settings.ini in this repo."
