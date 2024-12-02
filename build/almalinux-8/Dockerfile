# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

FROM almalinux:8

# Java requires proper locale for unicode. Set container=docker to allow systemd in container mode.
ENV LANG=C.UTF-8 container=docker

# Change git reference for a specific version of the vespa.spec file.
# Use a tag or SHA to allow for reproducible builds.
ENV VESPA_SRC_REF="b0402dc7d475bc65ac85d5d989b915f28d343ab8"

RUN --mount=type=bind,target=/include/,source=include/,rw /bin/sh /include/install-build-dependencies.sh
