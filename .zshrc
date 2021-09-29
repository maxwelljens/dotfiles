# The following lines were added by compinstall
# ------------------------------------------------------------------------------
zstyle ':completion:*' completer _complete _ignored _approximate
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle :compinstall filename '/home/maxwellj/.zshrc'

autoload -Uz compinit
compinit

# The following lines were added by zsh-newuser-install
# ------------------------------------------------------------------------------
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=10000
bindkey -v

# $PROMPT configuration
# ------------------------------------------------------------------------------
# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info }
# Format the vcs_info_msg_0_ variable
zstyle ":vcs_info:*" enable git
zstyle ":vcs_info:*" check-for-changes true
zstyle ":vcs_info:*" stagedstr "!"
zstyle ":vcs_info:*" unstagedstr "?"
zstyle ":vcs_info:*" formats "%F{yellow}%u%f%F{red}%c%f %F{blue}%b%f/%r"
# Set up the prompt (with git branch name)
setopt PROMPT_SUBST
RPROMPT="%B\$vcs_info_msg_0_%b"
# Left side prompt
PROMPT="%(0?.%B%F{blue}λ%f%b.%B%F{red}%? λ%f%b) "

# $PATH configuration
# ------------------------------------------------------------------------------
# Example: export PATH=/home/maxwellj/.thing/program:$PATH
export PATH=/home/maxwellj/.nimble/bin:$PATH

# nnn (file manager) configuration
# ------------------------------------------------------------------------------
# Keybinds for plugins (e.g. `p` for turning on preview-tui; image previews)
export NNN_PLUG="p:preview-tui"
# FIFO to write hovered file path to
export NNN_FIFO="/tmp/nnn.fifo"

# Other exports
# ------------------------------------------------------------------------------
export VISUAL=/usr/bin/vim
export EDITOR="$VISUAL"
export PAGER=/usr/bin/most

# zsh plugins; has to be at the end
# ------------------------------------------------------------------------------
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/autojump/autojump.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
