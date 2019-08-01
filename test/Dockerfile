FROM base/archlinux:latest

RUN pacman -Sy --noconfirm && \
  pacman -Su --noconfirm && \
  pacman-db-upgrade && \
  trust extract-compat

RUN pacman -S --noconfirm \
  base-devel \
  sudo 

RUN chmod 640 /etc/sudoers && \ 
  echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
  chmod 440 /etc/sudoers && \
  useradd -m -p glumpat -G wheel glumpat

USER glumpat

ENV USER glumpat
ENV HOME /home/glumpat

VOLUME $HOME
WORKDIR $HOME
