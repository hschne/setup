# Setup

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
    arandr \
    autorandr \
    betterlockscreen \
    brightnessctl \
    dunst \
    feh \
    i3-wm \
    jsoncpp \
    picom \
    polkit \
    polybar \
    rofi \
    rofimoji \
    sddm \
    sddm-theme-tokyo-night-git \
    xorg \
    xbanish \
    xdotool \
    xorg-xinit\
    xorg-xprop
```

### Enable Ly & Autorandr

```bash
sudo systemctl enable sddm.service
sudo systemctl enable autorandr.service
```

## CLI

```bash
yay -S --noconfirm \
    alacritty \
    asdf-vm \
    git-delta \
    eza \
    fd \
    fzf \
    github-cli \
    glab \
    lazygit \
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
cd hschne__cheats && git remote set-url origin git@github.com:hschne/ruby-conferences.github.io.git
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
    firefox  \
    chromium
```

## Utilities & Drivers

```bash
yay -S --noconfirm \
    atuin \
    bat \
    ctags \
    dua-cli \
    filezilla \
    flameshot \
    fx \
    gzip \
    htop \
    less \
    neofetch \
    network-manager-applet \
    networkmanager \
    mariadb-libs \
    p7zip \
    ranger \
    redshift \
    reflector \
    silicon \
    unzip \
    w3m \
    xclip \
    xpastemouseblock \
    xorg-xrdb \
    xorg-xrandr
```

```bash
sudo systemctl enable NetworkManager.service
```

### Bluetooth

```bash
yay -S --noconfirm \
    bluez \
    bluez-utils \
    blueman
```

```bash
modprobe btusb
systemctl enable bluetooth.service
```

### Audio

Install pipewire and related required utilities. For all full guide see [PipeWireWire Guide](https://github.com/mikeroyal/PipeWire-Guide).

```bash
yay -S --noconfirm \
    calf \
    easyeffects \
    lsp-plugins-lv2 \
    mda.lv2 \
    pavucontrol \
    pipewire \
    pipwire-audio \
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

# Ranger

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

### Install Node, Ruby & Python

```bash
asdf plugin add ruby
asdf install ruby $(asdf latest ruby)
asdf set -u ruby $(asdf latest ruby)

# Python
asdf plugin add python
asdf install python $(asdf latest python)
asdf set -u python $(asdf latest python)

# Node
asdf plugin add nodejs
asdf install nodejs $(asdf latest nodejs)
asdf set -u nodejs $(asdf latest nodejs)

# Go
asdf plugin add golang
asdf install golang $(asdf latest golang)
asdf set -u golang $(asdf latest golang)

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

## Redshift

```bash
systemctl --user enable redshift.service
systemctl --user start redshift.service
```
