#!/bin/sh

ALMALINUX_VERSION=8

IMG="vespaengine/vespa-dev-almalinux-${ALMALINUX_VERSION}:latest"

echo BUILDING: docker build -t ${IMG} "$@" .
docker build -t ${IMG} "$@" .
