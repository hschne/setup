#!/usr/bin/env bash

declare -Ag colors=( 
  [default]="\e[0m"
  [red]="\e[38;5;9m"
  [green]="\e[32m"
  [yellow]="\e[33m"
  [blue]="\e[34m"
  [cyan]="\e[38;5;44m"
) 

console::msg() {
  local subject=$1
  local color=${colors[$2]}
  local default=${colors[default]}
  local blue=${colors[blue]}
  shift 2
  local time
  time=$(date +"%Y-%m-%d %H:%M:%S")
  printf "${color}[%-6s]${default} ${blue}%s${default} - %b" "$subject" "$time" "$1"
}

console::print() {
  local msg=$1
  local color=${colors[$2]}
  local default=${colors[default]}
  printf "%b%b%b" "${color}" "$msg" "$default"
}

console::debug() {
  console::msg "DEBUG" "cyan" "$1"
}

console::info() {
  console::msg "INFO" "yellow" "$1"
}

console::error() {
  console::msg "ERROR" "red" "$1"
}

console::prompt() {
  console::msg "PROMPT" "green" "$1"
}

console::break() {
  printf "\n"
}

console::banner() {
  clear 
  cat << "EOF"

+============================================================================+
|    _____ _                             _      _____      _                 |
|   / ____| |                           | |    / ____|    | |                |
|  | |  __| |_   _ _ __ ___  _ __   __ _| |_  | (___   ___| |_ _   _ _ __    |
|  | | |_ | | | | | '_ ` _ \| '_ \ / _` | __|  \___ \ / _ \ __| | | | '_ \   |
|  | |__| | | |_| | | | | | | |_) | (_| | |_   ____) |  __/ |_| |_| | |_) |  |
|   \_____|_|\__,_|_| |_| |_| .__/ \__,_|\__| |_____/ \___|\__|\__,_| .__/   |
|                           | |                                     | |      |
|                           |_|                                     |_|      |
|                                                                            |
+============================================================================+

EOF
}

console::color() {
  local color=$1
  printf "%b\n" "${colors[$color]}"
}

set -o pipefail

function main() {
  console::banner

  setup::request_sudo "$@"

  file_location=https://raw.githubusercontent.com/glumpat/setup/master/files/setup.md
  # Extract all fenced code blocks from the gist 
  wget -O - -o /dev/null $file_location | sed -n '/^```/,/^```/ p' | sed '/^```/d' | cat -s | bash

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
