# Setup

## Basics

```bash
sudo pacman -Sy --noconfirm base-devel git curl openssh inetutils
```

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
    dunst \
    feh \
    i3-wm \
    ly \
    jsoncpp \
    picom \
    polkit \
    polybar \
    rofi \
    rofimoji \
    xorg \
    xbanish \
    xdotool \
    xorg-xinit\
    xorg-xprop 
```

### Enable Ly & Autorandr

```bash
sudo systemctl enable ly.service
sudo systemctl enable autorandr.service
```
 
## CLI

```bash
yay -S --noconfirm \
    alacritty \
    diff-so-fancy \
    fd \
    fzf \
    neovim \
    navi \
    hub \
    jq \
    httpie \
    ripgrep \
    tmux \
    zsh \
    zoxide
```

### Clone Cheats

```
mkdir -p ~/.local/share/navi/cheats
cd ~/.local/share/navi/cheats/
git clone git@github.com:hschne/cheats hschne__cheats
```
 
### Terminal Tools & Plugins
 
```
sh -c "$(curl -fsSL get.zshell.dev)" -- -i skip -b main
sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y
```

## Browsers & Dev Tooks

```bash
yay -S --noconfirm \
    docker \
    docker-compose \
    firefox-developer-edition 
```

## Utilities & Drivers

```bash
yay -S --noconfirm \
    baobab \
    bat \
    ctags \
    eog \
    fx \
    gnome-disk-utility \
    gzip \
    htop \
    less \
    mesa \
    nautilus \
    neofetch \
    network-manager-applet \
    networkmanager \
    p7zip \
    ranger \
    redshift \
    reflector \
    unzip \
    w3m \
    wget \
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

```
modprobe btusb
systemctl enable bluetooth.service
```

### Audio

Install pipewire and related required utilities. For all full guide see [PipeWireWire Guide](https://github.com/mikeroyal/PipeWire-Guide).

```
yay -S --noconfirm \
    alsa-utils \
    calf \
    easyeffects \
    lsp-plugins-lv2 \
    mda.lv2 \
    pavucontrol \
    pipewire \
    pipwire-audio \
    pipewire-alsa \
    pipewire-jack \
    pipewire-pulse \
    wireplumber \
    zam-plugins-lv2
```

```
systemctl --user enable --now pipewire.socket
systemctl --user enable --now pipewire-pulse.socket
systemctl --user enable --now wireplumber.service
```

## Random Apps

```bash
yay -S --noconfirm \
    calibre \
    gimp \
    inkscape \
    speedcrunch \
    spotify \
    syncthing \
    syncthingtray \
    vlc \
    xournalpp \
    zathura \
    zathura-pdf-mupdf 
```

## Homeshick

```bash
homeshick_root="$HOME/.homesick/repos/homeshick"
homeshick_bin="$homeshick_root/bin/homeshick"

git clone git@github.com:andsens/homeshick.git "$homeshick_root" 

"${homeshick_bin}" clone --batch git@github.com:hschne/dotfiles.git
"${homeshick_bin}" link --force
```

## ZSH

```bash
sudo chsh -s "/bin/zsh" "$USER" 
```

# Ranger

```bash
git clone git@github.com:alexanderjeurissen/ranger_devicons ~/.config/ranger/plugins/ranger_devicons
git clone git@github.com:jchook/ranger-zoxide.git ~/.config/ranger/plugins/zoxide
```

## TPM

```bash
tpm_root="$HOME/.tmux/plugins/tpm"
git clone git@github.com:tmux-plugins/tpm.git  "$tpm_root"
"$tpm_root/scripts/install_plugins.sh"
```

## Mise

```
curl https://mise.run | sh
# Setup usage for completions
~/.local/bin/mise use -g usage
~/.local/bin/mise completion zsh  > /usr/local/share/zsh/site-functions/_mise
```

### Install Node, Ruby & Python
```
~/.local/bin/mise use --global node@latest
~/.local/bin/mise use --global ruby@latest
~/.local/bin/mise use --global python@latest
```


## Fonts

```bash
yay -S --noconfirm \
    ttf-sourcecodepro-nerd \
    ttf-font-awesome \
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

## Better Lockscreen

```
mkdir -p ~/Pictures/Backgrounds
curl https://i.imgur.com/lhZoAOv.jpg -o ~/Pictures/Backgrounds/forest.jpg 
curl https://i.imgur.com/zuNUJ4J.jpg -o ~/Pictures/Backgrounds/mountains.jpg 
curl https://i.imgur.com/kTNHsRt.jpg -o ~/Pictures/Backgrounds/moss.jpg 
curl https://i.imgur.com/hdXF561.jpg -o ~/Pictures/Backgrounds/cliff.jpg 
curl https://i.imgur.com/ymmraHp.jpg -o ~/Pictures/Backgrounds/lake.jpg
curl https://i.imgur.com/f5YDfNq.jpg -o ~/Pictures/Backgrounds/autumn.jpg 
curl https://i.imgur.com/g9h0kkl.jpg -o ~/Pictures/Backgrounds/tundra.jpg 
betterlockscreen -u ~/Pictures/Backgrounds
```
