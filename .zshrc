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
PROMPT="%(0?.%B%F{blue}>%f%b.%B%F{red}%? >%f%b) "

# $PATH configuration
# ------------------------------------------------------------------------------
# Example: export PATH=/home/maxwellj/.thing/program:$PATH

# nnn (file manager) configuration
# ------------------------------------------------------------------------------
# Keybinds for plugins (e.g. `p` for turning on preview-tui; image previews)
export NNN_PLUG="p:preview-tui"
# FIFO to write hovered file path to
export NNN_FIFO="/tmp/nnn.fifo"

# zsh plugins; has to be at the end
# ------------------------------------------------------------------------------
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/autojump/autojump.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
