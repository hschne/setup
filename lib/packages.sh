#!/usr/bin/env bash

packages::install() {
  packages::pacman
  packages::aur
}

packages::pacman() {
  local -a packages=( 
    chrome-gnome-shell
    diff-so-fancy
    docker 
    docker-compose
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
  
  spinner::run "Updating package database..."\
    setup::execute \
    sudo pacman -Syu --noconfirm

  packages_string=$(printf "%s, " "${packages[@]}" | cut -d "," -f 1-${#packages[@]})
  console::info "Packages to install:\n"
  console::break
  printf "%s" "$packages_string" | fold | awk '{ print "\t" $0 }'
  console::break
  spinner::run "Installing packages. This could take a while..." \
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
  console::info "Community packages to install:\n"
  console::break
  printf "%s" "$packages_string" | fold | awk '{ print "\t" $0 }'
  console::break
  spinner::run "Installing community packages. This could take a while..." \
    setup::execute \
    yaourt -S --noconfirm --needed "${packages[@]}"
}
