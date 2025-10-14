#!/usr/bin/env bash
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${DEBUG:-no}" == "true" ]]; then
    set -o xtrace
fi

echo "Installing REST Client plugin..."
sudo -u ${TARGET_USER} /usr/bin/code-server --install-extension humao.rest-client
