#!/usr/bin/env bash

packages::install() {
  packages::pacman
  packages::aur
}

packages::pacman() {
  local -a packages=( 
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
    tmux
  )
  local packages_string 
  
  spinner::run "Updating package database"\
    setup::execute \
    sudo pacman -Syu --noconfirm

  packages_string=$(printf "%s, " "${packages[@]}" | cut -d "," -f 1-${#packages[@]})
  console::info "Packages to install: $packages_string \n"

  spinner::run "Installing packages. This could take a while" \
    setup::execute \
    sudo pacman -S --noconfirm "${packages[@]}"
}

packages::aur() {
  local -a packages=(
    synology-cloud-station-drive
    rambox-bin
    ngrok
    nerd-fonts-complete
  )
  local packages_string 
  packages_string=$(printf "%s, " "${packages[@]}" | cut -d "," -f 1-${#packages[@]})
  console::info "Community packages to install: $packages_string \n"

  spinner::run "Installing community packages. This could take a while" \
    setup::execute \
    yaourt -S --noconfirm --needed "${packages[@]}"
}
