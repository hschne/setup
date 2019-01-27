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
  setup::parse_arguments "$@"

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
  return $result
}

# TODO: Move this to appropriate tool file
configure_gdm(){
  sudo systemctl disable lightdm && sudo systemctl enable gdm
}

setup::parse_arguments() {
  local positional=()
  while [[ $# -gt 0 ]]
  do
    key="$1"
    case $key in
      --debug)
        console::info "Starting installation with debug option\n"
        DEBUG=1
        shift 
        ;;
      --dry-run)
        console::info "Dry run option set\n"
        DRY_RUN=1
        shift
        ;;
      *) 
        positional+=("$1") # save it in an array for later
        shift # past argument
        ;;
    esac
  done
  set -- "${positional[@]}" # restore positional parameters
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
