#!/usr/bin/env bash
set -e

echo "Creating LVM setup on /dev/sda and /dev/sdb..."

# 1. Initialize Physical Volumes
# WARNING: This will destroy data on sda and sdb
echo "Initializing Physical Volumes..."
sudo pvcreate /dev/sda /dev/sdb

# 2. Create Volume Group
echo "Creating Volume Group 'media-vol'..."
sudo vgcreate media-vol /dev/sda /dev/sdb

# 3. Create Logical Volume
echo "Creating Logical Volume 'media-lv' using 100% of available space..."
sudo lvcreate -l 100%FREE -n media-lv media-vol

# 4. Format the Logical Volume
echo "Formatting /dev/media-vol/media-lv as ext4..."
sudo mkfs.ext4 /dev/media-vol/media-lv

echo "LVM setup complete!"
echo "Now rebuild your NixOS configuration to mount it."
