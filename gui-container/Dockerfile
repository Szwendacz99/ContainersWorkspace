FROM registry.fedoraproject.org/fedora:38

ENV HISTSIZE=10000
ENV HISTTIMEFORMAT="%d/%m/%y %T "
ENV HISTFILESIZE=20000

ENV GENERAL_PKGS="\
    bash-completion \
    procps \
    iproute \
    fzf \
    wget \
    git \
    firefox \
    dbus \
    dbus-x11 \
    strace"

# install system dependencies
RUN dnf install -y \
    ${GENERAL_PKGS} \
    && dnf clean all

RUN echo $'[ -f /usr/share/fzf/shell/key-bindings.bash ] && source /usr/share/fzf/shell/key-bindings.bash' >> /root/.bashrc

ENTRYPOINT [ "/bin/bash" ]
