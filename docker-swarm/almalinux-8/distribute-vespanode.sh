#!/usr/bin/env bash
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${DEBUG:-no}" == "true" ]]; then
    set -o xtrace
fi

host=$1
DOCKER_IMAGE=$2
. "$(dirname "$0")"/vespanode-common.sh
# shellcheck disable=SC2086
ssh -a $SSH_REGISTRY_TUNNEL_ARG -o ExitOnForwardFailure=yes "$host" bash -lc "'git/docker-image-dev/docker-swarm/almalinux-8/download-vespanode.sh $DOCKER_IMAGE $TUNNELED_REGISTRY'"
