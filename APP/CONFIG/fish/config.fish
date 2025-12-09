### SETTINGS ###
## DEFAULT ##
set -U fish_greeting

## MAIN ##
# STARSHIP #
starship init fish | source

# ZOXIDE #
zoxide init fish | source


### ALIASES ###
## SYSTEM ##
alias sleep="sudo systemctl suspend"
alias off="sudo shutdown now"
alias restart="sudo reboot"

## DEFAULT ##
alias c="clear"
alias h="history"

## MAIN ##
# EZA #
alias l="eza --oneline --long --header --git --color=always --icons=always"
alias lt="eza --oneline --long --header --git --color=always --icons=always --tree"
alias la="eza --oneline --long --header --git --color=always --icons=always --all"
alias lat="eza --oneline --long --header --git --color=always --icons=always --all --tree"

# ZOXIDE #
alias cd="z"

# FZF #
alias f="fzf"
