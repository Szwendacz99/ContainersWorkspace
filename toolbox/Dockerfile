FROM registry.fedoraproject.org/fedora:38

ENV PKGS_GENERAL="htop \
    btop"

RUN dnf clean all && \
    dnf install -y ${PKGS_GENERAL} && \
    dnf -y autoremove && \
    dnf -y clean all

COPY help-toolbox.sh /usr/bin/help-toolbox

RUN chmod 555 /usr/bin/help-toolbox

USER root
