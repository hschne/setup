#!/usr/bin/env bash

readonly TMP_DIR="/tmp/install"

readonly UTIL="util.sh"

function main() {
  if [ "$UID" -ne "0" ]; then
      echo "You must be root to run $0."
      exit 1
  fi

  git
  jdk
  mvn
  rbenv
  pyenv
  nvm
  
}

function git(){
  local git="git"
  if ! [ $(is_installed git) ]; then 
    manual "Git must be installed manually. Visit https://git-scm.com/download/linux for installation instructions."
  else
    printf "Git is already installed...\n"
  fi
}

function jdk() {
  echo "Install jdk"
  if [ $(is_installed java) ]; then 
    printf "Java is already installed...\n"
    return 0
  fi
  sudo yaourt -S --noconfirm jdk 
}

function mvn() {
  echo "Install mvn"
  if [ $(is_installed mvn) ]; then 
    printf "Maven is already installed...\n"
      return 0
  fi
  sudo yaourt -S --noconfirm maven
}

function rbenv {
  echo "Install rbenv"
  local rbenv_root="${HOME}/.rbenv"
  gclone "https://github.com/rbenv/rbenv.git" "${rbenv_root}"
  # Ruby-build is required to actually install ruby versions
  mkdir -p "${rbenv_root}/plugins"
  gclone "https://github.com/rbenv/ruby-build.git" "${rbenv_root}/plugins/ruby-build"
}

function pyenv() {
  echo "Install pyenv"
  local pyenv_root="${HOME}/.pyenv"
  gclone "https://github.com/pyenv/pyenv.git" "${pyenv_root}"
}

function nvm() {
  echo "Install nvm"
  local nvm_root="${HOME}/.nvm"
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
# Returns 1 if the program is installed and 0 otherwise. 
function is_installed {
  local return=1
  type $1 >/dev/null 2>&1 || { local return=0; }
  echo "${return}"
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
  "${git}" clone $1 $2
}

main "$@"
