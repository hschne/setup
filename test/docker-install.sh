#!/usr/bin/env bash

main() {
  local test_dir source_dir tmp_dir
  # Set up sources: Copy everything to a temporary directory 
  test_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"   
  source_dir="$(dirname "$test_dir")"
  tmp_dir=$(mktemp -d)
  cp -r "$source_dir" "$tmp_dir"
  
  # Run installation & integration tests in docker container
  docker run --rm -it \
    -v "$tmp_dir/setup":/home/glumpat \
    "glumpat/setup-test" \
    bash -c  "cd /home/glumpat && ./setup.sh $*"
}

main "$@"
