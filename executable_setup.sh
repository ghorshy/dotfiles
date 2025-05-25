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
  noto-fonts-emoji
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
  qt5ct
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
  yazi
  wl-clipboard
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
  npm
  wtype
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
  hyprshot
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

cd /tmp || exit
git clone https://github.com/vinceliuice/Graphite-kde-theme
cd Graphite-kde-theme || exit
sh install.sh -t default --rimless
