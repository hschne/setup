#!/usr/bin/env bash

main() {
  local test_dir
  test_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"   
  local source_dir
  source_dir="$(dirname "$test_dir")"

  echo "SOURCE: $source_dir"

  docker run --rm -it -v "$source_dir":/home/ antergos/archlinux-base-devel bash -c  "cd /home; ./install.sh"
}

main "$@"
