Яндекс.Диск ServiceMenu 
-----------------------

Servicemenu, который позволяет получить быстрый доступ к сервису Яндекс.Диск

**Возможности:**

- Скопировать публичную ссылку на файл/папку в буфер обмена
- Сохранить файл в вашу папку Яндекс.Диск

**Зависимости:**

- Консольный клиент для Linux - http://help.yandex.ru/disk/cli-clients.xml
<br/>Для ArchLinux скачиваем с aur https://aur.archlinux.org/packages/yandex-disk/
- `libnotify` 
- `kdialog`
- `xsel`

------------------------

Yandex.Disk ServiceMenu
-----------------------
A servicemenu which allows easy access to Yandex.Disk features.

**Features:**

- Copy Public URL to clipboard
- Copy file to your Yandex.Disk folder

**Installation:**

- Run installation script - ./install-it.sh

**Dependencies:**

- Console client for Linux - http://help.yandex.com/disk/cli-clients.xml
<br/>For arch linux download from aur - https://aur.archlinux.org/packages/yandex-disk/
- `libnotify`
- `kdialog`
- `xsel`

----------------------------

### Add autostart yandex-disk daemon to systemd

Create unit file `/etc/systemd/system/yadisk@.service` and edit:

```
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
```

Enable a unit to be started on bootup:
`# systemctl enable yadisk@USERNAME.service `