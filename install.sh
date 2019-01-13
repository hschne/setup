#!/usr/bin/env bash

declare -g ERROR=0
declare -g DRY_RUN=0

declare spinner_pid

declare esc_seq="\e["
declare col_reset="${esc_seq}0m"
declare col_red="${esc_seq}38;5;9m"
declare col_green="${esc_seq}32m"
declare col_yellow="${esc_seq}33m"
declare col_blue="${esc_seq}34m"

function main() {
  print_banner

  echo "test"
  # Ask for sudo in the beginning, so that's done with
  sudo_keep_alive

  pacman_packages=( 
    bat 
    chrome-gnome-shell
    diff-so-fancy
    gdm
    git
    gvim
    hub 
    jdk-11-openjdk
    maven 
    thefuck
    zsh 
  )

  install_packages "${pacman_packages[@]}"
  exit 0

  # sudo pacman -Syy && sudo pacman -S --noconfirm --needed "${1[@]}"


  community_packages=(
    synology-cloud-station-drive
    rambox-bin
    ngrok
    nerd-fonts-complete
  )

  install_tools

  reboot
}

print_banner() {
  clear 
cat << "EOF"

+============================================================================+
|    _____ _                             _      _____      _                 |
|   / ____| |                           | |    / ____|    | |                |
|  | |  __| |_   _ _ __ ___  _ __   __ _| |_  | (___   ___| |_ _   _ _ __    |
|  | | |_ | | | | | '_ ` _ \| '_ \ / _` | __|  \___ \ / _ \ __| | | | '_ \   |
|  | |__| | | |_| | | | | | | |_) | (_| | |_   ____) |  __/ |_| |_| | |_) |  |
|   \_____|_|\__,_|_| |_| |_| .__/ \__,_|\__| |_____/ \___|\__|\__,_| .__/   |
|                           | |                                     | |      |
|                           |_|                                     |_|      |
|                                                                            |
+============================================================================+

EOF
}

print_info() {
  local time
  time=$(date +"%Y-%m-%d %H:%M:%S")
  printf "${col_yellow}[%-5s]${col_reset} ${col_blue}%s${col_reset} - %s\n" "INFO" "$time" "$1"
}

print_error() {
  local time
  time=$(date +"%Y-%m-%d %H:%M:%S")
  printf "${col_red}[%-5s]${col_reset} ${col_blue}%s${col_reset} - %s\n" "ERROR" "$time" "$@"
}

print_empty() {
  echo -e "\n"
}

configure_gdm(){
  sudo systemctl disable lightdm && sudo systemctl enable gdm.
}


install_packages() {
  local -a packages=( "$@" )
  local packages_string 
  packages_string=$(printf "%s, " "${packages[@]}" | cut -d "," -f 1-${#packages[@]})
  print_info "Packages to install: $packages_string"

  run_with_spinner "Installing packages..." "sleep 4"

  # Set shell for user, done here to avoid timeout problems for sudo 
  # sudo chsh -s "/bin/zsh" "${USER}"

  # yaourt -S --noconfirm --needed \
  #   synology-cloud-station-drive
}

run_with_spinner() {
  local message=$1
  local command="$2"

  time=$(date +"%Y-%m-%d %H:%M:%S")
  # Like print_info, but without the trailing newline
  printf "${col_yellow}[%-5s]${col_reset} ${col_blue}%s${col_reset} - %s" "INFO" "$time" "$message"
  start_spinner
  $command
  result=$?

  stop_spinner 
  [[ $result -eq 0 ]] && printf " ${col_green}Done${col_reset}\n" || printf " ${col_red}Error${col_reset}\n"
}

spinner() {
  local spinner="/|\\-/|\\-"
  while :
  do
    for i in $(seq 0 7)
    do
      printf "${spinner:$i:1}"
      printf "\010"
      sleep .3
    done
  done
}

start_spinner() {
  spinner &
  spinner_pid=$!
}

stop_spinner() {
  [[ -z "$spinner_pid" ]] && return 0

  kill -9 "$spinner_pid" > /dev/null 
  unset spinner_pid
}

function install_tools() {
  appindicator
  jetbrains_toolbox
  rbenv
  pyenv
  nvm_
  zplug
  homeshick
  vim_
  nord
}

generate_ssh_key() {
  cat "/dev/zero" | ssh-keygen -b 4096 -q -N "" -C "$1"
}

function rbenv {
  local rbenv_root="${HOME}/.rbenv"
  gclone "rbenv/rbenv" "${rbenv_root}" 

  # Ruby-build is required to actually install ruby versions
  mkdir -p "${rbenv_root}/plugins"
  gclone "rbenv/ruby-build" "${rbenv_root}/plugins/ruby-build"

  local rbenv_bin="${rbenv_root}/bin/rbenv"
  local version=$("${rbenv_bin}" install -l | highest_version) 
  "${rbenv_bin}" install "${version}"
}

function pyenv() {
  local pyenv_root="${HOME}/.pyenv"
  gclone "https://github.com/pyenv/pyenv.git" "${pyenv_root}"

  local pyenv_bin="${pyenv_root}/bin/pyenv"
  local version=$("${pyenv_bin}" install -l | highest_version)
  "${pyenv_bin}" install "${version}"
}

function nvm_() {
  local nvm_root="${HOME}/.nvm"
  gclone "https://github.com/creationix/nvm.git" "${nvm_root}"

  # Make nvm immediatly accessible in shell
  export NVM_DIR="${HOME}/.nvm"
  source ${NVM_DIR}/nvm.sh
  nvm install node
}

function jenv() {
  local jenv_root="${HOME}/.jenv"
  gclone "https://github.com/gcuisinier/jenv.git" "${jenv_root}"

  local jenv_bin="${jenv_root}/bin/jenv"
  $jenv_bin init -
  ${jenv_bin} add --skip-existing /usr/lib/jvm/java-10-openjdk
}

function zplug() {
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
}

function homeshick(){
  local homeshick_root="${HOME}/.homesick/repos/homeshick"
  gclone git://github.com/andsens/homeshick.git "${homeshick_root}"

  homeshick_bin="${homeshick_root}/bin/homeshick"
  # Clone dotfiles
  ${homeshick_bin} clone --batch glumpat/dotfiles
  # Clone scripts
  ${homeshick_bin} clone --batch glumpat/scripts
  ${homeshick_bin} link --force
}

function vim_() {
  gclone "https://github.com/VundleVim/Vundle.vim.git" ~/.vim/bundle/Vundle.vim

  vim +PluginInstall +qall
}

function nord() {
  local nord_url="https://raw.githubusercontent.com/arcticicestudio/nord-gnome-terminal/develop/src/nord.sh"
  wget -O - "${nord_url}" | bash
}

function appindicator() {
  # Use the repository clone for headless installation, see GitHub for more info: https://github.com/Ubuntu/gnome-shell-extension-appindicator
  local extension_home="${HOME}/.local/share/gnome-shell/extensions"
  gclone ubuntu/gnome-shell-extension-appindicator \
    "${extension_home}/appindicatorsupport@rgcjonas.gmail.com"

  gnome-shell-extension-tool -e appindicatorsupport@rgcjonas.gmail.com
}

function jetbrains_toolbox() {
  wget -O - "https://raw.githubusercontent.com/nagygergo/jetbrains-toolbox-install/master/jetbrains-toolbox.sh" | bash
}
sudo_keep_alive() {
  sudo -p "Enter your password:" -v
  # Keep-alive: update existing sudo time stamp until the script has finished
  # See here: https://gist.github.com/cowboy/3118588
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}


# Reboot after prompting the user for it
# Taken from https://unix.stackexchange.com/a/426189
function reboot() {
  echo "Setup completed. Reboot? (y/n)" && read x && [[ "$x" == "y" ]] && /sbin/reboot; 
}

# A wrapper around git clone. Does not rely on the path and clones with shallow 
# in order to speed up process. 
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
function gclone() {
  local git="/usr/bin/git"
  local source="https://github.com/$1.git"
  local destination="$2"
  [[ -z $destination ]] &&  destination="$HOME"

  "${git}" clone --depth 1 "$source" "$destination"
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
function highest_version() {
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

handle_exit() {
  stop_spinner
  echo ""
  print_error "Installation aborted by user" 
  exit 0
}

handle_error() {
  stop_spinner
  print_error "ERROR"
  exit 1
}

trap 'handle_exit $?' 2
trap 'handle_error $?' ERR

# Entrypoint
main "$@"
