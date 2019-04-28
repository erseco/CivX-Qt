#!/bin/bash

echo "Installig dependencies..."
sudo apt-get update
sudo apt-get install -y qt5-default
sudo apt-get install -y libboost-program-options1.65.1
# sudo apt-get install -y libboost-program-options1.58.0
sudo apt-get install -y libdb5.3++
sudo apt-get install -y libminiupnpc10

echo "Downloading release..."
wget -qO- https://github.com/erseco/EXOS-Qt/releases/download/ubuntu-installation/exos-qt.tar.gz | sudo tar xvz -C /tmp/

echo "Create directory for icons"
sudo mkdir -p /usr/share/exos

echo "Copying binary program..."
sudo mv /tmp/exos-qt /usr/local/bin/exos-qt
sudo chown root:root /usr/local/bin/exos-qt
sudo chmod +x /usr/local/bin/exos-qt

echo "Copying desktop file..."
sudo mv /tmp/exos.desktop /usr/share/applications/exos.desktop
sudo chown root:root /usr/share/applications/exos.desktop

echo "Copying logo..."
sudo mv /tmp/exos80.png /usr/share/exos/exos80.png
sudo chown root:root /usr/share/exos/exos80.png

echo "Ejecuting exos-qt to generate dir..."
nohup exos-qt &

echo "Waiting 4 secs..."
sleep 4

echo "Killing exos-qt"
pkill -9 exos-qt

echo "Copying wallet.dat to ~/.exos/wallet.dat"
if [ -e ~/.civx/wallet.dat ]; then
    cp ~/.civx/wallet.dat ~/.exos/wallet.dat;
fi
