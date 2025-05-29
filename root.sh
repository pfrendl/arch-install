#!/bin/bash
source /arch-install/config

getpasswd() {
    while
        echo "Set password for $1"
        passwd $1
        [ $? -ne 0 ]
    do true; done
}

getpasswd root

# create user with sudo access through wheel group
sed -i '/%wheel ALL=(ALL:ALL) ALL/s/^# //g' /etc/sudoers
useradd -mg wheel $user
getpasswd $user

# time zone
ln -sf $timezone /etc/localtime
hwclock --systohc

# localization
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' >> /etc/locale.conf

# network configuration
echo $host >> /etc/hostname
pacman --noconfirm -S networkmanager
systemctl enable NetworkManager

# bootloader
pacman --noconfirm -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# window manager, status bar updates, and key events
pacman --noconfirm -S xorg-server xorg-xinit libxft libxinerama xorg-xsetroot sxhkd bspwm
# fonts ~ inconsolata: xresources, fontawesome: icons, noto-fonts: unicode & emoji
pacman --noconfirm -S ttf-inconsolata ttf-font-awesome noto-fonts noto-fonts-emoji noto-fonts-cjk
# multimedia
pacman --noconfirm -S xwallpaper nsxiv pipewire pipewire-audio wireplumber pipewire-pulse pipewire-jack ffmpeg yt-dlp mpv
# graphics driver, video card monitoring
pacman --noconfirm -S nvidia nvtop
# code editor
pacman --noconfirm -S kakoune kak-lsp
# misc
pacman --noconfirm -S less git neofetch man

# nvidia automatic xorg configuration + fix screen tearing
nvidia-xconfig --force-full-composition-pipeline on

# user configuration
sudo -u $user /arch-install/user.sh

# install suckless packages
suckless_repos=$(find $suckless_dir -mindepth 1 -maxdepth 1)
for repo in $suckless_repos
do
    cd $repo
    make clean install
done
