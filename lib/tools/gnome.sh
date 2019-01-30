#!/usr/bin/env bash

tools::gnome() {
  console::info "Disable lightdm and enable systemctl\n"
  setup::execute \
    sudo systemctl disable lightdm && sudo systemctl enable gdm
  console::result "Enabled GDM\n" "Failed to enable gdm\n"
}
