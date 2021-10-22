/*
*							ИНФОРМАЦИЯ О ПЛАГИНЕ
*	Автор плагина  Pr[E]fix
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

#define PLUGIN_VERSION "1.0(beta)"
#define PLUGIN_NAME "[GAMECMS] Skins BuY"
#define PLUGIN_AUTHOR "Pr[E]fix | vk.com/cyxaruk1337"

new bool:b_enabled,
	bool:IsPlayerHasSkins[MAXPLAYERS+1];

new String:s_PlayerModelT[MAXPLAYERS+1][PLATFORM_MAX_PATH],
	String:s_PlayerModelCT[MAXPLAYERS+1][PLATFORM_MAX_PATH],
	String:s_DownListPath[PLATFORM_MAX_PATH];

new Handle:h_Enable,
	Handle:h_DownListPath,
	Handle:g_hDatabase;

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

	RegConsoleCmd("skins_buy_info", info_skins, "Информация о плагине");
	RegConsoleCmd("skins_buy_support", support_skins, "Поддержка плагина");
	
	RegAdminCmd("sm_skins_reload", Command_Reload, ADMFLAG_ROOT);
	
	b_enabled = GetConVarBool(h_Enable);
	
	HookConVarChange(h_Enable, CvarChanges);
	
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_team", Event_PlayerSpawn);
	
	char sError[128];
	g_hDatabase = SQL_Connect("skins_buy", true, sError, sizeof(sError));
	if (sError[0]) SetFailState(sError);
	
	AutoExecConfig(true, "skins_buy");
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
			if (s_PlayerModelT[client][0] && IsModelFile(s_PlayerModelT[client]))
				SetEntityModel(client, s_PlayerModelT[client]);
		}
		case CS_TEAM_CT :
		{
			if (s_PlayerModelCT[client][0] && IsModelFile(s_PlayerModelCT[client]))
				SetEntityModel(client, s_PlayerModelCT[client]);
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

public Action info_skins(int client, int args)
{
	PrintToConsole(client, "\n\n\n\n========Информация о плагине========\n\n**Автор: Pr[E]fix | vk.com/cyxaruk13337\n**Название плагина: [GAMECMS] Skins BuY\n**Описание плагина: Выдает скин который игрок купил на сайте\n**Версия плагина: 1.0\n**Поддержка плагина только через меня\n**[VK] - vk.com/cyxaruk1337\n\n========Информация о плагине========\n\n");
}
public Action support_skins(int client, int args)
{
	PrintToConsole(client, "\n\n\n\n========Поддержка плагина========\n\n**Поддержка плагина только через меня\n**[VK] - vk.com/cyxaruk1337\n**[GITHUB] - https://github.com/PrefixHLMOD/Skins_BuY\n\n========Поддержка плагина========\n\n");
}
