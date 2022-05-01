/*
*							ИНФОРМАЦИЯ О ПЛАГИНЕ
*	Автор плагина  Pr[E]fix & Ganter1234
*	[VK] https://vk.com/cyxaruk1337
*	[HLMOD] https://hlmod.ru/members/pr-e-fix.110719/
*	[TELEGRAM] https://tlgg.ru/@Prefix20192 
*	[GITHUB] https://github.com/PrefixHLMOD 
*
*	ПРОСЬБА АВТОРА ОСТАВИТЬ ОТЗЫВ НА ЭТИХ РЕСУРСАХ ГДЕ ВЫ СКАЧАЛИ У НЕГО ДАННЫЙ МОДУЛЬ
*	ПРОСЬБА НЕ УДАЛЯТЬ ДАННУЮ ЛИЦЕНЗИЮ В УВАЖЕНИЕ АВТОРА ПЛАГИНА
*	ПЛАГИН РАЗРАБОТАН ДЛЯ ДВИЖКА GAMECMS 
* 	
*	ПОДДЕРЖИВАЕТ ИГРЫ: CSSV34, CSS:OB, CS:GO
*
*	ПОДДЕРЖКА ПЛАГИНА ОСУЩЕСТВЛЯЕТСЯ СТРОГО В ВК ИЛИ НА ФОРУМЕ, ТАК КАК ДАННЫЙ ПЛАГИН МОЖЕТ БЫТЬ И НЕ РАБОЧИМ ДЛЯ ВАШЕЙ ВЕРСИИ ИГРЫ
*/

#include <sdktools>
#include <smlib>
#include <cstrike>
#include <clientprefs>

#define PLUGIN_VERSION "2.0"
#define PLUGIN_NAME "[GAMECMS] Skins Buy"
#define PLUGIN_AUTHOR "Pr[E]fix | vk.com/cyxaruk1337 & Ganter1234"

new bool:b_enabled,
	bool:IsPlayerHasSkins[MAXPLAYERS+1];

new String:s_PlayerModelT[MAXPLAYERS+1][PLATFORM_MAX_PATH],
	String:s_PlayerModelCT[MAXPLAYERS+1][PLATFORM_MAX_PATH],
	String:s_DownListPath[PLATFORM_MAX_PATH];

new Handle:h_Enable,
	Handle:h_DownListPath,
	Handle:g_hDatabase;

bool bSkinDisableT[MAXPLAYERS+1],
     bSkinDisableCT[MAXPLAYERS+1];

new Handle:cookieT;
new Handle:cookieCT;

public Plugin:myinfo = 
{/*
*							ИНФОРМАЦИЯ О ПЛАГИНЕ
*	Автор плагина  Pr[E]fix & Ganter1234
*	[VK] https://vk.com/cyxaruk1337
*	[HLMOD] https://hlmod.ru/members/pr-e-fix.110719/
*	[TELEGRAM] https://tlgg.ru/@Prefix20192 
*	[GITHUB] https://github.com/PrefixHLMOD 
*
*	ПРОСЬБА АВТОРА ОСТАВИТЬ ОТЗЫВ НА ЭТИХ РЕСУРСАХ ГДЕ ВЫ СКАЧАЛИ У НЕГО ДАННЫЙ МОДУЛЬ
*	ПРОСЬБА НЕ УДАЛЯТЬ ДАННУЮ ЛИЦЕНЗИЮ В УВАЖЕНИЕ АВТОРА ПЛАГИНА
*	ПЛАГИН РАЗРАБОТАН ДЛЯ ДВИЖКА GAMECMS 
* 	
*	ПОДДЕРЖИВАЕТ ИГРЫ: CSSV34, CSS:OB, CS:GO
*
*	ПОДДЕРЖКА ПЛАГИНА ОСУЩЕСТВЛЯЕТСЯ СТРОГО В ВК ИЛИ НА ФОРУМЕ, ТАК КАК ДАННЫЙ ПЛАГИН МОЖЕТ БЫТЬ И НЕ РАБОЧИМ ДЛЯ ВАШЕЙ ВЕРСИИ ИГРЫ
*/

#include <sdktools>
#include <smlib>
#include <cstrike>
#include <clientprefs>

#define PLUGIN_VERSION "2.0"
#define PLUGIN_NAME "[GAMECMS] Skins Buy"
#define PLUGIN_AUTHOR "Pr[E]fix | vk.com/cyxaruk1337 & Ganter1234"

new bool:b_enabled,
	bool:IsPlayerHasSkins[MAXPLAYERS+1];

new String:s_PlayerModelT[MAXPLAYERS+1][PLATFORM_MAX_PATH],
	String:s_PlayerModelCT[MAXPLAYERS+1][PLATFORM_MAX_PATH],
	String:s_DownListPath[PLATFORM_MAX_PATH];

new Handle:h_Enable,
	Handle:h_DownListPath,
	Handle:g_hDatabase;

bool bSkinDisableT[MAXPLAYERS+1],
     bSkinDisableCT[MAXPLAYERS+1];

new Handle:cookieT;
new Handle:cookieCT;

public Plugin:myinfo = 
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "Купленный скин из магазина",
	version = PLUGIN_VERSION,
	url = "https://vk.com/cyxaruk1337"
}

