#!/usr/bin/env bash

lsb_release -a | grep vivid > /dev/null

if [ "$?" == "0" ]; then
    pactl list sinks | grep -A10 analog-stereo | grep -P '^\W+Volume:' | grep -Po '\d{1,3}%' | head -1
else
    pactl list sinks | grep "Volume: 0" | tail -1 | awk -F : '{ print $4 }' | sed -e 's/^[[:space:]]*//'
fi

