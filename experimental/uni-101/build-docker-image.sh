#!/bin/sh

UBUNTU_VERSION=22.04

# myusername=$(id -un)
# set - "--build-arg" "MYUSERNAME=$myusername" "$@"

echo BUILDING:
set -x
docker build --progress plain -t uni101:v006 "$@" .
