#!/bin/bash

# TODO: like in Omarchy make auto-login and a Plymouth theme

# Shell & Terminal Tools
packages+=(
  zsh
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-theme-powerlevel10k-git
  zoxide
  eza
  bat
  fastfetch
  lazygit
  btop
  fzf
  unzip
  unrar
  wl-clipboard
  wtype
)

# Fonts
packages+=(
  inter-font
  noto-fonts-emoji
  ttf-font-awesome
  ttf-jetbrains-mono
)

# Wayland / Hyprland
packages+=(
  hypridle
  hyprlock
  hyprpaper
  xdg-desktop-portal-hyprland
  qt5-wayland
  qt6-wayland
  qt5ct
)

# File Management
packages+=(
  thunar
  thunar-archive-plugin
  thunar-volman
  engrampa
  udiskie
  yazi
)

# UI / UX / Looks
packages+=(
  waybar
  nwg-look
  mako
  papirus-icon-theme
)

# App Launchers (Rofi)
packages+=(
  rofi-wayland
  rofi-emoji
  rofi-calc
)

# Development Tools
packages+=(
  chezmoi
  neovim
  code
  dotnet-sdk
  dotnet-runtime
  aspnet-runtime
  godot-mono
  npm
)

# Media / Utilities
packages+=(
  yt-dlp
  obs-studio
  keepassxc
  kdeconnect
  pavucontrol
  pamixer
  blueman
)

# Gaming
packages+=(
  steam
  discord
)

# Remote Work / VPN
packages+=(
  freerdp
  remmina
  networkmanager-openconnect
)

# System Tools
packages+=(
  snapper
  snap-pac
)

sudo pacman -Sy --noconfirm

echo "--- Installing pacman packages ---"
for pkg in "${packages[@]}"; do
  echo "Installing $pkg..."
  if ! pacman -Qq "$pkg" &>/dev/null; then
    sudo pacman -S --noconfirm --needed "$pkg"
  fi
  echo "[!] $pkg is already installed"
done

aur=(
  hyprshot # better change it to grim + slurp
  zen-browser-bin
  bibata-cursor-theme-bin
  qimgv-git
  qt6ct-kde
  nerd-fonts-inter
  limine-mkinitcpio-hook
  limine-snapper-sync
)

if ! command -v yay &>/dev/null; then
  echo "yay is not installed. Installing yay..."
  sudo pacman -Sy --needed --noconfirm git base-devel
  cd /tmp || exit
  git clone https://aur.archlinux.org/yay.git
  cd yay || exit
  makepkg -si

  echo "yay installation complete."
else
  echo "yay is already installed."
fi

echo "Installing AUR packages"
for pkg in "${aur[@]}"; do
  echo "Installing $pkg..."
  if ! yay -Qq "$pkg" &>/dev/null; then
    yay -S --noconfirm --needed "$pkg"
  fi
  echo "[!] $pkg is already installed"
done

git clone https://github.com/LazyVim/starter ~/.config/nvim
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

KDE_THEME_DIR="$HOME/.local/share/plasma/desktoptheme/Graphite"
if [ -d "$KDE_THEME_DIR" ]; then
  echo "[!] KDE theme already installed"
else
  echo "--- Installing KDE theme"
  cd /tmp || exit
  git clone https://github.com/vinceliuice/Graphite-kde-theme
  cd Graphite-kde-theme || exit
  sh install.sh -t default --rimless
fi

GTK_THEME_DIR="$HOME/.local/share/themes/Graphite-Dark-compact/"
if [ -d "$GTK_THEME_DIR" ]; then
  echo "[!] GTK theme already installed"
else
  echo "--- Installing GTK theme ---"
  cd /tmp || exit
  git clone https://github.com/ghorshy/Graphite-gtk-theme
  cd Graphite-gtk-theme || exit
  sh install.sh -t default -c dark -s compact --tweaks rimless --round 4px
fi

# Bluetooth
rfkill unblock bluetooth

# Services
systemctl enable bluetooth.service
systemctl enable --now limine-snapper-sync.service
