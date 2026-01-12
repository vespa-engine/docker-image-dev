#!/usr/bin/env bash
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${DEBUG:-no}" == "true" ]]; then
    set -o xtrace
fi

ALMALINUX_VERSION=8

IMG="vespaengine/vespa-dev-almalinux-${ALMALINUX_VERSION}:latest"

echo BUILDING: docker build -t ${IMG} "$@" .
docker build -t ${IMG} "$@" .
