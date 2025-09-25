#!/bin/sh
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

cd "$(cd "$(dirname "$0")" && env pwd)" || exit 1

. ../../../shared-rpmbuild/build-rpm-common.sh

DOCKER_IMAGE=registry.fedoraproject.org/fedora:42
CONTAINER_SHORTNAME=fc42

build_rpm_common "$@"
