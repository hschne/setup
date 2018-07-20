#!/usr/bin/env bash

function main() {
  # Ask for sudo in the beginning, so that's done with
  sudo echo ""

  install_packages 

  install_tools
}

function install_packages() {
  sudo pacman -S --noconfirm --needed \
    git \
    gvim \
    jdk10-openjdk \
    zsh \
    thefuck

  # Set shell for user, done here to avoid timeout problems for sudo 
  sudo chsh -s "/bin/zsh" ${USER}

  yaourt -S --noconfirm --needed \
    maven 
}

function install_tools() {
  rbenv
  pyenv
  nvm_
  jenv
  fzf
  oh_my_zsh
  homeshick
  vim_
}

function rbenv {
  local rbenv_root="${HOME}/.rbenv"
  gclone "https://github.com/rbenv/rbenv.git" "${rbenv_root}"

  # Ruby-build is required to actually install ruby versions
  mkdir -p "${rbenv_root}/plugins"
  gclone "https://github.com/rbenv/ruby-build.git" "${rbenv_root}/plugins/ruby-build"

  local rbenv_bin="${rbenv_root}/bin/rbenv"
  # Get available version, pick the highest one, and then strip leading white space
  # Sed expression from here: https://stackoverflow.com/a/3232433
  local version=$("${rbenv_bin}" install -l | highest_version | sed -e 's/^[[:space:]]*//') 
  "${rbenv_bin}" install "${version}"
}

function pyenv() {
  local pyenv_root="${HOME}/.pyenv"
  gclone "https://github.com/pyenv/pyenv.git" "${pyenv_root}"

  local pyenv_bin="${pyenv_root}/bin/pyenv"
  local version=$("${pyenv_bin}" install -l | highest_version | sed -e 's/^[[:space:]]*//')
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

function oh_my_zsh() {
  # Lets do this manually, because the install script does a bunch of stuff we don't need
  local ohmyzsh_root="${HOME}/.oh-my-zsh"
  gclone "https://github.com/robbyrussell/oh-my-zsh.git" "${ohmyzsh_root}"

  local themes_root="${ohmyzsh_root}/custom/themes/"
  wget https://raw.githubusercontent.com/caiogondim/bullet-train.zsh/master/bullet-train.zsh-theme -P "${themes_root}"
}

function fzf() {
  local fzf_root="${HOME}/.fzf"
  gclone "https://github.com/junegunn/fzf.git" "${fzf_root}"
}

function homeshick(){
  local homeshick_root="${HOME}/.homesick/repos/homeshick"
  gclone git://github.com/andsens/homeshick.git "${homeshick_root}"

  homeshick_bin="${homeshick_root}/bin/homeshick" 
  ${homeshick_bin} clone --batch hschne/dotfiles
  ${homeshick_bin} link --force
}

function vim_() {
  gclone "https://github.com/VundleVim/Vundle.vim.git" ~/.vim/bundle/Vundle.vim

  vim +PluginInstall +qall
}

# Check if a certain program is installed.  
# 
# Taken from https://gist.github.com/JamieMason/4761049
#
# $1 - Command to be checked.
#
# Examples
#
#   is_installed "git"
#
# Returns 0 if the program is installed and 1 otherwise. 
function is_installed {
  local result=0
  type $1 >/dev/null 2>&1 || { local result=1; }
  return $result
}

# Prompts the user to perform a manual step. 
#
# Arguments:
#
# $1 - A message to display
#
# Examples
#
#   manual "Please install zsh manually"
# 
function manual() {
  local message=$1
  echo ${message}
  read -n 1 -s -r -p "Press any key to continue..."
}

# A wrapper around git clone. Does not rely on the path.
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

# Run the specified command as specified user
function run_as() {
  local user=$1
  shift
  sudo -u $user $@ 
}

function highest_version() {
  # Magic comes from here: https://stackoverflow.com/a/30183040/2553104
  awk -F '.' '
  /^[[:space:]]*[0-9]+\.[0-9]+\.[0-9]+[[:space:]]*$/ {
  if ( ($1 * 100 + $2) * 100 + $3 > Max ) {
    Max = ($1 * 100 + $2) * 100 + $3
    Version=$0
  }
}
END { print Version }'
}

main "$@"
