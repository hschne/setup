#!/usr/bin/env bash

tools::zplug() {
  console::info "Setting up zplug\n"
  setup::execute sudo chsh -s "/bin/zsh" "$USER"
  console::result "Default shell changed to zsh\n" "Failed to change shell to zsh\n"
  local destination="$HOME/.zplug"
  spinner::run "Cloning 'zplug/zplug' into '$destination'"\
    tools::gclone zplug/zplug "$destination"
}
