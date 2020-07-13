#!/bin/bash

# Disable ctrl-s and ctrl-q
stty -ixon

#Allows you to cd into directory merely by typing the directory name.
shopt -s autocd 

# Infinite history.
HISTSIZE= HISTFILESIZE=


# prompt customization


# Load shortcut aliases
[ -f "$HOME/.config/shortcutrc" ] && source "$HOME/.config/shortcutrc" 

# Load aliases
[ -f "$HOME/.config/aliasrc" ] && source "$HOME/.config/aliasrc"
