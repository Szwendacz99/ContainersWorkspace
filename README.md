# Containers-Workspace
Various useful and useless Dockerfiles, often experimental and work in progress

## toolbox

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
PostUp = nft add table inet filter; nft add chain inet filter forward { type filter hook forward priority 0 \; }; nft add rule inet filter forward iifname "%i" accept; nft add rule inet filter forward oifname "%i" accept; nft add table inet nat; nft add chain inet nat postrouting { type nat hook postrouting priority 100 \; }; nft add rule inet nat postrouting oifname "eth*" masquerade
PostDown = nft delete table inet filter
```

Example run (requires root and privileged for nftables setup)

```bash
podman run --privileged --name wireguard -d \
    -v './config:/data:ro' \
    -v './setup:/setup.d:ro' \
    -wireguard:latest
```