public OnPluginStart()
{
	h_Enable = CreateConVar("sm_skins_enable", "1", "Включить или выключить плагин", 0, true, 0.0, true, 1.0);
	h_DownListPath = CreateConVar("sm_skins_buy_downloadslist", "addons/sourcemod/configs/skins_buy/skins_downloadslist.txt", "Путь к списку скачки моделий");
	
	RegAdminCmd("sm_skins_reload", Command_Reload, ADMFLAG_ROOT);

	RegConsoleCmd("sm_skins", Command_SkinMenu);
	
	b_enabled = GetConVarBool(h_Enable);
	
	HookConVarChange(h_Enable, CvarChanges);
	
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_team", Event_PlayerSpawn);
	
	char sError[128];
	g_hDatabase = SQL_Connect("skins_buy", true, sError, sizeof(sError));
	if (sError[0]) SetFailState(sError);

	cookieT = RegClientCookie("SkinsBuy_CMS_T", "", CookieAccess_Private);
	cookieCT = RegClientCookie("SkinsBuy_CMS_CT", "", CookieAccess_Private);
	
	AutoExecConfig(true, "skins_buy");
}

public OnClientCookiesCached(client)
{
	decl String:sValue[8];
	GetClientCookie(client, cookieT, sValue, sizeof(sValue));
	if(sValue[0])
	{
		if(StringToInt(sValue) == 0)
		{
			bSkinDisableT[client] = false;
		}
		else if(StringToInt(sValue) == 1)
		{
			bSkinDisableT[client] = true;
		}
	}
	else
	{
		SetClientCookie(client, cookieT, "0");
		bSkinDisableT[client] = false;
	}

	GetClientCookie(client, cookieCT, sValue, sizeof(sValue));
	if(sValue[0])
	{
		if(StringToInt(sValue) == 0)
		{
			bSkinDisableCT[client] = false;
		}
		else if(StringToInt(sValue) == 1)
		{
			bSkinDisableCT[client] = true;
		}
	}
	else
	{
		SetClientCookie(client, cookieCT, "0");
		bSkinDisableCT[client] = false;
	}
}

public OnConfigsExecuted()
{	
	GetConVarString(h_DownListPath, s_DownListPath, sizeof(s_DownListPath));
	HookConVarChange(h_DownListPath, CvarChanges);
	
	if (FileExists(s_DownListPath))
		File_ReadDownloadList(s_DownListPath);
	else
		LogError("Downloadslist '%s' not found", s_DownListPath);
}

public CvarChanges(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (convar == h_Enable)
	{
		if (bool:StringToInt(newValue) != b_enabled)
		{
			b_enabled = !b_enabled;
			if (b_enabled)
			{
				HookEvent("player_spawn", Event_PlayerSpawn);
				HookEvent("player_team", Event_PlayerSpawn);
			}
			else
			{
				UnhookEvent("player_spawn", Event_PlayerSpawn);
				UnhookEvent("player_team", Event_PlayerSpawn);
			}
		}
	} else
	if (convar == h_DownListPath)
	{
		strcopy(s_DownListPath, sizeof(s_DownListPath), newValue);
		if (FileExists(s_DownListPath))
			File_ReadDownloadList(s_DownListPath);
	}
}

public Action:Command_Reload(client, args)
{
	if (FileExists(s_DownListPath))
		File_ReadDownloadList(s_DownListPath);
	
	return Plugin_Handled;
}

