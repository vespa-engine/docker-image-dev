#!/bin/sh

if ! [ -d .git ]; then
	echo "Usage: run $0 from your git/vespa directory"
	exit 1
fi

cfg=$(pwd)/.pre-commit-config.yaml
hook=$(pwd)/.git/hooks/pre-commit

if [ -f $cfg ]; then
	echo "Already exists: $cfg - leaving it as-is"
else
	cat > $cfg << 'EOF'
repos:
  - repo: https://github.com/pre-commit/mirrors-clang-format
    rev: v22.1.4  # Use the latest tag or a specific version
    hooks:
      - id: clang-format
        files: \.(cpp|h|hpp)$
EOF
	echo "Added: $cfg"
fi

if [ -f $hook ]; then
	echo "Already exists: $hook - leaving it as-is"
else
	cat > $hook << 'EOF'
#!/usr/bin/env bash
ARGS=(hook-impl --config=.pre-commit-config.yaml --hook-type=pre-commit)
HERE="$(cd "$(dirname "$0")" && pwd)"
ARGS+=(--hook-dir "$HERE" -- "$@")
if command -v pre-commit > /dev/null; then
    exec pre-commit "${ARGS[@]}"
else
    echo 'Error: `pre-commit` not found.' 1>&2
    exit 1
fi
EOF
	chmod +x $hook
	echo "Added: $hook"
fi
