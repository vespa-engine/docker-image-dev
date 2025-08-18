<!-- Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root. -->

# Scripts for building rpms on AlmaLinux 8

## Requirement

Docker or podman must be installed. This has only been tested with
docker-ce installed on Fedora and podman installed on Darwin (via homebrew).
On Fedora, the user should be a member of the docker group.

[vespa-3rdparty-deps](https://github.com/vespa-engine/vespa-3rdparty-deps) must
be checked out at `$HOME/git/vespa-3rdparty-deps`:

    mkdir -p $HOME/git
    cd $HOME/git
    git clone git@github.com:vespa-engine/vespa-3rdparty-deps.git

[vespa](https://github.com/vespa-engine/vespa) must
be checked out at `$HOME/git/vespa` when building vespa rpms:

    mkdir -p $HOME/git
    cd $HOME/git
    git clone git@github.com:vespa-engine/vespa.git

[vespa-ann-benchmark](https://github.com/vespa-engine/vespa-ann-benchmark) must
be checked out at `$HOME/git/vespa-ann-benchmark` when building vespa-ann-benchmark rpms:

    mkdir -p $HOME/git
    cd $HOME/git
    git clone git@github.com:vespa-engine/vespa-ann-benchmark.git

## Scripts that run in the host environment

### build-rpm.sh

This is a shell scripts that runs in the host environment, builds an rpm inside a container and stores the result in SRPMS and RPMS.

| Options | |
| :-- | :-- |
| -a      | automatic build, starts container and runs /work/build-rpm-inner.sh inside the container. |
| -m      | manual build, -r and -s options are ignored. Container is started but /work/build-rpm-inner.sh must be called manually inside the container. |
| -r      | rebuild from source rpm in same directory as build-rpm.sh script |
| -s      | split mode. Creates new container after making source rpm to miniminze initial set of installed rpms. Used to catch missing dependencies. |

The directory containing the build-rpm.sh script is mounted as `/work` inside
the container. The directory containing build-rpm-common.sh script is mounted as `/shared-work` inside the container. When building packages defined in vespa-3rdparty-deps repo, that repository is mounted as `/src` inside the container.

### refresh-test-repo

Rebuilds rpm repository metadata (index) inside the rpm repository.

## Scripts that run inside a build container

### build-rpm-inner.sh

Builds an rpm inside a container. The first argument is the package name, the optional second argument is one of:

| Second argument | |
| :-- | :-- |
| both (or missing) | Make source rpm and build rpm in the same container |
| srpm | make source rpm only, store it /root/rpmbuild/SRPMS (mounted from volume) |
| rebuild | build rpm from source rpm stored in /root/rpmbuild/SRPMS, store result in /work/SRPMS and /work/RPMS (mounted from host) |
| cleanrebuild | build rpm from source rpm stored in /work (mounted from host), store result in /work/SRPMS and /work/RPMS |

### setup-test-repo

Configures a vespa-test rpm repository mounted from host.
`/work/vespa-test.repo` is used as rpm repository config file.

# Example usage

Build all packages needed for building test docker image for vespa development or for building vespa rpms.

    cd $HOME/git/docker-image-dev/build/almalinux-8/rpmbuild
    ./build-rpm.sh -a toolset-12
    ./build-rpm.sh -a toolset-13
    ./build-rpm.sh -a toolset-14
    ./build-rpm.sh -a lz4
    ./build-rpm.sh -a zstd
    ./build-rpm.sh -a openssl
    ./build-rpm.sh -a cmake
    ./build-rpm.sh -a ccache
    ./build-rpm.sh -a gtest
    ./build-rpm.sh -a gradle
    ./build-rpm.sh -a onnxruntime
    ./build-rpm.sh -a abseil-cpp
    ./build-rpm.sh -a openblas
    ./build-rpm.sh -a protobuf
    ./build-rpm.sh -a build-dependencies
    ./build-rpm.sh -a jllama
    ./build-rpm.sh -a boost
    ./build-rpm.sh -a datasketches

Build test docker image for vespa development (assumes that packages above have been built)

    cd $HOME/git/docker-image-dev/build/almalinux-8
    ./build-test-docker-image.sh

Build vespa rpms (assumes that packages above have been built)

    cd $HOME/git/docker-image-dev/build/almalinux-8/rpmbuild
    ./build-rpm.sh -a vespa
