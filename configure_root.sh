#!/bin/sh
source ./config

getpasswd() {
    while
        echo "Set password for $1"
        passwd "$1"
        [ $? -ne 0 ]
    do true; done
}

getpasswd root

# time zone
ln -sf $timezone /etc/localtime
hwclock --systohc

# localization
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' >> /etc/locale.conf

# network configuration
echo $hostname >> /etc/hostname
pacman --noconfirm -S networkmanager
systemctl enable NetworkManager

# bootloader
pacman --noconfirm -S grub
grub-install $devicename
grub-mkconfig -o /boot/grub/grub.cfg

# create user with sudo access through wheel group
sed -i '/%wheel ALL=(ALL:ALL) ALL/s/^# //g' /etc/sudoers
useradd -mg wheel $username
getpasswd $username
