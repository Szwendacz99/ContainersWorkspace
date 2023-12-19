# Containers-Workspace
Various useful and useless Dockerfiles, often experimental and work in progress

## system-toolbox

Fedora based container wih preinstalled many usefull tools for various debug and problem searching purposes
run help-toolbox to show what can you do in there

Typical container run options that allows for host data access:
```bash
podman run --rm -it --privileged \
    --network host --pid host --ipc host --no-hosts --ulimit host \
    --userns host \
        --name toolbox toolbox
```

## cloud-toolbox

Sounds huge, but it is just set of tools for cloud-based stuff,
like openstack-cli, rclone, openshift cli, etc...

Also contains `fzf` and bash-completion. Mount your bash_history for
best experience.

```bash
podman run --rm -it \
    -v "$HOME/.bash_history:/root/.bash_history" \
    --security-opt label:disable \
        cloud-toolbox:latest
```

## gui-container

gui-container is an experiment for apps with GUI

how to run with default, permissive options:

```bash
podman run --privileged -it \
    -e XDG_RUNTIME_DIR=/runtime_dir \
    -e WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
    -e DISPLAY="$DISPLAY" \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v $HOME/.Xauthority:/root/.Xauthority:ro \
    -v "$XDG_RUNTIME_DIR:/runtime_dir:rw" \
    --entrypoint bash \
    --name "gui_container" \
        gui-container:latest
```

Minimal permissions example (for wayland).  Mounting just the display server socket, there will be no sound or anything else:
```bash
podman run -it --security-opt label:disable \
    -e XDG_RUNTIME_DIR=/runtime_dir\
    -e WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
    -v "$XDG_RUNTIME_DIR/wayland-0:/runtime_dir/wayland-0:rw" \
    --entrypoint bash --name "gui_container" \
        gui-container:latest
```

starting dbus:

```bash
export $(dbus-launch)
```

allowing podman to connect to X display as "non-network local connections"

```bash
xhost +"local:podman@"
```

unsetting `WAYLAD_DISPLAY` or `DISPLAY` can force apps to use the other one

```bash
unset DISPLAY
# or
unset WAYLAD_DISPLAY
```

to mage Qt-based apps work:

```bash
export QT_QPA_PLATFORM=wayland
```

## rathole

