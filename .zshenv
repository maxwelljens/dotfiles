# $PATH configuration
# ------------------------------------------------------------------------------
# Example: . "$HOME/maxwellj/.thing/program"
. "$HOME/.cargo/env"

# Other exports
# ------------------------------------------------------------------------------
export VISUAL=/usr/bin/nvim
export EDITOR=$VISUAL
export PAGER=/usr/bin/most
export FZF_DEFAULT_COMMAND="rg --files --follow --no-ignore-vcs --hidden -g '!{**/node_modules/*,**/.git/*}'"
