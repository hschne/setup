#!/usr/bin/env bash

source "./lib/console.sh"

printf "cols: ${col_yellow}bla\n"

color=$(console::color "yellow")
echo "COLOR: $color"
printf "${color}%s" "testing\n"
