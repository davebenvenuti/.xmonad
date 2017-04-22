#!/usr/bin/env bash

pactl list sinks | grep -A10 analog-stereo | grep -P '^\W+Volume:' | grep -Po '\d{1,3}%' | head -1
