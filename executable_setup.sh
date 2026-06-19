#!/bin/bash

if [ "$EUID" -eq 0 ]; then
  echo "Do not run this script as root. Run as a regular user."
  exit 1
fi

ask() {
  local prompt="$1"
  while true; do
    read -rp "$prompt [y/n]: " yn
    case "$yn" in
    [Yy]*) return 0 ;;
    [Nn]*) return 1 ;;
    *) echo "Please answer y or n." ;;
    esac
  done
}

install_pacman() {
  for pkg in "$@"; do
    if pacman -Qq "$pkg" &>/dev/null; then
      echo "[!] $pkg is already installed"
    else
      echo "Installing $pkg..."
      sudo pacman -S --noconfirm --needed "$pkg"
    fi
  done
}

install_aur() {
  ensure_yay
  for pkg in "$@"; do
    if yay -Qq "$pkg" &>/dev/null; then
      echo "[!] $pkg is already installed"
    else
      echo "Installing $pkg..."
      yay -S --noconfirm --needed "$pkg"
    fi
  done
}

ensure_yay() {
  if ! command -v yay &>/dev/null; then
    echo "yay not found. Installing yay..."
    sudo pacman -Sy --needed --noconfirm git base-devel
    cd /tmp || exit
    git clone https://aur.archlinux.org/yay.git
    cd yay || exit
    makepkg -si
    echo "yay installation complete."
  fi
}

sudo pacman -Sy --noconfirm

# ─── 1. Hyprland packages ─────────────────────────────────────────────────────
if ask "Install Hyprland UI packages (waybar, mako, rofi, fonts, grim, slurp, etc.)"; then
  install_pacman \
    hyprland \
    networkmanager network-manager-applet \
    kitty \
    hypridle hyprlock hyprpaper \
    xdg-desktop-portal-hyprland \
    qt5-wayland qt6-wayland qt5ct \
    waybar mako nwg-look papirus-icon-theme \
    rofi-wayland rofi-emoji rofi-calc \
    inter-font noto-fonts-emoji ttf-font-awesome ttf-jetbrains-mono \
    pavucontrol pamixer \
    grim slurp \
    wl-clipboard wtype \
    blueman udiskie \
    thunar thunar-archive-plugin thunar-volman engrampa \
    yazi

  install_aur \
    bibata-cursor-theme-bin \
    qimgv-git \
    qt6ct-kde \
    nerd-fonts-inter
fi

# ─── 2. ZSH config ────────────────────────────────────────────────────────────
if ask "Install ZSH and shell tools (zsh, p10k, fzf, eza, bat, etc.)"; then
  install_pacman \
    zsh \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    zsh-theme-powerlevel10k-git \
    zoxide \
    eza \
    bat \
    fastfetch \
    lazygit \
    btop \
    fzf

  if [ ! -d "$HOME/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  else
    echo "[!] powerlevel10k already cloned"
  fi

  chsh -s "$(which zsh)"
fi

# ─── 3. Limine & Snapper ──────────────────────────────────────────────────────
if ask "Install Limine and Snapper packages (snapper, snap-pac, limine hooks)"; then
  install_pacman \
    snapper \
    snap-pac

  install_aur \
    limine-mkinitcpio-hook \
    limine-snapper-sync

  systemctl enable --now limine-snapper-sync.service
fi

# ─── 4. KDE & GTK theme ───────────────────────────────────────────────────────
if ask "Install Graphite KDE and GTK themes"; then
  KDE_THEME_DIR="$HOME/.local/share/plasma/desktoptheme/Graphite"
  if [ -d "$KDE_THEME_DIR" ]; then
    echo "[!] KDE theme already installed"
  else
    echo "--- Installing KDE theme ---"
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
    git clone https://github.com/vinceliuice/Graphite-gtk-theme
    cd Graphite-gtk-theme || exit
    sh install.sh -t default -c dark -s compact --tweaks rimless --round 4px
  fi

  nwg-look -a
fi

# ─── 5. Dotnet development ────────────────────────────────────────────────────
if ask "Install dotnet development tools (dotnet-sdk, code, npm)"; then
  install_pacman \
    dotnet-sdk \
    dotnet-runtime \
    aspnet-runtime \
    zed \
    npm
fi

# ─── 6. Neovim & LazyVim ─────────────────────────────────────────────────────
if ask "Install Neovim with LazyVim"; then
  install_pacman neovim

  if [ ! -d "$HOME/.config/nvim" ]; then
    git clone https://github.com/LazyVim/starter ~/.config/nvim
  else
    echo "[!] LazyVim already cloned"
  fi
fi

# ─── 7. Misc packages ─────────────────────────────────────────────────────────
if ask "Install misc packages (chezmoi, unzip, keepassxc, godot, steam, discord, obs, etc.)"; then
  install_pacman \
    chezmoi \
    unzip \
    unrar \
    keepassxc \
    kdeconnect \
    obs-studio \
    yt-dlp \
    godot-mono \
    freerdp \
    remmina \
    networkmanager-openconnect \
    steam \
    discord

  install_aur \
    zen-browser-bin
fi

# ─── System ───────────────────────────────────────────────────────────────────
rfkill unblock bluetooth
systemctl enable bluetooth.service
systemctl enable --now NetworkManager.service

hyprpm update
if [ ! -d "$HOME/.config/hypr/plugins/split-monitor-workspaces" ]; then
  mkdir -p ~/.config/hypr/plugins
  git clone https://github.com/zjeffer/split-monitor-workspaces ~/.config/hypr/plugins/split-monitor-workspaces
else
  echo "[!] split-monitor-workspaces already cloned"
fi

echo "--- Detected monitors (configure in hyprland.conf) ---"
hyprctl monitors 2>/dev/null || echo "(run 'hyprctl monitors' inside a Hyprland session to see monitor list)"
