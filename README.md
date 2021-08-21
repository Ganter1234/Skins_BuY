![MySenPai](https://pa1.narvii.com/6862/6098ddd3be86e6253a9a2174796bf3fba9c06867r1-500-260_hq.gif)


## Требование:

# GameServer:
- [Sourcemode 1.8 - Sourcemode 1.11](https://www.sourcemod.net/downloads.php?branch=stable)

# Web-Хост:
- PHP 7.0 - PHP 7.2

***


# Установка
- #### Распокавать `.rar` или `.zip ` к себе на `WEB-Хост` соблюдая иерархию католога.
- #### Открыть папку `WEB-HOST`, перейти `skins_buy\settings`, открыть файл `install.sql`, все содержимое скапировать в `Базу данных` (где лежить сам движок GameCMS)
- #### Настроить модуль в `АЦ` - Админ Центр.

***

#### В папке `GAMESERVER` все файлы залить к себе на сервер соблюдая иерархию католога

#### В папке `configs/skins_buy/skins_downloadslist.txt` вписать модели для скачки, и естествено эти модели должы быть загружены на ваш сервер.

#### В папке `addons/sourcemod/configs/database.cfg` вписать запрос
```c
	"skins_buy"
	{
	  "driver"     "mysql" // Не трогать
	  "host"       "host"	// Ваш IP/Домен Базы данных
	  "database"   "database" // Название Базы данных
	  "user"       "login"	// Логин пользователя Базы данных
	  "pass"       "password" // Пароль от пользователя Базы данных
	  "port"       "3306" // Не трогать
	} 
```
 __ПОДДЕРЖКА СТРОГО В [VK](VK.COM/CYXARUK1337)__

***
__Лицензию в .sp просьба не трогать__

__P.S Просьба оставить коментарий на в профиле [HLMOD](https://hlmod.ru/members/pr-e-fix.110719/)__
***
![MySenPai](https://pa1.narvii.com/8008/5ff3a5128bf7a511810414eecce8018a7b0a52cer1-500-282_hq.gif)
