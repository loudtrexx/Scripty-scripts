#!/bin/bash
# https://github.com/loudtrexx/Scripty-scripts/
# Usage under the terms of BSD-3 clause
# Haaai, Curren-chan Desu~<3

# Find all whole USB removable devices (e.g., /dev/sdb, /dev/sdc)
devices=$(lsblk -dpno NAME,TRAN,RM | awk '$2=="usb" && $3=="1" {print $1}')
FS=${1:-exfat}
LBL=${2:-USB %02d} #%02d can be used to number the value (USB01, USB02...) vfat/fat32 doesn't allow longer names than 11 characters
RETABLE=${3:-}

case "$FS" in # You can select another type of fs in case exfat is not to your taste
    exfat)
        MKFS="mkfs.exfat" # Recommended
        PARAM="-n" # Used for the label, The "Advanced" filesystems (NTFS and ext4) use different parameters
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
        PARAM="-f -F -L"
	;;
    help)
	printf "Supported file systems: exfat (Default) | fat32 | ntfs | ext4\n
	EVERYTHING ON ALL PLUGGED IN USB drives WILL BE ERASED!!! 
 Usage:\n
 ./format-usb.sh [FILE SYSTEM] [LABEL] [RETABLE (Optional)]\n
 ./format-usb.sh fat32 \u2013 Format the USB drive as fat32\n
 ./format-usb.sh exfat \"Suzuka usb\" \u2013 Format the drive as exfat with the label \"Suzuka usb\"\n
 ./format-usb.sh exfat \"\" --zero-disk \u2013 Format the exfat with the label \"USB01\" and rebuild the GPT partition table\n
./format-usb.sh \u2013 Format the drive as exfat with label USB01 (If multiple usbs the next one will be USB02)
Encountered an error? Make sure you have ntfs-3g or exfatprogs installed\n"
	exit 1
	;;
-c|--credits)
	printf "Format USB script by loudtrexx (https://github.com/loudtrexx)\n
	Licensed under BSD-3-Clause \n
	\"Formatting USBs has never been easier!\" -Nobody ever "
	;;
*)
    printf "Invalid filesystem: $FS\n
Tip: Uncommon filesystems such as btrfs, xfs and zfs are not supported\n" # You're never gonna use those on an usb, right?
    exit 1
esac

if type "$MKFS" >/dev/null 2>&1; then
	:
else
	if [ "$MKFS" == "mkfs.exfat" ]; then
		printf "exprogs is missing from your system! Please install it via your package manager!\n"
		exit 1
	elif [ "$MKFS" == "mkfs.ntfs" ]; then
		printf "ntfs-3g is missing from your system! Please install it via your package manager!\n"
		exit 1
	else
		printf "Something went wrong trying to verify the existance of the provided file system utility for $FS.\n"
		exit 1
	fi
fi

if [ -z "$devices" ]; then
    echo "No USB devices detected." # If no usbs are found
    exit 1
fi

i=1
for dev in $devices; do
    case "$RETABLE" in
    	--zero-disk) # Has the user metioned that they want a retable? (Also stop crying about it we'll make a gpt table)
    		sudo umount "$dev"
			sudo dd /dev/zero "$dev"
		if type sgdisk >/dev/null 2>&1; then # If sgdisk is installed (Comes with gdisk)
       		 sudo sgdisk --zap-all "$dev"
        	 sudo sgdisk --clear "$dev" 
        	 sudo sgdisk -n 1:0:0 -t 1:8300 "$dev" # Make a single partition with the full capacity
    		 sudo partprobe "$dev"
		else
        	 printf "Please install gdisk from your package manager\n"
        	 exit 1
		fi
    		;;
    	*)
    	 :
    esac
    label=$(printf "$LBL" "$i")
    echo "Formatting $dev as $label"

    # Unmount any partitions
    sudo umount ${dev}* 2>/dev/null

    # Format the whole device
    sudo $MKFS $PARAM "$label" "$dev"

    i=$((i+1))
done
