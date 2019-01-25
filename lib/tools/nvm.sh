#!/usr/bin/env bash

tools::nvm() {
  local nvm_root="${HOME}/.nvm"
  gclone "https://github.com/creationix/nvm.git" "${nvm_root}"

  # Make nvm immediatly accessible in shell
  export NVM_DIR="${HOME}/.nvm"
  source "${NVM_DIR}/nvm.sh"
  nvm install node
}
