#!/bin/bash

if [ "$( uname )" == "Darwin" ];
then
    IS_MACOS=true
    VIM_DIR="${HOME}/.vim"
    VIMRC="${HOME}/.vimrc"
    GITCONFIG="${HOME}/.gitconfig"
else
    IS_MACOS=false
    VIM_DIR="/etc/vim"
    VIMRC="${VIM_DIR}/vimrc"
    GITCONFIG="/etc/gitconfig"
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
    local other_packages=( awscli argparse nose python-dateutil pycrypto )

    python_packages_install scientific_packages[@]
    python_packages_install ipython_packages[@]
    python_packages_install web_packages[@]
    python_packages_install linter_packages[@]
    python_packages_install other_packages[@]
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
    vim_bundle_install https://github.com/Valloric/YouCompleteMe && cd "${VIM_BUNDLE_DIR}/YouCompleteMe" \
                                                                 && git submodule update --init --recursive \
                                                                 && ./install.py --clang-completer
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
ln -fs "${current_directory}/git/gitconfig"         "${GITCONFIG}"
## terminal
ln -fs "${current_directory}/terminal/agignore"     "${HOME}/.agignore"
ln -fs "${current_directory}/terminal/bash_profile" "${HOME}/.bash_profile"
ln -fs "${current_directory}/terminal/gdbinit"      "${HOME}/.gdbinit"
ln -fs "${current_directory}/terminal/inputrc"      "${HOME}/.inputrc"
ln -fs "${current_directory}/terminal/screenrc"     "${HOME}/.screenrc"
## vim
ln -fs "${current_directory}/vim/vimrc"             "${VIMRC}"
ln -fs "${current_directory}/vim/ycm_cpp_conf.py"   "${HOME}/.ycm_cpp_conf.py"

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

              # terminal theme needs to be 'default'ed manually
              open "${current_directory}/terminal/colors.terminal"
            fi

            git_install
            python_install
            vim_install

            shift 1 ;;  # drop current command line arg
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
            echo "Usage: $0 [--all|--homebrew|--vim|--python|--git|--help]"
            shift 1 ;;
    esac
done
