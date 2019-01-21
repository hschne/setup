FROM base/archlinux:latest

RUN pacman -Sy --noconfirm && \
  pacman -S --noconfirm archlinux-keyring && \
  pacman -Su --noconfirm && \
  pacman-db-upgrade && \
  trust extract-compat

RUN pacman -S --noconfirm wget \
  git \
  sudo \
  base-devel

RUN chmod 640 /etc/sudoers && \ 
  echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
  chmod 440 /etc/sudoers && \
  useradd -m -p glumpat -G wheel glumpat

USER glumpat

ENV HOME /home/glumpat

VOLUME $HOME
WORKDIR $HOME

# Install yaourt like here: 
# https://hub.docker.com/r/alekzonder/archlinux-yaourt/dockerfile
RUN git clone https://aur.archlinux.org/package-query.git && \
  cd package-query && \
  yes | makepkg -si && \
  cd .. && \
  git clone https://aur.archlinux.org/yaourt.git && \
  cd yaourt && \
  yes | makepkg -si && \
  cd .. && \
  sudo rm -dR yaourt/ package-query/ && \
  yaourt -Syu --devel --aur 

