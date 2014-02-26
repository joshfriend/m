# oh-my-zsh m Theme

### Git [master <> ●]

ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[white]%}>%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[white]%}<%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%{$fg_bold[red]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[yellow]%}●%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_STASHED="%{$fg_bold[cyan]%}●%{$reset_color%}"

ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}]"

m_git_branch () {
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}

m_git_status1() {
  # Show ahead/behind status
  _INDEX=$(command git status -uno --porcelain -b 2> /dev/null)
  _STATUS=""
  if $(echo "$_INDEX" | grep '^## .*behind' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi
  if $(echo "$_INDEX" | grep '^## .*ahead' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi
  if $(echo "$_INDEX" | grep '^## .*diverged' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_DIVERGED"
  fi

  # Prepend space if non empty
  if [ "${_STATUS}x" != "x" ]; then
    _STATUS=" $_STATUS"
  fi

  echo $_STATUS
}

m_git_status2 () {
  # Show working copy/staged changes status
  _INDEX=$(command git status -uno --porcelain -b 2> /dev/null)
  _STATUS=""
  if $(echo "$_INDEX" | grep '^[AMRD]. ' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STAGED"
  fi
  if $(echo "$_INDEX" | grep '^.[MTD] ' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED"
  fi
  if $(echo "$_INDEX" | grep '^UU ' &> /dev/null); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED"
  fi
  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    _STATUS="$_STATUS$ZSH_THEME_GIT_PROMPT_STASHED"
  fi

  # Prepend space if non empty
  if [ "${_STATUS}x" != "x" ]; then
    _STATUS=" $_STATUS"
  fi

  echo $_STATUS
}

m_git_prompt () {
  local _branch=$(m_git_branch)
  local _status="$(m_git_status1)$(m_git_status2)"
  local _result=""
  if [[ "${_branch}x" != "x" ]]; then
    _result="[$_branch"
    if [[ "${_status}x" != "x" ]]; then
      _result="$_result$_status"
    fi
    _result="$_result$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
  echo $_result
}

if [[ $(id -u) == 0 ]]; then
  _LIBERTY="%{$fg[red]%}#%{$reset_color%}"
else
  _LIBERTY="%{$fg[green]%}$%{$reset_color%}"
fi

# Add 'user@hostname' in ssh session
_USERNAME=""
if [[ -n $SSH_CONNECTION ]]; then
  _USERNAME="%{$bg[white]%}%{$fg[white]%}%n@%m%{$reset_color%}:"
fi

_PATH="%{$fg_bold[white]%}%~%{$reset_color%}"

setopt prompt_subst
PROMPT='
$_USERNAME$_PATH
$_LIBERTY '
RPROMPT='$(m_git_prompt)'

autoload -U add-zsh-hook
