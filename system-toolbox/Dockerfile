FROM registry.fedoraproject.org/fedora:38

ENV PKGS_GENERAL="htop \
    btop \
    sysstat \
    util-linux \
    lm_sensors \
    smartmontools \
    ffmpeg-free \
    yt-dlp"

ENV PKGS_PROCESSES="procps-ng \
    strace"

ENV PKGS_NETWORK="bind-utils \
    nmap \
    nmap-ncat \
    telnet \
    tcpdump \
    iftop \
    iproute \
    iputils \
    whois \
    iptraf-ng"

RUN dnf clean all && \
    dnf install -y ${PKGS_GENERAL} ${PKGS_PROCESSES} ${PKGS_NETWORK} && \
    dnf -y autoremove && \
    dnf -y clean all

COPY help-toolbox.sh /usr/bin/help-toolbox

RUN chmod 555 /usr/bin/help-toolbox

USER root
