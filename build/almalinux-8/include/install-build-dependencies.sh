#!/usr/bin/env sh
  
set -xeu

VESPADEV_RPM_SOURCE="${1:-external}"

case "$VESPADEV_RPM_SOURCE" in
    external|test) ;;
    *) echo "Bad \$VESPADEV_RPM_SOURCE: $VESPADEV_RPM_SOURCE" 1>&2
       exit 1;;
esac

# Enable and install repositories
dnf -y install epel-release
dnf -y install dnf-plugins-core dnf-plugin-ovl
case "$VESPADEV_RPM_SOURCE" in
    external) dnf -y copr enable @vespa/vespa "epel-8-$(arch)";;
    test) /work/setup-test-repo;;
esac
dnf config-manager --enable powertools

# Java requires proper locale for unicode
export LANG=C.UTF-8

# Use newest packages
dnf -y upgrade

# Use newer maven
dnf -y module enable maven:3.8

dnf -y install \
    ccache \
    createrepo \
    curl \
    git-core \
    iputils \
    jq \
    pinentry \
    python3-pip \
    rpmdevtools \
    ShellCheck \
    sudo \
    time \
    valgrind

# Install recent aws CLI
curl -sSLf "https://awscli.amazonaws.com/awscli-exe-linux-$(arch).zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Install session manager
if [ "$(arch)" = x86_64 ]; then
    dnf install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm
else
    dnf install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_arm64/session-manager-plugin.rpm
fi

GIT_REPO="https://github.com/vespa-engine/vespa"

# Change git reference for a specific version of the vespa.spec file. Use a tag or SHA to allow for reproducible builds.
VESPA_SRC_REF="69299e1ca432e9dec6711dcc0fe7af60b8c58f5b"

# Fetch the RPM spec for vespa
curl -Lf -O $GIT_REPO/raw/$VESPA_SRC_REF/dist/vespa.spec

# Pick runtime dependencies
sed -e '/^BuildRequires:/d' \
    -e '/^Requires: %{name}/d' \
    -e 's/^Requires:/BuildRequires:/' < vespa.spec > vesparun.spec

# Install vespa build and runtime dependencies
dnf builddep --nobest -y vespa.spec vesparun.spec
rm -f vespa.spec vesparun.spec
gcc_version=$(rpm -qa | sed -ne "s/vespa-toolset-\([0-9][0-9]\)-meta.*/\1/p")

#  Install extra compiler tools
dnf -y install \
    clang \
    "gcc-toolset-$gcc_version-libasan-devel" \
    "gcc-toolset-$gcc_version-libtsan-devel" \
    "gcc-toolset-$gcc_version-libubsan-devel"

# shellcheck disable=SC1091
. /opt/rh/gcc-toolset/enable
/usr/lib/rpm/redhat/redhat-annobin-plugin-select.sh

# Install Ruby in build image that is required for running system test in PR jobs for both Vespa and system tests
dnf -y module enable ruby:3.1
dnf -y install \
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

# Compile two rubygems
gem install ffi libxml-ruby

printf '%s\n'  "* soft nproc 409600"   "* hard nproc 409600"    > /etc/security/limits.d/99-nproc.conf
printf '%s\n'  "* soft core 0"         "* hard core unlimited"  > /etc/security/limits.d/99-coredumps.conf
printf '%s\n'  "* soft nofile 262144"  "* hard nofile 262144"   > /etc/security/limits.d/99-nofile.conf

# Install docker client  to avoid doing this in all pipelines.
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf -y install docker-ce docker-ce-cli containerd.io

# Env wrapper for git access via ssh
cp -a /include/ssh-env-config.sh /usr/local/bin

dnf install -y https://github.com/sigstore/cosign/releases/latest/download/cosign-"$(curl -sSL https://api.github.com/repos/sigstore/cosign/releases/latest | jq -re '.tag_name|sub("^v";"")')"-1."$(arch)".rpm


TRIVY_VERSION=$(curl -sSL https://api.github.com/repos/aquasecurity/trivy/releases/latest |  jq -re '.tag_name|sub("^v";"")')
KUBECTL_VERSION="1.31.1"
if [ "$(arch)" = x86_64 ]; then
  dnf install -y "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.rpm"
  curl -L -o /usr/local/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
else
  dnf install -y "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-ARM64.rpm"
  curl -L -o /usr/local/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/arm64/kubectl"
fi
chmod 755 /usr/local/bin/kubectl

# Install crane for image management
GOPATH=/usr/local go install github.com/google/go-containerregistry/cmd/crane@v0.20.2

# Install siad for Buildkite provider
ATHENZ_VERSION="1.11.65"
curl -Lf -O https://github.com/AthenZ/athenz/archive/refs/tags/v${ATHENZ_VERSION}.tar.gz
tar zxvf v${ATHENZ_VERSION}.tar.gz
(
  cd "/athenz-${ATHENZ_VERSION}/provider/buildkite/sia-buildkite"
  GOTOOLCHAIN=auto /usr/bin/go build -v ./cmd/siad
  mv ./siad /usr/local/bin
)
rm -rf v${ATHENZ_VERSION}.tar.gz athenz-${ATHENZ_VERSION} /root/go

# Cleanup
dnf clean all --enablerepo='*'
rm -rf /var/cache/yum
