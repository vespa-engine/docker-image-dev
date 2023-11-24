#!/usr/bin/env sh
  
set -xeu

# Needed to build vespa
dnf -y install epel-release
dnf -y install dnf-plugins-core dnf-plugin-ovl
dnf -y copr enable @vespa/vespa centos-stream-8
dnf config-manager --enable powertools
dnf -y install \
        ccache \
        git \
        iputils \
        jq \
        pinentry \
        rpmdevtools \
        sudo


GIT_REPO="https://github.com/vespa-engine/vespa.git"

# Change git reference for a specific version of the vespa.spec file. Use a tag or SHA to allow for reproducible builds.
VESPA_SRC_REF="4c09bb8a361db8c22a105f24c100fe31153ba685"

# Fetch the RPM spec for vespa
curl -Lf -O $GIT_REPO/raw/$VESPA_SRC_REF/dist/vespa.spec
sed -e '/^BuildRequires:/d' -e '/^Requires: %{name}/d' -e 's/^Requires:/BuildRequires:/' vespa.spec > vesparun.spec
dnf -y module enable maven:3.8
dnf builddep --nobest -y vespa.spec vesparun.spec
rm -f vespa.spec vesparun.spec
alternatives --set java java-17-openjdk.$(arch)
alternatives --set javac java-17-openjdk.$(arch)
dnf install -y maven-openjdk17
gcc_version=$(rpm -qa | sed -ne "s/vespa-toolset-\([0-9][0-9]\)-meta.*/\1/p")

printf '%s\n%s\n' "# gcc" "source /opt/rh/gcc-toolset-$gcc_version/enable"  > /etc/profile.d/enable-gcc-toolset-$gcc_version.sh
printf '%s\n%s\n' "* soft nproc 409600"  "* hard nproc 409600"    > /etc/security/limits.d/99-nproc.conf
printf '%s\n%s\n' "* soft core 0"        "* hard core unlimited"  > /etc/security/limits.d/99-coredumps.conf
printf '%s\n%s\n' "* soft nofile 262144" "* hard nofile 262144"   > /etc/security/limits.d/99-nofile.conf

# Install Ruby in build image that is required for running system test in PR jobs for both Vespa and system tests
dnf -y module enable ruby:3.0
dnf -y install \
    clang \
    gcc-toolset-$gcc_version-libasan-devel \
    gcc-toolset-$gcc_version-libtsan-devel \
    gcc-toolset-$gcc_version-libubsan-devel \
    libffi-devel \
    libxml2-devel \
    ruby \
    ruby-devel \
    rubygems \
    rubygems-devel \
    rubygem-bigdecimal \
    rubygem-builder \
    rubygem-builder-doc \
    rubygem-concurrent-ruby \
    rubygem-concurrent-ruby-doc \
    rubygem-parallel \
    rubygem-parallel-doc \
    rubygem-rexml \
    rubygem-test-unit
( . /opt/rh/gcc-toolset-$gcc_version/enable && \
  /usr/lib/rpm/redhat/redhat-annobin-plugin-select.sh )

(source /opt/rh/gcc-toolset-$gcc_version/enable && gem install ffi libxml-ruby)

# Install docker client  to avoid doing this in all pipelines.
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf -y install docker-ce docker-ce-cli containerd.io

dnf clean all --enablerepo='*'