public Action:Command_SkinMenu(client, args)
{
	if (!client || !IsPlayerHasSkins[client] || IsFakeClient(client)) {
		PrintToChat(client, "[SKINS] У вас нету ни одного купленного скина!");
		return Plugin_Handled;
	}
	
	CreateSkinMenu(client);
	return Plugin_Handled;
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (!client || !IsPlayerHasSkins[client] || IsFakeClient(client) || !IsPlayerAlive(client))
		return;
	
	CreateTimer(0.1, SetClientModel, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:SetClientModel(Handle:timer, any:client)
{
	switch (GetClientTeam(client))
	{
		case CS_TEAM_T :
		{
			if (s_PlayerModelT[client][0] && IsModelFile(s_PlayerModelT[client]) && !bSkinDisableT[client])
				SetEntityModel(client, s_PlayerModelT[client]);
		}
		case CS_TEAM_CT :
		{
			if (s_PlayerModelCT[client][0] && IsModelFile(s_PlayerModelCT[client]) && !bSkinDisableCT[client])
				SetEntityModel(client, s_PlayerModelCT[client]);
		}
	}
}

void CreateSkinMenu(int client)
{
	Menu hMenu = new Menu(Handler_hMenu, MenuAction_End|MenuAction_Select);
	SetMenuExitBackButton(hMenu, true);
	hMenu.SetTitle("Skins | Меню");
	hMenu.AddItem("1", "Отключить скин за T");
	hMenu.AddItem("2", "Отключить скин за CT");
	hMenu.AddItem("3", "Меню скинов");
	hMenu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_hMenu(Menu hMenu, MenuAction action, int client, int item)
{
    switch(action)
    {
        case MenuAction_End:
        {
            delete hMenu;
        }
        case MenuAction_Select:
        {
            char info[64];
            hMenu.GetItem(item, info, sizeof info);

            if (StrEqual(info, "1"))
            {
				decl String:sValue[8];
				GetClientCookie(client, cookieT, sValue, sizeof(sValue));
				if(StringToInt(sValue) == 0)
				{
					SetClientCookie(client, cookieT, "1");
					bSkinDisableT[client] = true;
					PrintToChat(client, "[SKINS] Ваш скин за Т отключен!");

					if(client && IsClientInGame(client) && IsPlayerAlive(client))
					{
						CS_UpdateClientModel(client);
					}
				}
				else
				{
					SetClientCookie(client, cookieT, "0");
					bSkinDisableT[client] = false;
					PrintToChat(client, "[SKINS] Ваш скин за Т включен!");
				}
            }
            else if (StrEqual(info, "2"))
	    {
				decl String:sValue[8];
				GetClientCookie(client, cookieT, sValue, sizeof(sValue));
				if(StringToInt(sValue) == 0)
				{
					SetClientCookie(client, cookieCT, "1");
					bSkinDisableCT[client] = true;
					PrintToChat(client, "[SKINS] Ваш скин за CТ отключен!");

					if(client && IsClientInGame(client) && IsPlayerAlive(client))
					{
						CS_UpdateClientModel(client);
					}
				}
				else
				{
					SetClientCookie(client, cookieCT, "0");
					bSkinDisableCT[client] = false;
					PrintToChat(client, "[SKINS] Ваш скин за CТ включен!");
				}
            }
	    else if (StrEqual(info, "3"))
	    {
		CreateSkinListMenu(client);
            }
        }
    }
}

void CreateSkinListMenu(int client)
{
	Menu hMenu = new Menu(Handler_hMenuList, MenuAction_End|MenuAction_Select);
	SetMenuExitBackButton(hMenu, true);
	hMenu.SetTitle("Skins | Меню");
	char steam_id[21];
	GetClientAuthString(client, steam_id, sizeof(steam_id));
	do
	{
		char sQuery[128];
		FormatEx(sQuery, sizeof(sQuery), "SELECT skins_name,team FROM skins_buy_purchases WHERE steamid = '%s'", steam_id);
		Handle hResult = SQL_Query(g_hDatabase, sQuery);
		if (SQL_FetchRow(hResult))
		{
			char s_SkinName[64];
			SQL_FetchString(hResult, 0, s_SkinName, sizeof(s_SkinName));
			int g_iTeam = SQL_FetchInt(hResult, 1);

			if(!s_SkinName[0])
			{
				hMenu.Display(client, MENU_TIME_FOREVER);
				CloseHandle(hResult);
				break;
			}

			char s_Info[80];
			FormatEx(s_Info, sizeof(s_Info), "%s [%i]", s_SkinName, g_iTeam);
			if(g_iTeam == 3)
				ReplaceString(s_Info, 80, "[3]", "[CT]");
			else if(g_iTeam == 2)
				ReplaceString(s_Info, 80, "[2]", "[T]");
			hMenu.AddItem(s_SkinName, s_Info);
		}
		else 
		{
			hMenu.Display(client, MENU_TIME_FOREVER);
			CloseHandle(hResult);
			break;
		}
	}
	while(1 > 0); // Костыльчик вам в ленту :D
}

public int Handler_hMenuList(Menu hMenu, MenuAction action, int client, int item)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete hMenu;
		}
		case MenuAction_Select:
		{
			char info[64];
			hMenu.GetItem(item, info, sizeof info);

			char steam_id[21];
			GetClientAuthString(client, steam_id, sizeof(steam_id));

			char sQuery[128];
			FormatEx(sQuery, sizeof(sQuery), "SELECT modelt,modelct,team FROM skins_buy_purchases WHERE steamid = '%s' AND skins_name = '%s'", steam_id, info);
			Handle hResult = SQL_Query(g_hDatabase, sQuery);
			if (SQL_FetchRow(hResult))
			{
				char s_ModelT[64];
				SQL_FetchString(hResult, 0, s_ModelT, sizeof(s_ModelT));
				char s_ModelCT[64];
				SQL_FetchString(hResult, 1, s_ModelCT, sizeof(s_ModelCT));
				int g_iTeams = SQL_FetchInt(hResult, 2);

				if(g_iTeams == 2)
				{
					FormatEx(s_PlayerModelT[client], sizeof(s_PlayerModelT[]), "%s", s_ModelT);
					if (!IsModelPrecached(s_PlayerModelT[client])) PrecacheModel(s_PlayerModelT[client], true);
					PrintToChat(client, "[SKINS] Вы успешно установили скин: %s (будет доступен в след.раунде)", info);
				}
				if(g_iTeams == 3)
				{
					FormatEx(s_PlayerModelCT[client], sizeof(s_PlayerModelCT[]), "%s", s_ModelCT);
					if (!IsModelPrecached(s_PlayerModelCT[client])) PrecacheModel(s_PlayerModelCT[client], true);
					PrintToChat(client, "[SKINS] Вы успешно установили скин: %s (будет доступен в след.раунде)", info);
				}
			}
		}
	}
}

