#!/usr/bin/env bash

source "lib/console.sh"
source "lib/util.sh"
source "lib/spinny.sh"

ERROR=0
DRY_RUN=0
DEBUG=0

STAGE=0
LOG_FILE=""

user="hschne"
HOME="/home/$user"

set -oe pipefail

function main() {
  console::banner
  
  setup::parse_arguments "$@"

  if [[ "$STAGE" -eq 0 ]]; then 
    local dir; dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    setup::create_user
    sudo -u "$user" "$dir/setup.sh" "$@" --continue 
    console::summary
    setup::reboot
  else 
    setup::install_tools
  fi

  # setup::install_packages


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
      --dry-run)
        console::info "Dry run option set\n"
        DRY_RUN=1
        shift
        ;;
      --continue)
        STAGE=1
        shift 
        ;;
      *) 
        positional+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
  done
  set -- "${positional[@]}" # restore positional parameters
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

setup::create_user() {
  setup::wait "Synchronizing database and installing basics... "\
    setup::execute \
    pacman -Sy --noconfirm  \
    base-devel \
    git \
    openssh \
    sudo \
    xclip

  setup::wait "Creating new user... "\
    setup::execute \
    chmod 640 /etc/sudoers && \
    echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    chmod 440 /etc/sudoers && \
    useradd -m -p "$user" -G wheel "$user" && 
  cd "$HOME"
}

setup::install_packages() {
  setup::wait "Updating package database and installing yay..." \
    setup::execute \
    sudo -u "$user" git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    sudo -u "$user" makepkg -si --noconfirm &&
    cd .. && rm -rf yay \

  setup::wait "Installing packages. This could take a while..." \
    setup::execute \
    sudo -u "$user" yay -S --noconfirm \
    dialog \
    diff-so-fancy \
    zsh 
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

setup::install_tools() {
  # Before we do anything, add github to known hosts
  mkdir "$HOME/.ssh"
  setup::execute ssh-keyscan github.com >> "$HOME/.ssh/known_hosts"

  local homeshick_root="$HOME/.homesick/repos/homeshick"
  homeshick_bin="$homeshick_root/bin/homeshick"
  setup::wait "Setting up Homeshick..."\
    setup::execute \
    sudo -u "$user" /usr/bin/git clone "git@github.com:andsens/homeshick.git" "$homeshick_root" && \
    sudo -u "$user" "${homeshick_bin}" clone --batch git@github.com/glumpat/dotfiles && \
    sudo -u "$user" "${homeshick_bin}" link --force

  local destination="$HOME/.zplug"
  setup::wait "Setting up zplug..."\
    setup::execute \
    sudo -u "$user" chsh -s "/bin/zsh" "$user" \
    sudo -u "$user" /usr/bin/git clone "git@github.com:zplug/zplug.git" "$destination"
}

setup::generate_ssh_key() {
  console::info "The setup requires a new SSH key to be generated.\n"
  console::prompt "Please enter your email: " && { local email; read -e -r email; }
  local filename="id_rsa"

  mkdir "$HOME/.ssh"
  ssh-keygen -b 4096 -t rsa -N '' -q -C "$email" -f "$HOME/.ssh/id_rsa"
  local result=$?

  if [[ $result != 0 ]]; then 
    console::error "Failed to create new SSH key, aborting setup\n"
    exit 1
  else
    console::info "New SSH key '~/.ssh/$filename' generated:\n\n" 
  fi

  cat < "$HOME/.ssh/id_rsa.pub" | fold | awk '{ print "\t" $0 }'
  console::break
  console::prompt "Add your key to your Github account (https://github.com/) and continue...\n" && read -r -e x

  echo "github.com" > "$HOME/.ssh/known_hosts"
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
