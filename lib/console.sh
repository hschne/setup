#! /usr/bin/env bash

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

