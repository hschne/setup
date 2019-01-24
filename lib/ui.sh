#! /usr/bin/env bash

declare esc_seq="\e["
declare col_reset="${esc_seq}0m"
declare col_red="${esc_seq}38;5;9m"
declare col_green="${esc_seq}32m"
declare col_yellow="${esc_seq}33m"
declare col_blue="${esc_seq}34m"
declare col_cyan="${esc_seq}38;5;44m"

declare -Ag colors=( 
  [default]="${esc_seq}0m"
  [red]="${esc_seq}38;5;9m"
  [green]="${esc_seq}32m"
  [yello]="${esc_seq}33m"
  [blue]="${esc_seq}34m"
  [cyan]="${esc_seq}38;5;44m"
) 

console::msg() {
  local color=$1
  local subject=$2
  shift 2
  local time
  time=$(date +"%Y-%m-%d %H:%M:%S")
  printf "${color}[%-6s]${col_reset} ${col_blue}%s${col_reset} - %b" "$subject" "$time" "$1"
}

console::print() {
  local msg=$1
  local color=$2
  printf "%s%b%s" ${color} $msg ${col_reset}
}

console::debug() {
  console::msg "$col_cyan" "DEBUG" "$1"
}

console::info() {
  console::msg "$col_yellow" "INFO" "$1"
}

console::error() {
  console::msg "$col_red" "ERROR" "$1"
}

console::prompt() {
  console::msg "$col_green" "PROMPT" "$1"
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

console::summary() {
  if [[ $ERROR -ne 0 ]]; then 
    console::info "Installation finished\n"
    console::break
    console::info "Parts of the installation failed. See '$LOG_FILE' for more information\n"
  else
    console::info "Installation finished successfully!\n"
    console::break
  fi
}

console::color() {
  local color=$1
  printf ${colors[color]}
}

