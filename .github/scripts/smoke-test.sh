#!/bin/bash
set -e

# Load environment variables
if [ -f "agda-versions.env" ]; then
    source agda-versions.env
else
    echo "Error: agda-versions.env not found in current directory."
    exit 1
fi

echo "Running smoke test with:"
echo "AGDA_VERSION=${AGDA_VERSION}"
echo "STDLIB_VERSIONS=${STDLIB_VERSIONS}"
echo ""

# Global test directory
TEST_DIR="/tmp/agda-test"

# Cleanup function
cleanup_test_directory() {
    echo "Cleaning up test directory: $TEST_DIR"
    rm -rf "$TEST_DIR"
}

# Test: Check Agda version
test_agda_version() {
    echo "=== Checking Agda version ==="
    AGDA_VERSION_OUTPUT=$(agda --version)
    if ! echo "$AGDA_VERSION_OUTPUT" | grep -qE "\<${AGDA_VERSION}\>"; then
        echo "Error: Agda version mismatch. Expected $AGDA_VERSION, got: $AGDA_VERSION_OUTPUT"
        return 1
    fi
    echo "OK: Agda version verified: $AGDA_VERSION"
    echo ""
}

# Test: Check Emacs version
test_emacs_version() {
    echo "=== Checking Emacs ==="
    EMACS_VERSION_OUTPUT=$(emacs --version | head -1)
    echo "Emacs: $EMACS_VERSION_OUTPUT"
    echo "OK: Emacs installed"
    echo ""
}

# Test: Check xpra
test_xpra() {
    echo "=== Checking xpra ==="
    XPRA_VERSION_OUTPUT=$(xpra --version | head -1)
    echo "xpra: $XPRA_VERSION_OUTPUT"
    echo "OK: xpra installed"
    echo ""
}

# Test: Check fonts
test_fonts() {
    echo "=== Checking fonts ==="
    if fc-list | grep -qi noto; then
        echo "OK: Noto fonts installed"
        fc-list | grep -i noto | head -3
    else
        echo "Error: Noto fonts not found"
        return 1
    fi
    echo ""
}

# Test: Check Agda stdlib
test_agda_stdlib() {
    echo "=== Checking Agda stdlib ==="
    AGDA_DIR=$(agda --print-agda-app-dir)
    LIBRARIES_FILE="$AGDA_DIR/libraries-$AGDA_VERSION"

    if [ ! -f "$LIBRARIES_FILE" ]; then
        echo "Error: Libraries file not found: $LIBRARIES_FILE"
        return 1
    fi

    echo "Libraries file: $LIBRARIES_FILE"
    cat "$LIBRARIES_FILE"
    echo "OK: Agda stdlib configured"
    echo ""
}

# Test: Compile Agda file with stdlib
test_agda_compilation() {
    echo "=== Testing Agda compilation with stdlib ==="
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"

    cat > Test.agda << 'EOF'
module Test where

open import Data.Nat
open import Data.Bool

test : ℕ
test = 42
EOF

    echo "Compiling Test.agda..."
    agda Test.agda

    echo "OK: Agda compilation successful"
    echo ""
}

# Test: Emacs agda-mode (already setup during install)
test_emacs_agda_mode() {
    echo "=== Testing Emacs agda-mode ==="

    # Test if agda2-mode can be loaded (setup was done during install)
    AGDA_MODE_RESULT=$(emacs --batch \
        --eval "(load-file (let ((coding-system-for-read 'utf-8)) (shell-command-to-string \"agda --emacs-mode locate\")))" \
        --eval "(require 'agda2-mode nil t)" \
        --eval "(if (featurep 'agda2-mode) (message \"agda2-mode: OK\") (message \"agda2-mode: FAILED\"))" \
        2>&1)

    if echo "$AGDA_MODE_RESULT" | grep -q "agda2-mode: OK"; then
        echo "OK: agda2-mode loaded successfully"
    else
        echo "Error: Failed to load agda2-mode"
        echo "$AGDA_MODE_RESULT"
        return 1
    fi
    echo ""
}

# Test: Check pre-compiled stdlib modules
test_precompiled_stdlib() {
    echo "=== Checking pre-compiled stdlib modules ==="
    AGDA_DIR=$(agda --print-agda-app-dir)
    STDLIB_DIR=$(dirname $(head -1 "$AGDA_DIR/libraries-$AGDA_VERSION" | grep -v '^--'))

    AGDAI_COUNT=$(find "$STDLIB_DIR" -name "*.agdai" 2>/dev/null | wc -l)

    if [ "$AGDAI_COUNT" -gt 0 ]; then
        echo "OK: Found $AGDAI_COUNT pre-compiled .agdai files"
    else
        echo "Error: No pre-compiled .agdai files found"
        return 1
    fi
    echo ""
}

# Main test runner
main() {
    # Clean up test directory before starting
    cleanup_test_directory

    # Run all tests
    test_agda_version
    test_emacs_version
    test_xpra
    test_fonts
    test_agda_stdlib
    test_precompiled_stdlib
    test_agda_compilation
    test_emacs_agda_mode

    # Clean up test directory after all tests
    cleanup_test_directory

    echo "========================================"
    echo "OK: All smoke tests passed successfully!"
    echo "========================================"
}

# Run main
main
