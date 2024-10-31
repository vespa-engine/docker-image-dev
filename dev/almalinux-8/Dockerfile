# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

FROM docker.io/vespaengine/vespa-build-almalinux-8:latest

# Install sshd, man-db, nice-to-have packages and system test dependencies
RUN dnf -y install \
        bind-utils \
        openssh-server \
        xorg-x11-xauth \
        rsync \
        nmap-ncat \
        vim \
        wget \
        emacs \
        gcc-toolset-13-gdb \
        man-db \
        man-pages \
        hunspell-en \
        kdesdk-kcachegrind \
        python3-pip \
        graphviz && \
    pip3 install --upgrade pip && \
    pip3 install numpy xgboost scikit-learn && \
    dnf clean all --enablerepo=\* 

RUN useradd -M -d /opt/vespa -s /usr/sbin/nologin vespa

STOPSIGNAL SIGRTMIN+3

CMD [ "/usr/sbin/init" ]
