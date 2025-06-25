#!/bin/sh
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

cd "$(cd "$(dirname "$0")" && env pwd)" || exit 1

. ../../../shared-rpmbuild/build-rpm-common.sh

DOCKER_IMAGE=almalinux:10
CONTAINER_SHORTNAME=a10

build_rpm_common "$@"
