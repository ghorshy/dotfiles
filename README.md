# Dotfiles

My personal configuration for a Hyprland-based Arch Linux desktop.
Only tested on **Arch Linux** and its derivatives.

## What's Inside

| Category | Tools |
|---|---|
| **Window Manager** | [Hyprland](https://github.com/hyprwm/Hyprland), [hyprlock](https://github.com/hyprwm/hyprlock), [hypridle](https://github.com/hyprwm/hypridle), [hyprpaper](https://github.com/hyprwm/hyprpaper) |
| **Bar & Notifications** | [waybar](https://github.com/Alexays/Waybar), [mako](https://github.com/emersion/mako) |
| **App Launcher** | [rofi](https://github.com/davatorium/rofi) with emoji and calc plugins |
| **Terminal** | [kitty](https://github.com/kovidgoyal/kitty) |
| **Shell** | [zsh](https://www.zsh.org) with [powerlevel10k](https://github.com/romkatv/powerlevel10k), [zoxide](https://github.com/ajeetdsouza/zoxide), [eza](https://github.com/eza-community/eza), [bat](https://github.com/sharkdp/bat), [fzf](https://github.com/junegunn/fzf), [fastfetch](https://github.com/fastfetch-cli/fastfetch), [lazygit](https://github.com/jesseduffield/lazygit), [btop](https://github.com/aristocratos/btop) |
| **Editor** | [neovim](https://github.com/neovim/neovim) with [LazyVim](https://github.com/LazyVim/LazyVim) |
| **File Managers** | [Thunar](https://gitlab.xfce.org/xfce/thunar), [yazi](https://github.com/sxyazi/yazi) |
| **Image Viewer** | [qimgv](https://github.com/easymodo/qimgv) |
| **Theme** | Graphite [KDE](https://github.com/vinceliuice/Graphite-kde-theme) & [GTK](https://github.com/vinceliuice/Graphite-gtk-theme) theme by [vinceliuice](https://github.com/vinceliuice), [Bibata](https://github.com/ful1e5/Bibata_Cursor) cursor, [Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) icons |
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
~/.local/share/chezmoi/setup.sh
```

> **Check the script before running it** and adjust it to your needs.

**3. Set up your displays** in `~/.config/hypr/hyprland.conf`.
