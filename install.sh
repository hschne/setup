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
  ui::print_banner
  # Ask for sudo in the beginning, so that's done with
  
  util::request_sudo
  create_log_file

  packages::install

  tools::install

  print_summary

  exit 0
  

  util::reboot

}

create_log_file() {
  LOG_FILE=$(mktemp "/tmp/setup_XXXXXX.log")
}


setup::execute() {
  if [[ $DRY_RUN -eq 1 ]]; then 
    [[ $DEBUG -eq 0 ]] && return 0
    ui::print_debug "Dry running '$*' \n"; return 0
  fi 

  if [[ $DEBUG -ne 1 ]]; then 
    "$@" &>> "$LOG_FILE"
  else 
    "$@"
  fi
  local result=$?
  [[ $result -ne 0 ]] && ERROR=1
  return $result
}

configure_gdm(){
  sudo systemctl disable lightdm && sudo systemctl enable gdm
}

setup::handle_exit() {
  ui::break
  ui::print_error "Installation aborted by user\n" 
  exit 0
}

setup::handle_error() {
  ui::break
  ui::print_error "Setup failed unexpectedly. See '$LOG_FILE' for more information\n"
  exit 1
}

trap 'handle_exit $?' 2
trap 'handle_error $?' ERR

# Entrypoint
main "$@"
