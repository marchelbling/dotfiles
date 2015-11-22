#!/bin/bash

RUBY_VERSION="2.0.0-p247"

if [ "$( uname )" == "Darwin" ];
then
    IS_MACOS=true
    VIM_DIR="${HOME}/.vim"
    VIMRC="${HOME}/.vimrc"
else
    IS_MACOS=false
    VIM_DIR="/etc/vim"
    VIMRC="${VIM_DIR}/vimrc"
fi
VIM_BUNDLE_DIR="${VIM_DIR}/bundle"


function get_extension
{
    local fullname="${1}"
    local filename="${fullname##*/}"
    local extension="${filename##*.}"
    echo "${extension}" | tr '[:upper:]' '[:lower:]'
}


function strip_extension
{
    local name="${1}"
    echo "${name%.*}"
}


function make_dir
{
    local folder="$1"
    if [ ! -d "${folder}" ]
    then
        mkdir -p "${folder}"
    fi
}


function git_clone
{
    local remote="${1}"
    local clone_dir="${2:-${CLONE_DIR}}"
    local branch_or_tag="${3}"
    local current="$( pwd )"

    make_dir "${clone_dir}"

    # human repo name
    local repo="$(  basename "${remote}" )"

    # clone absolute path
    clone="${clone_dir}/${repo}"
    if [ -d "${clone}" ]
    then
        echo "Repository '${repo}' already cloned. Updating from upstream..."
        cd "${clone}" && git pull --rebase && git submodule update --init --recursive --force && cd -
    else
        if [ -n "${branch_or_tag}" ]
        then
            git clone --recursive --branch "${branch_or_tag}" "${remote}" "${clone}"
        else
            git clone --recursive "${remote}" "${clone}"
        fi
    fi

    cd "${current}"
}


function clean_macvim_install
{
    cd /System/Library/Frameworks/Python.framework/Versions
    sudo mv Current Current-sys
    sudo ln -s /usr/local/Cellar/python/2.7.*/Frameworks/Python.framework/Versions/Current Current
    brew install macvim
    sudo rm Current
    sudo mv Current-sys Current
    cd -
}


function homebrew_packages_install
{
    declare -a packages=("${!1}")
    for package in "${packages[@]}"
    do
        if ! brew list "${package}" 1>/dev/null
        then
            brew install "${package}"
        else
            brew upgrade "${package}"
        fi
    done
}


function clean_python_install
{
    brew install python --framework
}


function clean_ruby_install
{
    brew install rbenv
    brew install ruby-build
    rbenv install ${RUBY_VERSION}
    rbenv global ${RUBY_VERSION}
}


