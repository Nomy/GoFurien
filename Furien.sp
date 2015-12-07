#pragma semicolon 1
#define TAG "[\x05FURIEN\x01]"

#include <sourcemod>
#include <adminmenu>
#include <cstrike>
#include <clientprefs>
#include <sdktools>
#include <sdkhooks>
#include <emitsoundany>

#include "files/globals.sp"
#include "files/misc.sp"
#include "files/adminmenu.sp"
#include "files/Precache.sp"
#include "files/OnPlayerRunCmd.sp"
#include "files/menu.sp"
#include "files/mysqlpoints.sp"

public Plugin myinfo =
{
	name = "GameSites FurienMod",
	author = "ESK0",
	description = "GameSites FurienMod",
	version = "1.3c",
	url = "www.github.com/ESK0"
}
public OnPluginStart()
{
	AdminMenu_OnPluginStart();
	HookEvent("round_end", Event_OnRoundEnd);
	HookEvent("round_start", Event_OnRoundStart);
	HookEvent("round_prestart", Event_OnRoundStartPre);
	HookEvent("player_death", Event_OnPlayerDeath);
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("player_team", Event_OnPlayerTeam, EventHookMode_Pre);

	HookEvent("bomb_defused", Event_OnBombDefused);
	HookEvent("bomb_planted", Event_OnBombPlanted);
	HookEvent("hostage_rescued", Event_OnHostageRescued);

	AddNormalSoundHook(OnNormalSoundPlayed);

	RegConsoleCmd("kill", Event_BlockKill);

	RegConsoleCmd("sm_shop", Event_ShowShop);
	RegConsoleCmd("sm_obchod", Event_ShowShop);
	RegConsoleCmd("sm_furien", Event_Furien);
	RegConsoleCmd("sm_zbran", Event_Guns);
	RegConsoleCmd("sm_help", Event_Help);

	RegAdminCmd("sm_addpoints", Event_AddPoints, ADMFLAG_ROOT);
	RegAdminCmd("sm_removepoints", Event_RemovePoints, ADMFLAG_ROOT);
	RegAdminCmd("sm_getpoints", Event_GetPoints, ADMFLAG_ROOT);

	g_offsNextPrimaryAttack = FindSendPropOffs("CBaseCombatWeapon", "m_flNextPrimaryAttack");
	g_offsNextSecondaryAttack = FindSendPropOffs("CBaseCombatWeapon", "m_flNextSecondaryAttack");

	g_clientcookie = RegClientCookie("GS_FurienMenuToggle", "", CookieAccess_Private);
	g_clientcookieSound = RegClientCookie("GS_RoundEndSoundsFix", "", CookieAccess_Private);

	i_FlashAlpha = FindSendPropOffs("CCSPlayer", "m_flFlashMaxAlpha");
	if (i_FlashAlpha == -1)	SetFailState("Failed to find \"m_flFlashMaxAlpha\".");

	SetConVarInt(FindConVar("sv_ignoregrenaderadio"), 1);

	for(int i; i < sizeof(g_sRadioCommands); i++)
	{
		AddCommandListener(Command_BlockRadio, g_sRadioCommands[i]);
	}
	BuildPath(Path_SM, logfile, sizeof(logfile), "logs/furien.log");
}
public OnMapEnd()
{
	CloseHandle(db);
}
public OnMapStart()
{
	StartAdvertTime = GetGameTime();
	FurienWinStreak = 0;
	SQLlite_OnMapStart();
	SetConVarString(FindConVar("mp_teamname_1"), "ANTI-FURIENS");
	SetConVarString(FindConVar("mp_teamname_2"), "FURIENS");
	PrecacheModels();
	PrecacheSounds();
}
public OnClientPutInServer(client)
{
	if (!IsFakeClient(client) && IsValidClient(client))
	{
		SQLlite_OnClientPutInServer(client);
		SendConVarValue(client, FindConVar("sv_footsteps"), "0");
		SDKHook(client, SDKHook_WeaponCanUse, EventSDK_OnWeaponCanUse);
		SDKHook(client, SDKHook_OnTakeDamage, EventSDK_OnTakeDamage);
		SDKHook(client, SDKHook_PreThink, EventSDK_OnClientThink);
		SDKHook(client, SDKHook_SetTransmit, EventSDK_SetTransmit);
		SDKHook(client, SDKHook_PostThinkPost, EventSDK_OnPostThinkPost);
		SDKHook(client, SDKHook_WeaponDrop, EventSDK_OnWeaponDrop);
	}
}
public OnGameFrame()
{
	float time = 90.0;
	float timeleftadvert = StartAdvertTime - GetGameTime() + time;
	if(timeleftadvert < 0.01)
	{
		StartAdvertTime = GetGameTime();
		int rand = GetRandomInt(1,6);
		switch(rand)
		{
			case 1: PrintToChatAll("%s Pomocí příkazu \x0F!help\x01 si zobrazíte kompletní nápovedu.",TAG);
			case 2:	PrintToChatAll("%s Veškeré schopnosti které si zakoupíte v obchodu máte pouze na \x0F1\x01 kolo",TAG);
			case 3:	PrintToChatAll("%s Základní příkazy na serveru jsou: \x0F!furien\x01 a \x0F!shop\x01.",TAG);
			case 4:	PrintToChatAll("%s Tento mód je \x0Fstále\x01 ve vývoji, může zde docházet ke změnám.",TAG);
			case 5:	PrintToChatAll("%s Bomba lze položit až po \x0F20s\x01 od zahájení kola",TAG);
			case 6:	PrintToChatAll("%s Zakoupené VIP schopnosti jsou aktivní \x0Fpouze\x01 po dobu \x0Faktivního\x01 VIP",TAG);
		}
	}
	if(b_EnableBombZone)
	{
		float delay = 23.0;
		float timeleft = f_EnableBombZone - GetGameTime() + delay;
		if(timeleft < 0.01)
		{
			int index = -1;
			while ((index = FindEntityByClassname(index, "func_bomb_target")) != -1)
			{
				AcceptEntityInput(index, "Enable");
			}
			b_EnableBombZone = false;
		}
	}
}
public Action Command_BlockRadio(int client, const char[] command, args)
{
	return Plugin_Handled;
}
public Action Event_Help(client, args)
{
	if(IsValidClient(client))
	{
		ShowHelpMenu(client);
	}
	return Plugin_Handled;
}
public Action EventTimer_ShowGunMenu(Handle timer, any client)
{
	if(IsValidClient(client))
	{
		ShowCTSpawnMenu(client);
	}
	return Plugin_Handled;
}
public Action EventTimer_ShowTShopMenu(Handle timer, any client)
{
	if(IsValidClient(client))
	{
		ShowFurienMenu(client);
	}
	return Plugin_Handled;
}
public Action Event_BlockKill(client, args)
{
	return Plugin_Handled;
}
public Action Event_Guns(client, args)
{
	if(IsValidClient(client))
	{
		if(IsPlayerAlive(client))
		{
			if(GetClientTeam(client) == CS_TEAM_T)
			{
				PrintToChat(client, "%s Tento příkaz je dostupný pouze pro Anti-Furieny", TAG);
				return Plugin_Handled;
			}
			if(!PlayerSelectWeapon[client] && GetClientTeam(client) == CS_TEAM_CT)
			{
				ShowCTSpawnMenu(client);
			}
			else
			{
				PrintToChat(client, "%s Zbraň sis již vybral", TAG);
			}
		}
		else
		{
			PrintToChat(client,"%s Musíš být živí", TAG);
		}
	}
	return Plugin_Handled;
}
public Action Event_AddPoints(client, args)
{
	char s_amount[32];
	GetCmdArg(1, steamid, sizeof(steamid));
	GetCmdArg(2, s_amount, sizeof(s_amount));
	int i_amount = StringToInt(s_amount);

	Furien_AddPointsToSteamID(steamid, i_amount);
	LogToFile(logfile, "[Furien-VIP] SteamID: %s | si zakoupilo: %db", steamid, i_amount);

	return Plugin_Handled;
}
public Action Event_RemovePoints(client, args)
{
	Furien_RemoveClientPoints(client, 20);
	return Plugin_Handled;
}
public Action Event_GetPoints(client, args)
{
	PrintToChat(client, "%d",Furien_GetClientPoints(client));
	return Plugin_Handled;
}
public Action Event_ShowShop(client, args)
{
	if(IsValidClient(client, true))
	{
		if(GetClientTeam(client) == CS_TEAM_T)
		{
			ShowTShop(client);
		}
		if(GetClientTeam(client) == CS_TEAM_CT)
		{
			ShowCTShop(client);
		}
	}
	else
	{
		PrintToChat(client,"%s Musíš být naživu aby sis mohl otevřit shop", TAG);
	}
	return Plugin_Handled;
}
public Action Event_Furien(client, args)
{
	if(IsValidClient(client, true))
	{
		if(GetClientTeam(client) > 1)
		{
			ShowFurienMenu(client);
		}
		else
		{
			PrintToChat(client, "%s - Nemůźeš si otevřit Furien menu", TAG);
		}
	}
	else
	{
		PrintToChat(client, "%s - Musíš být naživu aby sis mohl otevřit Furien menu", TAG);
	}
	return Plugin_Handled;
}
/////////// GAMEHOOKS ///////////
public Action Event_OnBombDefused(Handle event, const char[] name, bool dontbroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsValidClient(client))
	{
		if(CountPlayers() >= 6)
		{
			Furien_AddPointsToClient(client, 30);
			PrintToChat(client, "%s Získáváš \x0F30\x01 $ za zneškodnění bomby", TAG);
		}
		else PrintToChat(client,"%s Na serveru není dostatek hráčů k získávání $ [\x0B6\x01]", TAG);
	}
}
public Action Event_OnBombPlanted(Handle event, const char[] name, bool dontbroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsValidClient(client))
	{
		if(CountPlayers() >= 6)
		{
			Furien_AddPointsToClient(client, 30);
			PrintToChat(client, "%s Získáváš \x0F30\x01 $ za položení bomby", TAG);
		}
		else PrintToChat(client,"%s Na serveru není dostatek hráčů k získávání $ [\x0B6\x01]", TAG);
	}
}
public Action Event_OnHostageRescued(Handle event, const char[] name, bool dontbroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsValidClient(client) && CountPlayers() >= MinPlayers)
	{
		Furien_AddPointsToClient(client, 2);
		PrintToChat(client, "%s Získáváš \x0F2\x01 $ za odvedení rukojmého", TAG);
	}
}
public Action Event_OnRoundStart(Handle event, const char[] name, bool dontbroadcast)
{
	int maxmoney = -1;
	char maxmoneyname[MAX_NAME_LENGTH];
	LoopClients(i)
	{
		if(IsValidClient(i))
		{
			int money = Furien_GetClientPoints(i);
			if(money > maxmoney)
			{
				Format(maxmoneyname, sizeof(maxmoneyname), "%N", i);
				maxmoney = money;
			}
			if(PlayerOneRoundSuperKnife[i])
			{
				PlayerOneRoundSuperKnife[i] = false;
			}
			if(i_Shop50HP[i] != 0)
			{
				i_Shop50HP[i] = 0;
			}
			if(b_ShopHeGrenade[i])
			{
				b_ShopHeGrenade[i] = false;
			}
			if(PlayerOneRoundAmfetamin[i])
			{
				PlayerOneRoundAmfetamin[i] = false;
			}
			if(PlayerSelectWeapon[i])
			{
				PlayerSelectWeapon[i] = false;
			}
			if(IsPlayerInvisible[i])
			{
				IsPlayerInvisible[i] = false;
			}
			if(IsPlayerComingToInvisible[i])
			{
				IsPlayerComingToInvisible[i] = false;
			}
		}
	}
	if(maxmoney != -1)
	{
		PrintToChatAll("%s Hráč \x07%s\x01 je nejbohatší hráč na serveru s \x10%d\x01$", TAG, maxmoneyname, maxmoney);
	}
	int index = -1;
	while ((index = FindEntityByClassname(index, "func_bomb_target")) != -1)
	{
		b_EnableBombZone = true;
		f_EnableBombZone = GetGameTime();
		AcceptEntityInput(index, "Disable");
	}
}
public Action Event_OnPlayerDeath(Handle event, const char[] name, bool dontbroadcast)
{
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	//bool headshot = GetEventBool(event,"headshot");
	char weapon[32];
	GetEventString(event, "weapon", weapon,sizeof(weapon));
	if(IsValidClient(victim) && IsValidClient(attacker) && victim != attacker)
	{
		if(IsPlayerVIP(attacker))	SetEntityHealth(attacker, GetClientHealth(attacker)+3);
		if(CountPlayers() >= MinPlayers)
		{
			if(IsPlayerVIP(attacker))
			{
				if(GetClientTeam(victim) == CS_TEAM_T)
				{
					Furien_AddPointsToClient(attacker, 20);
					PrintToChat(attacker, "%s Získáváš \x0F20\x01$ za zabití hráče \x0F%N", TAG, victim);
				}
				else if(GetClientTeam(victim) == CS_TEAM_CT)
				{
					Furien_AddPointsToClient(attacker, 15);
					PrintToChat(attacker, "%s Získáváš \x0F15\x01$ za zabití hráče \x0F%N", TAG, victim);
				}
			}
			else
			{
				if(GetClientTeam(victim) == CS_TEAM_T)
				{
					Furien_AddPointsToClient(attacker, 15);
					PrintToChat(attacker, "%s Získáváš \x0F15\x01$ za zabití hráče \x0F%N", TAG, victim);
				}
				else if(GetClientTeam(victim) == CS_TEAM_CT)
				{
					Furien_AddPointsToClient(attacker, 10);
					PrintToChat(attacker, "%s Získáváš \x0F10\x01$ za zabití hráče \x0F%N", TAG, victim);
				}
			}
		}
		else PrintToChat(attacker,"%s Na serveru není dostatek hráčů k získávání $ [\x0B%d\x01]", TAG, MinPlayers);
		/*if(headshot)
		{
			Furien_AddPointsToClient(attacker, 2);
			PrintToChat(attacker, "%s Získáváš \x0F2\x01 body za zabití hráče \x0F%N \x01do hlavy", TAG, victim);
		}
		else
		{
			if(StrContains(weapon, "knife") != -1 && GetClientTeam(victim) == CS_TEAM_T)
			{
				Furien_AddPointsToClient(attacker, 3);
				PrintToChat(attacker, "%s Získáváš \x0F3\x01 body za zabití hráče \x0F%N \x01nožem", TAG, victim);
			}
			else
		}*/
	}
}
public Action Event_OnRoundEnd(Handle event, const char[] name, bool dontbroadcast)
{
	int winner = GetEventInt(event, "winner");
	if(winner == CS_TEAM_T)
	{
		FurienWinStreak++;
		if(FurienWinStreak <= 3)
		{
			char buffer[512];
			Format(buffer,sizeof(buffer),"	<font color='#d43556'><b>FURIENI VYHRALI</b></font>");
			Format(buffer,sizeof(buffer),"%s\n		<font color='#2cf812'><b>|%d/3|</b></font>",buffer,FurienWinStreak);
			PrintHintTextToAll(buffer);
			if(FurienWinStreak == 3)
			{
				Format(buffer,sizeof(buffer),"%s\n <font size='14'>Furieni vyhráli 3x v řade. Prohazuji týmy.</font>",buffer);
				PrintHintTextToAll(buffer);
				LoopClients(i)
				{
					if(IsValidClient(i, true) && GetClientTeam(i) == CS_TEAM_T && CountPlayers() >= 6)
					{
						Furien_AddPointsToClient(i, 30);
						PrintToChat(i, "%s Získáváš \x0F30$\x01 za 3 vyhraná kola v řadě", TAG);
					}
				}
				switchteams = true;
			}
		}
		else switchteams = false;
	}
	else if(winner == CS_TEAM_CT)
	{
		char buffer[512];
		Format(buffer,sizeof(buffer),"	<font color='#0066cc' size='22'><b>ANTI-FURIENI VYHRALI</b></font>");
		Format(buffer,sizeof(buffer),"%s\n	      <font size='14'>Proběhne prohození týmu.</font>",buffer);
		PrintHintTextToAll(buffer);
		FurienWinStreak = 0;
		switchteams = true;
	}
}
public Action Event_OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	CheckTags(client);
	if (IsValidClient(client, true) && GetClientTeam(client) != 1)
	{
		b_WallHang[client] = false;
		SetEntityMoveType(client, MOVETYPE_WALK);
		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		Entity_SetRenderColor(client,-1,-1,-1,255);
		StripAllWeapons(client);
		// Furien
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			CreateTimer(0.2, EventTimer_ShowTShopMenu, client);
			FixMovement(client);
			if(IsPlayerVIP(client))
			{
				SetEntityHealth(client, 110);
				MaxHealth[client] = 110;
			}
			else MaxHealth[client] = 100;
			GivePlayerItem(client, "weapon_hegrenade");
			GivePlayerItem(client, "weapon_knife");
			SetEntProp(client, Prop_Send, "m_ArmorValue", 0);
			SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
			SetEntityModel(client, MODEL_FURIEN);
			FadeClient(client, 75,0,130,35);
    }
    // Anti-Furien
		else if (GetClientTeam(client) == CS_TEAM_CT)
		{
			CreateTimer(0.2, EventTimer_ShowGunMenu, client);
			MaxHealth[client] = 100;
			/*if(IsPlayerVIP(client))
			{
				SetEntProp(client, Prop_Send, "m_bHasDefuser", 1);
			}*/
			GivePlayerItem(client, "weapon_knife");
			GivePlayerItem(client, "weapon_flashbang");
			SetEntityGravity(client, 1.0);
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
			if(IsPlayerVIP(client)) SetEntProp(client, Prop_Send, "m_ArmorValue", 50);
			else SetEntProp(client, Prop_Send, "m_ArmorValue", 0);
			SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
    }
	}
}
public Action Event_OnRoundStartPre(Handle event, const char[] name, bool dontbroadcast)
{
	if(switchteams)
	{
		int ctscore = CS_GetTeamScore(CS_TEAM_CT);
		int tscore = CS_GetTeamScore(CS_TEAM_T);
		ChangeTeamScore(CS_TEAM_T,ctscore);
		ChangeTeamScore(CS_TEAM_CT,tscore);
		FurienWinStreak = 0;
		LoopClients(i)
		{
			if(IsValidClient(i))
			{
				if(GetClientTeam(i) == CS_TEAM_CT)
				{
					CS_SwitchTeam(i, CS_TEAM_T);
				}
				else if(GetClientTeam(i) == CS_TEAM_T)
				{
					CS_SwitchTeam(i, CS_TEAM_CT);

				}
			}
		}
		switchteams = false;
	}
}
public Action Event_OnPlayerTeam(Handle event, const char[] name, bool dontbroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	CheckTags(client);
	dontbroadcast = true;
	return Plugin_Changed;
}
//////////////////////////////////////////////////////////////
public Action OnNormalSoundPlayed(clients[64], &numClients, char sample[PLATFORM_MAX_PATH], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
	if (entity && entity <= MaxClients && StrContains(sample, "footsteps") != -1)
	{
		if(GetClientTeam(entity) == CS_TEAM_T)
		{
			return Plugin_Handled;
		}
		else
		{
			if(StrContains(sample, "footsteps/new/") != -1)
			{
				return Plugin_Stop;
			}
			EmitSoundToAll(sample, entity, SNDCHAN_AUTO,SNDLEVEL_NORMAL,SND_NOFLAGS,0.5);
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}
//////////SDKHOOKS///////////
public EventSDK_OnClientThink(client)
{
		if(IsValidClient(client, true))
		{
			if(GetClientTeam(client) == CS_TEAM_T || PlayerOneRoundAmfetamin[client])
			{
				FixMovement(client);
			}
		}
}
public Action EventSDK_OnWeaponDrop(client, weapon)
{
	if(IsValidClient(client) && IsValidEntity(weapon))
	{
		if(GetClientTeam(client) == CS_TEAM_T)
		{
			char wepname[32];
			GetEntityClassname(weapon,wepname,sizeof(wepname));
			if(StrEqual(wepname,"weapon_c4"))
			{
				SetEntityVisibility(weapon, 255);
				SetEntityAlpha(weapon,255);
			}
		}
	}
}
public Action EventSDK_OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, float damageForce[3], float damagePosition[3])
{
	char s_weapon[128];
	if(IsValidEntity(weapon))
	{
		GetEntityClassname(weapon, s_weapon, sizeof(s_weapon));
	}
	if(IsValidClient(victim, true) && GetClientTeam(victim) == CS_TEAM_T)
	{
		PlayerRegenHPStart[victim] = GetGameTime();
		if(damagetype == DMG_FALL)
		{
			return Plugin_Handled;
		}
		return Plugin_Continue;
	}
	if(IsValidClient(victim, true) && IsValidClient(attacker, true) && PlayerOneRoundSuperKnife[attacker] && StrContains(s_weapon, "knife") && GetClientTeam(attacker) == CS_TEAM_T && GetClientTeam(attacker) != GetClientTeam(victim))
	{
		damage = 400.0;
		return Plugin_Changed;
	}
	if(IsValidClient(victim, true) && IsValidClient(attacker, true) && IsPlayerInvisible[victim] && GetClientTeam(victim) != GetClientTeam(attacker))
	{
		IsPlayerInvisible[victim] = false;
		IsPlayerComingToInvisible[victim] = false;
	}
	return Plugin_Continue;
}
public EventSDK_OnPostThinkPost(client)
{
	if(IsValidClient(client, true) && GetClientTeam(client) == CS_TEAM_T)
	{
		SetEntProp(client, Prop_Send, "m_iAddonBits", 0);
	}
	if(IsValidClient(client, true) && GetClientTeam(client) == CS_TEAM_CT)
	{
		SetEntProp(client, Prop_Send, "m_iAddonBits", 1);
	}
}
public Action EventSDK_SetTransmit(entity, client)
{
	if(IsValidClient(entity, true))
	{
		if (client != entity && IsPlayerInvisible[entity])
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}
public Action EventSDK_OnWeaponCanUse(client, weapon)
{
	if(IsValidClient(client, true) && GetClientTeam(client) == CS_TEAM_T)
	{
		char s_weapon[128];
		GetEntityClassname(weapon, s_weapon, sizeof(s_weapon));
		if(StrEqual(s_weapon, "weapon_knife"))
		{
			return Plugin_Continue;
		}
		if(StrEqual(s_weapon, "weapon_hegrenade"))
		{
			return Plugin_Continue;
		}
		if(StrEqual(s_weapon, "weapon_c4"))
		{
			return Plugin_Continue;
		}
		if(StrEqual(s_weapon, "weapon_taser"))
		{
			return Plugin_Continue;
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;
}
public Action Timer_AllowHeckle(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(IsValidClient(client))
	{
		PlayerHeckle[client] = false;
	}
	else return Plugin_Stop;
	return Plugin_Continue;
}
