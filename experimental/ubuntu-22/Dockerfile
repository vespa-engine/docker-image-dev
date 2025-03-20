# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

FROM ubuntu:24.04

ARG MYUSERNAME=myuser
ARG ONNXCPU=x64
ARG ONNXVER=1.13.1

RUN apt-get update

RUN yes | unminimize

RUN useradd -M -d /opt/vespa -s /usr/sbin/nologin vespa

RUN apt-get -y install man-db
RUN apt-get -y install ssh
RUN apt-get -y install sudo
RUN apt-get -y install bash

RUN useradd -s /bin/bash $MYUSERNAME
RUN echo $MYUSERNAME 'ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN apt-get -y install curl wget

# ubuntu does not have any package for onnxruntime, so fetch the tarball from github
# and move the files to where the Vespa cmake setup expects to find them

RUN mkdir -p /opt/vespa-deps && cd /opt/vespa-deps && \
    wget -O- https://github.com/microsoft/onnxruntime/releases/download/v$ONNXVER/onnxruntime-linux-$ONNXCPU-$ONNXVER.tgz | \
    tar -zxf - && \
    cd onnxruntime-linux-$ONNXCPU-$ONNXVER && \
    mkdir -p /opt/vespa-deps/lib && \
    mkdir -p /opt/vespa-deps/share/onnxruntime && \
    mkdir -p /opt/vespa-deps/include/onnxruntime && \
    mv lib/*     /opt/vespa-deps/lib && rmdir lib && \
    mv include/* /opt/vespa-deps/include/onnxruntime && rmdir include && \
    mv LICENSE VERSION_NUMBER GIT_COMMIT_ID Privacy.md README.md ThirdPartyNotices.txt /opt/vespa-deps/share/onnxruntime && \
    rmdir /opt/vespa-deps/onnxruntime-linux-$ONNXCPU-$ONNXVER

# ubuntu uses "lib" not "lib64", but:
# vespa expects to load libraries at runtime from /opt/vespa-deps/lib64
RUN cd /opt/vespa-deps && ln -sf lib lib64

# basic C++ developement:
RUN apt-get -y install git
RUN apt-get -y install gcc-12 'g\+\+-12' gdb llvm
RUN apt-get -y install make cmake ccache
RUN apt-get -y install bison flex

# java development environment:
RUN apt-get -y install openjdk-17-jdk
RUN apt-get -y install maven
RUN apt-get -y install zip unzip

# libraries used by vespa:
RUN apt-get -y install libboost-dev
RUN apt-get -y install libedit-dev
RUN apt-get -y install libgmock-dev
RUN apt-get -y install libgtest-dev
RUN apt-get -y install liblz4-dev
RUN apt-get -y install libopenblas-dev
RUN apt-get -y install libpython3-dev
RUN apt-get -y install libre2-dev
RUN apt-get -y install libssl-dev
RUN apt-get -y install libxxhash-dev
RUN apt-get -y install libzstd-dev

# protobuf
RUN apt-get -y install protobuf-compiler libprotobuf-dev

# go development environment:
RUN apt-get -y install golang

# python development environment:
RUN apt-get -y install python-is-python3
RUN apt-get -y install python3-pybind11 python3-pytest

# nice-to-haves:
RUN apt-get -y install jq
RUN apt-get -y install strace
RUN apt-get -y install vim emacs

# ruby is needed if you want to run tests from vespa-engine/system-test
RUN apt-get -y install ruby
RUN apt-get -y install ruby-ffi ruby-libxml
RUN apt-get -y install file

RUN \
    printf "%s\n%s\n" "* soft nproc 409600"  "* hard nproc 409600"  > /etc/security/limits.d/99-nproc.conf && \
    printf "%s\n%s\n" "* soft nofile 262144" "* hard nofile 262144" > /etc/security/limits.d/99-nofile.conf

STOPSIGNAL SIGRTMIN+3

CMD [ "/usr/sbin/init" ]
