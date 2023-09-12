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

## GitHub

```bash
curl -L \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    --data "{\"title\":\"$USER@$(hostname)\",\"key\":\"$(cat ~/.ssh/id_rsa.pub)\"}" \
    https://api.github.com/user/keys
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
    betterlockscreen \
    dunst \
    feh \
    i3 \
    jsoncpp \
    picom \
    polybar \
    rofi \
    rofimoji \
    xdotool \
    xorg-xinit\
    xorg-xprop 
```
 
## CLI

```bash
yay -S --noconfirm \
    alacritty \
    diff-so-fancy \
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
 
## Terminal Tools & Plugins
 
```
sh -c "$(curl -fsSL get.zshell.dev)" -- -i skip -b main
sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y
```

## Browsers & Dev Tooks

```bash
yay -S --noconfirm \
    chromium \
    docker \
    docker-compose \
    firefox-developer-edition 
```

## Utilities & Drivers

```bash
yay -S --noconfirm pipewire
yay -S --noconfirm \
    arandr \
    ctags \
    gzip \
    easyeffects \
    htop \
    mesa \
    neofetch \
    network-manager-applet \
    networkmanager \
    pavucontrol \
    gst-plugin-pipewire \
    p7zip \
    ranger \
    redshift \
    reflector \
    w3m \
    wget \
    xclip \
    xorg-xrandr 
```

```bash
sudo systemctl enable NetworkManager.service
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
    slack-desktop \
    vlc \
    zathura \
    zathura-pdf-mupdf 
```

## Homeshick

```bash
homeshick_root="$HOME/.homesick/repos/homeshick"
homeshick_bin="$homeshick_root/bin/homeshick"

git clone git@github.com:andsens/homeshick.git "$homeshick_root" 

"${homeshick_bin}" clone --batch git@github.com:glumpat/dotfiles.git
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

## ASDF

```bash
asdf_root="$HOME/.asdf"

git clone  git@github.com:asdf-vm/asdf.git "$asdf_root"
```

## asdf-ruby / asdf-node / asdf-python

```bash
# ASDF is not yet loaded when installing, we need to use the absolute path

# Ruby
~/.asdf/bin/asdf plugin-add ruby
~/.asdf/bin/asdf install ruby $(asdf latest ruby)
# Python
~/.asdf/bin/asdf plugin-add python
~/.asdf/bin/asdf install python $(asdf latest python)
# Node
~/.asdf/bin/asdf plugin-add nodejs
"$HOME/.asdf/plugins/nodejs/bin/import-release-team-keyring"
~/.asdf/bin/asdf install nodejs $(asdf latest nodejs)
```

## Fonts

```bash
yay -S --noconfirm \
    ttf-sourcecodepro-nerd \
    ttf-font-awesome \
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
curl https://i.imgur.com/ymmraHp.jpg -o ~/Pictures/Backgrounds/mountainlake.jpg
curl https://i.imgur.com/f5YDfNq.jpg -o ~/Pictures/Backgrounds/autumn.jpg 
curl https://i.imgur.com/g9h0kkl.jpg -o ~/Pictures/Backgrounds/tundra.jpg 
betterlockscreen -u ~/Pictures/Backgrounds
```
