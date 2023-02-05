#!/bin/sh

ALMALINUX_VERSION=8

cname="vespa-almalinux-${ALMALINUX_VERSION}"

IMG="${cname}-build"

echo BUILDING: docker build --progress plain -t ${IMG} "$@" .
docker build --progress plain -t ${IMG} "$@" .
