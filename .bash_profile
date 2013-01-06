#show git branch in shell prompt (from: http://betterexplained.com/articles/aha-moments-when-learning-git/ and
#http://asemanfar.com/Current-Git-Branch-in-Bash-Prompt)
parse_git_branch()
{
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
export PS1="\[\033[00m\]\u@\h\[\033[01;34m\] \W \[\033[31m\]\$(parse_git_branch) \[\033[00m\]$\[\033[00m\] "

#prettify json
prettify()
{
  echo $1 | python -mjson.tool
}
##
#to get colors in terminal (see: http://it.toolbox.com/blogs/lim/how-to-fix-colors-on-mac-osx-terminal-37214):

#enables coloring of your terminal:
export CLICOLOR=1
#specifies how to color specific items:
export LSCOLORS=GxFxCxDxBxegedabagaced

#extend path
export PATH=/usr/local/share/python:/usr/local/Cellar:/usr/local/bin:/usr/local/sbin:$PATH

#source git completion script https://github.com/git/git/tree/master/contrib/completion
source ~/.git-completion.bash

eval "$(rbenv init -)"

alias pgstart='pg_ctl -D /usr/local/pgsql/data -l logfile start'
alias pgquit='pg_ctl -D /usr/local/pgsql/data stop -s -m fast'

