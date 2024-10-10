#!/bin/bash

docker run \
    -it --privileged --net=host --pid=host \
    -v /dev:/dev:ro \
    -v /lib/modules:/lib/modules:ro \
    -v /etc/os-release:/etc/os-release:ro \
    -v /var/log:/var/log:ro \
    -v ./output:/output \
    xoseperez/hw-probe -all -save /output
