# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

FROM almalinux:8

# Java requires proper locale for unicode. Set container=docker to allow systemd in container mode.
ENV LANG=C.UTF-8 container=docker

# Change git reference for a specific version of the vespa.spec file.
# Use a tag or SHA to allow for reproducible builds.
ENV VESPA_SRC_REF="f8f0e7afcb6fac3325e72be014496e78790c1b58"

RUN --mount=type=bind,target=/include/,source=include/,rw /bin/sh /include/install-build-dependencies.sh
