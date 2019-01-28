#!/usr/bin/env bash

tools::install_vundle() {
  console::info "Setting up Vundle and Vim plugins"
  local repo="VundleVim/Vundle.vim"
  local destination="$HOME/.vim/bundle/Vundle.vim"
  spinner::run "Cloning '$repo' into '$destination'..." \
    tools::gclone "$repo" "$destination"

  setup::execute vim +PluginInstall +qall
  console::result "Installed Vim plugins successfully\n" "Failed to install Vim plugins\n"
}
