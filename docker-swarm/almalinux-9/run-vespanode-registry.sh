#!/usr/bin/env bash
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${DEBUG:-no}" == "true" ]]; then
    set -o xtrace
fi

# docker pull registry:3
if test "$(docker image ls  -f reference=registry:3 | wc -l)" -le 1
then
    echo "registry:3 docker image is missing." 1>&2
    exit 1
fi
. "$(dirname "$0")"/vespanode-common.sh
CONTAINER_NAME=$USER-vespanode-registry
VOLUME_NAME=${CONTAINER_NAME}
docker container stop "${CONTAINER_NAME}" || true
docker container rm "${CONTAINER_NAME}" || true
docker run -d -p "${LOCAL_REGISTRY}:5000" -v "${VOLUME_NAME}":/var/lib/registry --name "${CONTAINER_NAME}" registry:3
