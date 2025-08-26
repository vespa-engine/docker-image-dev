#!/usr/bin/env bash
#
# Installs OpenTofu
#
# Ref: https://opentofu.org/docs/intro/install/rpm/

RPM_REPO_URL="https://packages.opentofu.org/opentofu/tofu/rpm_any/rpm_any/"
RPM_GPG_URL="https://get.opentofu.org/opentofu.asc"

bold=""
normal=""
red=""
green=""
yellow=""
cyan=""
gray=""
if [ -t 1 ]; then
    if command -v "tput" >/dev/null 2>&1; then
      colors=$(tput colors)
    else
      colors=2
    fi

    if [ "${colors}" -ge 8 ]; then
        bold="$(tput bold)"
        normal="$(tput sgr0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        cyan="$(tput setaf 6)"
        gray="$(tput setaf 245)"
    fi
fi

log_success() {
  if [ -z "$1" ]; then
    return
  fi
  echo "${green}$1${normal}" 1>&2
}

log_warning() {
  if [ -z "$1" ]; then
    return
  fi
  echo "${yellow}$1${normal}" 1>&2
}

log_info() {
  if [ -z "$1" ]; then
    return
  fi
  echo "${cyan}$1${normal}" 1>&2
}

log_debug() {
  if [ -z "$1" ]; then
    return
  fi
  if [ -z "${LOG_DEBUG}" ]; then
    return
  fi
  echo "${gray}$1${normal}" 1>&2
}

log_error() {
  if [ -z "$1" ]; then
    return
  fi
  echo "${red}$1${normal}" 1>&2
}
set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

install_repos() {
  if ! tee /etc/yum.repos.d/opentofu.repo; then
    log_error "Failed to write /etc/yum.repos.d/opentofu.repo"
    return 2
  fi <<EOF
[opentofu]
name=opentofu
baseurl=${RPM_REPO_URL}\$basearch
repo_gpgcheck=0
gpgcheck=1
enabled=1
gpgkey=${RPM_GPG_URL}
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300

[opentofu-source]
name=opentofu-source
baseurl=${RPM_REPO_URL}SRPMS
repo_gpgcheck=0
gpgcheck=1
enabled=1
gpgkey=${RPM_GPG_URL}
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
EOF
  for GPG_SRC in ${RPM_GPG_URL}; do
    echo "Importing GPG key from ${GPG_SRC}..."
    if ! rpm --import "${GPG_SRC}"; then
      log_error "Failed to import GPG key from ${GPG_SRC}."
      return 2
    fi
  done
}

main() {
  if ! command -v dnf >/dev/null; then
    log_error "dnf command not found. Cannot install OpenTofu."
    return 1
  fi

  if ! install_repos; then
    log_error "Failed to install OpenTofu."
    return 2`
  fi

  if ! dnf install -y tofu; then
    log_error "Failed to install tofu via dnf."
    return 3
  fi
  if ! tofu --version; then
    log_error "Failed to run tofu after installation."
    return 3
  fi

  log_info "${bold}OpenTofu installed successfully.${normal}"
  return 0
}

main "$@"
