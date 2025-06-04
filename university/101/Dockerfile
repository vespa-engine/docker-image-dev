# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

FROM ubuntu:22.04

ARG TARGET_USER=student

RUN apt-get update

RUN yes | unminimize

RUN apt-get -y install man-db
RUN apt-get -y install sudo
RUN apt-get -y install bash procps file unzip
RUN apt-get -y install ca-certificates

RUN apt-get -y install curl wget

RUN apt-get -y install git
RUN apt-get -y install openjdk-21-jdk
RUN apt-get -y install unzip

# nice-to-haves:
RUN apt-get -y install jq
RUN apt-get -y install less
RUN apt-get -y install vim emacs nano

ENV TARGET_USER=student
ENV USER_HOME=/home/$TARGET_USER

RUN \
	useradd -m -s /bin/bash -d ${USER_HOME} ${TARGET_USER}                \
	&& passwd -d ${TARGET_USER}                                                   \
	&& echo "${TARGET_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers               \
	&& echo "export VESPA_CLI_DUMMY_KEYRING=true" >> /home/${TARGET_USER}/.bashrc \
	&& chown -R ${TARGET_USER}:${TARGET_USER} ${USER_HOME}

RUN curl -fsSL https://code-server.dev/install.sh | sh

# with podman on MacOS, replace ,rw with ,z below:
RUN --mount=type=bind,target=/include/,source=include/,rw /bin/bash /include/code-server.sh
RUN --mount=type=bind,target=/include/,source=include/,rw /bin/bash /include/cli.sh
RUN --mount=type=bind,target=/include/,source=include/,rw /bin/bash /include/lsp.sh
RUN --mount=type=bind,target=/include/,source=include/,rw /bin/bash /include/rest-client.sh
RUN --mount=type=bind,target=/include/,source=include/,rw /bin/bash /include/labs.sh

RUN mkdir $USER_HOME/.cache
RUN touch $USER_HOME/.cache/motd.legal-displayed
RUN chown -R ${TARGET_USER}:${TARGET_USER} ${USER_HOME}

RUN --mount=type=bind,target=/include/,source=include/,rw /bin/bash /include/motd.sh

# run with  "docker run --hostname console -ti -p 5050:5000 uni101:v006 /bin/sh -c '/bin/login -f student'"
