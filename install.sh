#!/usr/bin/env bash

source "lib/console.sh"
source "lib/util.sh"
source "lib/spinny.sh"

ERROR=0
DEBUG=0

LOG_FILE=""

set -oe pipefail

function main() {
  console::banner

  setup::parse_arguments "$@"

  setup::request_sudo "$@"

  setup::basics

  setup::ssh

  setup::install_tools

  setup::install_packages

  console::summary

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
    openssh \
    inetutils
}

setup::ssh() {
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

setup::install_packages() {
  setup::wait "Downloading Yay... " \
    setup::gclone https://aur.archlinux.org/yay.git 
  cd yay
  setup::wait "Installing yay... " \
    sudo makepkg -si --noconfirm 
  cd .. &&  rm -rf yay 

  setup::wait "Installing all the packages. This could take a while..." \
    setup::execute \
    sudo yay -S --noconfirm \
    dialog \
    diff-so-fancy \
    zsh \
    ripgrep \
    # alacritty \
  # chromium \
  # docker  \
  # docker-compose \
  # feh \
  # firefox-developer-edition \
  # gvim \
  # hub  \
  # i3-wm \
  # jsoncpp 
  # nerd-fonts-complete \
  # polybar \
  # pulseaudio \
  # rambox-bin \
  # spotify \
  # synology-cloud-station-drive \
  # thefuck \
  # tmux \
  # ttf-font-awesome \
  # ttf-material-icons-git \
  # vlc \
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
    "$@"
    result=$?
    spinny:stop
    if [[ $result -eq 0 ]]; then console::print " done\n" "green"; else  console::print " error\n" "red"; fi
  else 
    console::break
    "$@"
  fi
}

setup::install_tools() {
  # Before we do anything, add github to known hosts

  local homeshick_root="$HOME/.homesick/repos/homeshick"
  homeshick_bin="$homeshick_root/bin/homeshick"
  setup::wait "Setting up Homeshick..." \
    setup::gclone "andsens/homeshick" "$homeshick_root" 
  setup::wait "Cloning your castles..."\
    "${homeshick_bin}" clone --batch git@github.com:glumpat/dotfiles.git && \
  setup::execute \
    "${homeshick_bin}" link --force

  local destination="$HOME/.zplug"
  setup::execute \
    chsh -s "/bin/zsh" "$USER" 
  setup::wait "Setting up zplug..."\
    setup::execute \
    gclone "git@github.com:zplug/zplug.git" "$destination"

  setup::wait "Downloading Tmux plugin manager..."\
    setup::gclone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  setup::wait "Installing Tmux plugins..." \
    setup::execute \
    ~/.tmux/plugins/tpm/scripts/install_plugins.sh
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

setup::execute() {
  if [[ $DRY_RUN -eq 1 ]]; then
    console::debug "Skip execution of '$*' \n"; return 0
  fi
  [[ ! -f "$LOG_FILE" ]] && LOG_FILE=$(mktemp "/tmp/setup_XXXXXX.log")
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
}

setup::handle_exit() {
  console::break
  console::error "Installation aborted by user\n" 
  exit 1
}

setup::handle_error() {
  console::break
  console::error "Some setup steps failed. See '$LOG_FILE' for more information\n"
  exit 1
}

trap 'setup::handle_exit $?' 2
trap 'setup::handle_error $?' ERR

# Entrypoint
main "$@"
