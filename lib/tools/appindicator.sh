#!/usr/bin/env bash

tools::appindicator() {
  console::info "Setting up gnome shell extensions\n"
  # Use the repository clone for headless installation, 
  # See GitHub for more info: https://github.com/Ubuntu/gnome-shell-extension-appindicator
  
  local extension_home="${HOME}/.local/share/gnome-shell/extensions"
  spinner::run "Cloning gnome-shell-extension-appindicator..." \
    tools::gclone \
      ubuntu/gnome-shell-extension-appindicator \
      "${extension_home}/appindicatorsupport@rgcjonas.gmail.com"

  setup::execute gnome-shell-extension-tool -e appindicatorsupport@rgcjonas.gmail.com
  console::result "Enabled gnome appindicator\n" "Failed to enable appindicator\n"
}
