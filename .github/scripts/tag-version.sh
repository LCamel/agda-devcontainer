#!/bin/bash
set -e

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load versions
if [ ! -f "$PROJECT_ROOT/docker/agda-versions.env" ]; then
    echo "Error: docker/agda-versions.env not found."
    exit 1
fi

. "$PROJECT_ROOT/docker/agda-versions.env"

# Construct tag with UTC timestamp
# Format: VERSION__TIMESTAMP
TIMESTAMP=$(date -u +'%Y%m%d-%H%M')
TAG_NAME="${AGDA_VERSION}__${TIMESTAMP}"

echo "Target tag: ${TAG_NAME}"

# Check if tag already exists
if git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
    echo "Tag '${TAG_NAME}' already exists."
    exit 0
fi

# Create tag
git tag "$TAG_NAME"
echo "Tag '${TAG_NAME}' created successfully."
echo "To push the tag, run:"
echo "  git push origin ${TAG_NAME}"
