#!/usr/bin/env bash

source "lib/ui.sh"
source "lib/util.sh"
source "lib/tools.sh"

declare -g ERROR=0
declare -g DRY_RUN=0
declare -g DEBUG=1

declare -g LOG_FILE

set -uo pipefail

function main() {
  console::print_banner
  # Ask for sudo in the beginning, so that's done with
  
  util::request_sudo

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

  if [[ $DEBUG -eq 1 ]]; then 
    "$@"
  else
    # Create logfile if necessary
    [[ ! -f "$LOG_FILE" ]] && LOG_FILE=$(mktemp "/tmp/setup_XXXXXX.log")

    "$@" &>> "$LOG_FILE"
  fi
  local result=$?
  [[ $result -ne 0 ]] && ERROR=1
  return $result
}

configure_gdm(){
  sudo systemctl disable lightdm && sudo systemctl enable gdm
}

setup::handle_exit() {
  console::break
  console::error "Installation aborted by user\n" 
  exit 0
}

setup::handle_error() {
  console::break
  console::error "Setup failed unexpectedly. See '$LOG_FILE' for more information\n"
  exit 1
}

trap 'handle_exit $?' 2
trap 'handle_error $?' ERR

# Entrypoint
main "$@"
