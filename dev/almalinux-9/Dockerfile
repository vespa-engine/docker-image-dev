# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

FROM docker.io/vespaengine/vespa-build-almalinux-9:latest

RUN --mount=type=bind,target=/include/,source=include/,rw /bin/sh /include/setup.sh

# Add default user
RUN useradd -M -d /opt/vespa -s /usr/sbin/nologin vespa

STOPSIGNAL SIGRTMIN+3

CMD [ "/usr/sbin/init" ]
