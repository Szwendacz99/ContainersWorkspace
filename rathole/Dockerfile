FROM registry.fedoraproject.org/fedora:38 as builder

WORKDIR /

RUN dnf clean all && \
    dnf install -y git cargo openssl-devel && \
    git clone https://github.com/rapiz1/rathole.git && \
    cd ./rathole && \
    cargo build --release


FROM registry.fedoraproject.org/fedora-minimal:38
WORKDIR /
COPY --from=builder /rathole/target/release/rathole .
USER 1852:1852
ENTRYPOINT ["./rathole"]
