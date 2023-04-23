FROM registry.fedoraproject.org/fedora:38

RUN useradd -u 1423 -m -s '/bin/bash' -U snowflake
ENV TZ=Europe/Warsaw

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    dnf clean all && \
    dnf install -y git golang && \
    git clone https://git.torproject.org/pluggable-transports/snowflake.git && \
    cd snowflake/proxy && \
    go build && \
    dnf remove -y golang git && \
    dnf -y autoremove && \
    dnf -y clean all && \
    mv /snowflake/proxy/proxy /usr/bin/proxy && \
    cd / && \
    rm -rf /snowflake /root/* && \
    chown snowflake.snowflake /usr/bin/proxy

USER snowflake

ENTRYPOINT ["/usr/bin/proxy"]
