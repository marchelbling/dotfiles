#!/bin/bash

RUBY_VERSION="2.0.0-p247"
VIM_BUNDLE_DIR="$HOME/.vim/bundle"

function clean_macvim_install()
{
  cd /System/Library/Frameworks/Python.framework/Versions
  sudo mv Current Current-sys
  sudo ln -s /usr/local/Cellar/python/2.7.*/Frameworks/Python.framework/Versions/Current Current
  brew install macvim
  sudo rm Current
  sudo mv Current-sys Current
  cd -
}

function homebrew_packages_install()
{
  declare -a packages=("${!1}")
  for package in ${packages[@]}
  do
    brew list $package 1>/dev/null
    if [ $? == 1 ];
    then
      brew install $package
    else
      brew upgrade $package
    fi
  done
}

function clean_python_install()
{
  brew install python --framework
}

function clean_ruby_install()
{
  brew install rbenv
  brew install ruby-build
  rbenv install $RUBY_VERSION
  rbenv global $RUBY_VERSION
}

function homebrew_install()
{
  # install homebrew and some utils
  if [ ! $( brew --version 2>/dev/null ) ]
  then
    ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
  fi
  brew update
  brew doctor

  code_packages=( git git-flow readline cmake ctags valgrind libyaml boost node gfortran htop-osx )
  compression_packages=( p7zip zlib xz )
  db_packages=( sqlite mysql )
  font_packages=( fontconfig freetype )
  image_packages=( imagemagick ffmpeg jpeg libpng libtiff )
  network_packages=( wget ack  openssl )
  queue_packages=( zeromq rabbitmq )

  homebrew_packages_install network_packages[@]
  homebrew_packages_install compression_packages[@]
  homebrew_packages_install image_packages[@]
  homebrew_packages_install db_packages[@]
  homebrew_packages_install font_packages[@]
  homebrew_packages_install code_packages[@]
  homebrew_packages_install queue_packages[@]

  clean_python_install
  clean_ruby_install

  # see http://stackoverflow.com/questions/11148403/homebrew-macvim-with-python2-7-3-support-not-working:
  clean_macvim_install

  brew doctor
}

function python_packages_install()
{
  declare -a packages=("${!1}")
  for package in ${packages[@]}
  do
    pip install $package
  done
}

function python_install()
{
  # set up a default virtualenv (installed by homebrew)
  which virtualenv > /dev/null 2>&1 || { easy_install --upgrade pip && pip install virtualenv; >&2; }
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

function ruby_packages_install()
{
  declare -a packages=("${!1}")
  for package in ${packages[@]}
  do
    if [ $( echo $package | grep '_' ) ]
    then
      local gem_name=$(    echo $package | cut -d'_' -f1 )
      local gem_version=$( echo $package | cut -d'_' -f2 )
      gem install $gem_name -v $gem_version --no-rdoc
    else
      gem install $package --no-rdoc
    fi

  done
}

function ruby_install()
{
  deploy_packages=( chef_11.8.0 chef-zero_1.7.2 knife-solo_0.4.0 librarian_0.1.1 librarian-chef_0.0.2 berkshelf_2.0.10 )

  ruby_packages_install deploy_packages[@]
}

function vim_bundle_install()
{
  local bundle=$1
  local bundle_name=$( basename $bundle )
  bundle_name=${bundle_name%.*}

  if [ ! -d $VIM_BUNDLE_DIR/$bundle_name ]
  then
    echo "trying to install bundle '${bundle_name}'..."
    git clone $bundle $VIM_BUNDLE_DIR/$bundle_name
  fi

  cd $VIM_BUNDLE_DIR/$bundle_name
  git pull --rebase
  git submodule update --init --recursive
  cd -
}

function vim_install()
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

  vim_bundle_install https://github.com/scrooloose/nerdcommenter.git
  vim_bundle_install https://github.com/scrooloose/nerdtree.git
  vim_bundle_install https://github.com/jistr/vim-nerdtree-tabs.git
  vim_bundle_install https://github.com/imsizon/wombat.vim.git
  vim_bundle_install https://github.com/xuhdev/SingleCompile.git
  vim_bundle_install https://github.com/Lokaltog/powerline.git
  vim_bundle_install https://github.com/Valloric/YouCompleteMe.git
  vim_bundle_install https://github.com/marijnh/tern_for_vim
  vim_bundle_install https://github.com/kien/ctrlp.vim
  vim_bundle_install https://github.com/airblade/vim-gitgutter
  vim_bundle_install https://github.com/vitorgalvao/autoswap_mac.git
  vim_bundle_install https://github.com/mileszs/ack.vim
  #vim_bundle_install https://github.com/Raimondi/delimitMate
  #vim_bundle_install https://github.com/majutsushi/tagbar

  # build YouCompleteMe
  cd $VIM_BUNDLE_DIR/YouCompleteMe
  ./install.sh --clang-completer

  # install tern
  cd $VIM_BUNDLE_DIR/tern_for_vim
  npm install
}

function git_install()
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
ln -fs $current_directory/vim/ycm_cpp_conf.py   $HOME/.vim/ycm_cpp_conf.py

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
      ruby_install
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
    --ruby)
      ruby_install
      shift 1 ;;
    --vim)
      vim_install
      shift 1 ;;
    --help)
      echo "Usage: ./setenv.sh [--all|--homebrew|--vim|--python|--ruby|--git|--help]" ; shift 1 ;;
    # -d) dest_dir=$2 ; shift 2 ;;
  esac
done
