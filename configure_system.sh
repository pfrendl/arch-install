#!/bin/sh
source ./config

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

# dwm dependencies and xbindkeys for audio keys
pacman --noconfirm -S xorg-server xorg-xinit libxft libxinerama xbindkeys
# fonts ~ inconsolata: xresources, fontawesome: icons, noto-fonts: unicode & emoji
pacman --noconfirm -S ttf-inconsolata ttf-font-awesome noto-fonts noto-fonts-emoji noto-fonts-cjk
# multimedia
pacman --noconfirm -S xwallpaper nsxiv pulseaudio ffmpeg yt-dlp mpv
# graphics driver
pacman --noconfirm -S nvidia
# misc
pacman --noconfirm -S vim less git neofetch man

# browser
sudo -u $user mkdir /home/$user/aur && cd $_
sudo -u $user git clone https://aur.archlinux.org/brave-bin.git
cd brave-bin
sudo -u $user makepkg -si --noconfirm

# suckless software
suckless_repos=(
    https://github.com/pfrendl/dwm.git
    https://github.com/pfrendl/st.git
    https://github.com/pfrendl/dmenu.git
    https://github.com/pfrendl/dwmblocks.git
)
sudo -u $user mkdir /home/$user/suckless && cd $_
for repo in "${suckless_repos[@]}"
do
    sudo -u $user git clone $repo
    program=$(basename $repo .git)
    cd $program
    make clean install
    cd ..
done

# vim plugins
sudo -u $user mkdir -p /home/$user/.vim/pack/default/start && cd $_
sudo -u $user git clone https://github.com/morhetz/gruvbox

# dotfiles
cd /home/$user
sudo -u $user git clone https://github.com/pfrendl/arch-dotfiles.git
cd arch-dotfiles
sudo -u $user find -name ".*" -not -path . -not -path ./.git | sudo -u $user xargs cp -r -t /home/$user
