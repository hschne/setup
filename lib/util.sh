#!usr/bin/env bash

generate_ssh_key() {
  cat "/dev/zero" | ssh-keygen -b 4096 -q -N "" -C "$1"
}

util::request_sudo() {
  if ! sudo -n true >/dev/null 2>&1; then { ui::print_prompt "Please enter your password: "; sudo -p "" -v; ui::break; }; fi

  # Keep-alive: update existing sudo time stamp until the script has finished
  # See here: https://gist.github.com/cowboy/3118588
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}


# Reboot after prompting the user for it
# Taken from https://unix.stackexchange.com/a/426189
util::reboot() {
  echo "Setup completed. Reboot? (y/n)" && read x && [[ "$x" == "y" ]] && /sbin/reboot; 
}
