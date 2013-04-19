#!/bin/bash

pg_setup()
{
  # this is a duplicate from bash_profile...
  PGDATA=/usr/local/var/postgres
  mkdir -p $PGDATA
  initdb --pgdata=$PGDATA -E utf8
}

homebrew_install()
{
  # install homebrew and some utils
  ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
  brew update
  brew doctor
  brew install wget ack git imagemagick readline htop openssl qt zeromq
  brew install gfortran
  brew install macvim
  # see http://stackoverflow.com/questions/11148403/homebrew-macvim-with-python2-7-3-support-not-working:
  brew install python --framework
  brew install rbenv
  brew install ruby-build
  brew install postgresql

  pg_setup
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
  virtualenv --distribute --no-site-package $VENV_DIR/$DEFAULT_VENV
  source $VENV_DIR/$DEFAULT_VENV/bin/activate

  # install extra packages
  scientific_packages=( numpy scipy scikit-learn matplotlib networkx pandas nltk )
  ipython_packages=( readline ipython )
  web_packages=( beautifulsoup psycopg2 django requests )
  other_packages=( boto argparse nose pyflakes python-dateutil pycrypto )

  python_packages_install scientific_packages[@]
  python_packages_install ipython_packages[@]
  python_packages_install web_packages[@]
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

  # install addons using pathogen
  curl -Sso ~/.vim/autoload/pathogen.vim \
      https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
  cd $HOME/.vim/bundle
  git clone https://github.com/scrooloose/nerdcommenter.git
  git clone https://github.com/scrooloose/nerdtree.git
  git clone https://github.com/jistr/vim-nerdtree-tabs.git
  git clone https://github.com/vim-ruby/vim-ruby.git
  git clone https://github.com/imsizon/wombat.vim.git
  git clone https://github.com/ervandew/supertab.git
  git clone https://github.com/klen/python-mode.git
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
ln -fs $current_directory/terminal/bash_profile $HOME/.bash_profile
ln -fs $current_directory/terminal/inputrc      $HOME/.inputrc
ln -fs $current_directory/terminal/screenrc     $HOME/.screenrc
## vim
ln -fs $current_directory/vim/vimrc             $HOME/.vimrc

source $HOME/.bash_profile

###############
# 2. install required compenents if needed
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
      open terminal/colors.terminal
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
