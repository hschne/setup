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

  git
  jdk
  mvn
  rbenv
  pyenv
  nvm

}

function git(){
  local git="git"
  if ! is_installed git; then 
    manual "Git must be installed manually. Visit https://git-scm.com/download/linux for installation instructions."
  else
    printf "Git is already installed...\n"
  fi
}

function jdk() {
  if is_installed java; then 
    printf "Java is already installed...\n"
    return
  fi
  yaourt -S --noconfirm jdk
}

function mvn() {
  if is_installed mvn; then 
    printf "Maven is already installed...\n"
    return 
  fi
  yaourt -S --noconfirm maven
}

function rbenv {
  echo "Install rbenv"
  local rbenv_root="${USER_HOME}/.rbenv"

  gclone "https://github.com/rbenv/rbenv.git" "${rbenv_root}"
  # Ruby-build is required to actually install ruby versions
  sudo -u "${SUDO_USER}" mkdir -p "${rbenv_root}/plugins"
  gclone "https://github.com/rbenv/ruby-build.git" "${rbenv_root}/plugins/ruby-build"
}

function pyenv() {
  echo "Install pyenv"
  local pyenv_root="${USER_HOME}/.pyenv"
  gclone "https://github.com/pyenv/pyenv.git" "${pyenv_root}"
}

function nvm() {
  echo "Install nvm"
  local nvm_root="${USER_HOME}/.nvm"
  gclone "https://github.com/creationix/nvm.git" "${nvm_root}"
}

function zsh() {
  echo "Install zsh"
}

function oh_my_zsh() {
  echo "Install oh-my-zsh"
}

function cloud_station(){
  echo "Install cloud station"
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

# Just a test, might get back to this later
function run_as() {
  local user=$1
  shift
  echo "I am $user"
su ${user} <<'EOF'
  $@
EOF
}

main "$@"
