#!/bin/bash 

ACTION=$1
FILE_URL=$2
LANGUAGE=$3
PATH_SERVICE_MENU="`kde4-config --localprefix`share/kde4/services/"


notify(){
	notify-send -i "$PATH_SERVICE_MENU"yandex/logo.png "$Title" "$1"
}

get_link(){
	is_path_matches_yadisk
	if [[ $? = 0 ]]; then
		publish
		exit
	fi

	is_exists "$YANDEX_DISK_HOME/${FILE_URL##*/}"
	if [[ $? = 0 ]]; then
		FILE_URL=$(get_newname)
		publish 
	elif [[ $? = 1 ]]; then
		rm -f "$YANDEX_DISK_HOME/${FILE_URL##*/}"
		publish 
	fi
	exit
}

publish(){
	pub=`yandex-disk publish "$FILE_URL"`
	if [[ $? = 0 ]]; then
		echo $pub | xsel -i -b 
		notify "$Available_link"
	else
		notify "$Error"
	fi	
}

is_exists(){
    	if [ -f "$1" ]; then
		kdialog --warningyesnocancel "$File_replace" --yes-label "Оставить оба"  --no-label "Заменить"
   	elif [ -d "$1" ]; then
		kdialog --sorry "$Folder_exists" 
		exit
	fi
}

get_newname(){
	name="${FILE_URL##*/}"
	ext=""

	if [[ "$name" =~ (\..+)$ ]]; then
	    ext="${BASH_REMATCH[1]}"
	    name="${name%\.*}"

	    if [[ "$name" =~ ^(.*)[[:space:]]\([[:digit:]]+\)$ ]]; then
	        name="${BASH_REMATCH[1]}"
	    fi
	fi    

	c=1
	while [ -f "$YANDEX_DISK_HOME/$name ($c)$ext" ]
	do
	    c=$[$c+1]
	done

	echo "$YANDEX_DISK_HOME/$name ($c)$ext"           
}

copy() {
    is_exists "$1"
    if [ $? = 1 ]; then
		cp -f "$FILE_URL" "$1"
		if [[ $? = 0 ]]; then
			notify "$Success_save"
		else
			notify "$Error_save"			
		fi
    fi
}

is_path_matches_yadisk(){
	echo $FILE_URL | grep "$YANDEX_DISK_HOME"
}

save(){
	is_path_matches_yadisk
	if [[ $? = 0 ]]; then
		notify "$File_exists"
		exit;
	fi

	path=`kdialog --getsavefilename  "$YANDEX_DISK_HOME/${FILE_URL##*/}" --title "$Choose_dir"`
	if [[ $? = 0 ]]; then
		copy "$path"
	fi
}

is_run_daemon(){
	pgrep yandex-disk
}


#Translations
load_ru(){
	Title="Яндекс.Диск"
	Error="Произошла ошибка"
	Error_save="Ошибка при сохранении"
	Success_save="Файл <b>${FILE_URL##*/}</b> успешно сохранен"
	Choose_dir="Выберите директорию"
	File_replace="Файл с именем <b>${FILE_URL##*/}</b> уже существует в директории $title<br/><br/>Заменить?"
	Available_link="Публичная ссылка на файл <b>${FILE_URL##*/}</b> скопирована в буфер"
	File_exists="Этот файл уже и так находится в вашей папке $title"
	Daemon="Ошибка: демон не запущен"
	Folder_exists="Не удалось скопировать ссылку. <b>${FILE_URL##*/}</b> уже существует в папке $title.
		<br/><br/>Чтобы получить ссылку на папку с таким же именем, необходимо переименовать одну из них. "
}

load_en(){
	Title="Yandex.Disk"
	Error="Error occurred"
	Error_save="Error saving"
	Success_save="File <b>${FILE_URL##*/}</b> successfully saved"
	Choose_dir="Choose directory"
	File_replace="A file named <b>${FILE_URL##*/}</b> already exists in your $title folder."
	File_replace2="<br/><br/>Would you like to replace it and copy a public link to our clipboard?"
	Available_link="Public link to <b>${FILE_URL##*/}</b> copied to clipboard"
	File_exists="File is already in you $title folder"
	Daemon="Error: daemon not running"
	Folder_exists="Не удалось скопировать ссылку. <b>${FILE_URL##*/}</b> уже существует в папке $title.
		<br/><br/>Чтобы получить ссылку на папку с таким же именем, необходимо переименовать одну из них. "
}

if [[ $LANGUAGE != "" ]]; then
	load_$LANGUAGE
else
	load_en
fi

is_run_daemon
if [[ $? = 1 ]]; then
	notify "$daemon"
	exit
fi

YANDEX_DISK_HOME=`yandex-disk status | sed -n 2p | cut -f 2 -d "'"`

case "$ACTION" in
	save) save ;;
	get_link) get_link ;;
esac