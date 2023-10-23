#!/bin/bash
device=/dev/sda
user=user
host=host
timezone=/usr/share/zoneinfo/America/New_York

# make sure there is internet
ping -q -c 1 archlinux.org > /dev/null
if [ $? -ne 0 ]; then
    echo "No internet connection" >&2
    exit 1
fi

# partition disk
umount -R /mnt
wipefs -af -t gpt $device
sgdisk -o $device
sgdisk -n 1::+512M -t 1:EF00 $device
sgdisk -n 2::0 -t 2:8300 $device
read -d '\n' efi_system_partition root_partition <<<$(ls $device?*)

# format partitions
mkfs.fat -F 32 $efi_system_partition
mkfs.ext4 -F $root_partition

# mount file systems
mount $root_partition /mnt
mkdir /mnt/boot
mount $efi_system_partition /mnt/boot

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
