#!/bin/bash

# parse command line arguments

while [ $# -ge 1 ] ; do
  case $1 in
    --homebrew)
      # install homebrew and some utils
      ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)"
      brew update
      brew doctor
      brew install wget macvim imagemagick postgresql readline
      brew install rbenv
      brew install ruby-build
      brew doctor
      # drop current command line arg
      shift 1 ;;
    --vim)
      # setup vim environment
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
      git clone https://github.com/scrooloose/nerdtree.git
      git clone https://github.com/jistr/vim-nerdtree-tabs.git
      git clone https://github.com/vim-ruby/vim-ruby.git
      git clone https://github.com/tpope/vim-surround.git
      git clone https://github.com/imsizon/wombat.vim.git
      shift 1 ;;
    --help) echo "Usage: ./setenv.sh [--homebrew|--vim|--help]" ; shift 1 ;;
    # -d) dest_dir=$2 ; shift 2 ;;
  esac
done

# copy all config files in HOME directory
for file in `ls -a .`; do cp $file $HOME/$file; done
# fetch git-completion.bash
curl https://raw.github.com/git/git/master/contrib/completion/git-completion.bash > $HOME/.git-completion.bash


