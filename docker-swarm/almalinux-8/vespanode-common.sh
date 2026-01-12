#!/usr/bin/env bash
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${DEBUG:-no}" == "true" ]]; then
    set -o xtrace
fi

# Sample settings
if test -d "$HOME"/volumes/vespa-dev-almalinux-8
then
    # shellcheck disable=SC2034
    VESPA_DEV_VOLUME=$HOME/volumes/vespa-dev-almalinux-8
else
    # shellcheck disable=SC2034
    VESPA_DEV_VOLUME=volume-vespa-dev-almalinux-8
fi
VESPANODE_IMAGE_SUFFIX=almalinux-8
LOCAL_REGISTRY_PORT=5000
TUNNELED_REGISTRY_PORT=5000
LOCAL_REGISTRY=127.0.0.1:$LOCAL_REGISTRY_PORT
TUNNELED_REGISTRY=127.0.0.1:$TUNNELED_REGISTRY_PORT
# shellcheck disable=SC2034
SSH_REGISTRY_TUNNEL_ARG="-R $TUNNELED_REGISTRY:$LOCAL_REGISTRY"

# Pick up overrides
for overrides_file in "$HOME"/.vespa-docker-image-dev-swarm-settings "$HOME"/.vespa-docker-image-dev-swarm-settings-"$VESPANODE_IMAGE_SUFFIX"
do
    # shellcheck disable=SC1090
    test -x "$overrides_file" && . "$overrides_file"
done
true
