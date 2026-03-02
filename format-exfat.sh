#!/bin/bash

# Find all whole USB removable devices (e.g., /dev/sdb, /dev/sdc)
devices=$(lsblk -dpno NAME,TRAN,RM | awk '$2=="usb" && $3=="1" {print $1}')

if [ -z "$devices" ]; then
    echo "No USB devices detected."
    exit 1
fi

i=1
for dev in $devices; do
    label=$(printf "USB%02d" "$i")
    echo "Formatting $dev as $label"

    # Unmount any partitions
    sudo umount ${dev}* 2>/dev/null

    # Format the whole device
    sudo mkfs.exfat -n "$label" "$dev"

    i=$((i+1))
done
