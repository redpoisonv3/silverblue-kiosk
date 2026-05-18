#!/bin/bash
# Path inside image configuration: /usr/usr-local/bin/atomic-update.sh
set -e

echo "🔄 Checking for custom Silverblue system image updates..."

# Pull down any newer image layers from your repository repository in the background.
# This does NOT disrupt your current running Moonlight streaming session.
rpm-ostree upgrade --check

if [ $? -eq 0 ]; then
    echo "📦 New update found! Staging system layers silently to disk..."
    rpm-ostree upgrade
    echo "✅ System update staged successfully. It will apply cleanly on the next reboot."
else
    echo "✨ Your thin client appliance is completely up to date!"
fi

# Keep local storage light by sweeping away older deployment cache stashes
rpm-ostree cleanup -m