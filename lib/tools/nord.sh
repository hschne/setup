#!/usr/bin/env bash

tools::nord() {
  local nord_url="https://raw.githubusercontent.com/arcticicestudio/nord-gnome-terminal/develop/src/nord.sh"
  wget -O - "${nord_url}" | bash
}

