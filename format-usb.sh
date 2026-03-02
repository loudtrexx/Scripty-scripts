#!/bin/bash
# https://github.com/loudtrexx/Scripty-scripts/
# Usage under the terms of GPL 3.0
# Haaai, Curren-chan Desu~<3

# Find all whole USB removable devices (e.g., /dev/sdb, /dev/sdc)
devices=$(lsblk -dpno NAME,TRAN,RM | awk '$2=="usb" && $3=="1" {print $1}')
FS=${1:-exfat}
case "$FS" in # You can select another type of fs in case exfat is not to your taste
    exfat)
        MKFS="mkfs.exfat"
        PARAM="-n"
        ;;
    vfat|fat32)
        MKFS="mkfs.vfat"
        PARAM="-n"
        ;;
    ext4)
        MKFS="mkfs.ext4"
        PARAM="-F -L"
        ;;
    ntfs)
        MKFS="mkfs.ntfs"
        PARAM="-f -L"
        ;;
*)
    echo "Invalid filesystem: $FS"
    echo "Tip: Uncommon filesystems such as btrfs, xfs and zfs are currently not supported" # You're never gonna use those on an usb, right?
    exit 1
esac

if [ -z "$devices" ]; then
    echo "No USB devices detected." # If no usbs are found
    exit 1
fi

i=1
for dev in $devices; do
    label=$(printf "USB%02d" "$i")
    echo "Formatting $dev as $label"

    # Unmount any partitions
    sudo umount ${dev}* 2>/dev/null

    # Format the whole device
    sudo $MKFS $PARAM "$label" "$dev"

    i=$((i+1))
done
