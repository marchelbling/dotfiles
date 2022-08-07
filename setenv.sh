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
    mkdir -p ~/.zsh/
fi

if [ -n "${IS_MACOS}" ];
then
    BASH_PROFILE="${HOME}/.bash_profile"
else
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


function homebrew_install
{
    # install homebrew and some utils
    if ! brew --version 2>/dev/null
    then
        ruby -e "$( curl -fsSkL raw.github.com/mxcl/homebrew/go )"
    fi

    local packages=( \
        go fzf \
        rustup rust-analyzer \
        git hub openssl gnupg pinentry-mac \
        nvim codemod \
        make cmake \
        ruby-build rbenv \
        python3 \
        yarn npm \
        yamllint \
        coreutils htop tree ag jq num-utils \
        bash-completion \
        vault terraform terraform-ls \
        postgresql sqlite redis \
        docker container-structure-test \
        basictex \
    )

    homebrew_install packages[@]

    # note gcloud requires some extra steps:
    # gcloud init
    # gcloud components update
    # gcloud components install cbt

    # rust: rustup-init
}


function vim_install
{
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    vim +PlugClean +PlugInstall +qall  # install all plugins from vimrc

    brew install bat
    pip install pynvim
}

function golang_install
{
    # requires go to be installed.
    go install golang.org/x/tools/gopls@latest
    go install golang.org/x/tools/cmd/goimports@latest
    go install mvdan.cc/gofumpt@latest
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.47.3
}


function fonts_install
{
    brew tap homebrew/cask-fonts
    # brew install --cask font-anonymice-nerd-font \
    #                     font-inconsolata-nerd-font \
    #                     font-roboto-mono-nerd-font
    open fonts/Anonymice Nerd Font/*
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


function lsp_completion
{
    if which npm 2>&1 >/dev/null
    then
        # bash: bash-language-server
        npm i -g bash-language-server

        # json: jsonlint
        npm install -g jsonlint
        npm install -g prettier
        npm install -g eslint
    fi

    # ruby: solargraph
    gem install solargraph

    # c++: ccls
    brew install ccls

    # terraform
    brew install hashicorp/tap/terraform-ls

    # lua
    brew install stylua

    # golang dependencies
    golang_install
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
                open "${current_directory}/terminal/nord.terminal"
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
ln -fs "${current_directory}/vim/lua"               "${NEOVIM_DIR}"
## finicky
ln -fs "${current_directory}/terminal/finicky.js" "${HOME}/.finicky.js"

if [ -f ${BASH_PROFILE} ]
then
    source "${BASH_PROFILE}"
fi
