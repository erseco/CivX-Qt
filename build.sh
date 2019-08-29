#!/bin/bash

set -e
date

#################################################################
#                  Build Rutanio from source                    #
#################################################################

build(){
        NPROC=$(nproc)
        echo "nproc: $NPROC"

        cd src
        sudo make -j$NPROC -f makefile.unix
        sudo cp rutaniod /usr/local/bin/rutaniod

        echo ""
        echo "Build completed ... copied src/rutaniod to /usr/bin/rutaniod"
        echo "Run the application by typing 'rutaniod' at the command prompt"
        exit 0
}

init(){
        config=~/.rutanio/rutanio.conf
        if [ ! -e "$config" ]
        then
           mkdir -p ~/.rutanio && touch $_/rutanio.conf
           user=$(gpw 1 7)
           password=$(pwgen 13 1)
           echo "daemon=1" >> $config
           echo "server=1" >> $config
           echo "rpcuser=$user" >> $config
           echo "rpcpassword=$password" >> $config
           echo "" >> $config
           echo "logtimestamps=1" >> $config
        fi

        file=/etc/init.d/rutanio
        if [ ! -e "$file" ]
        then
           printf '%s\n%s\n' '#!/bin/sh' 'sudo rutaniod' | sudo tee /etc/init.d/rutanio
           sudo chmod +x /etc/init.d/rutanio
           sudo update-rc.d rutanio defaults
        fi
}

version() { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

#################################################################
#   Update Ubuntu and install prerequisites for running Rutanio #
#################################################################
sudo apt-get update


#################################################################
#    Install all necessary packages for building Rutanio        #
#################################################################
sudo apt-get install -y qt5-default qt5-qmake qtbase5-dev-tools qttools5-dev-tools \
     build-essential libboost-all-dev libssl-dev libdb++-dev libminiupnpc-dev \
     software-properties-common libqrencode-dev gpw pwgen

if [ $(version `lsb_release -rs`) -gt $(version "16.04") ]
then
     sudo apt-get install -y libssl1.0-dev
fi

sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev


init
build
