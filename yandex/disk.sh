#!/bin/bash 

fileurl=$2
YANDEX_DISK_HOME=`yandex-disk status | sed -n 2p | cut -f 2 -d "'"`
PATH_SERVICE_MENU="`kde4-config --localprefix`share/kde4/services/"
TITLE="Яндекс.Диск"

notify(){
	notify-send -i "$PATH_SERVICE_MENU"yandex/logo.png "$TITLE" "$1"
}

get_link(){
	is_file_exists
	if [[ $? = 0 ]]; then
		rm -f "$YANDEX_DISK_HOME"/"${fileurl##*/}"
		write
	fi
}

write(){
	msg=`yandex-disk publish $fileurl`
	if [[ $? = 0 ]]; then
		echo $msg | xsel -i -b 
		notify "Публичная ссылка на файл <b>"${fileurl##*/}"</b> скопирована в буфер"
	else
		notify "Произошла ошибка"
	fi	
}

is_file_exists(){
    if [ -f "$YANDEX_DISK_HOME"/"${fileurl##*/}"  -o -d "$YANDEX_DISK_HOME"/"${fileurl##*/}" ]; then
		kdialog --warningyesno "Файл с именем <b>"${fileurl##*/}"</b> уже существует в дириктории Я.Диск\n\nЗаменить?" --title "Яндекс.Диск"
    fi	
}

copy() {
    is_file_exists
    if [ $? = 0 ]; then
		cp -rf "$fileurl" "$1"
		if [[ $? = 0 ]]; then
			notify "Файл <b>"${fileurl##*/}"</b> успешно сохранен"
		else
			notify "Ошибка при сохранении"			
		fi
    fi
}

is_path_matches_yadisk(){
	echo $fileurl | grep "$YANDEX_DISK_HOME"
	if [[ $? = 0 ]]; then
		notify "Этот файл уже и так находится в директории Я.Диск"
		exit 1;
	fi
}

check_path(){
	is_path_matches_yadisk
}

save(){
	check_path
	if [[ $? = 0 ]]; then
		path=`kdialog --getsavefilename  $YANDEX_DISK_HOME"/"${fileurl##*/} --title "Выбирите директорию"`
		if [[ $? = 0 ]]; then
			copy $path
		fi
	fi
}

is_run_daemon(){
	pgrep yandex-disk
}

is_run_daemon
if [[ $? = 0 ]]; then
	case "$1" in
	    	save) save ;;
		get_link) get_link ;;
	esac
else
	notify "Ошибка: демон не запущен"
fi