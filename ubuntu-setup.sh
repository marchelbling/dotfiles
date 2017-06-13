#!/bin/bash

# desktop theme
sudo add-apt-repository -y ppa:numix/ppa
# icon theme
sudo add-apt-repository -y ppa:papirus/papirus
# meshlab
sudo add-apt-repository -y ppa:zarquon42/meshlab
# f.lux
sudo add-apt-repository -y ppa:nathan-renniewaldock/flux

sudo apt-get update
sudo apt-get install -y numix-gtk-theme \
                        papirus-icon-theme \
                        meshlab \
                        unity-tweak-tool \
                        virtualbox git wget curl \
                        software-properties-common \
                        build-essential \
                        bash-completion \
                        cmake \
                        clang \
                        python-dev \
                        python3-dev \
                        curl \
                        htop \
                        tree \
                        rsync \
                        mercurial \
                        subversion \
                        silversearcher-ag \
                        vim-nox \
                        imagemagick \
                        openimageio-tools \
                        p7zip-full \
                        p7zip-rar \
                        fluxgui \
                        dconf-tools

# disable alt+drag to move windows (see https://askubuntu.com/a/118179/212079)
gsettings set org.gnome.desktop.wm.preferences mouse-button-modifier "<Super>"

# fetch git-completion.bash
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > "${HOME}/.git-completion.bash"

cd ~/Downloads
# chrome
wget  'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'

# vagrant
wget 'https://releases.hashicorp.com/vagrant/1.9.3/vagrant_1.9.3_x86_64.deb'

# slack
wget 'https://downloads.slack-edge.com/linux_releases/slack-desktop-2.6.2-amd64.deb'

sudo dpkg -i ~/Downloads/*.deb
sudo apt-get install -f -y

# spotify
# 1. Add the Spotify repository signing key to be able to verify downloaded packages
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886
# 2. Add the Spotify repository
echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
# 3. Update list of available packages
sudo apt-get update
# 4. Install Spotify
sudo apt-get install -y spotify-client

# foxit (pdf)
wget 'http://cdn09.foxitsoftware.com/pub/foxit/reader/desktop/linux/2.x/2.4/en_us/FoxitReader2.4.0.14978_Server_x64_enu_Setup.run.tar.gz'
gzip -d FoxitReader2.4.0.14978_Server_x64_enu_Setup.run.tar.gz
tar xvf FoxitReader2.4.0.14978_Server_x64_enu_Setup.run.tar
./FoxitReader.enu.setup.2.4.0.14978\(r254978\).x64.run
