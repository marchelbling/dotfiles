# colors: ANSI escape sequences for bash
# Format: \[\e[XXm\] where XX is the color code
# \[ and \] are required in PS1 to mark non-printing characters
none='\[\e[0m\]'
red='\[\e[31m\]'
gray='\[\e[90m\]'
orange='\[\e[38;5;172m\]'
green='\[\e[32m\]'
blue='\[\e[34m\]'
lightgray='\[\e[37m\]'
darkgray='\[\e[1;30m\]'
bold='\[\e[1m\]'

# Raw versions without \[ \] for use in echo statements
_none='\e[0m'
_red='\e[31m'
_gray='\e[90m'
_orange='\e[38;5;172m'
_green='\e[32m'
_blue='\e[34m'
_bold='\e[1m'

# show git branch in shell prompt
function get_relative_path {
    local from="$1"
    local to="$( pwd )"
    echo "${to}" | sed "s#${from}##g"
}

function parse_repo_path {
    git rev-parse --show-toplevel 2>/dev/null
}

function parse_branch {
    git branch --show-current 2>/dev/null
}

function parse_upstream {
    local branch="$1"
    if [ -z "${branch}" ]; then
        return
    fi
    local remote_branch="$( git rev-parse --abbrev-ref @{u} 2>/dev/null )"
    local color="${_gray}"
    if [ -z "${remote_branch}" ]
    then
        local remote=""
    else
        if [[ "${remote_branch}" == "@{u}" ]]
        then
            local remote="∅ /"
        else
            local remote="${remote_branch%$branch}"
            if ! git diff --quiet "${remote_branch}".."${branch}" >/dev/null 2>&1;
            then
                local color="${_orange}"
            fi
        fi
    fi
    echo -e " ${_red}(${_none}${color}${remote}${_none}${_red}${branch})${_none}"
}

function parse_repo {
    local repo_path="$1"
    if [ -n "${repo_path}" ]
    then
      local repo=$( basename "${repo_path}" )
      if [ "${repo_path}" != "$( pwd )" ]
      then
          repo="${repo}:"
      fi
    fi
    echo -e "${_green}${repo}"
}

function parse_path {
    local repo_path="$1"
    local my_path="$( pwd )"
    if [ -n "${repo_path}" ];
    then
        my_path=$( get_relative_path "${repo_path}" )
    else
        if [ "${PWD##${HOME}}" != "${PWD}" ];
        then
            my_path="~$( get_relative_path "${HOME}" )"
        fi
    fi
    echo -e "${_blue}${my_path}"
}

function parse_diff {
    if [ -d .git ] || git rev-parse --git-dir >/dev/null 2>&1;
    then
        local diff="$( git status --porcelain )"
        local state=""
        if [ -n "${diff}" ] && echo "${diff}" | grep -v "^?? " &>/dev/null;
        then
            state="✎ "
        fi

        if grep "^?? " <<<"${diff}" &>/dev/null;
        then
            state="${state}⚑"
        fi

        if [ -n "${state}" ]
        then
            echo -e "${_orange}[${state}]${_none}"
        fi
    fi
}

function git_prompt {
    local branch="$( parse_branch )"
    local root="$( parse_repo_path )"
    echo -e " $( parse_repo "${root}" )$( parse_path "${root}" )$( parse_upstream "${branch}" )$( parse_diff )${_none}"
}

function parse_k8s {
    if which kubectl >/dev/null 2>&1;
    then
        local k8s_context="$( kubectl config --request-timeout=1 current-context 2>/dev/null )"
        if [ -n "${k8s_context}" ]
        then
            echo -e " ${_bold}${_gray}(k8s=$( echo ${k8s_context} | rev | cut -d'_' -f1 | rev ))${_none}"
        fi
    fi
}

function parse_exit_bash {
    local exit_code=$1
    if [ $exit_code -ne 0 ]; then
        echo -e "${_bold}${_red}↳ ${exit_code}${_none} "
    fi
}

function parse_time {
    echo -e "${_gray}$( date +%H:%M:%S )${_none}"
}

function parse_user {
    echo -e " ${_bold}${USER}${_none}"
}

# Build prompt dynamically
function __prompt_command {
    local exit_code=$?
    PS1="$(parse_exit_bash $exit_code)$(parse_time)$(parse_user)$(git_prompt)$(parse_k8s)${none} \$ "
}

PROMPT_COMMAND=__prompt_command
