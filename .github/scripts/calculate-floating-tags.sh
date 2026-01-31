#!/bin/bash
set -e

# Usage: echo "$ALL_TAGS" | ./calculate-floating-tags.sh "$TARGET_TAG"
# Output: List of floating tags that should be updated to point to TARGET_TAG

TARGET_TAG="$1"

if [ -z "$TARGET_TAG" ]; then
    echo "Error: TARGET_TAG argument is required." >&2
    exit 1
fi

# Read all remote tags from stdin into a variable
REMOTE_TAGS=$(cat)

if [ -z "$REMOTE_TAGS" ]; then
    echo "Error: No remote tags provided on stdin." >&2
    exit 1
fi

# Parse version components from the Target Tag
# Format: VERSION__TIMESTAMP
# Example: 2.8.0__20260201-1234, 2.7.0.1__20260201-1234

# Extract Agda version (first field before "__")
AGDA_VERSION=$(echo "$TARGET_TAG" | awk -F__ '{print $1}')

# debug info to stderr
echo "Debug: Target='$TARGET_TAG'" >&2
echo "Debug: AGDA_VERSION='$AGDA_VERSION'" >&2

# Helper function to filter and sort tags using the project's logic
# Format: VERSION__TIMESTAMP
# Sort keys: 1.Version(V) 2.Timestamp(txt)
filter_and_sort_tags() {
    grep -E '^[0-9]+(\.[0-9]+)+__[0-9]{8}-[0-9]{4}$' | \
    # Convert X.Y.Z__TIMESTAMP to "X.Y.Z TIMESTAMP" for sorting
    sed 's/__/ /' | \
    sort -k1V -k2 | \
    # Convert back to original format
    sed 's/ /__/'
}

# Function to check if TARGET_TAG is the latest in a given scope
# Returns 0 (true) if it IS the latest, 1 (false) otherwise.
is_latest() {
    local pattern="$1"
    local relevant_tags

    if [ "$pattern" == ".*" ]; then
        relevant_tags="$REMOTE_TAGS"
    else
        relevant_tags=$(echo "$REMOTE_TAGS" | grep -E "$pattern" || true)
    fi

    # Defensive: append TARGET_TAG to handle cases where it's not yet visible in REMOTE_TAGS.
    # If it's already there, duplicate lines don't affect 'tail -n 1' results.
    local sorted_latest=$(echo -e "${relevant_tags}\n${TARGET_TAG}" | filter_and_sort_tags | tail -n 1)

    if [ "$TARGET_TAG" = "$sorted_latest" ]; then
        return 0
    else
        return 1
    fi
}

# 1. Check 'latest'
if is_latest ".*"; then
    echo "latest"
fi

# 2. Check Agda version floating tag (X.Y.Z or X.Y.Z.W)
if [ -n "$AGDA_VERSION" ]; then
    # Regex: Match tags with the same Agda version
    # e.g., ^2\.8\.0__
    PATTERN="^${AGDA_VERSION//./\.}__"
    if is_latest "$PATTERN"; then
        echo "${AGDA_VERSION}"
    fi
fi
