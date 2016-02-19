#!/bin/bash

docker run --name tilda --net host -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=unix$DISPLAY tilda
