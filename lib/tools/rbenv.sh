#!/usr/bin/env bash


tools::rbenv() {
  local rbenv_root="${HOME}/.rbenv"
  gclone "rbenv/rbenv" "${rbenv_root}" 

  # Ruby-build is required to actually install ruby versions
  mkdir -p "${rbenv_root}/plugins"
  gclone "rbenv/ruby-build" "${rbenv_root}/plugins/ruby-build"

  local rbenv_bin="${rbenv_root}/bin/rbenv"
  local version
  version=$("${rbenv_bin}" install -l | util::highest_version) 
  "${rbenv_bin}" install "${version}"
}
