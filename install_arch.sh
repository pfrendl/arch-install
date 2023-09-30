#!/bin/sh
devicename="/dev/sda"
username="user"
hostname="host"
timezone="/usr/share/zoneinfo/America/New_York"
script_source="https://raw.githubusercontent.com/pfrendl/arch-install/main"

boot_partition="${devicename}1"
root_partition="${devicename}2"

# make sure there is internet
ping -q -c 1 archlinux.org > /dev/null
if [ $? -ne 0 ]; then
    echo "No internet connection" >&2
    exit 1
fi

# partition disk
umount -R /mnt
sfdisk -w always -W always $devicename << EOF
label: dos
-,128MiB,83,*
-,     -,83,-
EOF

# format partitions
mkfs.ext4 $boot_partition
mkfs.ext4 $root_partition

# mount file systems
mount $root_partition /mnt
mkdir /mnt/boot
mount $boot_partition /mnt/boot

# installation
pacstrap /mnt base base-devel linux linux-firmware

# generate file systems table
genfstab -U /mnt >> /mnt/etc/fstab

# configure root and user
cd /mnt

cat > config << EOF
devicename=$devicename
username=$username
hostname=$hostname
timezone=$timezone
EOF

curl -O "$script_source/configure_{root,user}.sh"
chmod +x configure_{root,user}.sh

arch-chroot /mnt ./configure_root.sh
arch-chroot /mnt su $username -c ./configure_user.sh

rm config configure_{root,user}.sh

cd ..