function homebrew_install
{
    # install homebrew and some utils
    if ! brew --version 2>/dev/null
    then
        ruby -e "$( curl -fsSkL raw.github.com/mxcl/homebrew/go )"
    fi
    brew update
    brew doctor

    local code_packages=( git readline cmake ctags valgrind libyaml boost node gfortran htop-osx )
    local compression_packages=( p7zip zlib xz )
    local db_packages=( sqlite mysql )
    local font_packages=( fontconfig freetype )
    local image_packages=( imagemagick ffmpeg jpeg libpng libtiff )
    local network_packages=( wget ack ag  openssl )
    local queue_packages=( zeromq rabbitmq )

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

function python_packages_install
{
    local -a packages=( "${!1}" )
    for package in "${packages[@]}"
    do
        pip install "${package}"
    done
}


function python_install
{
    # set up a default virtualenv (installed by homebrew)
    which virtualenv > /dev/null 2>&1 || { easy_install --upgrade pip && pip install virtualenv; >&2; }
    local path="${VENV_DIR}/${DEFAULT_VENV}"
    virtualenv --distribute --no-site-packages "${path}"
    source "${path}/bin/activate"

    # install extra packages
    local scientific_packages=( numpy scipy scikit-learn matplotlib networkx pandas nltk )
    local ipython_packages=( readline ipython )
    local web_packages=( beautifulsoup requests )
    local linter_packages=( flake8 pyflakes pylint )
    local other_packages=( boto argparse nose python-dateutil pycrypto )

    python_packages_install scientific_packages[@]
    python_packages_install ipython_packages[@]
    python_packages_install web_packages[@]
    python_packages_install linter_packages[@]
    python_packages_install other_packages[@]
}


function ruby_packages_install
{
    local -a packages=( "${!1}" )
    for package in "${packages[@]}"
    do
        if grep '_' <<<"${package}"
        then
            local gem_name="$( cut -d'_' -f1 <<<"${package}" )"
            local gem_version="$( cut -d'_' -f2 <<<"${package}" )"
            gem install "${gem_name}" -v "${gem_version}" --no-rdoc --no-ri
        else
            gem install "${package}" --no-rdoc --no-ri
        fi
    done
}


function ruby_install
{
    local deploy_packages=( chef_11.8.0 chef-zero_1.7.2 knife-solo_0.4.0 librarian_0.1.1 librarian-chef_0.0.2 berkshelf_2.0.10 )

    ruby_packages_install deploy_packages[@]
}


function vim_bundle_install
{
    local bundle="$1"
    git_clone "${bundle}" "${VIM_BUNDLE_DIR}"
}


function vim_install
{
    # requires vim 7.4.615+ (see https://github.com/Shougo/unite.vim/issues/798)
    # Use e.g. `[sudo] add-apt-repository ppa:pi-rho/dev`
    for folder in "autoload" "bundle" "vim"
    do
        make_dir "${VIM_DIR}/${folder}"
    done

    # # setup vim environment: font & plugins using pathogen
    # make_dir ${HOME}/Library/Fonts
    # git_clone https://github.com/Lokaltog/powerline-fonts.git ${HOME}/Library/Fonts

    # install addons using pathogen
    curl -LSso "${VIM_DIR}/autoload/pathogen.vim" https://tpo.pe/pathogen.vim

    vim_bundle_install https://github.com/vim-scripts/taglist.vim
    vim_bundle_install https://github.com/tomtom/tcomment_vim
    vim_bundle_install https://github.com/vim-scripts/wombat256.vim
    vim_bundle_install https://github.com/xuhdev/SingleCompile
    vim_bundle_install https://github.com/bling/vim-airline
    vim_bundle_install https://github.com/Shougo/unite.vim
    vim_bundle_install https://github.com/Shougo/vimproc.vim && cd "${VIM_BUNDLE_DIR}/vimproc.vim" && make && cd -
    vim_bundle_install https://github.com/Shougo/neomru.vim
    vim_bundle_install https://github.com/airblade/vim-gitgutter
    vim_bundle_install https://github.com/scrooloose/syntastic
    vim_bundle_install https://github.com/tpope/vim-fugitive
    vim_bundle_install https://github.com/godlygeek/tabular
    vim_bundle_install https://github.com/henrik/vim-indexed-search
    vim_bundle_install https://github.com/rking/ag.vim
    vim_bundle_install https://github.com/skammer/vim-css-color
}


function git_install
{
    # fetch git-completion.bash
    curl https://raw.github.com/git/git/master/contrib/completion/git-completion.bash > "${HOME}/.git-completion.bash"
}

function docker_install
{
    # fetch docker-completion.bash
    curl https://raw.githubusercontent.com/docker/docker/master/contrib/completion/bash/docker > "${HOME}/.docker-completion.bash"
}


###############
# 1. distribute configuration files
###############
# sets medium font anti-aliasing
## see: http://osxdaily.com/2012/06/09/mac-screen-blurry-optimize-troubleshoot-font-smoothing-os-x/
if ${IS_MACOS};
then
    defaults -currentHost write -globalDomain AppleFontSmoothing -int 2
fi

# create soft links for all config files
current_directory="$( pwd )"
## git
ln -fs "${current_directory}/git/gitconfig"         /etc/gitconfig
## ruby
ln -fs "${current_directory}/ruby/irbrc"            "${HOME}/.irbrc"
ln -fs "${current_directory}/ruby/rdebugrc"         "${HOME}/.rdebugrc"
## terminal
ln -fs "${current_directory}/terminal/agignore"     "${HOME}/.agignore"
ln -fs "${current_directory}/terminal/bash_profile" "${HOME}/.bash_profile"
ln -fs "${current_directory}/terminal/gdbinit"      "${HOME}/.gdbinit"
ln -fs "${current_directory}/terminal/inputrc"      "${HOME}/.inputrc"
ln -fs "${current_directory}/terminal/screenrc"     "${HOME}/.screenrc"
## vim
ln -fs "${current_directory}/vim/vimrc"             "${VIMRC}"

source "${HOME}/.bash_profile"

###############
# 2. install required components if needed
###############
# parse command line arguments
while [ $# -ge 1 ] ; do
    case $1 in
        --all)
            if ${IS_MACOS};
            then
              homebrew_install
            fi

            git_install
            python_install
            ruby_install
            vim_install

            if ${IS_MACOS};
            then
              # terminal theme needs to be 'default'ed manually
              open "${current_directory}/terminal/colors.terminal"
            fi

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
