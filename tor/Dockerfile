FROM registry.fedoraproject.org/fedora:37

RUN dnf clean all && \
    dnf install -y tor nyx util-linux && \
    dnf clean all

COPY torrc.conf /torrc

WORKDIR /

USER toranon

ENTRYPOINT ["/usr/bin/tor", "-f", "/torrc"]
