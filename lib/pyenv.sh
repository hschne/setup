#!/usr/bin/env bash

tools::pyenv() {
  local pyenv_root="${HOME}/.pyenv"
  gclone "https://github.com/pyenv/pyenv.git" "${pyenv_root}"

  local pyenv_bin="${pyenv_root}/bin/pyenv"
  local version
  version=$("${pyenv_bin}" install -l | tools::highest_version)
  "${pyenv_bin}" install "${version}"
}
