FROM registry.fedoraproject.org/fedora:38


ENV PKGS="\
    wireguard-tools \
    nftables \
    bash-completion \
    procps \
    iproute"

COPY entrypoint.sh /usr/bin/

# install system dependencies
RUN dnf install -y \
    ${PKGS} \
    && dnf clean all &&\
    chmod +x /usr/bin/entrypoint.sh && \
    mkdir /setup.d

STOPSIGNAL SIGALRM

ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]