public OnClientPutInServer(client)
{
	if (!client || IsFakeClient(client))
		return;
	
	IsPlayerHasSkins[client] = false;

	decl String:steam_id[21];

	GetClientAuthString(client, steam_id, sizeof(steam_id));
	
	s_PlayerModelT[client][0] = s_PlayerModelCT[client][0] = 0;

	char sQueryTime[128];
	FormatEx(sQueryTime, sizeof(sQueryTime), "SELECT * FROM skins_buy_purchases WHERE steamid = '%s' AND CURDATE() > time", steam_id);
	Handle hResultTime = SQL_Query(g_hDatabase, sQueryTime);
	if (SQL_FetchRow(hResultTime))
	{
		char sQueryDelete[128];
		FormatEx(sQueryDelete, sizeof(sQueryDelete), "DELETE FROM skins_buy_purchases WHERE steamid = '%s'", steam_id);
		SQL_Query(g_hDatabase, sQueryDelete);
	}
	CloseHandle(hResultTime);

	char sQuery[128];
	FormatEx(sQuery, sizeof(sQuery), "SELECT modelt, modelct FROM skins_buy_purchases WHERE steamid = '%s'", steam_id);
	Handle hResult = SQL_Query(g_hDatabase, sQuery);
	if (SQL_FetchRow(hResult))
	{
		SQL_FetchString(hResult, 0, s_PlayerModelT[client], sizeof(s_PlayerModelT[]));
		if (!IsModelPrecached(s_PlayerModelT[client])) PrecacheModel(s_PlayerModelT[client], true);
		SQL_FetchString(hResult, 1, s_PlayerModelCT[client], sizeof(s_PlayerModelCT[]));
		if (!IsModelPrecached(s_PlayerModelCT[client])) PrecacheModel(s_PlayerModelCT[client], true);
		IsPlayerHasSkins[client] = true;
	}
	CloseHandle(hResult);
}

