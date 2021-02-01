#!/bin/sh

log(){
    echo " * $1"
}

is_cmd_exists(){
    command -v "$1" > /dev/null 2>&1
    return $?
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

is_cmd_exists "sudo"
exists_sudo=$?
if [ ! "$exists_sudo" -eq "0" ] ;
then
    log "sudo dose not exists - please install manualy"
    exit 1
else
    echo "Will asking sudo for apt installs"
    sudo ls > /dev/null
    success_sudo=$?
    if [ ! "$success_sudo" -eq "0" ] ;
    then
        echo "Without sudo we cannot install, bye-bye."
        exit 20
    fi
fi
exit 1


is_cmd_exists "git" 
git_exists=$?
if [ "$git_exists" -eq "0" ] ;
then
    echo "Git exitst"
else
 #   sudo apt install git
 echo "X"
fi
exit 0
#should have
# GIT
# Ansible

ansible-playbook  --ask-become-pass site.yml
