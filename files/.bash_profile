# Set up Guix Home profile
if [ -f ~/.profile ]; then . ~/.profile; fi

# Honor per-interactive-shell startup file
if [ -f ~/.bashrc ]; then . ~/.bashrc; fi

# Merge search-paths from multiple profiles, the order matters.
eval "$(guix package --search-paths \
-p $HOME/.config/guix/current \
-p $HOME/.guix-home/profile \
-p $HOME/.guix-profile \
-p /run/current-system/profile)"

export PATH=${HOME}/.local/bin:$PATH
export PATH=/bin:$PATH

# Prepend setuid programs.
export PATH=/run/setuid-programs:$PATH

set bell-style none
bind 'set bell-style none'
