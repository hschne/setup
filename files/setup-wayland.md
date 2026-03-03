# Setup (Wayland/Hyprland)

## SSH Key

```bash
ssh-keygen -b 4096 -t rsa -N '' -q -C "$USER" -f "$HOME/.ssh/id_rsa" <<< $'\ny'
ssh-keyscan github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
```

## Setup Yay

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
```

## Desktop

```bash
yay -S --noconfirm \
    brightnessctl \
    grim \
    hypridle \
    hyprland \
    hyprlock \
    hyprpaper \
    hyprpicker \
    hyprsunset \
    imv \
    kanshi \
    mako \
    playerctl \
    polkit-gnome \
    qt5-wayland \
    qt6-wayland \
    satty \
    sddm \
    sddm-theme-tokyo-night-git \
    slurp \
    swaybg \
    swayosd \
    uwsm \
    walker-bin \
    waybar \
    wayfreeze \
    wl-clipboard \
    wlr-randr \
    xdg-desktop-portal-gtk \
    xdg-desktop-portal-hyprland
```

### Enable SDDM

```bash
sudo systemctl enable sddm.service
```

## CLI

```bash
yay -S --noconfirm \
    alacritty \
    btop \
    bluetui \
    dust \
    fastfetch \
    git-delta \
    eza \
    fd \
    fzf \
    github-cli \
    glab \
    gpu-screen-recorder \
    impala \
    lazydocker \
    lazygit \
    mise \
    neovim \
    navi \
    jq \
    httpie \
    ripgrep \
    tmux \
    walk \
    zsh \
    zoxide
```

### Clone Cheats

```bash
mkdir -p ~/.local/share/navi/cheats
cd ~/.local/share/navi/cheats/
git clone https://github.com/hschne/cheats.git hschne__cheats
cd hschne__cheats && git remote set-url origin git@github.com:hschne/cheats.git
```

### Terminal Tools & Plugins

```bash
sh -c "$(curl -fsSL get.zshell.dev)" -- -i skip -b main
sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y
```

## Browsers & Dev Tools

```bash
yay -S --noconfirm \
    docker \
    docker-compose \
    docker-buildx \
    firefox  \
    chromium
```

## Utilities & Drivers

```bash
yay -S --noconfirm \
    atuin \
    bat \
    ctags \
    filezilla \
    fx \
    gzip \
    less \
    networkmanager \
    mariadb-libs \
    p7zip \
    lf \
    reflector \
    silicon \
    unzip \
    w3m
```

```bash
sudo systemctl enable NetworkManager.service
```

### Bluetooth

```bash
yay -S --noconfirm \
    bluez \
    bluez-utils
```

```bash
modprobe btusb
systemctl enable bluetooth.service
```

### Audio

Install pipewire and related required utilities. For a full guide see [PipeWire Guide](https://github.com/mikeroyal/PipeWire-Guide).

```bash
yay -S --noconfirm \
    calf \
    easyeffects \
    lsp-plugins-lv2 \
    mda.lv2 \
    pavucontrol \
    pipewire \
    pipewire-audio \
    pipewire-pulse \
    wireplumber \
    zam-plugins-lv2
```

```bash
systemctl --user enable --now pipewire.socket
systemctl --user enable --now pipewire-pulse.socket
systemctl --user enable --now wireplumber.service
```

## Random Apps

```bash
yay -S --noconfirm \
    calibre \
    libreoffice-still \
    gimp \
    inkscape \
    kdenlive \
    signal-desktop \
    speedcrunch \
    spotify-launcher \
    spicetify-cli \
    syncthing \
    vlc \
    xournalpp \
    zathura \
    zathura-pdf-mupdf
```

## Enable Syncthing

```bash
systemctl enable --user syncthing.service
```

## Homeshick

```bash
homeshick_root="$HOME/.homesick/repos/homeshick"
homeshick_bin="$homeshick_root/bin/homeshick"

