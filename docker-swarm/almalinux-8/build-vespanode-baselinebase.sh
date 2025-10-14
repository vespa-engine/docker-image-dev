#!/usr/bin/env bash
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${DEBUG:-no}" == "true" ]]; then
    set -o xtrace
fi

# Build baseline base image for running vespa system tests using docker swarm.

DEBUG_IMAGE=false

args=$(getopt d "$@")
# shellcheck disable=SC2181
if [ $? -ne 0 ]; then
    echo "Usage: build-vespanode-baselinebase.sh [-d]" 1>&2
    exit 1
fi
# shellcheck disable=SC2086
set -- $args
while :; do
    case "$1" in
	-d) DEBUG_IMAGE=true; shift;;
	--) shift; break;;
    esac
done

if test $# -gt 0
then
    echo "Unexpected remaining arguments: $*" 1>&2
    exit 1
fi

if $DEBUG_IMAGE
then
    # Prepare image with debuginfo packages for dependencies which are needed
    # to properly handle stack backtraces and suppressions for some sanitizers.
    DEVIMAGE=vespa-debug-dev-almalinux-8
    if docker build --progress=plain -t $DEVIMAGE ../../debug-dev/almalinux-8
    then
	echo "Created $DEVIMAGE"
    else
	echo "Failed creating $DEVIMAGE" 1>&2
	exit 1
    fi
else
    DEVIMAGE=vespaengine/vespa-dev-almalinux-8
fi

CONTAINER_NAME=$USER-build-vespanode-baselinebase-almalinux-8
BASELINEBASE_NAME=$USER-vespanode-baselinebase-almalinux-8

docker stop "$CONTAINER_NAME"
docker container rm "$CONTAINER_NAME"

if docker run \
	  --name "$CONTAINER_NAME" \
	  --env RUBYLIB="/home/$USER/git/system-test/lib:/home/$USER/git/system-test/tests" \
	  --env USER="$USER" \
	  --env VESPA_HOME=/home/"$USER"/vespa \
	  --env VESPA_SYSTEM_TEST_HOME=/home/"$USER"/git/system-test \
	  --env VESPA_SYSTEM_TEST_USE_TLS=true \
	  --env VESPA_USER="$USER" \
	  "$DEVIMAGE" \
	  bash -cxe "(groupadd -g $(id -g) $(id -gn) || true) && useradd -M -g $(id -g) -u $(id -u) -c 'vespanode user' $USER && mkdir /home/$USER && chown $(id -u):$(id -g) /home/$USER && echo '$USER ALL=(ALL) NOPASSWD: ALL' >>/etc/sudoers"
then
    echo "Created user $USER"
    docker commit --change "USER $USER" --change "WORKDIR /home/$USER" "$CONTAINER_NAME" "$BASELINEBASE_NAME"
else
    echo "Failed creating user $USER" 1>&2
    exit 1
fi
docker container rm "$CONTAINER_NAME"