bool:IsModelFile(const String:model[])
{
	decl String:buf[4];
	GetExtension(model, buf, sizeof(buf));
	
	return !strcmp(buf, "mdl", false);
}

stock GetExtension(const String:path[], String:buffer[], size)
{
	new extpos = FindCharInString(path, '.', true);
	
	if (extpos == -1)
	{
		buffer[0] = '\0';
		return;
	}

	strcopy(buffer, size, path[++extpos]);
}

	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = "Купленный скин из магазина",
	version = PLUGIN_VERSION,
	url = "https://vk.com/cyxaruk1337"
}

public OnPluginStart()
{
	h_Enable = CreateConVar("sm_skins_enable", "1", "Включить или выключить плагин", 0, true, 0.0, true, 1.0);
	h_DownListPath = CreateConVar("sm_skins_buy_downloadslist", "addons/sourcemod/configs/skins_buy/skins_downloadslist.txt", "Путь к списку скачки моделий");
	
	RegAdminCmd("sm_skins_reload", Command_Reload, ADMFLAG_ROOT);

	RegConsoleCmd("sm_skins", Command_SkinMenu);
	
	b_enabled = GetConVarBool(h_Enable);
	
	HookConVarChange(h_Enable, CvarChanges);
	
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_team", Event_PlayerSpawn);
	
	char sError[128];
	g_hDatabase = SQL_Connect("skins_buy", true, sError, sizeof(sError));
	if (sError[0]) SetFailState(sError);

	cookieT = RegClientCookie("SkinsBuy_CMS_T", "", CookieAccess_Private);
	cookieCT = RegClientCookie("SkinsBuy_CMS_CT", "", CookieAccess_Private);
	
	AutoExecConfig(true, "skins_buy");
}

public OnClientCookiesCached(client)
{
	decl String:sValue[8];
	GetClientCookie(client, cookieT, sValue, sizeof(sValue));
	if(sValue[0])
	{
		if(StringToInt(sValue) == 0)
		{
			bSkinDisableT[client] = false;
		}
		else if(StringToInt(sValue) == 1)
		{
			bSkinDisableT[client] = true;
		}
	}
	else
	{
		SetClientCookie(client, cookieT, "0");
		bSkinDisableT[client] = false;
	}

	GetClientCookie(client, cookieCT, sValue, sizeof(sValue));
	if(sValue[0])
	{
		if(StringToInt(sValue) == 0)
		{
			bSkinDisableCT[client] = false;
		}
		else if(StringToInt(sValue) == 1)
		{
			bSkinDisableCT[client] = true;
		}
	}
	else
	{
		SetClientCookie(client, cookieCT, "0");
		bSkinDisableCT[client] = false;
	}
}

public OnConfigsExecuted()
{	
	GetConVarString(h_DownListPath, s_DownListPath, sizeof(s_DownListPath));
	HookConVarChange(h_DownListPath, CvarChanges);
	
	if (FileExists(s_DownListPath))
		File_ReadDownloadList(s_DownListPath);
	else
		LogError("Downloadslist '%s' not found", s_DownListPath);
}

public CvarChanges(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (convar == h_Enable)
	{
		if (bool:StringToInt(newValue) != b_enabled)
		{
			b_enabled = !b_enabled;
			if (b_enabled)
			{
				HookEvent("player_spawn", Event_PlayerSpawn);
				HookEvent("player_team", Event_PlayerSpawn);
			}
			else
			{
				UnhookEvent("player_spawn", Event_PlayerSpawn);
				UnhookEvent("player_team", Event_PlayerSpawn);
			}
		}
	} else
	if (convar == h_DownListPath)
	{
		strcopy(s_DownListPath, sizeof(s_DownListPath), newValue);
		if (FileExists(s_DownListPath))
			File_ReadDownloadList(s_DownListPath);
	}
}

public Action:Command_Reload(client, args)
{
	if (FileExists(s_DownListPath))
		File_ReadDownloadList(s_DownListPath);
	
	return Plugin_Handled;
}

