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

Minimal(?)permissions example (for wayland)(you could also select single sockets from XDG_RUNTIME_DIR)
```bash
podman run -it --security-opt label:disable \
    -e XDG_RUNTIME_DIR=/runtime_dir\
    -e WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
    -v "$XDG_RUNTIME_DIR:/runtime_dir:rw" \
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
