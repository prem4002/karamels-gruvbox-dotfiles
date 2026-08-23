# karamel's gruvbox rice

my Hyprland setup on Arch. Gruvbox teal, dark, soft — that's the whole vibe. this repo is
how I keep it from disappearing every time I reinstall.

![desktop](screenshots/desktop.png)

fastfetch + waybar + cava sitting on top of a pixel-art forest wallpaper, vesktop open on
the side. this is basically what my screen looks like on a normal day.

![waybar](screenshots/waybar.png)

waybar close up — workspaces on the left, a little media/tray cluster in the middle, then
network/bluetooth/battery/clock on the right. kept it minimal on purpose, I don't want a
bar that's doing too much.

## the stack

| | |
|---|---|
| OS | Arch Linux |
| WM | Hyprland 0.56 (Wayland) |
| Terminal | kitty |
| Shell | fish |
| Bar | waybar |
| Launcher | rofi |
| Notifications | dunst |
| Lockscreen | [qylock](https://github.com/Darkkal44/qylock) (quickshell-based, not mine — see below) |
| GTK theme | Gruvbox-Teal-Dark-Soft |
| Icons | WhiteSur-Dark |
| Cursor | phinger-cursors-dark |
| Font | CaskaydiaCove Nerd Font |
| Audio viz | cava |
| System info | fastfetch |

CPU's an i7-14650HX, GPU is a 4050 Max-Q, running on a laptop — so a chunk of the hypr
config is fan/perf-mode stuff, not just eye candy.

## why gruvbox teal

I wanted gruvbox's warmth without the usual orange/brown everywhere — teal reads calmer to
me and still fits the palette without clashing. soft variant because the hard-contrast
gruvbox themes felt a bit much for something I'm staring at for 8+ hours a day.

## what's actually in here

This isn't a straight copy of my `~/.config` — that folder's got 18GB of Discord/browser/
editor cache sitting in it that has nothing to do with the rice. This repo only tracks the
stuff I actually hand-configure, managed with [GNU Stow](https://www.gnu.org/software/stow/)
— every top-level folder here mirrors where it lands under `$HOME`, so `stow hypr` symlinks
`hypr/.config/hypr` straight to `~/.config/hypr`. Editing my live config *is* editing this
repo.

Full breakdown of what's tracked vs. deliberately left out, plus the day-to-day workflow for
adding new configs, is in the comments — this file's just the vibe check.

## installing this

```sh
git clone https://github.com/prem4002/karamels-gruvbox-dotfiles.git
cd karamels-gruvbox-dotfiles
./install.sh
```

Installs packages (native + AUR), stows everything into place, offers to set up the boot
theme, and clones [qylock](https://github.com/Darkkal44/qylock) for the lockscreen since
that's someone else's project I just use, not something I vendor here.

## credits

- [Gruvbox-Teal-Dark-Soft](https://www.gnome-look.org) GTK theme — committed directly in
  `gtk-theme/`, it's the actual bytes since it's a specific variant I'm not trying to
  regenerate from scratch every install
- [WhiteSur-icon-theme](https://github.com/vinceliuice/WhiteSur-icon-theme) for icons
- [phinger-cursors](https://github.com/phisch/phinger-cursors) for the cursor
- [qylock](https://github.com/Darkkal44/qylock) by Darkkal44 for the lockscreen — go check
  out the original, it's not something I built

## still on the todo list

- wallpapers aren't in the repo yet (782MB collection, only the couple hyprpaper actually
  uses need to make the cut — haven't trimmed it down)
- boot theme (GRUB) isn't snapshotted in yet either, need to grab it with sudo separately

if you're poking around this repo and something looks half-finished, that's why.
