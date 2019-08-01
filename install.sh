#!/usr/bin/env bash

source "lib/console.sh"
source "lib/util.sh"
source "lib/spinny.sh"

ERROR=0
DEBUG=0

LOG_FILE=""

user="hschne"
HOME="/home/$user"

set -oe pipefail

function main() {
  console::banner

  setup::parse_arguments "$@"

  setup::setup_output

  setup::user

  setup::ssh

  setup::install_tools

  setup::install_packages

  console::summary

  setup::reboot
}

setup::setup_output(){
  if [[ "$DEBUG" -eq 1 ]]; then
  exec 3>&2 
else 
  exec 3>/dev/null
fi
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

setup::upload_ssh() {
  local username=$1
  local password=$2
  local otp=$3

  local name="$user@$(hostname)"

status =$(curl -o /dev/null \
  -s -w "%{http_code}\n" \
  -u "$username:$password" \
  --data "{\"title\":\"$name\",\"key\":\"$(cat ~/.ssh/id_rsa.pub)\"}" \
  https://api.github.com/user/keys)
  echo "Result $?"
  

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
    curl \
    openssh \
    sudo \
    inetutils
  setup::spinstop

  console::info "Creating new user...\n"
  chmod 640 /etc/sudoers 
  echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
  chmod 440 /etc/sudoers 
  useradd -m -p "$user" -G wheel "$user" 
}

setup::ssh() {
  console::info "The setup requires a new SSH key to be generated.\n"
  console::prompt "Please enter your email: " && { local email; read -e -r email; }

  sudo -u "$user" mkdir $HOME/.ssh >&3
  sudo -u "$user" ssh-keygen -b 4096 -t rsa -N '' -q -C "$email" -f "$HOME/.ssh/id_rsa"

  console::info "New SSH key generated. Now let's upload that to GitHub!\n"
  console::prompt "Please enter your Github username: " && { local login; read -e -r login; }
  console::prompt "Now your password: " && { local password; read -e -r password; }
  console::prompt "And finally your Github OTP code: " && { local password; read -e -r otp; }
  key_data="$( cat "$HOME/.ssh/id_rsa")"
  title="$user@$(hostname)"
  curl -u "$login:$password"  \
    --header "authorization: Basic $password" \
    --header 'content-type: application/json' \
    --header "x-github-otp: $otp" \
    --data "{\"title\":\"$title\",\"key\":\"$key_data\"}" \
    https://api.github.com/user/keys

  ssh -T git@github.com 2>&1 | grep "success"
  echo "github.com" > "$HOME/.ssh/known_hosts"
  console::info "Added 'github.com' to known hosts\n"
}

setup::install_packages() {
  setup::spinstart "Updating package database and installing yay..." \
    sudo -u "$user" git clone https://aur.archlinux.org/yay.git && cd yay
  sudo -u "$user" makepkg -si --noconfirm 
  cd .. &&  rm -rf yay 

  setup::wait "Installing packages. This could take a while..." \
    setup::execute \
    sudo -u "$user" yay -S --noconfirm \
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
  # shellcheck
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
  "$user" chsh -s "/bin/zsh" "$user" 
  setup::wait gclone "git@github.com:zplug/zplug.git" "$destination"


  console::info "Setting up TMP and installing tmux plugins..."
  setup::wait "Setting up zplug..."\ 
    setup::execute git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  ~/.tmux/plugins/tpm/scripts/install_plugins.sh
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
setup::spinstart() {
  if [[ $DEBUG -eq 1 ]]; then
    console::info "$1\n"
  else
    console::info "$1\n"
    spinny::start
  fi
}

setup::spinstop() {
  result=$?

  [[ $DEBUG -eq 1 ]] && return 0
  spinny::stop
  if [[ $result -eq 0 ]]; then console::print " done\n" "green"; else  console::print " error\n" red; fi
}

setup::skip() {
  console::debug "Skip execution of '$*' \n"; return 0
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

util::request_sudo() {
  if ! sudo -n true >/dev/null 2>&1; then { console::prompt "Please enter your password: "; sudo -p "" -v; console::break; }; fi

  # Keep-alive: update existing sudo time stamp until the script has finished
  # See here: https://gist.github.com/cowboy/3118588
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}
trap 'setup::handle_exit $?' 2
trap 'setup::handle_error $?' ERR

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
# Entrypoint
main "$@"
