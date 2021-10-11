# __Модуль для GameCMS__

![MySenPai](https://pa1.narvii.com/6862/6098ddd3be86e6253a9a2174796bf3fba9c06867r1-500-260_hq.gif)

## Поддерживающие игры CS:S(steam) CSS(no-steam) CS:GO

# F.A.Q
 ## __Что делает данный модуль?__

- ### Данный модуль позволяет вам купить скин на сайте, так же купленный скин будет выдан в игру (по типу персонального скина :D )  Данный модуль работает GameCMS UNI и AWS Code
# Общие вопросы
- ### Данный модуль находится в `beta` версии, возможны баги,ошибки,недочеты, по всем вопросам писать на github.

# U.P.D
- ### Планируется добавить меню в самой игре, чтобы можно было выберать между купленными скинами на сайте, прямо в игре.
- ### Планируется добавить выдачу скина на N время.
- ### Планируется добавить статистику купленных скинов (Какой игрок купил тот или иной скин)
- ### Планируется добавит выкл/вкл скин за Т, за кт.


***
# Требование:

## GameServer:
- [Sourcemode 1.8 - Sourcemode 1.11](https://www.sourcemod.net/downloads.php?branch=stable)

## Web-Хост:
- PHP 7.0 - PHP 7.2

***

# Установка
- #### Распокавать `.rar` или `.zip ` к себе на `WEB-Хост` соблюдая иерархию католога.
- #### Открыть папку `WEB-HOST`, перейти `skins_buy\settings`, открыть файл `install.sql`, все содержимое скапировать в `Базу данных` (где лежить сам движок GameCMS)
- #### Настроить модуль в `АЦ` - Админ Центр.

***

#### В папке `GAMESERVER` все файлы залить к себе на сервер соблюдая иерархию католога

#### В папке `configs/skins_buy/skins_downloadslist.txt` вписать модели для скачки, и естествено эти модели должы быть загружены на ваш сервер.

#### В папке `addons/sourcemod/configs/database.cfg` вписать подключение к базе сайта (база данных именно сайта ваша `GameCMS`)
```c
	"skins_buy"
	{
	  "driver"     "mysql" // Не трогать
	  "host"       "host"	// Ваш IP/Домен Базы данных
	  "database"   "database" // Название Базы данных
	  "user"       "login"	// Логин пользователя Базы данных
	  "pass"       "password" // Пароль от пользователя Базы данных
	  "port"       "3306" // Не трогать
      // подключаться нужно к базе сайта где стоит ваш движок
	} 
```
***
# Структура файлов/католога и описание
- ### __`skins_buy/GAMESERVER/addons/sourcemod/configs/skins_buy/skins_downloadslist.txt` - Путь для скачки моделей на сервер (должно быть на вашем игровом сервере)__  
- ### __`skins_buy/GAMESERVER/addons/sourcemod/plugins/skins_buy.smx` - Исполняемый файл `плагни` для игрового сервера (должно быть на вашем игровом сервере)__  

- ### __`skins_buy/WEB-HOST/skins_buy/ajax/` - Папка которая Обязана быть на вашем Веб хостинге (должно быть на вашем wed-host)__  
- ### __`skins_buy/WEB-HOST/skins_buy/base/` - Папка которая Обязана быть на вашем Веб хостинге (должно быть на вашем wed-host)__  
- ### __`skins_buy/WEB-HOST/skins_buy/settings/install.sql` - SQL запрос который должен быть введен на вашем сайте в бд вашего движка, для отображение и создание нужных модулю таблиц (должно быть на вашем wed-host)__ 
- ### __`skins_buy/WEB-HOST/skins_buy/templates/` - Папка которая Обязана быть на вашем Веб хостинге, шаблоны для сайта, можно залить для своего шаблона (должно быть на вашем wed-host)__  
- ### __`skins_buy/WEB-HOST/skins_buy/uploads/` - Папка которая Обязана быть на вашем Веб хостинге, в папке находится ваше изабражение товара (должно быть на вашем wed-host)__  

***


 __ПОДДЕРЖКА СТРОГО В [VK](VK.COM/CYXARUK1337)__
__Поддержать денюшкойй [QIWI](https://qiwi.com/n/PREFIX) 

***
__Лицензию в .sp просьба не трогать__

__P.S Просьба оставить коментарий на в профиле [HLMOD](https://hlmod.ru/members/pr-e-fix.110719/)__
***
![MySenPai](https://pa1.narvii.com/8008/5ff3a5128bf7a511810414eecce8018a7b0a52cer1-500-282_hq.gif)
