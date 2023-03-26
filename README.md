# Containers-Workspace
Various useful and useless Dockerfiles, often experimental and work in progress

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

starting dbus:

```bash
export $(dbus-launch)
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

# run
podman run -d --read-only \
    -v "/home/user/torrc.conf:/torrc:rw,Z" \
    -v "/home/user/tor/logs:/var/log:Z,rw" \
    -v "/home/user/tor/data:/var/lib/tor:Z,rw" \
    --name tornode -p 443:443 -p 9091:9091 tornode:latest

# prepare systemd service for reboot persistence
podman generate systemd --new --name tornode > /etc/systemd/system/tornode.service;
restorecon -v /etc/systemd/system/tornode.service;
systemctl daemon-reload;
systemctl enable --now tornode.service;

# view nyx dashboard
podman exec -it tornode nyx
```
