#!/usr/bin/env bash

tools::install_jetbrains_toolbox() {
  wget -O - "https://raw.githubusercontent.com/nagygergo/jetbrains-toolbox-install/master/jetbrains-toolbox.sh" | bash
}
