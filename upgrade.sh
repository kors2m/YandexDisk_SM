#!/bin/bash 
 
path = "`kde4-config --localprefix`/share/kde4/services/"
rm "$path"yadisk.desktop
rm -r "$path"yandex
exec ./install-it.sh