#!/usr/bin/env bash

packages::install() {
  packages::pacman
  packages::aur
}

packages::pacman() {
  local -a packages=( 
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
  local packages_string 
  packages_string=$(printf "%s, " "${packages[@]}" | cut -d "," -f 1-${#packages[@]})
  ui::print_info "Packages to install: $packages_string \n"

  ui::run_with_spinner "Installing packages..." \
    "command::execute sudo pacman -S --noconfirm ${packages[*]}"
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
  ui::print_info "Community packages to install: $packages_string \n"

  ui::run_with_spinner "Installing community packages..." \
    "command::execute yaourt -S --noconfirm --needed ${packages[*]}"

}
