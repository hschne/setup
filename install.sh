#!/usr/bin/env bash

function main() {
  # Ask for sudo in the beginning, so that's done with
  sudo echo ""

  install_packages 

  install_tools

  reboot
}

function install_packages() {
  sudo pacman -Syy

  sudo pacman -S --noconfirm --needed \
    git \
    gvim \
    jdk10-openjdk \
    maven \
    zsh \
    bat \
    thefuck \
    hub \
    diff-so-fancy \
    chrome-gnome-shell

  # Set shell for user, done here to avoid timeout problems for sudot 
  sudo chsh -s "/bin/zsh" ${USER}

  yaourt -S --noconfirm --needed \
    synology-cloud-station-drive
}

function install_tools() {
  appindicator
  jetbrains_toolbox
  rbenv
  pyenv
  nvm_
  jenv
  zplug
  homeshick
  vim_
  nord
}

function rbenv {
  local rbenv_root="${HOME}/.rbenv"
  gclone "https://github.com/rbenv/rbenv.git" "${rbenv_root}"

  # Ruby-build is required to actually install ruby versions
  mkdir -p "${rbenv_root}/plugins"
  gclone "https://github.com/rbenv/ruby-build.git" "${rbenv_root}/plugins/ruby-build"

  local rbenv_bin="${rbenv_root}/bin/rbenv"
  local version=$("${rbenv_bin}" install -l | highest_version) 
  "${rbenv_bin}" install "${version}"
}

function pyenv() {
  local pyenv_root="${HOME}/.pyenv"
  gclone "https://github.com/pyenv/pyenv.git" "${pyenv_root}"

  local pyenv_bin="${pyenv_root}/bin/pyenv"
  local version=$("${pyenv_bin}" install -l | highest_version)
  "${pyenv_bin}" install "${version}"
}

function nvm_() {
  local nvm_root="${HOME}/.nvm"
  gclone "https://github.com/creationix/nvm.git" "${nvm_root}"

  # Make nvm immediatly accessible in shell
  export NVM_DIR="${HOME}/.nvm"
  source ${NVM_DIR}/nvm.sh
  nvm install node
}

function jenv() {
  local jenv_root="${HOME}/.jenv"
  gclone "https://github.com/gcuisinier/jenv.git" "${jenv_root}"

  local jenv_bin="${jenv_root}/bin/jenv"
  $jenv_bin init -
  ${jenv_bin} add --skip-existing /usr/lib/jvm/java-10-openjdk
}

function zplug() {
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
}

function homeshick(){
  local homeshick_root="${HOME}/.homesick/repos/homeshick"
  gclone git://github.com/andsens/homeshick.git "${homeshick_root}"

  homeshick_bin="${homeshick_root}/bin/homeshick"
  # Clone dotfiles
  ${homeshick_bin} clone --batch glumpat/dotfiles
  # Clone scripts
  ${homeshick_bin} clone --batch glumpat/scripts
  ${homeshick_bin} link --force
}

function vim_() {
  gclone "https://github.com/VundleVim/Vundle.vim.git" ~/.vim/bundle/Vundle.vim

  vim +PluginInstall +qall
}

function nord() {
  local nord_url="https://raw.githubusercontent.com/arcticicestudio/nord-gnome-terminal/develop/src/nord.sh"
  wget -O - "${nord_url}" | bash
}

function appindicator() {
  # Use the repository clone for headless installation, see GitHub for more info: https://github.com/Ubuntu/gnome-shell-extension-appindicator
  local extension_home="${HOME}/.local/share/gnome-shell/extensions"
  gclone https://github.com/ubuntu/gnome-shell-extension-appindicator.git \
    "${extension_home}/appindicatorsupport@rgcjonas.gmail.com"

  gnome-shell-extension-tool -e appindicatorsupport@rgcjonas.gmail.com
}

function jetbrains_toolbox() {
  wget -O - "https://raw.githubusercontent.com/nagygergo/jetbrains-toolbox-install/master/jetbrains-toolbox.sh" | bash
}



# Reboot after prompting the user for it
# Taken from https://unix.stackexchange.com/a/426189
function reboot() {
  echo "Setup completed. Reboot? (y/n)" && read x && [[ "$x" == "y" ]] && /sbin/reboot; 
}

# A wrapper around git clone. Does not rely on the path and clones with shallow 
# in order to speed up process. 
#
# Arguments:
#
# $1 - The URL to clone from.
# $2 - The destination to clone to.
#
# Examples
#
#   gclone "http://someurl/myrepo.git" $HOME
# 
function gclone() {
  local git="/usr/bin/git"
  "${git}" clone --depth 1 $1 $2
}

# Returns the highest version from a list of version strings,
# stripped of leading white space. 
# Magic taken from: 
#   https://stackoverflow.com/a/30183040/2553104
#   https://stackoverflow.com/a/3232433
# 
# Arguments: 
# 
# $@ - A list of versions of the form x.x.x
#
# Examples
#
#    echo "1.2.3 3.4.2 5.0.1" | highest_version
#
function highest_version() {
  # Magic comes from here: https://stackoverflow.com/a/30183040/2553104
  awk -F '.' '
  /^[[:space:]]*[0-9]+\.[0-9]+\.[0-9]+[[:space:]]*$/ {
  if ( ($1 * 100 + $2) * 100 + $3 > Max ) {
    Max = ($1 * 100 + $2) * 100 + $3
    Version=$0
  }
}
END { print Version }' | sed -e 's/^[[:space:]]*//'
}

# Entrypoint
main "$@"
