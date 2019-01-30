#!/usr/bin/env bash


tools::rbenv() {
  console::info "Setting up rbenv and ruby\n"
  local rbenv_root="${HOME}/.rbenv"
  spinner::run "Cloning 'rbenv/rbenv' into '$rbenv_root'..." \
    tools::gclone "rbenv/rbenv" "${rbenv_root}" 

  # Ruby-build is required to actually install ruby versions
  mkdir -p "${rbenv_root}/plugins"
  spinner::run "Cloning 'rbenv/ruby-build' into '$rbenv_root/plugins'..." \
    tools::gclone \
      "rbenv/ruby-build" \
      "${rbenv_root}/plugins/ruby-build"

  local rbenv_bin="${rbenv_root}/bin/rbenv"
  local version
  version=$("${rbenv_bin}" install -l | tools::highest_version) 
  spinner::run "Installing Ruby $version. This might take a while..."\
    setup::execute \
    "${rbenv_bin}" install "${version}"
}
