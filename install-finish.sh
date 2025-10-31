#! /bin/bash 

# This script was made by loudtrexx (https://github.com/loudtrexx)
# I had to do this because the ytl team was too lazy to do it themselves

# Start by making the shortcuts to simplify things
shortcuts="$HOME/Desktop"

cat <<EOF > "$shortcuts/firefox.desktop"
[Desktop Entry]
Name=Firefox
Comment=Web browser
Type=Application
Exec=/snap/bin/firefox %u
Icon=/snap/firefox/7177/default256.png
Terminal=false
EOF  

cat <<EOF > "$shortcuts/Naksu2.desktop"
[Desktop Entry]
Name=Naksu2
Comment=Server setup utility
GenericName=Naksu2
Exec=naksu2 %u
Icon=naksu2
Type=Application
StartupNotify=true
Categories=Utility
EOF

# Check if already root, if not then execute it as root

if [ "$EUID" -ne 0 ]; then
    echo "Warning: Not running as root! Requesting root permissions..."
    exec sudo "$0" "$@" 
    exit 1
fi
# Get the keys and apply them
wget -qO- https://download.docker.com/linux/ubuntu/gpg | tee /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "Signed-By: /etc/apt/keyrings/docker.asc" | tee /etc/apt/sources.list.d/docker.sources > /dev/null
wget -qO- https://linux.abitti.fi/apt-signing-key.pub | tee /etc/apt/trusted.gpg.d/ytl-linux.asc
chmod a+r /etc/apt/keyrings/ytl-linux.asc
echo "Signed-By: /etc/apt/trusted.gpg.d/ytl-linux.asc" | tee /etc/apt/sources.list.d/ytl-linux.sources
rm -fr /etc/apt/sources.list.d/virtualbox-oracle.sources # This has no reason to be here as it is already in the ubuntu archive


# Update the repos
apt update
apt upgrade -y
# Turn off grub timeout so there's no need to wait or press enter
echo "GRUB_TIMEOUT=0" | tee -a /etc/default/grub
update-grub
reboot

# Thank you for coming to my ted talk