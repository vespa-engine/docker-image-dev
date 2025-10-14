#!/usr/bin/env bash
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${DEBUG:-no}" == "true" ]]; then
    set -o xtrace
fi

echo "Creating MOTD files..."
# Create the 00-header file
cat << 'EOF' > /etc/update-motd.d/00-header
#!/bin/sh
printf "\n#############################################\n"
printf " Welcome to the Vespa Student Console\n"
printf "#############################################\n\n"
EOF

# Create the 10-help-text file
cat << 'EOF' > /etc/update-motd.d/10-help-text
#!/bin/sh
printf "Available resources:\n"
printf "  - lab: Exercise repository for the training session\n"
printf "\n"
printf "Tools installed for the training session:\n"
printf "  - vespa: Vespa CLI to interact with Vespa tenant\n"
printf "  - curl: Handy for interacting with Vespa APIs\n"
printf "  - code-server: IDE for editing schemas and queries\n"
printf "\n"
printf "Good luck!\n\n"
EOF

# Ensure the files are executable
chmod +x /etc/update-motd.d/00-header
chmod +x /etc/update-motd.d/10-help-text

# Remove unused MOTD scripts (optional, only if needed)
rm -f /etc/update-motd.d/50-motd-news
rm -f /etc/update-motd.d/60-unminimize
