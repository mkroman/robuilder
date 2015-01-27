FROM l3iggs/archlinux

MAINTAINER Mikkel Kroman <mk@maero.dk>

USER root

ADD conf/mirrorlist /etc/pacman.d/mirrorlist

# Install development packages.
RUN pacman -Sy --noconfirm --noprogressbar subversion base-devel sudo git \
  clang zsh wget bzr mercurial rsync && rm -rf /var/cache/pacman/pkg

# Set up our robuilder user, with sudo privileges.
RUN useradd -d /home/robuilder -m -s /bin/zsh robuilder && \
  echo "robuilder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Download, build and install cower.
USER robuilder

WORKDIR /home/robuilder

# Get the cower developers gpg key for package verification.
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 487EACC08557AD082088DABA1EB2638FF56C0C53 

RUN mkdir ~/src && wget https://aur.archlinux.org/packages/co/cower/cower.tar.gz && \
  tar xvzf cower.tar.gz && cd cower && \
  makepkg --noconfirm --syncdeps --install && cd .. && \
  rm -rf cower/ cower.tar.gz

# Download and install pacaur.
RUN cd ~/src && cower -d pacaur && cd pacaur && \
  makepkg --noconfirm --syncdeps --install && cd .. && \
  rm -rf pacaur/ pacaur.tar.gz

# Install our build script.
USER root

ADD pacaur-skippgpcheck-support-patch.diff /tmp/pacaur-patch.diff
RUN patch /usr/bin/pacaur /tmp/pacaur-patch.diff && rm /tmp/pacaur-patch.diff

ADD build.sh /usr/bin/robuilder-build
RUN chmod +x /usr/bin/robuilder-build
USER robuilder

# Expose a volume where we leave our finished packages.
VOLUME /packages

ENTRYPOINT ["robuilder-build"]
