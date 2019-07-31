#!/usr/bin/env bash

util::generate_ssh_key() {
  spinner::run "Installing xclip..." \
    setup::execute sudo pacman -S --noconfirm xclip

  console::info "The setup requires a new SSH key to be generated.\n"
  console::prompt "Please enter your email: " && { local email; read -e -r email; }
  local filename="id_rsa"
  
  ssh-keygen -b 4096 -t rsa -N '' -q -C "$email" -f "$HOME/.ssh/id_rsa"
  local result=$?

  if [[ $result != 0 ]]; then 
    console::error "Failed to create new SSH key, aborting setup\n"
    exit 1
  else
    console::info "New SSH key '~/.ssh/$filename' generated:\n\n" 
  fi

  cat < "$HOME/.ssh/id_rsa.pub" | fold | awk '{ print "\t" $0 }'
  console::break
  xclip -sel clip < "$HOME/.ssh/id_rsa.pub"
  console::info "Key has been copied to the clipboard!\n"
  console::prompt "Add your key to your Github account (https://github.com/) and continue...\n" && read -r -e x
  
  echo "github.com" > "$HOME/.ssh/known_hosts"
  console::info "Added 'github.com' to known hosts\n"
}



