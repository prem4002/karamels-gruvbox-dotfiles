# dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level folder is a
"package" that mirrors the path it should land at under `$HOME` — `hypr/.config/hypr/...`
gets symlinked to `~/.config/hypr/...` when you run `stow hypr`.

## Philosophy: allowlist, not mirror

This repo does **not** track `~/.config` wholesale. It only tracks the specific app folders
listed in `migrate.sh`. Anything not explicitly added — `Claude`, `vesktop`, `mozilla`,
`Code`, `obsidian`, browser profiles, Steam, caches — is simply never touched, so there's
nothing to exclude or gitignore for those. If you add a new app to your setup and want it
tracked, add it to `migrate.sh`'s list (or just `mkdir`/`cp -a` it into a new package folder
by hand) rather than trying to sweep in all of `.config`.

## What's in here

| package | what it is |
|---|---|
| hypr, waybar, kitty, dunst, rofi, wlogout, btop, cava, nvim | full app configs, low file count, safe to commit whole |
| fish | shell config, minus `fish_variables`/`fish_history` (runtime state) |
| gtk-3.0, gtk-4.0 | only `settings.ini` — the rest of gtk-4.0's folder is symlinks into `gtk-theme/`, not real files |
| gtk-theme | the actual Gruvbox-Teal-Dark-Soft theme bytes (~3MB, small enough to commit directly) |
| icons-cursor | `~/.icons/default/index.theme` — a 3-line pointer selecting the `phinger-cursors-dark` package, not the cursor pack itself |
| spicetify | `config-xpui.ini` only — not the `Themes` folder, which is a symlink into `/opt/spicetify-cli` (package-provided) |
| config-misc | loose files directly in `~/.config`: `mimeapps.list`, `starship.toml`, `user-dirs.dirs`, etc. |
| shell | `.bashrc .zshrc .profile .bash_profile .bash_logout .gitconfig` |
| local-bin | `env`, `env.fish` from `~/.local/bin` — not `uv`/`uvx` (61MB downloaded binaries) or `git-filter-repo` (a symlink into a pipx venv; reinstall with `pipx install git-filter-repo` instead) |
| openrazer, nwg-displays, yay, fastfetch | small app configs, committed whole |
| packages/pacman.txt, packages/aur.txt | `pacman -Qqen` / `pacman -Qqem` output — the actual package list, arguably the highest-value file in the repo |
| system/ | snapshot of things that live outside `$HOME` and can't be symlinked (GRUB theme, sddm config) — see below |
| install.sh | rebuilds everything on a fresh machine |
| migrate.sh | (not meant to be committed — it's the tool that populated this repo from the live system) |

## Deliberately excluded, and why

- **`Claude`, `vesktop`, `mozilla`, `Code`, `Code - OSS`, `obsidian`, `libreoffice`** — these
  are app profile/cache directories, not hand-edited config. Thousands of files, gigabytes
  of IndexedDB/session data/vault content. If you want editor settings tracked, cherry-pick
  `Code/User/settings.json` and `keybindings.json` specifically rather than the whole folder.
- **`~/.claude.json`** — contains session/auth data. Never commit this, anywhere.
- **Steam, pnpm/uv caches, `.cargo`, `.npm`** — package manager and game caches, fully
  regenerable, huge.
- **Wallpapers** — kept out of this repo on purpose (782MB across a personal collection).
  If your hyprpaper/swww config references specific wallpaper files, copy just those into
  a small `wallpapers/` package; keep the rest as a separate synced folder.

## Boot theme / sddm (`system/`)

These live outside `$HOME` (`/boot`, `/etc`) so Stow can't symlink them — root-owned paths
read before your home directory is even mounted. Instead they're kept as **copies** under
`system/boot/...` and `system/etc/...`, applied by `install.sh` with an explicit
confirmation prompt and a `diff` against whatever's already on the target machine before
anything is overwritten. This is one-directional: if you tweak your GRUB theme later,
manually re-copy it into the repo (`cp -a /boot/grub/themes/OldBIOS system/boot/grub/themes/`)
— there's no live sync.

You currently have both GRUB and systemd-boot present with entries. If that's leftover from
switching bootloaders at some point rather than intentional dual-boot management, worth
picking one and removing the other's entries — right now both `install.sh` and any manual
setup should treat GRUB as the one actually in use, since `/etc/default/grub` sets
`GRUB_THEME`.

## External: lockscreen (qylock)

Uses [Darkkal44/qylock](https://github.com/Darkkal44/qylock), cloned separately to `~/qylock`,
not vendored in this repo. `~/.local/share/quickshell-lockscreen/themes_link` symlinks to
`~/qylock/themes`. `install.sh` clones it automatically on a fresh machine.

## Day-to-day workflow

Adding a new app's config:
```sh
mkdir -p ~/dotfiles/newapp/.config/newapp
cp -a ~/.config/newapp/* ~/dotfiles/newapp/.config/newapp/
cd ~/dotfiles && stow --adopt -t ~ newapp   # symlinks it, seeding from what you just copied
git add newapp && git commit -m "track newapp config"
```

Editing an already-tracked config: just edit the file at its normal path
(`~/.config/hypr/hyprland.conf`) — it's a symlink into the repo, so you're editing the repo
file directly. `cd ~/dotfiles && git status` to see what changed, commit as usual.

Removing a package: `stow -D -t ~ appname` un-symlinks it and restores nothing (the repo
copy stays; delete the folder + commit if you want it gone for good).

Fresh machine: clone this repo, run `./install.sh`.

## Package list maintenance

Regenerate when your installed packages drift from what's committed:
```sh
pacman -Qqen > packages/pacman.txt   # native, explicitly installed
pacman -Qqem > packages/aur.txt      # foreign (AUR)
```

## If something huge ever gets committed by accident

You already have `git-filter-repo` installed (`~/.local/bin/git-filter-repo`, via pipx).
That's the right tool — `git-filter-repo --path .config/Claude --invert-paths` (run on a
fresh clone, then force-push) strips a path from all of history. Cheaper to just not commit
it in the first place, which is what the allowlist in `migrate.sh` is for.
