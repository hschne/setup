#!/usr/bin/env bash

source "lib/console.sh"
source "lib/util.sh"
source "lib/spinner.sh"
source "lib/tools.sh"
source "lib/packages.sh"

declare -g ERROR=0
declare -g DRY_RUN=0
declare -g DEBUG=0

declare -g LOG_FILE=""

set -uo pipefail

function main() {
  console::banner
  util::request_sudo

  util::generate_ssh_key

  packages::install

  tools::install

  console::summary

  exit 0
  
  util::reboot
}


setup::execute() {
  if [[ $DRY_RUN -eq 1 ]]; then 
    console::debug "Skip execution of '$*' \n"; return 0
  fi 

  [[ ! -f "$LOG_FILE" ]] && LOG_FILE=$(mktemp "/tmp/setup_XXXXXX.log")
  if [[ $DEBUG -eq 1 ]]; then 
    "$@" | tee -a "$LOG_FILE"
  else
    "$@" &>> "$LOG_FILE"
  fi
  local result=$?
  [[ $result -ne 0 ]] && ERROR=1
  return $result
}

# TODO: Move this to appropriate tool file
configure_gdm(){
  sudo systemctl disable lightdm && sudo systemctl enable gdm
}

setup::handle_exit() {
  console::break
  console::error "Installation aborted by user\n" 
  exit 1
}

setup::handle_error() {
  console::break
  console::error "Some setup steps faile. See '$LOG_FILE' for more information\n"
  exit 1
}

trap 'setup::handle_exit $?' 2
trap 'setup::handle_error $?' ERR

# Entrypoint
main "$@"
