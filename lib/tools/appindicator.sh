#!/usr/bin/env bash

tools::appindicator() {
  # Use the repository clone for headless installation, see GitHub for more info: https://github.com/Ubuntu/gnome-shell-extension-appindicator
  local extension_home="${HOME}/.local/share/gnome-shell/extensions"
  gclone ubuntu/gnome-shell-extension-appindicator \
    "${extension_home}/appindicatorsupport@rgcjonas.gmail.com"

  gnome-shell-extension-tool -e appindicatorsupport@rgcjonas.gmail.com
}
