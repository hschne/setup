
declare spinner_pid

declare esc_seq="\e["
declare col_reset="${esc_seq}0m"
declare col_red="${esc_seq}38;5;9m"
declare col_green="${esc_seq}32m"
declare col_yellow="${esc_seq}33m"
declare col_blue="${esc_seq}34m"
declare col_cyan="${esc_seq}38;5;44m"

ui::print() {
  local color=$1
  local subject=$2
  shift 2
  local time
  time=$(date +"%Y-%m-%d %H:%M:%S")
  printf "${color}[%-6s]${col_reset} ${col_blue}%s${col_reset} - %b" "$subject" "$time" "$1"
}

ui::print_debug() {
  ui::print "$col_cyan" "DEBUG" "$1"
}

ui::print_info() {
  ui::print "$col_yellow" "INFO" "$1"
}

ui::print_error() {
  ui::print "$col_red" "ERROR" "$1"
}

ui::print_prompt() {
  ui::print "$col_green" "PROMPT" "$1"
}

ui::break() {
  printf "\n"
}

ui::print_banner() {
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
    [[ $result -eq 0 ]] && printf "${col_green}done${col_reset}\n" || printf " ${col_red}error${col_reset}\n"
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
      printf "${spinner:$i:1}"
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

  kill -9 "$spinner_pid" > /dev/null 
  unset spinner_pid
}
