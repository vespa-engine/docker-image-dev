#!/bin/sh
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

ALMALINUX_VERSION=8test

# shellcheck disable=SC2209
VESPADEV_RPM_SOURCE=test

case "$1" in
    test|external)
        VESPADEV_RPM_SOURCE=$1
        shift;;
esac

case "$VESPADEV_RPM_SOURCE" in
    test) rpmbuild/refresh-test-repo;;
esac

IMG="vespaengine/vespa-build-almalinux-${ALMALINUX_VERSION}:latest"

WORKDIR=$(cd "$(dirname "$0")" && env pwd)
cd "$WORKDIR" || exit 1

# shellcheck disable=SC1091
. ../../shared/common.sh
set - "--build-arg" $(cat ../vespa-src-ref.txt) "$@"

MOUNTS_CMD=

case "$CONTAINER_ENGINE" in
    podman) DOCKERFILE_MOUNTS_CMD=
	    MOUNTS_CMD="-v $WORKDIR/include:/include -v $WORKDIR/rpmbuild:/work"
	    ;;
    docker) DOCKERFILE_MOUNTS_CMD="--mount=type=bind,target=/include/,source=include/,rw --mount=type=bind,target=/work/,source=rpmbuild/,ro"
	    MOUNTS_CMD=""
	    ;;
esac

sed -e "s;@@MOUNTS_CMD@@;$DOCKERFILE_MOUNTS_CMD;" -e "s,@@VESPADEV_RPM_SOURCE@@,$VESPADEV_RPM_SOURCE," Dockerfile.test.tmpl > Dockerfile.test

# shellcheck disable=SC2086
echo BUILDING: docker build --progress plain $MOUNTS_CMD -t "${IMG}" -f Dockerfile.test "$@" "$WORKDIR"
# shellcheck disable=SC2086
$CONTAINER_ENGINE build --progress plain $MOUNTS_CMD -t "${IMG}" -f Dockerfile.test "$@" "$WORKDIR"
