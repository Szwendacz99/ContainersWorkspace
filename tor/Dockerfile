FROM registry.fedoraproject.org/fedora:38

RUN dnf clean all && \
    dnf install -y tor nyx util-linux && \
    dnf clean all

COPY torrc.conf /torrc

WORKDIR /

USER toranon

ENTRYPOINT ["/usr/bin/tor", "-f", "/torrc"]
