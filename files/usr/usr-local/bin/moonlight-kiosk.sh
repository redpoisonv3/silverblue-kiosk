#!/bin/bash
set -e

# --- CONFIGURATION ENGINE ---
PVE_HOST="192.168.1.100"               
WOLF_HOST="192.168.1.100"              
VM_ID="101"                            
PVE_TOKEN="local-kiosk@pam!silverblue-node=XXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
# ----------------------------

pkill cage || true

echo "🔌 Querying power state for Proxmox VM $VM_ID..."
VM_STATUS=$(curl -s -k -H "Authorization: PVEAPIToken=$PVE_TOKEN" \
    "https://$PVE_HOST:8006/api2/json/nodes/localhost/qemu/$VM_ID/status/current" | \
    grep -o '"status":"[^"]*"' | cut -d'"' -f4 || echo "unknown")

if [ "$VM_STATUS" != "running" ]; then
    echo "🚀 VM $VM_ID is offline. Initializing boot block..."
    curl -s -k -X POST -H "Authorization: PVEAPIToken=$PVE_TOKEN" \
        "https://$PVE_HOST:8006/api2/json/nodes/localhost/qemu/$VM_ID/status/start"
    sleep 5
fi

export SDL_VIDEODRIVER=wayland
export WLR_DRM_NO_MODIFIERS=1

echo "🔒 Handing display thread to Moonlight..."
exec cage -- flatpak run com.limelight_stream.Moonlight \
    stream "$WOLF_HOST" "Desktop" \
    --display borderless