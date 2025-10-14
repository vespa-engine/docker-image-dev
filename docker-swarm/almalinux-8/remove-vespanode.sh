#!/usr/bin/env bash
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${DEBUG:-no}" == "true" ]]; then
    set -o xtrace
fi

DOCKER_IMAGE=$1
. "$(dirname "$0")"/vespanode-common.sh
echo "Removing vespanode image ${DOCKER_IMAGE} on $(hostname)"
docker image rm "${TUNNELED_REGISTRY}/${DOCKER_IMAGE}"
docker image rm "${LOCAL_REGISTRY}/${DOCKER_IMAGE}"
docker image rm "${DOCKER_IMAGE}"
true
