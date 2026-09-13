#!/usr/bin/env bash
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${DEBUG:-no}" == "true" ]]; then
    set -o xtrace
fi

# Enable and install repositories
dnf -y install epel-release
dnf -y install dnf-plugins-core
dnf -y install 'dnf-command(config-manager)'
/usr/bin/crb enable

# Java requires proper locale for unicode
export LANG=C.UTF-8

# Use newest packages
dnf -y upgrade

# Install OpenTofu in the Build
/include/install-opentofu.sh

dnf -y install \
    rpm-sign \
    gnupg2 \
    ccache \
    createrepo_c \
    git-core \
    iputils \
    jq \
    openssl \
    pinentry \
    rpmdevtools \
    ShellCheck \
    sudo \
    time \
    unzip

if [ "$(arch)" = x86_64 ]; then
  GOARCH=amd64
else
  GOARCH=arm64
fi

# We want the newest version of golang:
GOTGZ="go1.27.1.linux-$GOARCH.tar.gz"
curl -sSL -O "https://go.dev/dl/$GOTGZ"
rm -rf /usr/local/go && tar -C /usr/local -xzf $GOTGZ
rm -f $GOTGZ
ln -sf /usr/local/go/bin/go /usr/local/bin/go
ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt

# Install recent aws CLI
curl -sSLf "https://awscli.amazonaws.com/awscli-exe-linux-$(arch).zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Install session manager
if [ "$(arch)" = x86_64 ]; then
    dnf install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm
else
    dnf install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_arm64/session-manager-plugin.rpm
fi

# Install docker client  to avoid doing this in all pipelines.
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# The versions pinned for the almalinux 8 and 9 images are not built for EL10,
# so use whatever the docker-ce repo offers for EL10.
dnf install -y \
  containerd.io \
  docker-buildx-plugin \
  docker-ce \
  docker-ce-cli \
  docker-ce-rootless-extras \
  docker-compose-plugin

# Env wrapper for git access via ssh
cp -a /include/ssh-env-config.sh /usr/local/bin

# FIXME @marlon remove hardcoded versions and fetch latest after updating usage
# Refer to https://blog.sigstore.dev/cosign-3-0-available/
# COSIGN_VERSION=$(curl https://api.github.com/repos/sigstore/cosign/releases/latest | grep tag_name | cut -d : -f2 | tr -d "v\", ")
COSIGN_VERSION=2.6.1
echo "✍️ Installing cosign version ${COSIGN_VERSION}"
dnf install -y "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-${COSIGN_VERSION}-1.$(arch).rpm"

TRIVY_VERSION=$(curl -sSL https://api.github.com/repos/aquasecurity/trivy/releases/latest |  jq -re '.tag_name|sub("^v";"")')
KUBECTL_VERSION="1.34.3"
echo "⎈ Installing trivy version ${TRIVY_VERSION} and kubectl version ${KUBECTL_VERSION}"
if [ "$(arch)" = x86_64 ]; then
  dnf install -y "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.rpm"
  curl -L -o /usr/local/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
else
  dnf install -y "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-ARM64.rpm"
  curl -L -o /usr/local/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/arm64/kubectl"
fi

chmod 755 /usr/local/bin/kubectl

# Install helm for package management in Kubernetes
/include/get_helm.sh --version 3.19.4

# Install crane for image management
GOPATH=/usr/local go install github.com/google/go-containerregistry/cmd/crane@v0.21.5

# Install siad for Buildkite provider
# FIXME @marlon remove hardcoded version and fetch latest after updating usage
ATHENZ_VERSION="1.11.67"
echo "🔑 Installing athenz version ${ATHENZ_VERSION} and building siad for buildkite"
curl -Lf -O https://github.com/AthenZ/athenz/archive/refs/tags/v${ATHENZ_VERSION}.tar.gz
tar zxf v${ATHENZ_VERSION}.tar.gz
(
  cd "/athenz-${ATHENZ_VERSION}/provider/buildkite/sia-buildkite"
  GOTOOLCHAIN=auto /usr/local/bin/go build -v ./cmd/siad
  mv ./siad /usr/local/bin
)
rm -rf v${ATHENZ_VERSION}.tar.gz athenz-${ATHENZ_VERSION} /root/go

# EL10 has python3.12 already, should be OK
dnf install -y python3-pip

# Add factory command
curl -L -o /usr/local/bin/factory-command "https://raw.githubusercontent.com/vespa-engine/vespa/refs/heads/master/.buildkite/factory-command.sh"
chmod 755 /usr/local/bin/factory-command

# Cleanup
dnf clean all --enablerepo='*'
rm -rf /var/cache/yum

printf '%s\n' \
       '# for cmake, ccache, protobuf etc:' \
       'export PATH="/opt/vespa-deps/bin:${PATH}"'              >  /etc/profile.d/enable-vespa-deps.sh

printf '%s\n'  "* soft nproc 102400"   "* hard nproc 102400"    > /etc/security/limits.d/99-nproc.conf
printf '%s\n'  "* soft core 0"         "* hard core unlimited"  > /etc/security/limits.d/99-coredumps.conf
printf '%s\n'  "* soft nofile 262144"  "* hard nofile 262144"   > /etc/security/limits.d/99-nofile.conf
