#!/bin/sh

GIT_FROM_URL="https://github.com/alefbt/DevEnv-Setup.git"
GIT_BRANCH="main"

C_USERNAME=$(whoami)
timestamp=$(date +%s)
C_ts=$(date +"%Y-%m-%d_%H-%M-%S")

COMMENT_STAMP="Generated v$timestamp ($C_ts)" 
C_TRUE=0
C_FALSE=10
STATUS_SUCCESS="$C_TRUE"
STATUS_ERROR="$C_FALSE"

TMP_APT_SOURCE_LIST="/tmp/new-source-list.$timestamp"
TMP_ENV_PATH="$HOME/tmp/_create-env.$timestamp"

#
# Functions
#
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


promptYesNo(){
    while true; do
        read -p "$1 [Y/N] " yn
        case $yn in
            [Yy]* ) return $C_TRUE; break;;
            [Nn]* ) return $C_FALSE;;
            * ) echo "Please answer yes or no and Enter [Y/y/N/n]";;
        esac
    done
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
# SODO check
#
if groups $C_USERNAME | grep -q '\bsudo\b'; then
    echo "Current user in sudo group"
else
    log "In order to install via 'apt install' command we should have sudo"
    log "you can cancel the installation via CTRL-C keys"
    log "Adding to current user to sudo, need root password"
    su - -c "usermod -aG sudo $C_USERNAME"
    newgrp sudo
fi

#
# Test sudo 
#
log "Testing sudo | might ask $C_USERNAME password"
sudo ls > /dev/null
HAS_SUDO=$?
if [ "$HAS_SUDO" -eq "0" ] ; then
    log "All right continueing..."
else
    log "Cannot continue without sudo. Aborting"
    exit 1
fi


#
# Update apt source.list
#
. /etc/os-release
promptYesNo "Update apt sources ?"
P_update_apt=$?
if [ "$P_update_apt" -eq "$C_TRUE" ] ; then
	echo "Backup /etc/apt/source.list"
	sudo cp /etc/apt/sources.list /etc/apt/sources.list.orig.$timestamp
    UPGRADE_CODENAME="$VERSION_CODENAME"
    UPGRADE_CODENAME="testing"
	cat <<EOT > $TMP_APT_SOURCE_LIST
#
# $COMMENT_STAMP
#
deb http://deb.debian.org/debian $UPGRADE_CODENAME main contrib non-free
deb-src http://deb.debian.org/debian $UPGRADE_CODENAME main contrib non-free

deb http://deb.debian.org/debian-security/ $UPGRADE_CODENAME/updates main contrib non-free
deb-src http://deb.debian.org/debian-security/ $UPGRADE_CODENAME/updates main contrib non-free

deb http://deb.debian.org/debian $UPGRADE_CODENAME-updates main contrib non-free
deb-src http://deb.debian.org/debian $UPGRADE_CODENAME-updates main contrib non-free
EOT

	sudo mv $TMP_APT_SOURCE_LIST /etc/apt/sources.list
	sudo apt update
fi


#
# Install firmware to enable wifi
#
sudo apt install intel-microcode firmware-iwlwifi firmware-linux



## Ask re-enable wifi mode
promptYesNo "Enable wifi mod ?"
P_enable_wifi=$?
if [ "$P_enable_wifi" -eq "$C_TRUE" ] ; then
    echo "Enabling wifi"
    sudo rmmod iwlwifi
    sudo modprobe iwlwifi

    echo "Set the wifi connection"
    read -p "Press enter to continue"
fi

#
# Apt update, upgrade, install essntials
#
sudo bash -c 'apt update -y && apt upgrade -y && apt dist-upgrade -y && apt install -y git curl ansible'

#
# Configure git
#
promptYesNo "Configure git ?"
P_git_conf=$?
if [ "$P_git_conf" -eq "$C_TRUE" ] ; then
	log "For git configuration"
	read -p "Enter your email: " p_email
	read -p "Enter your fullname: " p_fullname
    
    log "The configuration:"
    log "git config --global user.email \"$p_email\""
	log "git config --global user.name \"$p_fullname\""

    promptYesNo "Enable wifi mod ?"
    P_git_conf=$?
    if [ "$P_git_conf" -eq "$C_FALSE" ] ; then
        log "Aborting."
        exit 1
    fi

    git config --global user.email "$p_email"
	git config --global user.name  "$p_fullname"
fi

############ ANSIBLE ###########
#
# Create temp workspace
#
mkdir -p "$TMP_ENV_PATH"
cd "$TMP_ENV_PATH"

git clone --branch "$GIT_BRANCH" "$GIT_FROM_URL" "from-git"
cd "$TMP_ENV_PATH/from-git"

log "Might ask $C_USERNAME password"
ansible-playbook  --ask-become-pass site.yml

#
#
################################



#####
# CLEAN UP
#####
rm -rf "$TMP_ENV_PATH"
rm "$TMP_APT_SOURCE_LIST"

echo "DONE"
