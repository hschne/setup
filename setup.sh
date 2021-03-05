#!/usr/bin/env bash

source "lib/console.sh"
source "lib/spinny.sh"

DEBUG=0

set -o pipefail

function main() {
  console::banner

  setup::parse_arguments "$@"

  setup::request_sudo "$@"

  setup::github "$@"

  gist_location=https://gist.githubusercontent.com/hschne/2f079132060adf903abe3e2afdc2be96/raw/0be5a8359d2b5a18c90b6b83fa116f007bd763ae/Setup.md
wget -O - -o /dev/null $gist_location | \
  sed '/^#/d' | \ 
  sed '/^```/d' | \ 
  cat -s | \
  head -n -5 > /tmp/setup.sh
  chmod +x /tmp/setup.sh
  /tmp/setup.sh

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
      *) 
        positional+=("$1") # save it in an array for later
        shift
        ;;
    esac
  done
  set -- "${positional[@]}" # restore positional parameters
}

setup::github() {
  mkdir "$HOME/.ssh"

  console::info "To continue we'll need to upload a SSH key to GitHub.\n"
  console::prompt "Enter the script personal access token: " && { local token; read -e -r token; }
  console::break

  console::info "Generating a new SSH key and uploading it to Github... "
  spinny::start

  local name; name="$USER@$(hostname)"
  local status; status=$(curl -o /dev/null \
    -s -w "%{http_code}\n" \
    -H "Authorization: token $token"
    --data "{\"title\":\"$name\",\"key\":\"$(cat ~/.ssh/id_rsa.pub)\"}" \
    https://api.github.com/user/keys)
  spinny::stop

  #TODO: Handle error codes nicely
  if [[ "$status" -ne "201" ]]; then
    console::print " error\n" red
    console::error "Failed to upload SSH key. Exiting setup...\n"
    exit 1;
  fi
  console::print " done\n" "green"

  ssh-keyscan github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
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
  spinny::stop 2>/dev/null
}

setup::handle_abort() {
  console::break
  setup::die "Installation aborted by user\n" 
}

setup::handle_error() {
  console::break
  setup::die "Some setup steps failed. See '$LOG_FILE' for more information\n"
}

trap 'setup::handle_abort $?' SIGINT
trap 'setup::handle_error $?' ERR

# Entrypoint
main "$@"
