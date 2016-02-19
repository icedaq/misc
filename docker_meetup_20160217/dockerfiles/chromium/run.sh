#!/bin/bash

docker run --net host --name chromium -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY chromium
