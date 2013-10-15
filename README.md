Яндекс.Диск ServiceMenu 
-------------------------
Servicemenu, который позволяет получить быстрый доступ к сервису Яндекс.Диск

Возможности:
* Делиться ссылкой на файл


Yandex.Disk ServiceMenu
-----------------------
A servicemenu which allows easy access to Yandex.Disk features.

Features:
* Copy Public URL to clipboard
* Copy file to your Yandex.Disk folder

Installation:
* Run installation script - ./install-it.sh

Dependencies:
* Console client for Linux - http://help.yandex.com/disk/cli-clients.xml
  For arch linux download from aur - https://aur.archlinux.org/packages/yandex-disk/
* notify-send
* kdialog
* xsel

Tip:
* Add autostart yandex-disk daemon to systemd
Create /etc/systemd/system/yadisk@.service and edit:

[Unit]
Description=Yandex.Disk
Requires=network.target
After=network.target

[Service]
Type=forking
User=%i
ExecStart=/usr/bin/yandex-disk start --auth=%h/.config/yandex-disk/passwd
RestartSec=1min
Restart=on-failure

[Install]
WantedBy=multi-user.target
