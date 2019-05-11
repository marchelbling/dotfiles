#!/bin/bash

if [ "$( uname )" == "Darwin" ];
then
    IS_MACOS=true
fi

VIM_DIR="${HOME}/.vim"
VIMRC="${HOME}/.vimrc"
NEOVIMRC="${HOME}/.config/nvim/init.vim"
GITCONFIG="${HOME}/.gitconfig"

if [ "${IS_MACOS}" == "true" ];
then
    FONTS_DIR="${HOME}/Library/Fonts"
    BASH_PROFILE="${HOME}/.bash_profile"
else
    FONTS_DIR="${HOME}/.fonts"
    BASH_PROFILE="${HOME}/.bashrc"
fi

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
        ( cd "${clone}" && git pull --rebase && git submodule update --init --recursive --force )
    else
        if [ -n "${branch_or_tag}" ]
        then
            git clone --recursive --branch "${branch_or_tag}" "${remote}" "${clone}"
        else
            git clone --recursive "${remote}" "${clone}"
        fi
    fi
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


function homebrew_install
{
    # install homebrew and some utils
    if ! brew --version 2>/dev/null
    then
        ruby -e "$( curl -fsSkL raw.github.com/mxcl/homebrew/go )"
    fi

    local code_packages=( go cmake valgrind libyaml htop-osx python3 )
    local compression_packages=( p7zip )
    local db_packages=( sqlite )
    local editor_packages=( vim nvim ack ag )
    local font_packages=( fontconfig freetype )

    homebrew_packages_install code_packages[@]
    homebrew_packages_install compression_packages[@]
    homebrew_packages_install db_packages[@]
    homebrew_packages_install editor_packages[@]
    homebrew_packages_install font_packages[@]

    brew doctor
}


function vim_install
{
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    vim +PlugClean +PlugInstall +qall  # install all plugins from vimrc

    pip3 install --upgrade neovim
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    nvim +PlugClean +PlugInstall +qall  # install all plugins from vimrc
}


function fonts_install {
    mkdir -p "${FONTS_DIR}"
    sudo cp "fonts/Anonymice Powerline.ttf" "${FONTS_DIR}"
    fc-cache -f -v
}


function git_completion
{
    # fetch git-completion.bash
    curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > "${HOME}/.git-completion.bash"
}


function docker_completion
{
    # fetch docker-completion.bash
    curl https://raw.githubusercontent.com/docker/docker/master/contrib/completion/bash/docker > "${HOME}/.docker-completion.bash"
}


###############
# 1. install required components if needed
###############
# parse command line arguments
while [ $# -ge 1 ] ; do
    case $1 in
        --all)
            if [ "${IS_MACOS}" == "true" ];
            then
                homebrew_install
                # terminal theme needs to be 'default'ed manually
                open "${current_directory}/terminal/wombat.terminal"
            fi

            fonts_install
            git_completion
            python_install
            vim_install

            shift 1 ;;  # drop current command line arg
        --fonts)
            fonts_install
            shift 1 ;;
        --git)
            git_completion
            shift 1 ;;
        --homebrew)
            homebrew_install
            shift 1 ;;
        --vim)
            vim_install
            shift 1 ;;
        --help)
            echo "Usage: $0 [--all|--fonts|--ubuntu|--homebrew|--vim|--python|--git|--help]"
            shift 1 ;;
    esac
done


###############
# 2. distribute configuration files
###############
# sets medium font anti-aliasing
## see: http://osxdaily.com/2012/06/09/mac-screen-blurry-optimize-troubleshoot-font-smoothing-os-x/
if [ "${IS_MACOS}" == "true" ];
then
    defaults -currentHost write -globalDomain AppleFontSmoothing -int 2
fi

# create soft links for all config files
current_directory="$( pwd )"
## git
ln -fs "${current_directory}/git/gitconfig"         "${GITCONFIG}"
## terminal
ln -fs "${current_directory}/terminal/agignore"     "${HOME}/.agignore"
ln -fs "${current_directory}/terminal/bash_profile" "${BASH_PROFILE}"
ln -fs "${current_directory}/terminal/gdbinit"      "${HOME}/.gdbinit"
ln -fs "${current_directory}/terminal/inputrc"      "${HOME}/.inputrc"
ln -fs "${current_directory}/terminal/screenrc"     "${HOME}/.screenrc"
ln -fs "${current_directory}/terminal/curlrc"       "${HOME}/.curlrc"
## vim
ln -fs "${current_directory}/vim/vimrc"             "${VIMRC}"
## neovim
mkdir -p $( dirname ${NEOVIMRC} )
ln -fs "${current_directory}/vim/vimrc"             "${NEOVIMRC}"

source "${BASH_PROFILE}"
