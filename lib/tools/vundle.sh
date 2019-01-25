#!/usr/bin/env bash

tools::install_vundle() {
  gclone "https://github.com/VundleVim/Vundle.vim.git" ~/.vim/bundle/Vundle.vim

  vim +PluginInstall +qall
}
