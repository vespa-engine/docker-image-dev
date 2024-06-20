#!/bin/sh

ALMALINUX_VERSION=9

IMG="vespaengine/vespa-build-almalinux-${ALMALINUX_VERSION}:latest"

echo BUILDING: docker build --progress plain -t ${IMG} "$@" .
docker build --progress plain -t ${IMG} "$@" .
