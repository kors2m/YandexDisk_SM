#!/bin/bash 

ACTION="$1"
FILE_URL="$2"
LANGUAGE="$3"
PATH_SERVICE_MENU=$(kde4-config --localprefix)"share/kde4/services/"

notify(){
	notify-send -i "$PATH_SERVICE_MENU"yandex/logo.png "$Title" "$1"
}

get_link(){
	if is_path_matches_yadisk; then
		publish
		exit
	fi

	# all files placed in the root of Yandex.Disk
	if is_exists_dir "$YANDEX_DISK_HOME/${FILE_URL##*/}"; then
		kdialog --sorry "$Folder_exists" --title "$Title"
		exit
	fi

	if is_exists "$YANDEX_DISK_HOME/${FILE_URL##*/}"; then
		kdialog --warningyesnocancel "$File_replace" --yes-label "$Save_both"  --no-label "$Replace" --title "$Title"
		retval=$?
		if  [ $retval -eq 0 ]; then					# save both files
			newname_url="$(get_newname)"
			cp -f "$FILE_URL" "$newname_url"
			FILE_URL="$newname_url"
		elif [ $retval -eq 1 ]; then					# replace
			publish "--overwrite"
			exit
		elif [ $retval -eq 2 ]; then					# cancel
			exit
		fi
	fi

	publish
	exit
}

publish(){
	pub=$(yandex-disk publish "$FILE_URL" "$1")
	if [ $? = 0 ]; then
		echo "$pub" | xsel -i -b 
		notify "$Available_link"
	else
		notify "$Error"
	fi	
}

is_exists_dir(){
	[ -d "$1" ]
}

is_exists(){
	[ -f "$1" ]
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
	    (( c++ ))
	done

	echo "$YANDEX_DISK_HOME/$name ($c)$ext"           
}

is_path_matches_yadisk(){
	echo "$FILE_URL" | grep "$YANDEX_DISK_HOME"
}

save(){
	if is_path_matches_yadisk; then
		notify "$File_exists"
		exit
	fi

	while true; do
		path=$(kdialog --getsavefilename  "$YANDEX_DISK_HOME/${FILE_URL##*/}" --title "$Choose_dir")
		retval=$?
		if [ $retval = 0 ]; then
			if is_exists "$path"; then
				kdialog --warningyesno "$File_replace" --title "$Title"
				if [ $? = 0 ]; then	# yes
					break
				fi
			else		# the file not exists
				break
			fi
		elif [ $retval = 1 ]; then				# cancel
			exit
		fi
	done

	# coping a file with overwrite
	cp -rf "$FILE_URL" "$path"
	if [ $? = 0 ]; then
		notify "$Success_save"
	else
		notify "$Error_save"
	fi
	exit
}

is_run_daemon(){
	! [ $(pgrep yandex-disk) ]
}

# translations
load_ru(){
	Title="Яндекс.Диск"
	Error="Произошла ошибка"
	Error_save="Ошибка при сохранении"
	Success_save="Файл <b>${FILE_URL##*/}</b> успешно сохранен"
	Choose_dir="Выберите директорию"
	File_replace="Файл с именем <b>${FILE_URL##*/}</b> уже существует в директории $Title."
	Replace="Заменить"
	Save_both="Оставить оба"
	Available_link="Публичная ссылка на файл <b>${FILE_URL##*/}</b> скопирована в буфер"
	File_exists="Этот файл уже находится в вашей папке $Title"
	Daemon="Ошибка: демон не запущен"
	Folder_exists="Не удалось скопировать ссылку. <b>${FILE_URL##*/}</b> уже существует в папке $Title.
		<br/><br/>Чтобы получить ссылку на папку с таким же именем, необходимо переименовать одну из них."
}

load_en(){
	Title="Yandex.Disk"
	Error="Error occurred"
	Error_save="Error saving"
	Success_save="File <b>${FILE_URL##*/}</b> successfully saved"
	Choose_dir="Choose directory"
	File_replace="A file named <b>${FILE_URL##*/}</b> already exists in your $Title folder.
		<br/><br/>Would you like to replace it and copy a public link to our clipboard?"
	Replace="Replace"
	Save_both="Save both"
	Available_link="Public link to <b>${FILE_URL##*/}</b> copied to clipboard"
	File_exists="This file is already in your $Title folder"
	Daemon="Error: daemon not running"
	Folder_exists="Failed to copy the link. <b>${FILE_URL##*/}</b> is already in your $Title folder.
		<br/><br/>To get a link to a folder with the same name, you must rename one of them."
}

# loading localization
if [ "$LANGUAGE" != "" ]; then
	load_"$LANGUAGE"
else
	load_en
fi

if is_run_daemon; then
	notify "$Daemon"
	exit
fi

YANDEX_DISK_HOME=$(yandex-disk status | sed -n 2p | cut -f 2 -d "'")

case "$ACTION" in
	save) save ;;
	get_link) get_link ;;
esac