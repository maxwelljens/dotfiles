# --- Aliases ---

alias obliterate="git filter-repo --invert-paths --force --path"
alias clipdiff="git diff --no-prefix -U8 | dms cl copy"

# --- Exports ---

export PATH=$PATH:$HOME/.local/bin:$HOME/go/bin
export EDITOR=/bin/nvim
export BAT_THEME="gruvbox-dark"
export GITHUB_TOKEN="$(pass show github/token 2>/dev/null)"

# LLM
export HYPER_API_KEY="$(pass show hyper/api_key 2>/dev/null)"
export DEEPSEEK_API_KEY="$(pass show deepseek/api_key 2>/dev/null)"
export OPENCODE_API_KEY="$(pass show opencode/api_key 2>/dev/null)"

# GPG
# It is important that this environment variable always reflects the output of
# the tty command. Make sure that a proper pinentry program has been installed
# under the default filename.
GPG_TTY=$(tty)
export GPG_TTY
