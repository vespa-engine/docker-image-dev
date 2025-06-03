set -euxo pipefail

echo "Installing RedHat XML plugin (helps Vespa Language Server parse services.xml)..."
sudo -u ${TARGET_USER} /usr/bin/code-server --install-extension redhat.vscode-xml

echo "Installing Vespa Language Support plugin..."
LANGUAGE_SERVER_VERSION=$(curl -s https://api.github.com/repos/vespa-engine/vespa/releases | jq -r '.[].name' | grep Vespa.Language.Server | head -n 1 | sed 's|.*\ ||')
wget --progress=dot:giga https://github.com/vespa-engine/vespa/releases/download/lsp-v${LANGUAGE_SERVER_VERSION}/vespa-language-support-${LANGUAGE_SERVER_VERSION}.vsix -O /opt/vespa/vespa-language-support.vsix
sudo -u ${TARGET_USER} /usr/bin/code-server --install-extension /opt/vespa/vespa-language-support.vsix

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
