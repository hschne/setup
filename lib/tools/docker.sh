#!/usr/bin/env bash

tools::docker() {
  console::info "Configuring docker\n"
  setup::execute sudo usermod -aG docker "$USER" 
  setup::execute sudo systemctl enable docker
  console::result "Successfully configured docker\n" "Failed to add user to docker user group\n"
}
