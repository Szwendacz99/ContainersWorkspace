FROM registry.fedoraproject.org/fedora:38

ENV HISTSIZE=10000
ENV HISTTIMEFORMAT="%d/%m/%y %T "
ENV HISTFILESIZE=20000
ENV QT_QPA_PLATFORM=wayland

ENV GENERAL_PKGS="\
    bash-completion \
    procps \
    iproute \
    fzf \
    wget \
    git \
    dbus \
    dbus-x11 \
    strace \
    systemd"

ENV APPS="\
    chromium \
    firefox \
    librewolf"

# install dependencies and basic apps
RUN dnf install -y 'dnf-command(config-manager)' \
    dnf config-manager --add-repo https://rpm.librewolf.net/librewolf-repo.repo \
    dnf install -y \
    ${GENERAL_PKGS} \
    ${APPS} \
    && dnf clean all

RUN echo $'[ -f /usr/share/fzf/shell/key-bindings.bash ] && source /usr/share/fzf/shell/key-bindings.bash' >> /root/.bashrc

ENTRYPOINT [ "/sbin/init" ]
