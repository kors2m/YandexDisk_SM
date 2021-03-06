#!/bin/bash 

echo "Install Service Menu for Yandex.Disk"
mkdir -p "`kde4-config --localprefix`/share/kde4/services/yandex"
install -m 755 yandex/disk.sh "`kde4-config --localprefix`/share/kde4/services/yandex/"
install -m 644 yandex/logo.png "`kde4-config --localprefix`/share/kde4/services/yandex/"
install -m 644 yadisk_files.desktop "`kde4-config --localprefix`/share/kde4/services/"
install -m 644 yadisk_directories.desktop "`kde4-config --localprefix`/share/kde4/services/"
echo "Done"