FROM cgr.dev/chainguard/wolfi-base

ARG GITHUB_USERNAME="nunix"
ARG REPOSITORY="boxwolfi"
ENV FLEEKCONFIG="git@github.com:$GITHUB_USERNAME/$REPOSITORY.git"
ENV USER="root"

# Add packages
RUN apk update && \
    apk add bash curl git posix-libc-utils

# Change root shell to BASH
RUN sed -i -e '/^root/s/\/bin\/ash/\/bin\/bash/' /etc/passwd

# Install NIX with the Determinate Systems script
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux --init none --no-confirm && \
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Install Fleek
RUN mkdir -p /root/.config/nix && \
    echo "experimental-features = nix-command flakes" >> /root/.config/nix/nix.conf && \
    nix profile install github:ublue-os/fleek/main

# Apply the Fleek config
WORKDIR /root
RUN fleek init ${FLEEKCONFIG} && \
    fleek apply