Compiled from source [rathole](https://github.com/rapiz1/rathole) image.

## snowflake

Compiled from source [torproject snowflake](https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake) image.

## Tor relay/bridge node

```bash
# prepare
cd tor/;
podman build -t tornode .;
chmod 777 ./data ./logs;

# run (network host for easy port bind on ipv6)
podman run -d --read-only --network host \
    -v "/home/user/torrc.conf:/torrc:rw,Z" \
    -v "/home/user/tor/logs:/var/log:Z,rw" \
    -v "/home/user/tor/data:/var/lib/tor:Z,rw" \
    --name tornode tornode:latest

# prepare systemd service for reboot persistence
podman generate systemd --new --name tornode > /etc/systemd/system/tornode.service;
restorecon -v /etc/systemd/system/tornode.service;
systemctl daemon-reload;
systemctl enable --now tornode.service;

# view nyx dashboard
podman exec -it tornode nyx
```

## Wireguard

Simple container that will setup wireguard interface according to
`/data/wg0.conf` and then replace process with pid 1 to `sleep infinity`.
MASQUERADE required for accessing external networks is done by nftables, so
it should work with nftables kernel modules, iptables-only modules can
be missing.

Before seting up the wg interface, entrypoint will execute files in
`/setup.d/` if any.

`PostUp` and `PostDown` in network interface config should look like this:

```bash
PostUp = nft add table inet filter; nft add chain inet filter forward { type filter hook forward priority 0 \; }; nft add rule inet filter forward iifname "%i" accept; nft add rule inet filter forward oifname "%i" accept; nft add table inet nat; nft add chain inet nat postrouting { type nat hook postrouting priority 100 \; }; nft insert rule inet nat postrouting tcp flags syn / syn,rst counter tcp option maxseg size set rt mtu; nft add rule inet nat postrouting oifname "eth*" masquerade
PostDown = nft delete table inet filter; nft delete table inet nat;
```
The `nft insert rule inet nat postrouting tcp flags syn / syn,rst counter tcp option maxseg size set rt mtu` is optional, but recommended if on client side there are virtual networks from which discovering the MTU of whole path can be difficult.

Example run (requires root and privileged for nftables setup)

```bash
podman run --privileged --name wireguard -d \
    -v './config:/data:ro' \
    -v './setup:/setup.d:ro' \
    -wireguard:latest
```

## zabbix-agent

Very simple alpine-based zabbix-agent image providing additioanl deps
required for SMART monitoring.

Setting up such contenerized agent in systemd based system:

```bash
podman run --restart no \
  --network host --pid host --ipc host --no-hosts --ulimit host --userns host \
  --privileged \
  -v "/path/to/custom/config.conf:/etc/zabbix/zabbix_agent2.conf:ro" \
  -v "/sys:/sys:ro" \
  -v "/sys/fs/cgroup:/sys/fs/cgroup:ro" \
  -v "/var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket:rw" \
  --name zabbix-agent \
  -d localhost/zabbix-agent;

podman generate systemd --new --name zabbix-agent > /etc/systemd/system/zabbix-agent.service;
restorecon -v /etc/systemd/system/zabbix-agent.service;
systemctl daemon-reload;
systemctl enable --now zabbix-agent.service;
```

## gitea-runner

An image for running double-container setup - one with podman system service,
and the other with gitea act_runner which will use podman service as
docker runner.

Example uses root, but it should be very similar to setup under non-root user.

Build image (will compile from main branch)
```bash
podman build --no-cache -t gitea-runner \
        ./ContainersWorkspace/gitea-runner/
```


Create dirs for runner config, and for podman socket shared between containers.
```bash
mkdir -p /root/act-runner/{runner,podman}
```

Generate example config
```bash
podman run --rm -it  gitea-runner:latest generate-config > /root/act-runner/runner/config.yaml
```

Update registration file path in config and privileged mode.
```bash
sed -i 's`file: .runner`file: /etc/runner/registration.json`g' /root/act-runner/runner/config.yaml;
sed -i 's`privileged: false`privileged: true`g' /root/act-runner/runner/config.yaml;
sed -i 's`docker_host: ""`docker_host: "-"`g' /root/act-runner/runner/config.yaml;
```
Currently you **need** to set `docker_host: "-"` in "container" section
to make this setup with mounted docker.sock work.

Fix perms on those dirs:
```bash
podman run --rm -it \
    -v /root/act-runner/:/data:z,rw \
    --privileged \
    --entrypoint bash \
    -u root \
        gitea-runner:latest \
            -c "chown -R podman /data"
```

Register runner.  
example value for labels can be `ubuntu-latest:docker://quay.io/podman/stable`.
```bash
podman run --rm -it \
    -v /root/act-runner/runner/:/etc/runner:z,rw \
    --privileged  \
        gitea-runner:latest \
            --config /etc/runner/config.yaml register
```

Start container acting as podman/docker (use `--init` to get rid of zombies):
```bash
podman run --rm -d --privileged --name gitea-podman \
    --init \
    --entrypoint podman \
    -v /root/act-runner/podman:/podman:z,rw \
        gitea-runner:latest  \
            system service --time=0 unix:///podman/docker.sock
```

Now start container with runner
```bash
podman run --rm -d --name gitea-runner \
    -v /root/act-runner/runner/:/etc/runner:rw,Z \
    -v /root/act-runner/podman:/podman:rw,z \
        gitea-runner:latest \
            daemon -c /etc/runner/config.yaml
```

Now generate systemd services for these containers
```bash
podman generate systemd --new --name gitea-podman > /etc/systemd/system/gitea-podman.service;
podman generate systemd --new --name gitea-runner > /etc/systemd/system/gitea-runner.service;
restorecon -v /etc/systemd/system/gitea-podman.service;
restorecon -v /etc/systemd/system/gitea-runner.service;
systemctl daemon-reload;
systemctl enable --now gitea-podman.service;
systemctl enable --now gitea-runner.service;
```

## Podman quadlets examples

This section is about quadlets, rather than specific image, but it is based on
examples.

To enable such container managed by systemd, create `.container` file
at `/etc/containers/systemd/my-container.container`, and then run:
```bash
systemctl daemon-reload;
systemctl enable --now my-container.service
```

### Example host-monitoring purpose quadlets

#### zabbix-agent

```systemd
[Unit]
Description=Zabbix agent 2
After=local-fs.target

[Container]
Image=zabbix-agent
ContainerName=zabbix-agent
LogDriver=journald
Network=host
Pull=newer
ReadOnly=yes
VolatileTmp=true
SecurityLabelDisable=yes
Ulimit=host
Unmask=ALL
AddCapability=SYS_ADMIN
AddCapability=SYS_RAWIO

AutoUpdate=registry

PodmanArgs=--pid=host
PodmanArgs=--ipc=host
PodmanArgs=--no-hosts
PodmanArgs=--device-cgroup-rule='a *:* r'

Volume=/etc/zabbix-agent2.conf:/etc/zabbix/zabbix_agent.conf:ro
Volume=/dev:/dev:ro
Volume=/var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket:rw

[Service]
Restart=always

[Install]
WantedBy=multi-user.target default.target
```

#### node-exporter (Prometheus)

```systemd
[Unit]
Description=Node exporter for Prometheus
After=local-fs.target

[Container]
Image=docker.io/prom/node-exporter:latest
ContainerName=node-exporter
LogDriver=journald
Network=host
Pull=newer
ReadOnly=yes
VolatileTmp=true
SecurityLabelDisable=yes
User=1222
UserNS=host
Ulimit=host
Unmask=ALL

AutoUpdate=registry

# Exec=--help

PodmanArgs=--pid=host
PodmanArgs=--ipc=host
PodmanArgs=--no-hosts

Volume=/proc:/host/proc:ro
Volume=/sys:/host/sys:ro
Volume=/:/rootfs:ro

Exec=--path.procfs=/host/proc --path.rootfs=/rootfs --path.sysfs=/host/sys --collector.filesystem.mount-points-exclude='^/(sys|proc|dev|host|etc)($$|/)'

[Service]
Restart=always

[Install]
# Start by default on boot
WantedBy=multi-user.target default.target
```
