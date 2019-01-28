#!/usr/bin/env bash

tools::nvm() {
  console::info "Setting up nvm and node\n"
  local nvm_root="${HOME}/.nvm"
  
  spinner::run "Cloning 'creationix/nvm'..." \
    tools::gclone creationix/nvm "${nvm_root}"

  # Make nvm immediatly accessible in shell
  export NVM_DIR="${HOME}/.nvm"
  #shellcheck disable=SC1090
  source "${NVM_DIR}/nvm.sh"
  spinner::run "Installing latest version of node..." \
    setup::execute \
      nvm install node
}
