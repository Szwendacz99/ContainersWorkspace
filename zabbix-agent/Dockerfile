FROM docker.io/alpine:latest

RUN apk add smartmontools util-linux zabbix-agent2 zabbix-utils sudo && \
    echo 'zabbix ALL=(ALL) NOPASSWD:/usr/sbin/smartctl' >> /etc/sudoers

USER zabbix

ENTRYPOINT [ "/usr/sbin/zabbix_agent2", "-f" ]
