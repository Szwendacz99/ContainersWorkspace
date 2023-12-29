FROM registry.fedoraproject.org/fedora:39

USER root

ENV HISTSIZE=10000
ENV HISTTIMEFORMAT="%d/%m/%y %T "
ENV HISTFILESIZE=20000

ENV PKGS_BASE="fzf git python3-pip rclone bash-completion kubernetes-client helm golang-sigs-k8s-kustomize"
ENV PKGS_TEMP="python3-devel gcc wget"

RUN dnf clean all && \
    dnf install -y ${PKGS_BASE} ${PKGS_TEMP} && \
    pip3 install python-openstackclient python-swiftclient python-heatclient && \
    wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz && \
    tar -xvf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz && \
    chmod +x openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/* && \
    mv openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc /usr/bin/ && \
    rm -rf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit* && \
    dnf remove -y ${PKGS_TEMP} && \
    dnf -y autoremove && \
    dnf -y clean all && \
    mkdir /data

WORKDIR /data

COPY kube_ps.sh /root/kube_ps.sh

RUN echo $'[ -f /usr/share/fzf/shell/key-bindings.bash ] && source /usr/share/fzf/shell/key-bindings.bash;\
source /root/kube_ps.sh;\
PS1=\'[cloud-toolbox \W/ $(kube_ps1)]\$ \'\
' >> /root/.bashrc

ENTRYPOINT [ "/bin/bash" ]
