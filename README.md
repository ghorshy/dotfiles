# Dotfiles

My personal config.
This repo contains all the scripts, configs, and tweaks.
Only tested with **Arch Linux** (should also work with any of it's deriatives).

## What’s Inside

A collection of configuration files for:
- **hyprland** window manager
- **waybar**
- **mako** notification daemon
- **kitty** terminal
- **zsh** shell with **powerlevel10k** theme
- **neovim** with **LazyVim** config
- **rofi** app launcher
- **Thunar** file manager
- **Limine** bootloader with Snapper snapshots for btrfs
- beautiful **KDE** and **GTK** theme by vinceliuice
- automatic USB mount with **udiskie**
- **Bluetooth** support with **blueman**
- **hyprsplit** plugin for dwm-like workspaces

## Installation

This repo uses **chezmoi** as dotfile manager.

Simply use

```bash
chezmoi init https://github.com/ghorshy/dotfiles.git
```

and then run the install script to install my favorite hand-picked programs that work best with my workflow

**BE SURE TO CHECK WHAT'S INSIDE, FEEL FREE TO ADJUST IT FOR YOUR OWN NEEDS**
```bash
./install.sh
```
