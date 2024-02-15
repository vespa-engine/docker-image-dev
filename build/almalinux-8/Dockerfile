# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

FROM almalinux:8

# Java requires proper locale for unicode
ENV LANG C.UTF-8

# Change git reference for a specific version of the vespa.spec file.
# Use a tag or SHA to allow for reproducible builds.
ENV VESPA_SRC_REF="15bf1fde5bae46750516ff1facb8a52250043afd"

RUN --mount=type=bind,target=/include/,source=include/,rw /bin/sh /include/install-build-dependencies.sh