public Action:Command_SkinMenu(client, args)
{
	if (!client || !IsPlayerHasSkins[client] || IsFakeClient(client)) {
		PrintToChat(client, "[SKINS] У вас нету ни одного купленного скина!");
		return Plugin_Handled;
	}
	
	CreateSkinMenu(client);
	return Plugin_Handled;
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (!client || !IsPlayerHasSkins[client] || IsFakeClient(client) || !IsPlayerAlive(client))
		return;
	
	CreateTimer(0.1, SetClientModel, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:SetClientModel(Handle:timer, any:client)
{
	switch (GetClientTeam(client))
	{
		case CS_TEAM_T :
		{
			if (s_PlayerModelT[client][0] && IsModelFile(s_PlayerModelT[client]) && !bSkinDisableT[client])
				SetEntityModel(client, s_PlayerModelT[client]);
		}
		case CS_TEAM_CT :
		{
			if (s_PlayerModelCT[client][0] && IsModelFile(s_PlayerModelCT[client]) && !bSkinDisableCT[client])
				SetEntityModel(client, s_PlayerModelCT[client]);
		}
	}
}

void CreateSkinMenu(int client)
{
	Menu hMenu = new Menu(Handler_hMenu, MenuAction_End|MenuAction_Select);
	SetMenuExitBackButton(hMenu, true);
	hMenu.SetTitle("Skins | Меню");
	hMenu.AddItem("1", "Отключить скин за T");
	hMenu.AddItem("2", "Отключить скин за CT");
	hMenu.AddItem("3", "Меню скинов");
	hMenu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_hMenu(Menu hMenu, MenuAction action, int client, int item)
{
    switch(action)
    {
        case MenuAction_End:
        {
            delete hMenu;
        }
        case MenuAction_Select:
        {
            char info[64];
            hMenu.GetItem(item, info, sizeof info);

            if (StrEqual(info, "1"))
            {
				decl String:sValue[8];
				GetClientCookie(client, cookieT, sValue, sizeof(sValue));
				if(StringToInt(sValue) == 0)
				{
					SetClientCookie(client, cookieT, "1");
					bSkinDisableT[client] = true;
					PrintToChat(client, "[SKINS] Ваш скин за Т отключен!");

					if(client && IsClientInGame(client) && IsPlayerAlive(client))
					{
						CS_UpdateClientModel(client);
					}
				}
				else
				{
					SetClientCookie(client, cookieT, "0");
					bSkinDisableT[client] = false;
					PrintToChat(client, "[SKINS] Ваш скин за Т включен!");
				}
            }
            else if (StrEqual(info, "2"))
	    {
				decl String:sValue[8];
				GetClientCookie(client, cookieT, sValue, sizeof(sValue));
				if(StringToInt(sValue) == 0)
				{
					SetClientCookie(client, cookieCT, "1");
					bSkinDisableCT[client] = true;
					PrintToChat(client, "[SKINS] Ваш скин за CТ отключен!");

					if(client && IsClientInGame(client) && IsPlayerAlive(client))
					{
						CS_UpdateClientModel(client);
					}
				}
				else
				{
					SetClientCookie(client, cookieCT, "0");
					bSkinDisableCT[client] = false;
					PrintToChat(client, "[SKINS] Ваш скин за CТ включен!");
				}
            }
	    else if (StrEqual(info, "3"))
	    {
		CreateSkinListMenu(client);
            }
        }
    }
}

void CreateSkinListMenu(int client)
{
	Menu hMenu = new Menu(Handler_hMenuList, MenuAction_End|MenuAction_Select);
	SetMenuExitBackButton(hMenu, true);
	hMenu.SetTitle("Skins | Меню");
	char steam_id[21];
	GetClientAuthString(client, steam_id, sizeof(steam_id));
	do
	{
		char sQuery[128];
		FormatEx(sQuery, sizeof(sQuery), "SELECT skins_name,team FROM skins_buy_purchases WHERE steamid = '%s'", steam_id);
		Handle hResult = SQL_Query(g_hDatabase, sQuery);
		if (SQL_FetchRow(hResult))
		{
			char s_SkinName[64];
			SQL_FetchString(hResult, 0, s_SkinName, sizeof(s_SkinName));
			int g_iTeam;
			SQL_FetchInt(hResult, 1, g_iTeam);

			if(!s_SkinName[0])
			{
				CloseHandle(hResult);
				break;
			}

			char s_Info[80];
			FormatEx(s_Info, sizeof(s_Info), "%s [%i]", s_SkinName, g_iTeam);
			if(g_iTeam == 3)
				ReplaceString(s_Info, 80, "[3]", [CT]);
			else if(g_iTeam == 2)
				ReplaceString(s_Info, 80, "[2]", [T]);
			hMenu.AddItem(s_SkinName, s_Info);
		}
		else 
		{
			CloseHandle(hResult);
			break;
		}
	}
	while(1 > 0); // Костыльчик вам в ленту :D
	hMenu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_hMenuList(Menu hMenu, MenuAction action, int client, int item)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete hMenu;
		}
		case MenuAction_Select:
		{
			char info[64];
			hMenu.GetItem(item, info, sizeof info);

			char steam_id[21];
			GetClientAuthString(client, steam_id, sizeof(steam_id));

			char sQuery[128];
			FormatEx(sQuery, sizeof(sQuery), "SELECT modelt,modelct,team FROM skins_buy_purchases WHERE steamid = '%s' AND skins_name = '%s'", steam_id, info);
			Handle hResult = SQL_Query(g_hDatabase, sQuery);
			if (SQL_FetchRow(hResult))
			{
				char s_ModelT[64];
				SQL_FetchString(hResult, 0, s_ModelT, sizeof(s_ModelT));
				char s_ModelCT[64];
				SQL_FetchString(hResult, 1, s_ModelCT, sizeof(s_ModelCT));
				int g_iTeam;
				SQL_FetchInt(hResult, 2, g_iTeam);

				if(g_iTeam == 2)
				{
					FormatEx(s_PlayerModelT[client], sizeof(s_PlayerModelT[]), "%s", s_ModelT);
	`				if (!IsModelPrecached(s_PlayerModelT[client])) PrecacheModel(s_PlayerModelT[client], true);
					PrintToChat(client, "[SKINS] Вы успешно установили скин: %s (будет доступен в след.раунде)", info);
				}
				if(g_iTeam == 3)
				{
					FormatEx(s_PlayerModelCT[client], sizeof(s_PlayerModelCT[]), "%s", s_ModelCT);
					if (!IsModelPrecached(s_PlayerModelCT[client])) PrecacheModel(s_PlayerModelCT[client], true);
					PrintToChat(client, "[SKINS] Вы успешно установили скин: %s (будет доступен в след.раунде)", info);
				}
			}
		}
	}
}

public OnClientPutInServer(client)
{
	if (!client || IsFakeClient(client))
		return;
	
	IsPlayerHasSkins[client] = false;

	decl String:steam_id[21];

	GetClientAuthString(client, steam_id, sizeof(steam_id));
	
	s_PlayerModelT[client][0] = s_PlayerModelCT[client][0] = 0;

	char sQueryTime[128];
	FormatEx(sQueryTime, sizeof(sQueryTime), "SELECT * FROM skins_buy_purchases WHERE steamid = '%s' AND CURDATE() > time", steam_id);
	Handle hResultTime = SQL_Query(g_hDatabase, sQueryTime);
	if (SQL_FetchRow(hResultTime))
	{
		char sQueryDelete[128];
		FormatEx(sQueryDelete, sizeof(sQueryDelete), "DELETE FROM skins_buy_purchases WHERE steamid = '%s'", steam_id);
		SQL_Query(g_hDatabase, sQueryDelete);
	}
	CloseHandle(hResultTime);

	char sQuery[128];
	FormatEx(sQuery, sizeof(sQuery), "SELECT modelt, modelct FROM skins_buy_purchases WHERE steamid = '%s'", steam_id);
	Handle hResult = SQL_Query(g_hDatabase, sQuery);
	if (SQL_FetchRow(hResult))
	{
		SQL_FetchString(hResult, 0, s_PlayerModelT[client], sizeof(s_PlayerModelT[]));
		if (!IsModelPrecached(s_PlayerModelT[client])) PrecacheModel(s_PlayerModelT[client], true);
		SQL_FetchString(hResult, 1, s_PlayerModelCT[client], sizeof(s_PlayerModelCT[]));
		if (!IsModelPrecached(s_PlayerModelCT[client])) PrecacheModel(s_PlayerModelCT[client], true);
		IsPlayerHasSkins[client] = true;
	}
	CloseHandle(hResult);
}

bool:IsModelFile(const String:model[])
{
	decl String:buf[4];
	GetExtension(model, buf, sizeof(buf));
	
	return !strcmp(buf, "mdl", false);
}

stock GetExtension(const String:path[], String:buffer[], size)
{
	new extpos = FindCharInString(path, '.', true);
	
	if (extpos == -1)
	{
		buffer[0] = '\0';
		return;
	}

	strcopy(buffer, size, path[++extpos]);
}
