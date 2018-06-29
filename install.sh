#!/usr/bin/env bash

readonly TMP_DIR="/tmp/"

readonly UTIL="util.sh"

function main() {
  
  source ${UTIL}  
  check_install

  manual
  echo "Hello World!"
}

function git(){
  echo "Install git"
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
