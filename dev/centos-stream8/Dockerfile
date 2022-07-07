# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
FROM docker.io/vespaengine/vespa-build-centos-stream8:latest

RUN dnf install -y dnf-plugins-core && \
    dnf install -y epel-release && \
    dnf config-manager --enable powertools --enable epel && \
    dnf clean --enablerepo=* all

