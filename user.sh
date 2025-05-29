#!/bin/bash
source /arch-install/config

# download aur repositories
aur_repos=(
    https://aur.archlinux.org/brave-bin.git
)
mkdir $aur_dir && cd $_
for repo in "${aur_repos[@]}"
do
    git clone $repo
    program=$(basename $repo .git)
    cd $program
    makepkg -si --noconfirm
done

# download suckless repositories
suckless_repos=(
    https://github.com/pfrendl/st.git
    https://github.com/pfrendl/dmenu.git
    https://github.com/pfrendl/mustat.git
)
mkdir $suckless_dir && cd $_
for repo in "${suckless_repos[@]}"
do
    git clone $repo
done

# dotfiles
cd ~
git clone https://github.com/pfrendl/arch-dotfiles.git
cd arch-dotfiles
find -name ".*" -not -path . -not -path ./.git | xargs cp -r -t ~

# python development environment
python -m venv $pyenv_dir && source $_/bin/activate
pip install python-lsp-server[all] isort black
