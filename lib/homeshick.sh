#!/usr/bin/env bash

tools::homeshick(){
  local homeshick_root="${HOME}/.homesick/repos/homeshick"
  gclone git://github.com/andsens/homeshick.git "${homeshick_root}"

  homeshick_bin="${homeshick_root}/bin/homeshick"
  # Clone dotfiles
  ${homeshick_bin} clone --batch glumpat/dotfiles
  # Clone scripts
  ${homeshick_bin} clone --batch glumpat/scripts
  ${homeshick_bin} link --force
}