git clone https://github.com/andsens/homeshick.git "$homeshick_root"

"${homeshick_bin}" clone --batch https://github.com/hschne/dotfiles.git
"${homeshick_bin}" link --force
```

Create default `.env` file and Source folder.

```bash
touch ~/.env
mkdir ~/Source
```

## ZSH

```bash
sudo chsh -s "/bin/zsh" "$USER"
```

## Ranger

```bash
git clone https://github.com/alexanderjeurissen/ranger_devicons.git ~/.config/ranger/plugins/ranger_devicons
git clone https://github.com/jchook/ranger-zoxide.git ~/.config/ranger/plugins/zoxide
```

## TPM

```bash
tpm_root="$HOME/.tmux/plugins/tpm"
git clone https://github.com/tmux-plugins/tpm.git  "$tpm_root"
"$tpm_root/scripts/install_plugins.sh"
```

## Install Languages (mise)

Add mise to your shell config (`~/.zshrc`):

```bash
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
```

Install languages:

```bash
mise use -g ruby@latest
mise use -g python@latest
mise use -g node@latest
mise use -g go@latest
```

## Fonts

```bash
yay -S --noconfirm \
    ttf-sourcecodepro-nerd \
    ttf-font-awesome \
    noto-fonts \
    noto-fonts-emoji \
    ttf-material-icons-git
```

## Icons & Themes

```bash
yay -S --noconfirm \
    arc-gtk-theme \
    papirus-icon-theme \
    papirus-folders
```

```bash
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
gsettings set org.gnome.desktop.interface gtk-theme "Arc-Dark"
papirus-folders -C black --theme Papirus-Dark
```

## Docker

```bash
sudo usermod -aG docker "$USER"
sudo systemctl enable docker
```

## Reflector

```bash
sudo systemctl enable reflector.service reflector.timer
sudo systemctl start reflector.service reflector.timer
```

## IWD + NetworkManager + Impala

Impala is a TUI for managing WiFi that requires iwd. By default, NetworkManager uses wpa_supplicant for WiFi. To use impala, configure NetworkManager to use iwd as its backend instead.

**The players:**

| Tool               | Role                                                     |
| ------------------ | -------------------------------------------------------- |
| **wpa_supplicant** | WiFi authentication daemon (old default)                 |
| **iwd**            | WiFi authentication daemon (modern, faster, less memory) |
| **NetworkManager** | Network management (WiFi, Ethernet, VPN, etc.)           |

Using **NetworkManager + iwd** gives you the best of both worlds: faster WiFi with full NetworkManager features.

### Install

```bash
yay -S --noconfirm \
    iwd \
    impala
```

### Switch from wpa_supplicant to iwd

```bash
# Stop and disable wpa_supplicant
sudo systemctl stop wpa_supplicant
sudo systemctl disable wpa_supplicant

# Configure NetworkManager to use iwd backend
echo -e "[device]\nwifi.backend=iwd" | sudo tee /etc/NetworkManager/conf.d/iwd.conf

# Enable iwd and restart NetworkManager
sudo systemctl enable --now iwd
sudo systemctl restart NetworkManager
```

### Troubleshooting Auto-Connect

When using iwd as the WiFi backend for NetworkManager, auto-connect issues can occur due to duplicate connection profiles.

### Check for Duplicate Profiles

After setting up iwd + NetworkManager, interface names may change (e.g., `wlp1s0` → `wlan0`). This can leave stale profiles pointing to non-existent interfaces:

```bash
nmcli connection show | grep wifi
```

If you see duplicates (e.g., "Network" and "Network 1"), check which interface each is bound to:

```bash
nmcli connection show "Network" | grep interface-name
nmcli connection show "Network 1" | grep interface-name
```

### Fix: Delete Stale Profiles

Delete profiles bound to old/non-existent interfaces:

```bash
nmcli connection delete "Network"
```

Keep the profile that matches your current interface (`wlan0` when using iwd).
