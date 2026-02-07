#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y libicu-dev emacs-lucid fonts-noto-cjk xpra
apt-get clean
rm -rf /var/lib/apt/lists/*
