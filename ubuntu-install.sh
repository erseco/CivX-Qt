#!/bin/bash

sudo curl -L -o /usr/local/bin/EXOS-Qt-v2.0.0.1-x86_64.AppImage https://github.com/exoeconomy/exos-qt/releases/download/v2.0.0.1/EXOS-Qt-v2.0.0.1-x86_64.AppImage
sudo chmod +x /usr/local/bin/EXOS-Qt-v2.0.0.1-x86_64.AppImage

sudo mkdir -p /usr/share/exos/
sudo curl -L -o /usr/share/exos/exos80.png https://github.com/exoeconomy/EXOS-Qt/raw/master/src/qt/res/icons/exos80.png

sudo ln -s /usr/local/bin/EXOS-Qt-v2.0.0.1-x86_64.AppImage /usr/local/bin/exos-qt

echo "Ejecuting exos-qt to generate dir..."
nohup exos-qt &

echo "Waiting 4 secs..."
sleep 4

echo "Killing exos-qt"
pkill -9 exos-qt

echo "Waiting 4 secs..."
sleep 4

if [ -e ~/.civx/wallet.dat ]; then
	echo "Copying wallet.dat to ~/.exos/wallet.dat"
    cp ~/.civx/wallet.dat ~/.exos/wallet.dat;
fi

sudo tee -a /usr/share/applications/exos.desktop > /dev/null << EOL
[Desktop Entry]
Name=Exos
Comment=wallet
Exec=/usr/local/bin/exos-qt
Icon=/usr/share/exos/exos80.png
Terminal=false
Type=Application  
Name[en_US]=exos.desktop
EOL