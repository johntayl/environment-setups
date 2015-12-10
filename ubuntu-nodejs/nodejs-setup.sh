#!/bin/bash
#
# NodeJS Development Environment Installer
#
# This script will install everything required for a NodeJS application.
# DO NOT run this in any environment that contains live settings. This is
# strictly a development setup.


###############################################################################
# Starting off
###############################################################################

# Make sure the setup has not already been run
if [ -f ~/nodejs_complete ];
then
    echo "ERROR: NodeJS script has already been run. Exiting."
    exit 1
fi


###############################################################################
# Configuration Setup
###############################################################################

# Verify environment flag
APP_ENV="dev"
APP_ROOT="/var/app"
EXPECTED_USER="ubuntu"
EXPECTED_GROUP="ubuntu"


###############################################################################
# Install prerequisites
###############################################################################

# Install applications
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo apt-get install -y nodejs

sudo npm install -f gulp bower

touch ~/nodejs_complete
