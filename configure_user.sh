#!/bin/sh
source ./config

cd ~/

# dwm dependencies
sudo -S pacman --noconfirm -S xorg-server xorg-xinit libxft libxinerama
# fonts ~ inconsolata: xresources, fontawesome: icons, noto-fonts: unicode & emoji
sudo -S pacman --noconfirm -S ttf-inconsolata ttf-font-awesome noto-fonts noto-fonts-emoji noto-fonts-cjk
# multimedia
sudo -S pacman --noconfirm -S xwallpaper nsxiv ffmpeg yt-dlp mpv
# misc
sudo -S pacman --noconfirm -S git less neofetch

# install suckless software
mkdir suckless
cd suckless
for program in dwm st dmenu slstatus
do
    git clone "https://github.com/pfrendl/$program.git"
    cd "$program"
    sudo -S make clean install
    cd ..
done
cd ..

# vim
sudo -S pacman --noconfirm -S vim
mkdir -p .vim/pack/default/start
cd .vim/pack/default/start
git clone https://github.com/morhetz/gruvbox

# copy dotfiles
cd ~/
git clone https://github.com/pfrendl/arch-dotfiles.git
cd arch-dotfiles
find -name ".*" -not -path . -not -path ./.git | xargs cp -r -t ~
