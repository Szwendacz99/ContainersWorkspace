FROM quay.io/podman/stable

ENV VERSION="0.2.6"
ARG ARCH="amd64"

RUN curl -o /act_runner https://gitea.com/gitea/act_runner/releases/download/v0.2.6/act_runner-${VERSION}-linux-${ARCH} && \
    chmod +x /act_runner && \
    chown podman /act_runner

USER podman

ENTRYPOINT [ "/act_runner" ]
