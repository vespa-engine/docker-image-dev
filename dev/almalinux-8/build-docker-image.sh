#!/bin/sh

ALMALINUX_VERSION=8

cname="vespa-almalinux-${ALMALINUX_VERSION}"

IMG="${cname}-dev:latest"

echo BUILDING: docker build -t ${IMG} "$@" .
docker build -t ${IMG} "$@" .