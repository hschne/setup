#!/usr/bin/env bash

readonly TMP_DIR="/tmp/"

readonly UTIL="util.sh"

function main() {
  source ${UTIL}  

  git
  manual "Please confirm the procedure. It will require a strong will."
}

function git(){
  local git="git"
  if ! [ $(is_installed git) ]; then 
    manual 'git'
  else
    printf "Git is already installed...\n"
  fi
}

function jdk() {
  echo "Install jdk"
}

function mvn() {
  echo "Install maven"
}
function rbenv {
  echo "Install rbenv"
}

function pyenv() {
  echo "Install pyenv"
}

function nvm() {
  echo "Install nvm"
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

main "$@"
