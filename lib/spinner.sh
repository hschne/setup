#!/usr/bin/env bash 

declare spinner_pid

ui::run_with_spinner() {
  local message=$1
  shift 
  local command=$*

  ui::print_info "$message"
  if [[ $DEBUG -eq 0 ]]; then 
    ui::start_spinner
    $command
    result=$?
    ui::stop_spinner 
    [[ $result -eq 0 ]] && printf " ${col_green}done${col_reset}\n" || printf " ${col_red}failed${col_reset}\n"
  else 
    ui::break
    $command
  fi
}

ui::_spinner() {
  local spinner="/|\\-/|\\-"
  while :
  do
    for i in $(seq 0 7)
    do
      printf "%s" "${spinner:$i:1}"
      printf "\010"
      sleep .3
    done
  done
}

ui::start_spinner() {
  ui::_spinner &
  spinner_pid=$!
}

ui::stop_spinner() {
  [[ -z "$spinner_pid" ]] && return 0

  kill -9 "$spinner_pid" 
  # Use conditional to avoid exiting the program immediatly
  wait "$spinner_pid" 2>/dev/null || true
  unset spinner_pid
}

