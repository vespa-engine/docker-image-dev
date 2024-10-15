#!/bin/sh -ex
# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

# shellcheck source=../../../shared-rpmbuild/build-rpm-inner-common.sh
. /shared-work/build-rpm-inner-common.sh

enable_repos()
{
    dnf -y install \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
        https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm
    dnf -y install 'dnf-command(config-manager)'
    dnf config-manager --set-enabled crb
}

enable_modules()
{
    dnf -y module enable maven:3.8
    dnf -y module enable ruby:3.1
}

enable_cuda_repos()
{
    enable_cuda_repos_helper rhel9
}

build_rpm_inner_common "$@"
