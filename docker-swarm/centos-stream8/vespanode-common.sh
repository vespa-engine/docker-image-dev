#!/bin/sh
# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

# Sample settings
if test -d $HOME/volumes/vespa-dev-centos-stream8
then
    VESPA_DEV_VOLUME=$HOME/volumes/vespa-dev-centos-stream8
else
    VESPA_DEV_VOLUME=volume-vespa-dev-centos-stream8
fi
VESPANODE_IMAGE_SUFFIX=centos-stream8
LOCAL_REGISTRY_PORT=5000
TUNNELED_REGISTRY_PORT=5000
LOCAL_REGISTRY=127.0.0.1:$LOCAL_REGISTRY_PORT
TUNNELED_REGISTRY=127.0.0.1:$TUNNELED_REGISTRY_PORT
SSH_REGISTRY_TUNNEL_ARG="-R 127.0.0.1:$TUNNELED_REGISTRY_PORT:127.0.0.1:$LOCAL_REGISTRY_PORT"

# Pick up overrides
for overrides_file in $HOME/.vespa-docker-image-dev-swarm-settings $HOME/.vespa-docker-image-dev-swarm-settings-$VESPANODE_IMAGE_SUFFIX
do
    test -x $overrides_file && . $overrides_file
done
true
