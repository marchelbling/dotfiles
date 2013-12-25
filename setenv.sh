#!/bin/bash

clean_macvim_install()
{
  cd /System/Library/Frameworks/Python.framework/Versions
  sudo mv Current Current-sys
  sudo ln -s /usr/local/Cellar/python/2.7.*/Frameworks/Python.framework/Versions/Current Current
  brew install macvim
  sudo rm Current
  sudo mv Current-sys Current
  cd -
}

homebrew_install()
{
  # install homebrew and some utils
  ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
  brew update
  brew doctor
  brew install wget ack htop-osx openssl qt
  brew install sqlite mysql
  brew install git git-flow readline cmake ctags valgrind
  brew install imagemagick ffmpeg
  brew install p7zip zlib xz
  brew install zeromq rabbitmq
  # to be cleaned?
  brew install fontconfig freetype jpeg libpng libtiff libyaml

  brew install gfortran node boost
  brew install python --framework

  # see http://stackoverflow.com/questions/11148403/homebrew-macvim-with-python2-7-3-support-not-working:
  clean_macvim_install

  brew install rbenv
  brew install ruby-build

  brew doctor
}

python_packages_install()
{
  declare -a packages=("${!1}")
  for package in ${packages[@]}
  do
    pip install $package
  done
}

python_install()
{
  # set up a default virtualenv (installed by homebrew)
  virtualenv --distribute --no-site-packages $VENV_DIR/$DEFAULT_VENV
  source $VENV_DIR/$DEFAULT_VENV/bin/activate

  # install extra packages
  scientific_packages=( numpy scipy scikit-learn matplotlib networkx pandas nltk )
  ipython_packages=( readline ipython )
  web_packages=( beautifulsoup requests )
  django_packages=( django south )
  linter_packages=( flake8 pyflakes pylint )
  other_packages=( boto argparse nose python-dateutil pycrypto )

  python_packages_install scientific_packages[@]
  python_packages_install ipython_packages[@]
  python_packages_install web_packages[@]
  python_packages_install linter_packages[@]
  python_packages_install other_packages[@]
}

vim_install()
{
  # setup vim environment: font & plugins using pathogen
  mkdir -p $HOME/Library/Fonts
  mkdir -p $HOME/.vim/{autoload,bundle}
  mkdir $HOME/.vim-{back,swap,undo}

  # install AnonymousPro free font
  curl http://www.ms-studio.com/FontSales/AnonymousPro-1.002.zip > AnonymousPro.zip
  unzip AnonymousPro.zip
  for file in `ls AnonymousPro-1-002*/*.ttf`; do mv $file $HOME/Library/Fonts/; done
  rm -fr AnonymousPro*

  git clone https://github.com/Lokaltog/powerline-fonts.git
  cp powerline-fonts/AnonymousPro/* $HOME/Library/Fonts/
  rm -fr powerline-fonts

  # install addons using pathogen
  curl -Sso ~/.vim/autoload/pathogen.vim \
      https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
  cd $HOME/.vim/bundle
  git clone https://github.com/scrooloose/nerdcommenter.git
  git clone https://github.com/scrooloose/nerdtree.git
  git clone https://github.com/jistr/vim-nerdtree-tabs.git
  git clone https://github.com/imsizon/wombat.vim.git
  git clone https://github.com/xuhdev/SingleCompile.git
  git clone https://github.com/Lokaltog/powerline.git
  git clone https://github.com/Valloric/YouCompleteMe.git
  git clone https://github.com/marijnh/tern_for_vim
  git clone https://github.com/airblade/vim-gitgutter
  git clone https://github.com/vitorgalvao/autoswap_mac.git

  # build YouCompleteMe
  cd YouCompleteMe
  git submodule update --init --recursive
  ./install.sh --clang-completer

  # install tern
  cd ../tern_for_vim
  npm install
}

git_install()
{
  # fetch git-completion.bash
  curl https://raw.github.com/git/git/master/contrib/completion/git-completion.bash > $HOME/.git-completion.bash
}

###############
# 1. distribute configuration files
###############
# sets medium font anti-aliasing
## see: http://osxdaily.com/2012/06/09/mac-screen-blurry-optimize-troubleshoot-font-smoothing-os-x/
defaults -currentHost write -globalDomain AppleFontSmoothing -int 2

# create soft links for all config files
current_directory=`pwd`
## git
ln -fs $current_directory/git/gitconfig         $HOME/.gitconfig
## ruby
ln -fs $current_directory/ruby/irbrc            $HOME/.irbrc
ln -fs $current_directory/ruby/rdebugrc         $HOME/.rdebugrc
## terminal
ln -fs $current_directory/terminal/ackrc        $HOME/.ackrc
ln -fs $current_directory/terminal/bash_profile $HOME/.bash_profile
ln -fs $current_directory/terminal/inputrc      $HOME/.inputrc
ln -fs $current_directory/terminal/screenrc     $HOME/.screenrc
## vim
ln -fs $current_directory/vim/vimrc             $HOME/.vimrc

source $HOME/.bash_profile

###############
# 2. install required components if needed
###############
# parse command line arguments
while [ $# -ge 1 ] ; do
  case $1 in
    --all)
      homebrew_install
      git_install
      python_install
      vim_install
      # terminal theme needs to be 'default'ed manually
      open $current_directory/terminal/colors.terminal
      # drop current command line arg
      shift 1 ;;
    --git)
      git_install
      shift 1 ;;
    --homebrew)
      homebrew_install
      shift 1 ;;
    --python)
      python_install
      shift 1 ;;
    --vim)
      vim_install
      shift 1 ;;
    --help)
      echo "Usage: ./setenv.sh [--all|--homebrew|--vim|--git|--help]" ; shift 1 ;;
    # -d) dest_dir=$2 ; shift 2 ;;
  esac
done
