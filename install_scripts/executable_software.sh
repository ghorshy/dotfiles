#!/bin/bash
packages=(
  # zsh
  zsh
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-theme-powerlevel10k-git
  z
  # fonts
  ttf-font-awesome
  ttf-jetbrains-mono
  inter-font
  # hypr
  hyprpaper
  hyprlock
  hypridle
  xdg-desktop-portal-hyprland
  # thunar
  thunar
  thunar-archive-plugin
  thunar-volman
  engrampa
  # qt
  qt5-wayland
  qt6-wayland
  # rofi
  rofi-wayland
  rofi-emoji
  rofi-calc
  #looks
  waybar
  nwg-look
  dunst
  papirus-icon-theme
  # utils
  lazygit
  fastfetch
  btop
  unzip
  unrar
  chezmoi
  eza
  pavucontrol
  pamixer
  bluez-utils
  blueman
  udiskie
  #other
  code
  neovim
  yt-dlp
  keepassxc
  obs-studio
  steam
  dotnet-sdk
  dotnet-runtime
  aspnet-runtime
  discord
  kdeconnect
  godot-mono
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
  hyprshot
  zen-browser-bin
  bibata-cursor-theme-bin
  qimgv-git
)

echo "Installing AUR packages"
for pkg in "${aur[@]}"; do
  echo "Installing $pkg..."
  if ! yay -Qq "$pkg" &>/dev/null; then
    yay -S --noconfirm --needed "$pkg"
  fi
  echo "[!] $pkg is already installed"
done
