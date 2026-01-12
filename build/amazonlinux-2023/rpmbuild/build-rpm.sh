#!/usr/bin/env bash
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${DEBUG:-no}" == "true" ]]; then
    set -o xtrace
fi

cd "$(cd "$(dirname "$0")" && env pwd)" || exit 1

. ../../../shared-rpmbuild/build-rpm-common.sh

DOCKER_IMAGE=amazonlinux:2023
CONTAINER_SHORTNAME=amzn2023

build_rpm_common "$@"
