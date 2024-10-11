#!/bin/bash
# Put this file to the root path of the UDisk, execute with root

# Ensure run with root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

PACKAGE="nanopi_m6.tar.gz"

TMP_DIR=$(mktemp -d)
echo "Temp folder: $TMP_DIR"

# Use current working directory as the mount point
CURRENT_DIR=$(pwd)

tar -xzvf $CURRENT_DIR/$PACKAGE -C $TMP_DIR

# Deploy kernel
dd if=$TMP_DIR/resource.img of=/dev/mmcblk2p4 bs=1M
dd if=$TMP_DIR/kernel.img of=/dev/mmcblk2p5 bs=1M
mkdir /lib/modules/6.1.57
cp -rT $TMP_DIR/modules /lib/modules/6.1.57

# Config the device
echo -e "\ng_ether" | sudo tee -a /etc/modules > /dev/null

sed -i '/^exit 0/i\modprobe g_ether\nip addr add 192.168.7.1/24 dev usb0\nip link set usb0 up\n' /etc/rc.local

# Clean
rm -rf $TMP_DIR

sync
# Reboot
sudo reboot