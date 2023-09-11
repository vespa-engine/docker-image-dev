# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

FROM almalinux:8.8

# Java requires proper locale for unicode
ENV LANG C.UTF-8

# Change git reference for a specific version of the vespa.spec file.
# Use a tag or SHA to allow for reproducible builds.
ENV VESPA_SRC_REF="19132930725b9a127fd3ca0421e4c0ba2b3d9225"

RUN --mount=type=bind,target=/include/,source=include/,rw /bin/sh /include/install-build-dependencies.sh
