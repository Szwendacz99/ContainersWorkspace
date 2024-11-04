#!/bin/bash

source /etc/profile
eval "$(cat /root/ssh_agent_eval)";
source /usr/share/fzf/shell/key-bindings.bash;

ssh() {
    /bin/ssh -o HostKeyAlgorithms=+ssh-dss \
        -o PubkeyAcceptedKeyTypes=+ssh-rsa,ssh-dss \
        "$@"
}
ssh-add -l | grep 'The agent has no identities' && ssh-add
