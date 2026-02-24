#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

# Add xpra official repository
curl -fsSL https://xpra.org/gpg.asc -o /usr/share/keyrings/xpra.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/xpra.asc] https://xpra.org/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/xpra.list

# Install packages
apt-get update
apt-get install -y libicu-dev emacs-lucid fonts-noto-cjk xpra xterm xclip
apt-get clean
rm -rf /var/lib/apt/lists/*

# Create XDG_RUNTIME_DIR for vscode user (uid 1000)
mkdir -p /run/user/1000
chown 1000:1000 /run/user/1000
chmod 700 /run/user/1000

# install newer version of HTML5 client for Xpra
cd /usr/share/xpra
git clone https://github.com/Xpra-org/xpra-html5
echo -e "\nswap_keys=false\nclipboard_preferred_format=UTF8_STRING" >> /usr/share/xpra/xpra-html5/html5/default-settings.txt
