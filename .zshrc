# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/mjensen/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Download Znap, if it's not there yet.
[[ -r ~/.znap/core/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git ~/.znap/core
source ~/.znap/core/znap.zsh  # Start Znap

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/home/mjensen/.opam/opam-init/init.zsh' ]] || source '/home/mjensen/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null
# END opam configuration

# Znap plugins
znap source romkatv/powerlevel10k
znap source zsh-users/zsh-syntax-highlighting
znap source zsh-users/zsh-autosuggestions
znap source mrjohannchang/zsh-interactive-cd
znap source kazhala/dotbare
znap source agkozak/zsh-z

# bun completions
[ -s "/home/mjensen/.bun/_bun" ] && source "/home/mjensen/.bun/_bun"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
