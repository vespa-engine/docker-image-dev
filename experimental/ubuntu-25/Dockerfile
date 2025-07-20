# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

FROM ubuntu:plucky-20250714

ARG MYUSERNAME=myuser
ARG ONNXCPU=x64
ARG ONNXVER=1.20.0

RUN apt-get update

RUN apt-get -y install unminimize
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
    wget --progress=dot:mega -O- https://github.com/microsoft/onnxruntime/releases/download/v$ONNXVER/onnxruntime-linux-$ONNXCPU-$ONNXVER.tgz | \
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
RUN apt-get -y install build-essential
RUN apt-get -y install gdb llvm
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
RUN apt-get -y install libssl-dev
RUN apt-get -y install libxxhash-dev
RUN apt-get -y install libzstd-dev
RUN apt-get -y install libicu-dev

# protobuf is too old, skip
# RUN apt-get -y install protobuf-compiler libprotobuf-dev
# uses too-old abseil (libabsl-dev) version
# RUN apt-get -y install libre2-dev

# go development environment:
RUN apt-get -y install golang

# python development environment:
RUN apt-get -y install python-is-python3
RUN apt-get -y install python3-pybind11 python3-pytest

# nice-to-haves:
RUN apt-get -y install jq
RUN apt-get -y install strace
RUN apt-get -y install vim emacs
RUN apt-get -y install rsync
RUN apt-get -y install file

# ruby is needed if you want to run tests from vespa-engine/system-test
RUN apt-get -y install ruby
RUN apt-get -y install ruby-ffi ruby-libxml

RUN cd && mvn org.apache.maven.plugins:maven-dependency-plugin::get -Dartifact=com.microsoft.onnxruntime:onnxruntime:$ONNXVER:jar
RUN cd && unzip .m2/repository/com/microsoft/onnxruntime/onnxruntime/$ONNXVER/onnxruntime-$ONNXVER.jar ai/onnxruntime/native/*
RUN cd && mv -v ai/onnxruntime/native/linux-$ONNXCPU/libonnxruntime4j_jni.so /opt/vespa-deps/lib
RUN cd && rm -rf .m2 ai

RUN wget --progress=dot:mega https://github.com/abseil/abseil-cpp/releases/download/20250512.0/abseil-cpp-20250512.0.tar.gz
RUN wget --progress=dot:mega https://github.com/protocolbuffers/protobuf/releases/download/v31.1/protobuf-31.1.tar.gz
RUN wget --progress=dot:mega https://github.com/google/re2/releases/download/2024-07-02/re2-2024-07-02.tar.gz
RUN wget --progress=dot:mega -Ojava-llama.cpp-4.1.0.tar.gz https://github.com/kherud/java-llama.cpp/archive/refs/tags/v4.1.0.tar.gz

RUN tar xzf abseil-cpp-20250512.0.tar.gz
RUN cmake -S abseil-cpp-20250512.0 -B build.absl \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_CXX_STANDARD=20 \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_RPATH=/opt/vespa-deps/lib \
    -DCMAKE_INSTALL_PREFIX=/opt/vespa-deps
RUN cmake --build build.absl -j 8
RUN make -C build.absl install

RUN tar xzf protobuf-31.1.tar.gz
RUN cmake -S protobuf-31.1 -B build.protobuf \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_CXX_STANDARD=20 \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_RPATH=/opt/vespa-deps/lib \
    -Dprotobuf_BUILD_TESTS=OFF \
    -DCMAKE_INSTALL_PREFIX=/opt/vespa-deps
RUN cmake --build build.protobuf -j 8
RUN make -C build.protobuf install

RUN tar xzf re2-2024-07-02.tar.gz
RUN cmake -S re2-2024-07-02 -B build.re2 \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_CXX_STANDARD=20 \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_RPATH=/opt/vespa-deps/lib \
    -DCMAKE_INSTALL_PREFIX=/opt/vespa-deps
RUN cmake --build build.re2 -j 8
RUN make -C build.re2 install

RUN tar xzf java-llama.cpp-4.1.0.tar.gz
RUN cd java-llama.cpp-4.1.0 && mvn compile
RUN cd java-llama.cpp-4.1.0 && cmake -S . -B build \
    -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_CXX_STANDARD=20 \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_RPATH=/opt/vespa-deps/lib \
    -DCMAKE_INSTALL_PREFIX=/opt/vespa-deps
RUN cd java-llama.cpp-4.1.0 && cmake --build build -j 8
RUN cd java-llama.cpp-4.1.0 && cp src/main/resources/de/kherud/llama/Linux/*/libjllama.so /opt/vespa-deps/lib/.

RUN \
    printf "%s\n%s\n" "* soft nproc 102400"  "* hard nproc 102400"  > /etc/security/limits.d/99-nproc.conf && \
    printf "%s\n%s\n" "* soft nofile 262144" "* hard nofile 262144" > /etc/security/limits.d/99-nofile.conf

COPY compile-vespa.sh /usr/local/bin/compile-vespa.sh
RUN ls -l /usr/local/bin

STOPSIGNAL SIGRTMIN+3

CMD [ "/usr/sbin/init" ]
