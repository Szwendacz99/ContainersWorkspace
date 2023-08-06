#!/bin/bash

stopcontainer()
{
    echo "removing wg0 interface"
    wg-quick down /data/wg0.conf
    echo goodbye
    exit 0
}

trap stopcontainer SIGINT

for file in /setup.d/*;
do
    echo "Executing setup file $file";
    bash -c "$file";
done

wg-quick up /data/wg0.conf

sleep infinity &
wait $!
