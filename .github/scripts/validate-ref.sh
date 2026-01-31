#!/bin/bash
set -e

# Usage: ./validate-ref.sh <ref_name> <ref_type>
# ref_type: "tag" or "branch"
# Exit code: 0 if valid, 1 if invalid

REF_NAME="$1"
REF_TYPE="$2"

if [ -z "$REF_NAME" ]; then
    echo "Error: REF_NAME argument is required." >&2
    echo "Usage: $0 <ref_name> <ref_type>" >&2
    exit 1
fi

if [ -z "$REF_TYPE" ]; then
    echo "Error: REF_TYPE argument is required." >&2
    echo "Usage: $0 <ref_name> <ref_type>" >&2
    exit 1
fi

echo "Validating ref_name: ${REF_NAME}"
echo "Ref type: ${REF_TYPE}"

if [ "$REF_TYPE" == "tag" ]; then
    # Tags must match the exact format: VERSION__TIMESTAMP
    # Example: 2.8.0__20260201-1234, 2.7.0.1__20260201-1234
    # Agda version can have varying depth (e.g., 2.8.0, 2.7.0.1)
    PATTERN='^[0-9]+(\.[0-9]+)+__[0-9]{8}-[0-9]{4}$'

    if ! echo "${REF_NAME}" | grep -qE "$PATTERN"; then
        echo "❌ ERROR: Tag does not match required format" >&2
        echo "" >&2
        echo "Required format: VERSION__TIMESTAMP" >&2
        echo "  - VERSION: X.Y.Z or X.Y.Z.W (e.g., 2.8.0, 2.7.0.1)" >&2
        echo "  - TIMESTAMP: YYYYMMDD-HHMM (e.g., 20260201-1234)" >&2
        echo "" >&2
        echo "Example: 2.8.0__20260201-1234" >&2
        echo "Got: ${REF_NAME}" >&2
        exit 1
    fi

elif [ "$REF_TYPE" == "branch" ]; then
    # Branches must contain only: a-z, A-Z, 0-9, '.', '_', '-'
    if echo "${REF_NAME}" | grep -qE '[^a-zA-Z0-9._-]'; then
        echo "❌ ERROR: Branch name contains invalid characters" >&2
        echo "" >&2
        echo "Allowed characters: a-z, A-Z, 0-9, '.', '_', '-'" >&2
        echo "" >&2
        echo "Invalid characters found:" >&2
        echo "${REF_NAME}" | grep -oE '[^a-zA-Z0-9._-]' | sort -u >&2
        echo "" >&2
        echo "Branch name: ${REF_NAME}" >&2
        exit 1
    fi

else
    echo "❌ ERROR: Unknown ref_type: ${REF_TYPE}" >&2
    echo "Expected: 'tag' or 'branch'" >&2
    exit 1
fi

echo "✅ Validation passed"
exit 0
