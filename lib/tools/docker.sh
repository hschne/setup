#!/usr/bin/env bash

tools::docker() {
  console::info "Configuring docker"
  setup::execute sudo groupadd docker && sudo usermod -aG docker "$USER" 
  console::result "Successfully configured docker" "Failed to add user to docker user group"
}
