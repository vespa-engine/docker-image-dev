#!/bin/sh

UBUNTU_VERSION=24.04

case $(uname -m) in
	arm64|aarch64) set - "--build-arg" "ONNXCPU=aarch64" "$@" ;;
esac

myusername=$(id -un)
set - "--build-arg" "MYUSERNAME=$myusername" "$@"

echo BUILDING: docker build -t vespa-ubuntu-dev:${UBUNTU_VERSION} "$@" .
docker build -t vespa-ubuntu-dev:${UBUNTU_VERSION} "$@" .
