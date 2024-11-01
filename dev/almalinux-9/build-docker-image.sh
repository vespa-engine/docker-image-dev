#!/bin/sh
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

ALMALINUX_VERSION=9

IMG="vespaengine/vespa-dev-almalinux-${ALMALINUX_VERSION}:latest"

echo BUILDING: docker build -t ${IMG} "$@" .
docker build -t ${IMG} "$@" .
