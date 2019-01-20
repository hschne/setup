FROM base/archlinux:latest

RUN pacman -Sy --noconfirm && \
  pacman -S --noconfirm archlinux-keyring && \
  pacman -Su --noconfirm && \
  pacman-db-upgrade && \
  trust extract-compat

RUN pacman -S --noconfirm wget git sudo base-devel
run chmod 640 /etc/sudoers && \ 
  echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
  chmod 440 /etc/sudoers && \
  useradd -m -pglumpat -G wheel glumpat

USER glumpat

WORKDIR /home/glumpat

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
  sudo pacman -Sy --noconfirm yaourt && \
  yaourt -Syu --devel --aur 

