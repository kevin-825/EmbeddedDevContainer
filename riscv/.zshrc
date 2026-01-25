export ZSH="$HOME/.oh-my-zsh"

# Switch themes by editing this line:
# ZSH_THEME="powerlevel10k/powerlevel10k"
# ZSH_THEME="pure"
ZSH_THEME="agnoster"
# ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  sudo
  docker
  python
  zsh-autosuggestions
  zsh-syntax-highlighting
  history-substring-search
)

source $ZSH/oh-my-zsh.sh

# Load your workspace alias files
#[ -f $HOME/workspaces/.bash_aliases ] && source $HOME/workspaces/.bash_aliases
#[ -f $HOME/workspaces/.bash_aliases_1 ] && source $HOME/workspaces/.bash_aliases_1
# Load your workspace alias files
[ -f /hst_root/home/kflyn/.bash_aliases ] && source /hst_root/home/kflyn/.bash_aliases
[ -f /hst_root/home/kflyn/.bash_aliases_1 ] && source /hst_root/home/kflyn/.bash_aliases_1

# fzf keybindings + completion
if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi
if [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
  source /usr/share/doc/fzf/examples/completion.zsh
fi

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
