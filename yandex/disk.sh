#!/bin/bash 

FILE_URL=$2
LANGUAGE=$3
YANDEX_DISK_HOME=`yandex-disk status | sed -n 2p | cut -f 2 -d "'"`
PATH_SERVICE_MENU="`kde4-config --localprefix`share/kde4/services/"


notify(){
	notify-send -i "$PATH_SERVICE_MENU"yandex/logo.png "$title" "$1"
}

get_link(){
	is_file_exists
	if [[ $? = 0 ]]; then
		rm -f "$YANDEX_DISK_HOME"/"${FILE_URL##*/}"
		write
	fi
}

write(){
	msg=`yandex-disk publish $FILE_URL`
	if [[ $? = 0 ]]; then
		echo $msg | xsel -i -b 
		notify "$available_link"
	else
		notify "$error"
	fi	
}

is_file_exists(){
    if [ -f "$YANDEX_DISK_HOME"/"${FILE_URL##*/}"  -o -d "$YANDEX_DISK_HOME"/"${FILE_URL##*/}" ]; then
		kdialog --warningyesno "$file_replace" --title "$title"
    fi	
}

copy() {
    is_file_exists
    if [ $? = 0 ]; then
		cp -rf "$FILE_URL" "$1"
		if [[ $? = 0 ]]; then
			notify "$success_save"
		else
			notify "$error_save"			
		fi
    fi
}

is_path_matches_yadisk(){
	echo $FILE_URL | grep "$YANDEX_DISK_HOME"
	if [[ $? = 0 ]]; then
		notify "$file_exists"
		exit;
	fi
}

check_path(){
	is_path_matches_yadisk
}

save(){
	check_path
	if [[ $? = 0 ]]; then
		path=`kdialog --getsavefilename  $YANDEX_DISK_HOME"/"${FILE_URL##*/} --title "$choose_dir"`
		if [[ $? = 0 ]]; then
			copy $path
		fi
	fi
}

is_run_daemon(){
	pgrep yandex-disk
}



#Translations
load_ru(){
	title="Яндекс.Диск"
	error="Произошла ошибка"
	error_save="Ошибка при сохранении"
	success_save="Файл <b>${FILE_URL##*/}</b> успешно сохранен"
	choose_dir="Выберите директорию"
	file_replace="Файл с именем <b>${FILE_URL##*/}</b> уже существует в директории $title<br/><br/>Заменить?"
	available_link="Публичная ссылка на файл <b>${FILE_URL##*/}</b> скопирована в буфер"
	file_exists="Этот файл уже и так находится в директории $title"
	daemon="Ошибка: демон не запущен"
}

load_en(){
	title="Yandex.Disk"
	error="Missing error"
	error_save="Error saving"
	success_save="File <b>${FILE_URL##*/}</b> successfully saved"
	choose_dir="Choose directory"
	file_replace="A file named <b>${FILE_URL##*/}</b> already exists in your $title folder.<br/><br/>
			Would you like to replace it and copy a public link to our clipboard?"
	available_link="Public link to <b>${FILE_URL##*/}</b> copied to clipboard"
	file_exists="File is already in you $title folder"
	daemon="Daemon not running"
}


is_run_daemon
if [[ $? != 0 ]]; then
	notify $daemon
	exit 1;
fi

case "$LANGUAGE" in
	ru ) load_ru ;;
	*) load_en ;;
esac

case "$1" in
    	save) save ;;
	get_link) get_link ;;
esac