#!/bin/sh

STATUS_SUCCESS=0
STATUS_ERROR=1

log(){
    echo " * $1"
}

is_cmd_exists(){
    command -v "$1" > /dev/null 2>&1
    return $?
}

require_command () {
    is_cmd_exists $1
    cmd_exists=$?
    if [ ! "$cmd_exists" -eq "$STATUS_SUCCESS" ] ;
    then
        log "the command '$1' not exists - please install manualy "
        log " eg. # apt install $1"
        log " then reran the script"
        exit 1
    else
        return $STATUS_SUCCESS
    fi
}


#
# Just senety test
# 
is_cmd_exists "command-should-not-be-exists-Random-123231356677"
dummy_non_exists_test=$?
if [ "$dummy_non_exists_test" -eq "0" ] ;
then
    log "Non exists command should not be there is some error"
    exit 1
fi


#
# Check requried
#
require_command "sudo"



#
# Check sudo
#
log "In order to install via 'apt install' command we should have sudo"
log "you can cancel the installation via CTRL-C keys"
sudo ls > /dev/null
success_sudo=$?
if [ ! "$success_sudo" -eq "0" ] ;
then
    echo "Without sudo we cannot install, bye-bye."
    exit 20
fi

exit 1


sudo apt install -y git wget ansible neovim neovim-qt \
zsh zsh-autosuggetions zsh-syntax-highlighting \
fzf ranger 

#should have
# GIT
# Ansible
# ansible-playbook  --ask-become-pass site.yml
#
#
# Todo:
# Dropbox
# vim
# nix
# snap
# fzf
# ranger
# kitty