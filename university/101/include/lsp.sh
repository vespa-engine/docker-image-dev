#!/usr/bin/env bash
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${DEBUG:-no}" == "true" ]]; then
    set -o xtrace
fi

echo "Installing RedHat XML plugin (helps Vespa Language Server parse services.xml)..."
sudo -u ${TARGET_USER} /usr/bin/code-server --install-extension redhat.vscode-xml

echo "Installing Vespa Language Support plugin..."
sudo -u ${TARGET_USER} /usr/bin/code-server --install-extension vespaai.vespa-language-support

# pointing language server to the correct java home
# also pre-trust the contents of the lab files and pre-fill Rest Client certificate config
echo '{
  "security.workspace.trust.enabled": false,
  "vespaSchemaLS": {
    "javaHome": "/usr/lib/jvm/java-21-openjdk-amd64/"
  },
  "rest-client.certificates": {
    "MTLS_ENDPOINT_DNS_NAME_GOES_HERE": {
        "key": "/home/student/.vespa/<tenant>.<application>.default/data-plane-private-key.pem",
        "cert": "/home/student/.vespa/<tenant>.<application>.default/data-plane-public-cert.pem"
    }
  }
}' > ${USER_HOME}/.local/share/code-server/User/settings.json

echo "Making sure all files in the ${TARGET_USER} home directory belong to the ${TARGET_USER} user..."
chown -R "${TARGET_USER}:${TARGET_USER}" ${USER_HOME}
