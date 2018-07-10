#!/usr/bin/env bash

# Provides a bunch of utility methods used from the main script


# Check if a certain program is installed.  
# 
# Taken from https://gist.github.com/JamieMason/4761049
#
# $1 - Command to be checked.
#
# Examples
#
#   is_installed "git"
#
# Returns 1 if the program is installed and 0 otherwise. 
function is_installed {
  local return=1
  type $1 >/dev/null 2>&1 || { local return=0; }
  echo "${return}"
}

function manual() {
  local message=$1
  echo ${message}
  read -n 1 -s -r -p "Press any key to continue..."
}

function download() {
  echo "Download file to given location"
}

function clone() {
  echo "Clone given repository to given location"
}
