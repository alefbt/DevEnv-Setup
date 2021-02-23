#!/bin/sh

GIT_FROM_URL="https://github.com/alefbt/DevEnv-Setup.git"
GIT_BRANCH="main"

C_USERNAME=$(whoami)
C_USER_HOME="$HOME" #$(eval echo "~")
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

deb http://security.debian.org/debian-security/ $UPGRADE_CODENAME-security main contrib non-free
deb-src http://security.debian.org/debian-security/ $UPGRADE_CODENAME-security main contrib non-free

deb http://deb.debian.org/debian $UPGRADE_CODENAME-updates main contrib non-free
deb-src http://deb.debian.org/debian $UPGRADE_CODENAME-updates main contrib non-free
EOT

	sudo mv $TMP_APT_SOURCE_LIST /etc/apt/sources.list
	sudo apt update
fi


#
# Install firmware to enable wifi
#
sudo apt -y install intel-microcode firmware-iwlwifi firmware-linux


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


#
# Create basic workspace
#
mkdir -p $C_USER_HOME/Projects			 > /dev/null 2>&1 
mkdir -p $C_USER_HOME/tmp			 > /dev/null 2>&1 
mkdir -p $C_USER_HOME/Applications		 > /dev/null 2>&1 
mkdir -p $C_USER_HOME/Data 			> /dev/null 2>&1 
mkdir -p $C_USER_HOME/.config/autostart 	> /dev/null 2>&1 

USER_LOG_DIR="/var/log/users/$C_USERNAME/"
sudo mkdir -p "$USER_LOG_DIR"
sudo chown -R $C_USERNAME "$USER_LOG_DIR"

#
# ssh generate key
#
if [ ! -f ~/.ssh/id_rsa ] ; then
    log "Generate ssh default key"
    ssh-keygen -b 4096 -q -f ~/.ssh/id_rsa -P ""
else
    log "SSH key file exists"
fi




#####################
#
# Create temp workspace
#
log "Create temp workspace"
mkdir -p "$TMP_ENV_PATH"
cd "$TMP_ENV_PATH"


## Ask to install dropbox
if [ ! -d "$C_USER_HOME/.dropbox-dist" ] ; then
    promptYesNo "Install dropbox ?"
    P_install_dropbox=$?
    if [ "$P_install_dropbox" -eq "$C_TRUE" ] ; then
	    wget -O dropbox.tar.gz "https://www.dropbox.com/download?plat=lnx.x86_64" 
	    tar xzf dropbox.tar.gz
	    mv .dropbox-dist "$C_USER_HOME"
    fi
    AUTOSTART_DROPBOX="$C_USER_HOME/.config/autostart/dropbox.desktop"
    if [ ! -f "$AUTOSTART_DROPBOX" ] ; then 
        cat <<EOT > $AUTOSTART_DROPBOX
[Desktop Entry]
Type=Application
Name=dropbox
GenericName=Dropbox deamon
Comment=Sync my files dropbox way to cloud
Icon=utilities-terminal
Exec=$C_USER_HOME/.dropbox-dist/dropboxd > $USER_LOG_DIR/dropbox.log 2>&1
Categories=ConsoleOnly;System
Terminal=false
X-GNOME-Autostart-enabled=true
EOT
	chmod +x $AUTOSTART_DROPBOX
	sudo chmod +x $AUTOSTART_DROPBOX
    fi
fi

# Install zoom
if [ ! -f "/usr/bin/zoom" ] ; then
	promptYesNo "Install zoom ?"
	P_install_zoom=$?
	if [ "$P_install_zoom" -eq "$C_TRUE" ] ; then
		wget "https://zoom.us/client/latest/zoom_amd64.deb" -O zoom_amd64.deb
		sudo apt install libgl1-mesa-glx libegl1-mesa libxcb-xtest0 -y
		sudo dpkg -i zoom_amd64.deb
	fi
fi


if [ ! -d "/nix" ] ; then
  sudo mkdir /nix
  sudo chown $C_USERNAME /nix
  wget "https://nixos.org/nix/install" -O ./nix-install.sh
  sh ./nix-install.sh --no-daemon
  rm ./nix-install.sh
  # add . /home/yehuda/.nix-profile/etc/profile.d/nix.sh
fi


if [ ! -f "$C_USER_HOME/.zshrc" ] ; then
    sudo apt install zsh fonts-powerline
    wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O zsh-omz-install.sh
    sh zsh-omz-install.sh --unattended
    rm zsh-omz-install.sh
    git clone https://github.com/bhilburn/powerlevel9k.git "$C_USER_HOME/.oh-my-zsh/custom/themes/powerlevel9k"
    #wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
    #wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
    #mkdir -p "$C_USER_HOME/.local/share/fonts/"
    #mv PowerlineSymbols.otf "$C_USER_HOME/.local/share/fonts/"
    #fc-cache -vf ~/.local/share/fonts/
    #mv 10-powerline-symbols.conf "$C_USER_HOME/.config/fontconfig/conf.d/"

fi

git clone --branch "$GIT_BRANCH" "$GIT_FROM_URL" "from-git"
cd "$TMP_ENV_PATH/from-git"

# RUN ANSIBLE
log "Might ask $C_USERNAME password"
ansible-playbook  --ask-become-pass site.yml

#
#
################################



#####
# CLEAN UP
#####
rm -rf "$TMP_ENV_PATH"

echo "DONE"
