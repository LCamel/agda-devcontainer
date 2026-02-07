#!/bin/bash
set -e

# Load versions from external file
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/agda-versions.env"

time cabal update
time cabal install Agda-${AGDA_VERSION} -f enable-cluster-counting --install-method=copy
rm -rf ~/.cache/cabal/ ~/.local/state/cabal/
rm -f ~/.local/bin/agda-mode  # From Agda 2.8.0 on, use `agda --emacs-mode` instead.

# ~/.local/bin should be in the PATH
which agda
agda --version


# Install stdlib
# SEE: https://github.com/agda/agda-stdlib

curl --proto '=https' --tlsv1.2 -s \
    https://raw.githubusercontent.com/agda/agda-stdlib/refs/heads/master/stdlib-install.sh \
    -o /tmp/stdlib-install.sh

AGDA_DIR=$(agda --print-agda-app-dir)

# Space-separated list of stdlib versions to install.
# Only the first one will be active; others are commented out in the libraries file.
for ver in $STDLIB_VERSIONS; do
    AGDA_EXEC=agda AGDA_DIR="$AGDA_DIR" AGDA_VERSION="$AGDA_VERSION" STDLIB_VERSION="$ver" sh /tmp/stdlib-install.sh
done
# Keep only the first line active, comment out the rest.
sed -i '2,$s/^/-- /' "$AGDA_DIR/libraries-$AGDA_VERSION"

rm -f /tmp/stdlib-install.sh

# Setup Emacs agda-mode
agda --emacs-mode setup

# Pre-compile common stdlib modules
mkdir -p /tmp/precompile && cd /tmp/precompile
cat > Precompile.agda << 'EOF'
module Precompile where
open import Data.Nat
open import Data.Bool
open import Data.List
open import Data.String
open import Data.Maybe
open import Data.Product
open import Data.Sum
open import Relation.Binary.PropositionalEquality
open import Function
EOF
agda Precompile.agda
cd / && rm -rf /tmp/precompile
