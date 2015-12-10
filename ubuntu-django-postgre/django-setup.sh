#!/bin/bash
#
# Django Development Environment Installer
#
# This script will install everything required for a Django/PostgreSQL server.
# DO NOT run this in any environment that contains live settings. This is
# strictly a development setup.


###############################################################################
# Starting off
###############################################################################

# Make sure the setup has not already been run
if [ -f ~/django_complete ];
then
    echo "ERROR: Django script has already been run. Exiting."
    exit 1
fi


###############################################################################
# Configuration Setup
###############################################################################

# Verify environment flag
if [ "$1" = "vagrant" ];
then
    APP_ENV="dev"
    APP_ROOT="/vagrant"
    EXPECTED_USER="vagrant"
    EXPECTED_GROUP="vagrant"
fi


###############################################################################
# Install prerequisites
###############################################################################

# Install applications
sudo apt-get install -y nginx postgresql-common postgresql-contrib-9.4 postgresql-server-dev-9.4

# Install Python 2.7
cd ~/downloads
sudo wget https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tgz
sudo tar -xvf Python-2.7.9.tgz
cd Python-2.7.9
sudo ./configure --prefix=/usr/local
sudo make
sudo make altinstall

# Install Python Setup Tools
cd ~/downloads
sudo wget --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-11.3.tar.gz
sudo tar -xvf setuptools-11.3.tar.gz
cd setuptools-11.3
sudo python2.7 setup.py install

# Install PIP
cd ~/downloads
sudo curl https://raw.githubusercontent.com/pypa/pip/master/contrib/get-pip.py | sudo python2.7 -

# Install virtualenv
sudo pip2.7 install virtualenv

# Install uWSGI
sudo pip2.7 install uwsgi

###############################################################################
# Configure web server
###############################################################################

# Make uwsgi log directory
if [ ! -d /var/log/uwsgi ];
then
    sudo mkdir /var/log/uwsgi
    sudo chown -R $EXPECTED_USER:$EXPECTED_GROUP /var/log/uwsgi
fi

# Make uwsgi run directory
if [ ! -d /var/run/uwsgi ];
then
    sudo mkdir /var/run/uwsgi
    sudo chown -R $EXPECTED_USER:$EXPECTED_GROUP /var/run/uwsgi
fi

# Make uwsgi etc directory
if [ ! -d /etc/uwsgi ];
then
    sudo mkdir /etc/uwsgi
    sudo chown -R $EXPECTED_USER:$EXPECTED_GROUP /etc/uwsgi
fi

# Remove default nginx site conf
if [ -f /etc/nginx/sites-enabled/default ];
then
    sudo rm /etc/nginx/sites-enabled/default
fi

# Link App nginx conf
if [ ! -f /etc/nginx/sites-enabled/app_nginx.conf ];
then
    if [ "$APP_ENV" == "dev" ];
    then
        sudo ln -s $APP_ROOT/resources/setup/app.conf /etc/nginx/sites-enabled/app.conf
    fi
fi

# Link uWSGI ini file
if [ ! -f /etc/uwsgi/app.ini ];
then
    if [ "$APP_ENV" == "dev" ];
    then
        sudo ln -s $APP_ROOT/resources/setup/app.ini /etc/uwsgi/app.ini
    fi
fi

# time sync (ntp)

sudo cp $APP_ROOT/resources/server/ntp.conf /etc/ntp.conf
sudo service ntp restart

###############################################################################
# Configure database
###############################################################################

# Start PostgreSQL
sudo service postgresql start

# Overwrite /etc/postgresql/9.4/main/pg_hba.conf
copy_file $APP_ROOT/resources/setup/pg_hba.conf /etc/postgresql/9.4/main/pg_hba.conf

# Restart PostgreSQL
sudo service postgresql restart

# Reset database password
psql -U postgres -h localhost << EOF
    ALTER USER postgres WITH PASSWORD 'password';
EOF

# Create database
createdb -U postgres -h localhost django


###############################################################################
# Configure virtualenv
###############################################################################

# Setup virtualenv
cd ~/
virtualenv -p /usr/local/bin/python2.7 env
sudo chown -R $EXPECTED_USER:$EXPECTED_GROUP ~/env/
sudo chown -R $EXPECTED_USER:$EXPECTED_GROUP ~/.cache/pip
source ~/env/bin/activate


touch ~/django_complete
