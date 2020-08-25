#!/bin/bash

if [ "$( uname )" == "Darwin" ];
then
    IS_MACOS=true
fi

VIM_DIR="${HOME}/.vim"
VIMRC="${HOME}/.vimrc"
NEOVIM_DIR="${HOME}/.config/nvim"
NEOVIMRC="${NEOVIM_DIR}/init.vim"
GITCONFIG="${HOME}/.gitconfig"

if [[ $( basename "${SHELL}" ) == "zsh" ]]
then
    IS_ZSH=true
fi

if [ -n "${IS_MACOS}" ];
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


function homebrew_cask_install
{
    declare -a packages=("${!1}")
    for package in "${packages[@]}"
    do
        if ! brew cask list "${package}" 1>/dev/null
        then
            brew cask install "${package}"
        else
            brew cask upgrade "${package}"
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

    local packages=( \
        golang \
        make \
        rbenv \
        python3 \
        yarn npm \
        yamllint \
        p7zip coreutils htop-osx ag jq num-utils \
        bash-completion \
        vault postgresql redis \
        vim nvim codemod \
        fontconfig freetype \
    )

    homebrew_packages_install packages[@]

    # note gcloud requires some extra steps:
    # gcloud init
    # gcloud components update
    # gcloud components install cbt
    local binaries=( docker tunnelblick basictex google-cloud-sdk )
    homebrew_cask_install binaries[@]
}


function vim_install
{
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    vim +PlugClean +PlugInstall +qall  # install all plugins from vimrc

    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    nvim +PlugClean +PlugInstall +qall  # install all plugins from vimrc

    # setup extensions (see https://github.com/neoclide/coc.nvim/issues/118)
    ( mkdir -p ~/.config/coc/extensions && cd ~/.config/coc/extensions && yarn add coc-json coc-python coc-solargraph coc-yaml )
}


function fonts_install {
    mkdir -p "${FONTS_DIR}"
    sudo cp "fonts/Anonymice Powerline.ttf" "${FONTS_DIR}"
    fc-cache -f -v
}


function terminal_completion
{
    if [ -n "${IS_ZSH}" ]
    then
        mkdir -p "${HOME}/.zsh/completion"
        curl -sSL https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh > "${HOME}/.zsh/completion/_git"
    else
        curl -sSL https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > "${HOME}/.git-completion.bash"
        curl -sSL https://raw.githubusercontent.com/docker/docker/master/contrib/completion/bash/docker > "${HOME}/.docker-completion.bash"
        kubectl completion bash > "${HOME}/.kubectl-completion.bash"
        # FIXME: freeze and host assets locally for security
        curl -sSL https://raw.githubusercontent.com/modosc/rake-autocomplete/master/rake > "${HOME}/.rake-completion.bash"
        curl -sSL https://raw.githubusercontent.com/Bash-it/bash-it/master/completion/available/makefile.completion.bash > "${HOME}/.make-completion.bash"
    fi
}


function lsp_completion {
    # golang: gopls
    if which go 2>&1 >/dev/null
    then
        go get -u golang.org/x/tools/cmd/gopls
    fi

    # bash: bash-language-server
    npm i -g bash-language-server

    # json: jsonlint
    npm install -g jsonlint
    npm install -g prettier

    # ruby: solargraph
    gem install solargraph

    # c++: ccls
    brew install ccls
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

            lsp_completion
            fonts_install
            terminal_completion
            vim_install

            shift 1 ;;  # drop current command line arg
        --fonts)
            fonts_install
            shift 1 ;;
        --homebrew)
            homebrew_install
            shift 1 ;;
        --lsp)
            lsp_completion
            shift 1 ;;
        --vim)
            vim_install
            shift 1 ;;
        --help)
            echo "Usage: $0 [--all|--fonts|--homebrew|--vim|--git|--help]"
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
if [ -n "IS_ZSH" ]
then
    ln -fs "${current_directory}/terminal/zshrc"        "${HOME}/.zshrc"
    ln -fs "${current_directory}/terminal/theme.zsh"    "${HOME}/.zsh/theme.zsh"
else
    ln -fs "${current_directory}/terminal/bash_profile" "${BASH_PROFILE}"
fi
ln -fs "${current_directory}/terminal/gdbinit"      "${HOME}/.gdbinit"
ln -fs "${current_directory}/terminal/inputrc"      "${HOME}/.inputrc"
ln -fs "${current_directory}/terminal/screenrc"     "${HOME}/.screenrc"
ln -fs "${current_directory}/terminal/curlrc"       "${HOME}/.curlrc"
## vim
ln -fs "${current_directory}/vim/vimrc"             "${VIMRC}"
ln -fs "${current_directory}/vim/coc-settings.json" "${VIM_DIR}"
## neovim
mkdir -p $( dirname ${NEOVIMRC} )
ln -fs "${current_directory}/vim/vimrc"             "${NEOVIMRC}"
ln -fs "${current_directory}/vim/coc-settings.json" "${NEOVIM_DIR}"

source "${BASH_PROFILE}"
