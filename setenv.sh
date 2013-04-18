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
  brew install wget ack git imagemagick readline htop
  # see http://stackoverflow.com/questions/11148403/homebrew-macvim-with-python2-7-3-support-not-working:
  brew install macvim
  #brew install python --framework # this is useless as python is installed using anaconda
  brew install rbenv
  brew install ruby-build
  brew install postgresql

  pg_setup
  brew doctor
}

python_install()
{
  # ipython & 'standard' scientific packages
  curl http://09c8d0b2229f813c1b93-c95ac804525aac4b6dba79b00b39d1d3.r79.cf1.rackcdn.com/Anaconda-1.4.0-MacOSX-x86_64.sh > anaconda.sh
  bash anaconda.sh -b -p $CONDA_DIR
  conda update conda

  # install extra packages
  pip install beautifulsoup
  pip install django
  pip install psycopg2
  pip install argparse
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
#ln -fs $current_directory/vim/gvimrc            $HOME/.gvimrc

