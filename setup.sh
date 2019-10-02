#!/usr/bin/env bash

source "lib/console.sh"
source "lib/spinny.sh"

DEBUG=0

LOG_FILE=$(mktemp "/tmp/setup_XXXXXX.log")

set -o pipefail

function main() {
  console::banner

  setup::parse_arguments "$@"

  setup::request_sudo "$@"

  setup::basics

  setup::github
  
  setup::packages

  setup::plugins

  setup::asdf

  setup::services

  console::info "Installation finished successfully!\n"
  console::break

  setup::reboot
}


setup::request_sudo() {
  if ! sudo -n true >/dev/null 2>&1; then { 
    console::prompt "This script requires sudo access. Please enter your password: ";
    sudo -p "" -v -n; console::break; 
  }; fi

  # Keep-alive: update existing sudo time stamp until the script has finished
  # See here: https://gist.github.com/cowboy/3118588
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

setup::parse_arguments() {
  local positional=()
  while [[ $# -gt 0 ]]
  do
    key="$1"
    case $key in
      --debug)
        console::info "Starting installation with debug option\n"
        DEBUG=1
        shift 
        ;;
      *) 
        positional+=("$1") # save it in an array for later
        shift
        ;;
    esac
  done
  set -- "${positional[@]}" # restore positional parameters
}

setup::basics() {
  setup::wait "Installing some basics, just a second... "\
    setup::execute \
    sudo pacman -Sy --noconfirm  \
    base-devel \
    git \
    curl \
    wget \
    openssh \
    inetutils
}

setup::github() {
  mkdir "$HOME/.ssh"

  console::info "To continue we'll need to upload a SSH key to GitHub.\n"
  console::prompt "Enter your Github username: " && { local username; read -e -r username; }
  console::prompt "Enter your password: " && { local password; read -e -r -s password; }
  console::break
  console::prompt "Enter your two-factor code: " && { local password; read -e -r -s otp; }
  console::break

  console::info "Generating a new SSH key and uploading it to Github... "
  spinny::start
  setup::execute ssh-keygen -b 4096 -t rsa -N '' -q -C "$USER" -f "$HOME/.ssh/id_rsa"

  local name; name="$USER@$(hostname)"
  local status; status=$(curl -o /dev/null \
    -s -w "%{http_code}\n" \
    -u "$username:$password" \
    --header "x-github-otp: $otp" \
    --data "{\"title\":\"$name\",\"key\":\"$(cat ~/.ssh/id_rsa.pub)\"}" \
    https://api.github.com/user/keys)
  spinny::stop

  #TODO: Handle error codes nicely
  if [[ "$status" -ne "201" ]]; then
    console::print " error\n" red
    console::error "Failed to upload SSH key. Exiting setup...\n"
    exit 1;
  fi
  console::print " done\n" "green"

  ssh-keyscan github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
}

setup::packages() {
  setup::wait "Downloading Yay... " \
    setup::execute git clone https://aur.archlinux.org/yay.git 
  cd yay
  setup::wait "Installing Yay... " \
    setup::execute makepkg -si --noconfirm 
  cd .. &&  rm -rf yay 

  setup::wait "Installing desktop packages... " \
    setup::execute \
    yay -S --noconfirm \
    compton \
    dunst \
    feh \
    gnome \
    gnome-tweaks \
    i3-gaps \
    jsoncpp \
    lxappearance \
    nordic-theme-git \
    polybar \
    rofi \
    xorg-xprop \
    zafiro-icon-theme 

  setup::wait "Installing fonts... " \
    setup::execute \
    yay -S --noconfirm \
    nerd-fonts-complete \
    ttf-font-awesome \
    ttf-material-icons-git 

  setup::wait "Installing CLI tools... " \
    setup::execute \
    yay -S --noconfirm \
    alacritty \
    diff-so-fancy \
    fzf \
    gvim \
    hub \
    ripgrep \
    thefuck \
    tmux \
    zsh 

  setup::wait "Installing browsers and dev tools... " \
    setup::execute \
    yay -S --noconfirm \
    chromium \
    docker \
    docker-compose \
    firefox-developer-edition \
    jetbrains-toolbox 


  setup::wait "Installing utilities and drivers... " \
    setup::execute \
    yay -S --noconfirm \
    arandr \
    ctags \
    dialog \
    htop \
    mesa \
    neofetch \
    network-manager-applet \
    networkmanager \
    pavucontrol \
    pulseaudio \
    ranger \
    redshift \
    w3m \
    xclip \
    xournal \
    xrandr 

  setup::wait "Installing apps... " \
    setup::execute \
    yay -S --noconfirm \
    spotify \
    station \
    synology-cloud-station-drive \
    vlc \
    zathura \
    zathura-pdf-mupdf 
}

setup::plugins() {
  local homeshick_root="$HOME/.homesick/repos/homeshick"
  homeshick_bin="$homeshick_root/bin/homeshick"
  setup::wait "Setting up Homeshick... " \
    setup::gclone "andsens/homeshick" "$homeshick_root" 
  setup::wait "Cloning your castles... " \
    setup::execute \
    "${homeshick_bin}" clone --batch git@github.com:glumpat/dotfiles.git && \
    setup::execute \
    "${homeshick_bin}" link --force

  local zplug_root="$HOME/.zplug"
  setup::wait "Setting up zplug..."\
    setup::execute \
    setup::gclone "zplug/zplug" "$zplug_root"

  local tpm_root="$HOME/.tmux/plugins/tpm"
  setup::wait "Downloading Tmux plugin manager... "\
    setup::gclone "tmux-plugins/tpm" "$tpm_root"
  # TODO: This does not work. Make it work
  # setup::wait "Installing Tmux plugins..." \
  #   setup::execute \
  #   "$tpm_root/scripts/install_plugins.sh"

}

setup::asdf() {
  local asdf_root="$HOME/.asdf"
  setup::wait "Downloading asdf-vm... "\
    setup::gclone "asdf-vm/asdf" "$asdf_root"
  local asdf; asdf="$asdf_root/asdf"
  # Create a temporary executable for use in subshells
  cat "$asdf_root/asdf.sh" >> "$asdf" && echo "asdf \"\$@\"" >> "$asdf" && chmod +x "$asdf"
  local latest

  console::info "Installing the latest Ruby... "
  setup::execute "$asdf" plugin-add ruby
  versions=$("$asdf" list-all ruby 2>/dev/null)
  latest=$(echo "$versions" | setup::highest_version)
  setup::execute "$asdf" install ruby "$latest"
  console::break

  console::info "Installing the latest Python... "
  setup::execute "$asdf" plugin-add python
  versions=$("$asdf" list-all python 2>/dev/null)
  latest=$(echo "$versions" | setup::highest_version)
  setup::execute "$asdf" install python "$latest"
  console::break

  console::info "Installing the latest Node... "
  setup::execute "$asdf" plugin-add nodejs
  setup::execute bash "$asdf_root/plugins/nodejs/bin/import-release-team-keyring"
  versions=$("$asdf" list-all nodejs 2>/dev/null)
  latest=$(echo "$versions" | setup::highest_version)
  setup::execute "$asdf" install nodejs "$latest"
  console::break

  rm "$asdf"
}

setup::services() {
  console::info "Setting up Zsh, enabling Docker and GDM... \n"
  # Set zsh as default
  setup::execute sudo chsh -s "/bin/zsh" "$USER" 
  # Enable docker
  setup::execute sudo usermod -aG docker "$USER" 
  setup::execute sudo systemctl enable docker
  # Enable gdm
  setup::execute sudo systemctl enable gdm
}

# Wait executes a command and wraps it in a spinner.
# 
# Arguments:
#
# $1 - The URL to clone from.
# $2 - The destination to clone to.
#
# Examples
#
#   gclone "http://someurl/myrepo.git" $HOME
# 
setup::wait() {
  local message=$1
  shift 

  console::info "$message"
  # When debugging is enabled command output is printed to tty
  # and no progress thing is required, as that is visible anyway
  if [[ $DEBUG -eq 0 ]]; then 
    spinny::start
    # TODO: Add call to setup::execute here, to get rid of some code duplication
    "$@"
    result=$?
    spinny::stop
    if [[ $result -eq 0 ]]; then console::print " done\n" "green"; else  console::print " error\n" red; fi
  else 
    console::break
    "$@"
  fi
}

setup::spinstart() {
  [[ $DEBUG -eq 0 ]] && spinny::start
}

setup::spinstop() {
  result=$1
  if [[ $DEBUG -eq 0 ]]; then 
    spinny::stop
    if [[ $result -eq 0 ]]; then console::print " done\n" "green"; else  console::print " error\n" "red"; fi
  else 
    console::break
    "$@"
  fi
}

setup::execute() {
  if [[ $DRY_RUN -eq 1 ]]; then
    console::debug "Skip execution of '$*' \n"; return 0
  fi
  if [[ $DEBUG -eq 1 ]]; then
    "$@" | tee -a "$LOG_FILE"
  else
    "$@" &>> "$LOG_FILE"
  fi
  local result=$?
  return $result
}

# A wrapper around git clone. Does not rely on the path and clones with shallow 
# in order to speed up process. 

# Arguments:
#
# $1 - The URL to clone from.
# $2 - The destination to clone to.
#
# Examples
#
#   gclone "http://someurl/myrepo.git" $HOME
# 
setup::gclone() {
  local git="/usr/bin/git"
  local source="git@github.com:$1.git"
  local destination="$2"
  [[ -z $destination ]] && destination="$HOME"

  setup::execute "${git}" clone --depth 1 "$source" "$destination"
}

# Returns the highest version from a list of version strings,
# stripped of leading white space. 
# Magic taken from: 
#   https://stackoverflow.com/a/30183040/2553104
#   https://stackoverflow.com/a/3232433
# 
# Arguments: 
# 
# $@ - A list of versions of the form x.x.x
#
# Examples
#
#    echo "1.2.3 3.4.2 5.0.1" | highest_version
#
setup::highest_version() {
  # Magic comes from here: https://stackoverflow.com/a/30183040/2553104
  awk -F '.' '
  /^[[:space:]]*[0-9]+\.[0-9]+\.[0-9]+[[:space:]]*$/ {
  if ( ($1 * 100 + $2) * 100 + $3 > Max ) {
    Max = ($1 * 100 + $2) * 100 + $3
    Version=$0
  }
}
END { print Version }' | sed -e 's/^[[:space:]]*//'
}


# Reboot after prompting the user for it
# Taken from https://unix.stackexchange.com/a/426189
setup::reboot() {
  console::prompt "It is recommended that you reboot your PC\n"
  console::prompt "Would you like to reboot now? (y/N) " && read -r -e x
  if [[ "$x" == "y" ]]; then 
    reboot
  fi
}

setup::die(){
  local message=$1
  console::error "$message\n" && exit 1
  spinny::stop 2>/dev/null
}

setup::handle_abort() {
  console::break
  setup::die "Installation aborted by user\n" 
}

setup::handle_error() {
  console::break
  setup::die "Some setup steps failed. See '$LOG_FILE' for more information\n"
}

trap 'setup::handle_abort $?' SIGINT
trap 'setup::handle_error $?' ERR

# Entrypoint
main "$@"
