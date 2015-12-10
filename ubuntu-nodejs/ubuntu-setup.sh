#!/bin/bash
#
# Ubuntu Development Environment Installer
#
# This script will install a development stack.
# DO NOT run this in any environment that contains live settings. This is
# strictly a development setup.


###############################################################################
# Starting off
###############################################################################

# Make sure the setup has not already been run
if [ -f ~/setup_complete ];
then
    echo "ERROR: Setup script has already been run. Exiting."
    exit 1
fi


# Check system memory
if [[ "2000000" -gt $(awk '/MemTotal/{print $2}' /proc/meminfo) ]];
then
    LOW_MEM_PROMPT="WARNING: Ubuntu development environment requires at least 2GB of memory to work properly, continue anyway? [y/n] "
    read -er -n1 -p "$LOW_MEM_PROMPT" response
    if [[ "$response" != "y" ]];
    then
        echo "Quitting."
        exit 1
    fi
fi


###############################################################################
# Configuration Setup
###############################################################################

# Set locale
sudo locale-gen en_US.UTF-8

# Set environment variables
APP_ENV="dev"
APP_ROOT="/var/app"
EXPECTED_USER="ubuntu"
EXPECTED_GROUP="ubuntu"

# Verify Working Directory
if [ ! -d $APP_ROOT ];
then
    echo "ERROR: Expected directory does not exist"
    exit 1
fi

# Setup user global settings
if [ -f ~/.settings ];
then
    rm ~/.settings
fi

touch ~/.settings
cat > ~/.settings << EOL
#!/bin/bash
APP_ROOT=$APP_ROOT
APP_ENV=$APP_ENV
EXPECTED_USER=$EXPECTED_USER
EXPECTED_GROUP=$EXPECTED_GROUP

export APP_ROOT
export APP_ENV
export EXPECTED_USER
export EXPECTED_GROUP
EOL


###############################################################################
# Configure Ubuntu
###############################################################################

# Copy File
# argument1: source file
# argument2: target file
copy_file() {
    if [ ! -z $1 ] && [ ! -z $2 ];
        echo "Attempting to copy: $1 > $2"
    then
        if [ ! -f $1 ];
        then
            echo "ERROR: Could not locate source \"$1\""
            exit 1
        fi

        sudo cp $1 $2
    else
        echo "ERROR: copy_file() requires 2 arguments"
        exit 1
    fi
}

# Make a download directory
if [ ! -d ~/downloads ];
then
    sudo mkdir ~/downloads
fi

set -x
set -e


###############################################################################
# Enable Swap Memory
###############################################################################

cd /
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile       none    swap    sw      0       0" | sudo tee --append /etc/fstab


###############################################################################
# Install Prerequisites
###############################################################################

# Add apt-get repositories
sudo add-apt-repository -y ppa:nginx/stable

# Update apt-get
sudo apt-get -y update

# Install dev tools
sudo apt-get install -y build-essential libjpeg-dev libgcrypt11-dev libssl-dev libncurses5-dev zlib1g-dev libffi-dev ntp

# Install applications
sudo apt-get install git

touch ~/setup_complete
