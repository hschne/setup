#!/usr/bin/env bash

tools::nord() {
  console::info "Setting up Nord color scheme\n "

  # Download to temp file to avoid pipes. They fuck up the loggin output
  local tempfile
  tempfile=$(mktemp "/tmp/nord_XXXXX.sh")
  local nord_url="https://raw.githubusercontent.com/arcticicestudio/nord-gnome-terminal/develop/src/nord.sh"
  # Quote command in order to maintain pipes
  setup::execute wget -O "$tempfile" ${nord_url} 
  console::info "Downloaded Nord installer \n"

  chmod +x "$tempfile"

  spinner::run "Installing nord color scheme"\
    setup::execute \
    "$tempfile" 
}

