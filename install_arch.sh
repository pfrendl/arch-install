#!/bin/sh
device=/dev/sda
user=user
host=host
timezone=/usr/share/zoneinfo/America/New_York

boot_partition="${device}1"
root_partition="${device}2"

# make sure there is internet
ping -q -c 1 archlinux.org > /dev/null
if [ $? -ne 0 ]; then
    echo "No internet connection" >&2
    exit 1
fi

# partition disk
umount -R /mnt
sfdisk -w always -W always $device << EOF
label: dos
-,256MiB,83,*
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
device=$device
user=$user
host=$host
timezone=$timezone
EOF

curl -O https://raw.githubusercontent.com/pfrendl/arch-install/main/configure_system.sh
chmod +x configure_system.sh
arch-chroot /mnt ./configure_system.sh
rm config configure_system.sh

cd ..
