#!/usr/bin/env bash

tools::jetbrains_toolbox() {
  local tempfile
  tempfile=$(mktemp "/tmp/toolbox_XXXXX.sh")
  spinner::run "Downloading Jetbrains toolbox" \
    setup::execute \
    wget -O "$tempfile" https://raw.githubusercontent.com/nagygergo/jetbrains-toolbox-install/master/jetbrains-toolbox.sh 
  chmod +x "$tempfile"
  spinner::run "Installing Jetbrains toolbox"\
    setup::execute \
    "$tempfile"
}
