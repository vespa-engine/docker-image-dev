# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

# Docker image for vespa development with debug info for dependencies
# added.

FROM docker.io/vespaengine/vespa-dev-almalinux-8:latest

RUN dnf debuginfo-install -y \
        --setopt="docker-ce-stable-debuginfo.skip_if_unavailable=true" \
        $(rpm -q -a --qf '%{NAME}\n' | grep -E '^vespa(-.*)?$') \
        glibc \
        libatomic \
        libffi \
        libgcc \
        libgfortran \
        libicu \
        libquadmath \
        libstdc++ \
        llvm-libs \
        ncurses-libs \
        re2 \
        xxhash-libs \
        zlib && \
    dnf clean all --enablerepo='*'
