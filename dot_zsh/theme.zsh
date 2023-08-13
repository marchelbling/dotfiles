# colors: custom definitions
none="%f%b"
red="%F{1}"
gray="%F{240}"
orange="%F{172}"
green="%F{2}"
blue="%F{4}"
lightgray="%F{7}"
darkgray="%B%F{0}"
bold="%B"

# show git branch in shell prompt
# http://betterexplained.com/articles/aha-moments-when-learning-git/ and http://asemanfar.com/Current-Git-Branch-in-Bash-Prompt
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
    # https://stackoverflow.com/questions/171550/find-out-which-remote-branch-a-local-branch-is-tracking
    local remote_branch="$( git rev-parse --abbrev-ref @{u} 2>/dev/null )"
    local color="$gray"
    if [ -z "${remote_branch}" ]  # handle local branch
    then
        local remote=""
    else
        if [[ "${remote_branch}" == "@{u}" ]]
        then
            local remote="∅ /"  # remote branch deleted
        else
            local remote="${remote_branch%$branch}"  # strip suffix (/branch)

            if ! git diff --quiet "${remote_branch}".."${branch}" >/dev/null 2>&1;
            then
                local color="$orange"
            fi
        fi
    fi
    echo -e " ${red}(${none}${color}${remote}${none}${red}${branch})%f%b"
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
    echo -e "${green}${repo}"
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

    echo -e "${blue}${my_path}"
}

function parse_diff {
    if [ -d .git ] || git rev-parse --git-dir >/dev/null 2>&1;
    then
        local diff="$( git status --porcelain )"
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
            echo "${orange}[${state}]${none}"
        fi
    fi
}

function git_prompt {
    local branch="$( parse_branch )"
    local root="$( parse_repo_path )"
    echo " $( parse_repo "${root}" )$( parse_path "${root}" )$( parse_upstream "${branch}" )$( parse_diff )${none}"
}

function parse_k8s {
    if which kubectl >/dev/null 2>&1;
    then
        local k8s_context="$( kubectl config --request-timeout=1 current-context 2>/dev/null )"
        if [ -n "${k8s_context}" ]
        then
            echo -e " ${bold}${gray}(k8s=$( echo ${k8s_context} | rev | cut -d'_' -f1 | rev ))${none}"
        fi
    fi
}

function parse_exit {
    # see https://scriptingosx.com/2019/07/moving-to-zsh-06-customizing-the-zsh-prompt/
    echo '%(?..%B%F{red}↳ %?%f) '
}

function parse_time {
    echo -e "${gray}$( date +%H:%M:%S )${none}"
}

function parse_user {
    echo -e " ${bold}${USER}${none}"
}


# prompt (https://unix.stackexchange.com/questions/40595/reevaluate-the-prompt-expression-each-time-a-prompt-is-displayed-in-zsh)
setopt prompt_subst
PROMPT='$(parse_exit)$(parse_time)$(parse_user)$(git_prompt)$(parse_k8s)%f%b $ '

