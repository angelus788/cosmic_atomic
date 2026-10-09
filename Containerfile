FROM quay.io/fedora-ostree-desktops/cosmic-atomic:44

LABEL org.opencontainers.image.title="cosmic-atomic-custom" \
      org.opencontainers.image.description="Fedora COSMIC Atomic 44 with extra tools and services"

# --- Files shipped in the image ---------------------------------------------
# etc/yum.repos.d/netbird.repo          NetBird's official RPM repo
# etc/profile.d/starship.sh             starship prompt for bash and zsh
# etc/fish/conf.d/starship.fish         starship prompt for fish
# usr/lib/systemd/system/netbird.service  NetBird daemon unit (see note below)
# usr/lib/tmpfiles.d/netbird.conf       creates /var/log/netbird at boot
COPY etc/ /etc/
COPY usr/ /usr/

# --- Packages ---------------------------------------------------------------
# Requested: zsh, fish, fastfetch, btop, git, tmux, ansible (+ netbird, below)
# ansible-core is the lean engine; swap for `ansible` if you want the bundled
# community collections too (much larger), or add collections later with
# `ansible-galaxy collection install ...`.
RUN dnf install -y \
      zsh \
      fish \
      fastfetch \
      btop \
      git \
      tmux \
      stow \
      eza \
    ansible-core \
    && dnf clean all

# zsh + starship: Fedora's /etc/zshrc sources /etc/profile.d/*.sh under
# `emulate -L ksh`, which breaks starship's zsh init, so hook a native zsh file in
# at the end of /etc/zshrc instead (bash uses /etc/profile.d/starship.sh).
RUN printf '\n# Added by image build: starship prompt for zsh\n[ -r /usr/share/cosmic-custom/starship.zsh ] && . /usr/share/cosmic-custom/starship.zsh\n' >> /etc/zshrc

# Extras from the first draft. Delete this block if you don't want them.
RUN dnf install -y \
      neovim \
      htop \
      ripgrep \
      fd-find \
      fzf \
      jq \
      rsync \
      wireguard-tools \
      distrobox \
      cockpit-system \
      cockpit-podman \
      cockpit-ws \
      openssh-server \
    && dnf clean all

# --- NetBird ----------------------------------------------------------------
# The RPM's %post scriptlet runs `netbird service install/start`, which fails
# inside an image build, so install with scriptlets disabled. The package then
# registers no service, which is why usr/lib/systemd/system/netbird.service is
# shipped above.
RUN dnf --setopt=tsflags=noscripts install -y netbird && dnf clean all

# --- Starship ---------------------------------------------------------------
# Not in the main Fedora repos: install the official static release binary and
# verify it against the checksum published next to it. Replace "latest/download"
# with "download/vX.Y.Z" to pin a version.
RUN set -eux; \
    cd /tmp; \
    base=https://github.com/starship/starship/releases/latest/download; \
    tarball=starship-x86_64-unknown-linux-musl.tar.gz; \
    curl -fsSLO "$base/$tarball"; \
    curl -fsSLO "$base/$tarball.sha256"; \
    echo "$(awk '{print $1}' "$tarball.sha256")  $tarball" | sha256sum -c -; \
    tar -xzf "$tarball" -C /usr/bin starship; \
    chmod 0755 /usr/bin/starship; \
    starship --version; \
    rm -f "$tarball" "$tarball.sha256"

# --- Services ---------------------------------------------------------------
RUN systemctl enable \
      netbird.service \
      podman.socket \
      cockpit.socket \
      sshd.service

# --- Cleanup + bootc validation ---------------------------------------------
RUN rm -rf /var/cache/* /var/log/dnf* /var/lib/dnf /run/dnf /tmp/* && \
    bootc container lint
