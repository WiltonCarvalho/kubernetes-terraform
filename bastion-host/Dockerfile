FROM public.ecr.aws/docker/library/ubuntu:22.04
ARG TZ=America/Sao_Paulo
ARG DEBIAN_FRONTEND=noninteractive
RUN set -ex \
    && apt-get -q update \
    && apt-get -q -y install --no-install-recommends \
        tzdata openssl gnupg2 ca-certificates git curl wget less groff \
        jq jp procps psmisc zip unzip bzip2 iptables iproute2 openssh-client \
        dbus-x11 zsh tmux zsh-autosuggestions zsh-syntax-highlighting \
        zsh-theme-powerlevel9k powerline powerline-gitstatus \
        fonts-powerline libcanberra-gtk3-module \
        lxterminal sudo fuse-overlayfs vim skopeo \
    && curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x0ab215679c571d1c8325275b9bdb3d89ce49ec21" | \
        gpg --dearmor -o /etc/apt/trusted.gpg.d/mozillateam.gpg \
    && echo "deb https://ppa.launchpadcontent.net/mozillateam/ppa/ubuntu jammy  main" | \
        tee /etc/apt/sources.list.d/mozillateam.list \
    && wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com jammy main" | \
        tee /etc/apt/sources.list.d/hashicorp.list \
    && apt-get -q update \
    && apt-get -q -y install --no-install-recommends firefox-esr terraform \
    && ln -s /usr/bin/firefox-esr /usr/local/bin/firefox \
    && rm -rf /var/lib/apt/lists/*
RUN set -ex \
    && DOCKER_BUCKET="download.docker.com" \
    && ARCH=$(uname -p) \
    && DOCKER_VERSION=$(curl -fsSL https://${DOCKER_BUCKET}/linux/static/stable/$ARCH/ | grep -Eo '[0-9]+\.[0-9]+\.[0-9]*' | tail -1) \
    && curl -fsSL "https://${DOCKER_BUCKET}/linux/static/stable/$(uname -p)/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \
    #&& echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
    && tar --extract --file docker.tgz --strip-components 1  --directory /usr/local/bin/ \
    && rm docker.tgz \
    && addgroup -gid 133 docker \
    # set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
    # && addgroup dockremap \
    # && useradd -g dockremap -s /bin/bash -d /home/dockremap -m dockremap \
    # && echo 'dockremap:165536:65536' >> /etc/subuid \
    # && echo 'dockremap:165536:65536' >> /etc/subgid \
    && mkdir -p /usr/local/lib/docker/cli-plugins \
    && BUILDX_RELESES="https://github.com/docker/buildx/releases" \
    && BUILDX_VERSION=$(curl -fsL $BUILDX_RELESES | grep -m 1 -Eo 'v[0-9]+\.[0-9]+\.[0-9]*') \
    && curl -fsSL $BUILDX_RELESES/download/$BUILDX_VERSION/buildx-$BUILDX_VERSION.linux-amd64 \
        -o /usr/local/lib/docker/cli-plugins/docker-buildx \
    && chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx \
    && COMPOSE_RELEASES="https://github.com/docker/compose/releases" \
    && COMPOSE_VERSION=$(curl -fsL $COMPOSE_RELEASES/latest | grep -m 1 -Eo 'v[0-9]+\.[0-9]+\.[0-9]*') \
    && curl -fsSL $COMPOSE_RELEASES/download/$COMPOSE_VERSION/docker-compose-linux-x86_64 \
        -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && ln -sf /usr/local/bin/docker-compose /usr/local/lib/docker/cli-plugins/docker-compose \
    # Smoke Test
    && docker-compose version \
    && docker --version
ARG MYUID=$MYUID
RUN set -ex \
    && useradd -g root -G sudo -s /bin/zsh -u $MYUID -m myself \
    && usermod -s /bin/zsh root \
    && sed -i 's/^audio.*/audio:x:29:myself/g' /etc/group \
    && echo 'myself:165536:65536' >> /etc/subuid \
    && echo 'myself:165536:65536' >> /etc/subgid \
    && echo 'myself ALL=(ALL) NOPASSWD:ALL' | tee -a /etc/sudoers.d/99-myself \
    && dbus-uuidgen > /var/lib/dbus/machine-id
RUN set -ex \
    && wget https://storage.googleapis.com/kubernetes-release/release/v1.26.2/bin/linux/amd64/kubectl \
        -O /usr/local/bin/kubectl \
    && wget https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64 -O /usr/local/bin/kind \
    && chmod +x /usr/local/bin/kubectl /usr/local/bin/kind \
    && wget -O- https://get.helm.sh/helm-v3.8.1-linux-amd64.tar.gz | \
        tar zxvf - -C "/usr/local/bin" linux-amd64/helm --strip-components 1 \
    && export KUSTOMIZE_VERSION=v4.5.7 \
    && wget -O- https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz | \
        tar zxvf - -C "/usr/local/bin" \
    && wget https://github.com/mikefarah/yq/releases/download/v4.40.4/yq_linux_amd64 \
        -O /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq
USER myself
WORKDIR /home/myself
COPY zshrc /root/.zshrc
COPY tmux.conf /root/.tmux.conf
COPY --chmod=755 dockerd.sh /dockerd.sh
COPY --chmod=755 run.sh /run.sh
COPY --chown=myself zshrc /home/myself/.zshrc
COPY --chown=myself tmux.conf /home/myself/.tmux.conf
COPY --chown=myself lxterminal.conf /home/myself/.config/lxterminal/lxterminal.conf
ENTRYPOINT ["/run.sh"]
VOLUME /home/myself
VOLUME /root
STOPSIGNAL KILL
ENV LANG='C.UTF-8'
ENV LANGUAGE='en_US:en'

