#!/usr/bin/env bash

readonly TMP_DIR="/tmp/install"

USER_HOME=

function main() {
  if [ "${UID}" -ne "0" ]; then
    echo "You must be root to run $0."
    exit 1
  fi

  # Set original user home, see https://stackoverflow.com/a/7359006
  USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)

  install_packages 

  install_tools
}

function install_packages() {
  sudo -u "${USER}" pacman -S --noconfirm --needed \
    git \
    gvim \
    zsh

  sudo -u "${SUDO_USER}" yaourt -S --noconfirm --needed \
   # jdk \
    maven 
}

function install_tools() {
  #rbenv
  #pyenv
  install_nvm
  jenv
  fzf
  oh_my_zsh
}

function rbenv {
  local rbenv_root="${USER_HOME}/.rbenv"

  gclone "https://github.com/rbenv/rbenv.git" "${rbenv_root}"

  # Ruby-build is required to actually install ruby versions
  run_as "${SUDO_USER}" mkdir -p "${rbenv_root}/plugins"
  gclone "https://github.com/rbenv/ruby-build.git" "${rbenv_root}/plugins/ruby-build"

  local rbenv_bin="${rbenv_root}/bin/rbenv"
  local result=$(run_as ${SUDO_USER} "${rbenv_bin}" install -l) 
  local version=$(echo "${result}" | highest_version)
  run_as "${SUDO_USER}" "${rbenv_bin}" install "${version}"
}

function pyenv() {
  local pyenv_root="${USER_HOME}/.pyenv"
  gclone "https://github.com/pyenv/pyenv.git" "${pyenv_root}"

  local pyenv_bin="${pyenv_root}/bin/pyenv"
  local result=$(run_as ${SUDO_USER} "${pyenv_bin}" install -l) 
  local version=$(echo "${result}" | highest_version)
  run_as "${SUDO_USER}" "${pyenv_bin}" install "${version}"
}

function install_nvm() {
  local nvm_root="${USER_HOME}/.nvm"
  gclone "https://github.com/creationix/nvm.git" "${nvm_root}"

  # Make nvm immediatly accessible in shell
  export NVM_DIR="${USER_HOME}/.nvm"
  sudo su ${SUDO_USER} <<EOF
    . ${NVM_DIR}/nvm.sh
   nvm install node
EOF

}

function jenv() {
  local jenv_root="${USER_HOME}/.jenv"
  gclone "https://github.com/gcuisinier/jenv.git" "${jenv_root}"
}

function oh_my_zsh() {
  # Lets do this manually, because the install script does a bunch of stuff we don't need
  local ohmyzsh_root="${USER_HOME}/.oh-my-zsh"
  gclone "https://github.com/robbyrussell/oh-my-zsh.git" "${ohmyzsh_root}"

  # Change shell to zsh
  chsh -s "/bin/zsh" ${SUDO_USER}
}

function fzf() {
  echo "Install fzf"
  local fzf_root="${USER_HOME}/.fzf"
  gclone "https://github.com/junegunn/fzf.git" "${fzf_root}"
}

# Check if a certain program is installed.  
# 
# Taken from https://gist.github.com/JamieMason/4761049
#
# $1 - Command to be checked.
#
# Examples
#
#   is_installed "git"
#
# Returns 0 if the program is installed and 1 otherwise. 
function is_installed {
  local result=0
  type $1 >/dev/null 2>&1 || { local result=1; }
  return $result
}

# Prompts the user to perform a manual step. 
#
# Arguments:
#
# $1 - A message to display
#
# Examples
#
#   manual "Please install zsh manually"
# 
function manual() {
  local message=$1
  echo ${message}
  read -n 1 -s -r -p "Press any key to continue..."
}

# A wrapper around git clone. Does not rely on the path.
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
  # Run clone as original user, not as sudo
  sudo -u "${SUDO_USER}" "${git}" clone --depth=1 $1 $2
}

# Run the specified command as specified user
function run_as() {
  local user=$1
  shift
  sudo -u $user $@ 
}

function highest_version() {
  # Magic comes from here: https://stackoverflow.com/a/30183040/2553104
  awk -F '.' '
  /^[[:space:]]*[0-9]+\.[0-9]+\.[0-9]+[[:space:]]*$/ {
  if ( ($1 * 100 + $2) * 100 + $3 > Max ) {
    Max = ($1 * 100 + $2) * 100 + $3
    Version=$0
  }
}
END { print Version }'
}

main "$@"
