# Dotfiles

My personal configuration for a Hyprland-based Arch Linux desktop.
Only tested on **Arch Linux** and its derivatives.

## What's Inside

| Category | Tools |
|---|---|
| **Window Manager** | [Hyprland](https://github.com/hyprwm/Hyprland), [hyprlock](https://github.com/hyprwm/hyprlock), [hypridle](https://github.com/hyprwm/hypridle), [hyprpaper](https://github.com/hyprwm/hyprpaper) |
| **Shell (bar, notifications, OSD, power menu, app launcher)** | [Quickshell](https://quickshell.org) |
| **Calculator** | [libqalculate](https://github.com/Qalculate/libqalculate) (qalc), in the Quickshell launcher |
| **Terminal** | [kitty](https://github.com/kovidgoyal/kitty) |
| **Shell** | [zsh](https://www.zsh.org) with [powerlevel10k](https://github.com/romkatv/powerlevel10k), [zoxide](https://github.com/ajeetdsouza/zoxide), [eza](https://github.com/eza-community/eza), [bat](https://github.com/sharkdp/bat), [fzf](https://github.com/junegunn/fzf), [fastfetch](https://github.com/fastfetch-cli/fastfetch), [lazygit](https://github.com/jesseduffield/lazygit), [btop](https://github.com/aristocratos/btop) |
| **Editor** | [neovim](https://github.com/neovim/neovim) with [LazyVim](https://github.com/LazyVim/LazyVim) |
| **File Managers** | [Thunar](https://gitlab.xfce.org/xfce/thunar), [yazi](https://github.com/sxyazi/yazi) |
| **Image Viewer** | [qimgv](https://github.com/easymodo/qimgv) |
| **Theme** | Bazalth [Qt](https://github.com/ghorshy/Bazalth-QT) and [GTK](https://github.com/ghorshy/Bazalth-GTK) themes (built from the same palette), [Bibata](https://github.com/ful1e5/Bibata_Cursor) cursor, [Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) icons |
| **Bluetooth & USB** | [blueman](https://github.com/blueman-project/blueman), [udiskie](https://github.com/coldfix/udiskie) |
| **Bootloader** | [Limine](https://github.com/limine-bootloader/limine) with [Snapper](https://github.com/openSUSE/snapper) for btrfs snapshots, [limine-snapper-sync](https://gitlab.com/Zesko/limine-snapper-sync) for automatic boot entry sync |
| **Dev Tools** | dotnet SDK, Zed, npm, [Godot](https://github.com/godotengine/godot) |
| **Apps** | KeePassXC, KDE Connect, OBS, Steam, Discord, Zen Browser, yt-dlp |

## Installation

This repo uses **chezmoi** as the dotfile manager.

**1. Initialize and apply dotfiles:**
```bash
chezmoi init https://github.com/ghorshy/dotfiles.git
chezmoi apply
```

**2. Run the install script** to set up packages (interactive — each section is opt-in):
```bash
~/setup.sh
```

> **Check the script before running it** and adjust it to your needs.

**3. Set up your displays** in `~/.config/hypr/monitors.lua`. Use `hyprctl monitors` to see their specs.
Machine-specific files (monitors, wallpapers, workspaces, autostart) are chezmoi templates; hosts listed
under `laptops` in `.chezmoidata/hosts.toml` get the laptop variant, every other host the desktop one.

## Theme

Colors, fonts, corner radius, border width and the icon theme live in a single file:
`.chezmoidata/theme.toml`. Hyprland, hyprlock, Quickshell and kitty are generated from it,
so after changing it run `chezmoi apply`; Quickshell reloads by itself. If you need to restart it,
start it through Hyprland so it stays in the logind session (otherwise locking and suspend fail):
`qs kill; hyprctl dispatch 'hl.dsp.exec_cmd("qs")'`.
