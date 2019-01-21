#!/usr/bin/env bash

source "lib/ui.sh"

declare -g ERROR=0
declare -g DRY_RUN=0
declare -g DEBUG=1

declare -g LOG_FILE

set -uo pipefail

function main() {
  ui::print_banner
  # Ask for sudo in the beginning, so that's done with
  
  request_sudo

  create_log_file

  pacman_packages=( 
    bat 
    chrome-gnome-shell
    diff-so-fancy
    gdm
    git
    gvim
    hub 
    jdk-openjdk
    maven 
    thefuck
    zsh 
  )
  
  # Set shell for user, done here to avoid timeout problems for sudo 
  # sudo chsh -s "/bin/zsh" "${USER}"

  install_packages "${pacman_packages[@]}"

  community_packages=(
    synology-cloud-station-drive
    rambox-bin
    ngrok
    nerd-fonts-complete
  )

  install_community_packages "${community_packages[@]}"

  print_summary

  exit 0
  
  install_tools

  reboot

}

print_summary() {
  if [[ $ERROR -ne 0 ]]; then 
    ui::print_info "Installation finished\n"
    ui::break
    ui::print_info "Parts of the installation failed. See '$LOG_FILE' for more information\n"
  else
    ui::print_info "Installation finished successfully!\n"
    ui::break
  fi
}



create_log_file() {
  LOG_FILE=$(mktemp "/tmp/setup_XXXXXX.log")
}

install_packages() {
  local -a packages=( "$@" )
  local packages_string 
  packages_string=$(printf "%s, " "${packages[@]}" | cut -d "," -f 1-${#packages[@]})
  ui::print_info "Packages to install: $packages_string \n"

  ui::run_with_spinner "Installing packages..." \
    "command::execute sudo pacman -S --noconfirm ${packages[*]}"
}

install_community_packages() {
  local -a packages=( "$@" )
  local packages_string 
  packages_string=$(printf "%s, " "${packages[@]}" | cut -d "," -f 1-${#packages[@]})
  ui::print_info "Community packages to install: $packages_string \n"

  ui::run_with_spinner "Installing community packages..." \
    "command::execute yaourt -S --noconfirm --needed ${packages[*]}"

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


command::execute() {
  if [[ $DRY_RUN -eq 1 ]]; then 
    [[ $DEBUG -eq 0 ]] && return 0
    ui::print_debug "Dry running '$*' \n"; return 0
  fi 

  if [[ $DEBUG -ne 1 ]]; then 
    "$@" &>> "$LOG_FILE"
  else 
    "$@"
  fi
  local result=$?
  [[ $result -ne 0 ]] && ERROR=1
  return $result
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
  source "${NVM_DIR}/nvm.sh"
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

request_sudo() {
  if ! sudo -n true >/dev/null 2>&1; then { ui::print_prompt "Please enter your password: "; sudo -p "" -v; ui::break; }; fi

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

configure_gdm(){
  sudo systemctl disable lightdm && sudo systemctl enable gdm
}

handle_exit() {
  ui::break
  ui::print_error "Installation aborted by user\n" 
  exit 0
}

handle_error() {
  ui::break
  ui::print_error "Setup failed unexpectedly. See '$LOG_FILE' for more information\n"
  exit 1
}

trap 'handle_exit $?' 2
trap 'handle_error $?' ERR

# Entrypoint
main "$@"
