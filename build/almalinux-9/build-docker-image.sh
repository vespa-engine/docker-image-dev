#!/bin/sh

ALMALINUX_VERSION=9

IMG="vespaengine/vespa-build-almalinux-${ALMALINUX_VERSION}:latest"
set - "--build-arg" $(cat ../vespa-src-ref.txt) "$@"

echo BUILDING: docker build --progress plain -t ${IMG} "$@" .
docker build --progress plain -t ${IMG} "$@" .
