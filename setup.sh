#!/usr/bin/env bash

source "lib/console.sh"

set -o pipefail

function main() {
  console::banner

  setup::request_sudo "$@"

  gist_location=https://gist.githubusercontent.com/hschne/2f079132060adf903abe3e2afdc2be96/raw/Setup.md
  # Extract all fenced code blocks from the gist 
  wget -O - -o /dev/null $gist_location | sed -n '/^```/,/^```/ p' | sed '/^```/d' | cat -s | bash

  console::info "Installation finished successfully!\n"
  console::break

  setup::reboot
}


setup::request_sudo() {
  if ! sudo -n true >/dev/null 2>&1; then { 
    console::prompt "This script requires sudo access. Please enter your password: ";
    sudo -p "" -v -n; console::break; 
  }; fi

  # Keep-alive: update existing sudo time stamp until the script has finished
  # See here: https://gist.github.com/cowboy/3118588
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

# Reboot after prompting the user for it
# Taken from https://unix.stackexchange.com/a/426189
setup::reboot() {
  console::prompt "It is recommended that you reboot your PC\n"
  console::prompt "Would you like to reboot now? (y/N) " && read -r -e x
  if [[ "$x" == "y" ]]; then 
    reboot
  fi
}

setup::die(){
  local message=$1
  console::error "$message\n" && exit 1
}

setup::handle_abort() {
  console::break
  setup::die "Installation aborted by user\n" 
}

setup::handle_error() {
  console::break
  setup::die "Some setup steps failed" 
}

trap 'setup::handle_abort $?' SIGINT
trap 'setup::handle_error $?' ERR

# Entrypoint
main "$@"
