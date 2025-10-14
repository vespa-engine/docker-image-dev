#!/usr/bin/env bash
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${DEBUG:-no}" == "true" ]]; then
    set -o xtrace
fi

ALMALINUX_VERSION=9

IMG="vespaengine/vespa-build-almalinux-${ALMALINUX_VERSION}:latest"
set - "--build-arg" $(cat ../vespa-src-ref.txt) "$@"

echo BUILDING: docker build --progress plain -t ${IMG} "$@" .
docker build --progress plain -t ${IMG} "$@" .
