#!/usr/bin/env bash

tools::pyenv() {
  console::info "Setting up Pyenv and Python\n"
  local pyenv_root="${HOME}/.pyenv"
  spinner::run "Cloning 'pyenv/pyenv' into '$pyenv_root'..."\
    tools::gclone "pyenv/pyenv" "${pyenv_root}"

  local pyenv_bin="${pyenv_root}/bin/pyenv"
  local version
  version=$("${pyenv_bin}" install -l | tools::highest_version)
  spinner::run "Installing Python $version..." \
    setup::execute \
    "${pyenv_bin}" install "${version}"
}
