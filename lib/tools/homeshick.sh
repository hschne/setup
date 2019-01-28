#!/usr/bin/env bash

tools::homeshick(){
  console::info "Setting up homeshick\n"
  local homeshick_root="${HOME}/.homesick/repos/homeshick"
  spinner::run "Cloning 'andens/homeshick' into '$homeshick_root'..."\
    tools::gclone andsens/homeshick "${homeshick_root}"

  homeshick_bin="${homeshick_root}/bin/homeshick"
  # Clone dotfiles
  console::info "Setting up homeshick castles\n"
  spinner::run "Cloning 'glumpat/dotfiles'..."\
    setup::execute \
    "${homeshick_bin}" clone --batch glumpat/dotfiles
  # Clone scripts
  setup::execute "${homeshick_bin}" link --force
  console::result "Linked castle 'glumpat/dotfiles'\n" "Failed to execute homeshick link\n"
}
