#!/bin/bash

homebrew_install()
{
  # install homebrew and some utils
  ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
  brew update
  brew doctor
  brew install wget ack git macvim imagemagick postgresql readline
  brew install python --framework
  brew install rbenv
  brew install ruby-build
  brew doctor
}

make_venv()
{
  virtualenv --distribute --no-site-packages $1
  source $1/bin/activate
  echo `basename $1` 'created'
}
python_install()
{
  # distribute should already be installed by homebrew
  easy_install pip
  pip install virtualenv
  mkdir $VIRTUALENV_DIR
  make_venv $VIRTUALENV_DIR/$DEFAULT_VIRTUALENV

  # ipython & 'standard' scientific packages
  curl http://09c8d0b2229f813c1b93-c95ac804525aac4b6dba79b00b39d1d3.r79.cf1.rackcdn.com/Anaconda-1.4.0-MacOSX-x86_64.sh > anaconda.sh
  bash anaconda.sh -b -p $CONDA_DIR
  conda update conda

  # install extra packages
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
  git clone https://github.com/ervandew/supertab
  git clone https://github.com/kevinw/pyflakes-vim.git
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
      vim_install
      python_install
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
ln -fs $current_directory/terminal/screenrc     $HOME/.screenrc
## vim
ln -fs $current_directory/vim/vimrc             $HOME/.vimrc
#ln -fs $current_directory/vim/gvimrc            $HOME/.gvimrc

