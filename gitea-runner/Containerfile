FROM quay.io/podman/stable

RUN mkdir -p /opt /var/run && \
    ln -sf /podman/docker.sock /var/run/docker.sock

RUN dnf install -y make go git && \
    cd /tmp && \
    git clone https://gitea.com/gitea/act_runner.git && \
    cd act_runner && \
    make build && \
    mv /tmp/act_runner/act_runner /opt/ && \
    chown podman /opt/act_runner && \
    dnf remove -y make go git && \
    dnf autoremove -y && \
    dnf clean all && \
    rm -rf /tmp/* /root/go

USER podman

ENTRYPOINT [ "/opt/act_runner" ]
