#define LoopClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++)

stock ChangeTeamScore(int index, int score)
{
  CS_SetTeamScore(index, score);
  SetTeamScore(index, score);
}
stock SendOverlayToClient(int client, const char[] overlay)
{
	if(IsClientValid(client))
	{
		ClientCommand(client, "r_screenoverlay \"%s\"", overlay);
	}
}
stock AddWeaponToMenu(Menu menu, const char[] weaponkey, const char[] weaponname,const int clientpoints, const int weaponcost)
{
  char string[64];
  Format(string, sizeof(string), "%s [%d$]",weaponname, weaponcost);
  if(clientpoints >= weaponcost) menu.AddItem(weaponkey, string);
  else menu.AddItem(weaponkey, string, ITEMDRAW_DISABLED);
}
stock SendOverlayToAll(const char[] overlay)
{
	LoopClients(i)
	{
		if (IsValidClient(i) !IsFakeClient(i))
		{
			ClientCommand(i, "r_screenoverlay \"%s\"", overlay);
		}
	}
}
stock CountPlayers()
{
	int count = 0;
	LoopClients(i)
	{
		if(IsValidClient(i) && GetClientTeam(i) > 1)
		{
			count++;
		}
	}
	return count;
}
stock GetWeaponCost(const char[] name)
{
  if(StrEqual(name, "weapon_m4a1")) return i_ShopM4A4Cost;
  else if(StrEqual(name, "weapon_awp")) return i_ShopAWPCost;
  else if(StrEqual(name, "weapon_ak47")) return i_ShopAK47Cost;
  else if(StrEqual(name,"weapon_mp7")) return i_ShopMP7Cost;
  else return 0;
}
stock GetSecWeaponCost(const char[] name)
{
  if(StrEqual(name, "weapon_p250")) return i_ShopP250Cost;
  else if(StrEqual(name, "weapon_fiveseven")) return i_ShopFSCost;
  else if(StrEqual(name, "weapon_deagle")) return i_ShopDeagleCost;
  else return 0;
}
stock GetRandomPlayer(team, bool alive = false)
{
	new clients[MaxClients+1];
	int clientCount;
	LoopClients(i)
	{
		if(IsValidClient(i, alive) && GetClientTeam(i) == team)
		{
			clients[clientCount++] = i;
		}
	}
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}
stock StripWeapons(client)
{
	new wepIdx;
	for (new x = 0; x <= 5; x++)
	{
		if (x != 2 && (wepIdx = GetPlayerWeaponSlot(client, x)) != -1)
		{
			RemovePlayerItem(client, wepIdx);
			RemoveEdict(wepIdx);
		}
	}
}
stock StripAllWeapons(Client)
{
	new iEnt;
	for (new i = 0; i <= 4; i++)
	{
    while ((iEnt = GetPlayerWeaponSlot(Client, i)) != -1)
    {
			RemovePlayerItem(Client, iEnt);
			RemoveEdict(iEnt);
    }
	}
}
stock FixMovement(client)
{
  if(GetClientTeam(client) == CS_TEAM_T)  SetEntityGravity(client, 0.4);
  if(b_VipShopSpeedUp[client] && GetClientTeam(client) == CS_TEAM_T && IsPlayerVIP(client))
  {
    SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.9);
  }
  else SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.75);
}
stock FadeClient(client, r, g, b, a)
{
	#define FFADE_STAYOUT 0x0008
	#define	FFADE_PURGE 0x0010
	Handle hFadeClient = StartMessageOne("Fade",client);
	if (GetUserMessageType() == UM_Protobuf)
	{
		int color[4];
		color[0] = r;
		color[1] = g;
		color[2] = b;
		color[3] = a;
		PbSetInt(hFadeClient, "duration", 0);
		PbSetInt(hFadeClient, "hold_time", 0);
		PbSetInt(hFadeClient, "flags", (FFADE_PURGE|FFADE_STAYOUT));
		PbSetColor(hFadeClient, "clr", color);
	}
	else
	{
		BfWriteShort(hFadeClient, 0);
		BfWriteShort(hFadeClient, 0);
		BfWriteShort(hFadeClient, (FFADE_PURGE|FFADE_STAYOUT));
		BfWriteByte(hFadeClient, r);
		BfWriteByte(hFadeClient, g);
		BfWriteByte(hFadeClient, b);
		BfWriteByte(hFadeClient, a);
	}
	EndMessage();
}
stock GetClientWaterLevel(client){

  return GetEntProp(client, Prop_Send, "m_nWaterLevel");
}
stock CheckTags(client)
{
  if(IsValidClient(client))
  {
    if(IsPlayerVIP(client) && !IsPlayerAdmin(client))
    {
      CS_SetClientClanTag(client, "[VIP]");
    }
    else if(IsPlayerAdmin(client)){}
    else (CS_SetClientClanTag(client, ""));
  }
}
stock bool IsPlayerVIP(client)
{
	if(GetAdminFlag(GetUserAdmin(client), Admin_Reservation))
  {
		return true;
	}
	return false;
}
stock bool IsPlayerAdmin(client)
{
	if (GetAdminFlag(GetUserAdmin(client), Admin_Generic))
    {
		return true;
	}
	return false;
}
stock bool:IsValidClient(client, bool:alive = false)
{
  if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && (alive == false || IsPlayerAlive(client)))
  {
    return true;
  }
  return false;
}

#define 	HEGrenadeOffset 		14	// (11 * 4)
#define 	FlashbangOffset 		15	// (12 * 4)
#define 	SmokegrenadeOffset		16	// (13 * 4)

stock GetClientHEGrenades(client)
{
	return GetEntProp(client, Prop_Data, "m_iAmmo", _, HEGrenadeOffset);
}
stock GetClientSmokeGrenades(client)
{
	return GetEntProp(client, Prop_Data, "m_iAmmo", _, SmokegrenadeOffset);
}
stock GetClientFlashbangs(client)
{
	return GetEntProp(client, Prop_Data, "m_iAmmo", _, FlashbangOffset);
}
stock GetClientDefuse(client)
{
	return GetEntProp(client, Prop_Send, "m_bHasDefuser");
}
stock SetClientWeaponsVisibility(client, int amout)
{
	int weapon;
	for (int i = 0; i <= CS_SLOT_C4; i++)
	{
		if ((weapon = GetPlayerWeaponSlot(client, i)) != -1)
		{
			if (IsValidEdict(weapon))
			{
				SetEntityVisibility(weapon, amout);
				SetEntityAlpha(weapon,amout);
			}
		}
	}
}

stock SetEntityVisibility(entity, amout)
{
	SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
	SetEntityRenderColor(entity, 255, 255, 255, amout);
}
stock Entity_GetRenderColor(entity, color[4])
{
	static bool gotconfig = false;
	static char prop[32];

	if (!gotconfig) {
		Handle gc = LoadGameConfigFile("core.games");
		bool exists = GameConfGetKeyValue(gc, "m_clrRender", prop, sizeof(prop));
		CloseHandle(gc);

		if (!exists) {
			strcopy(prop, sizeof(prop), "m_clrRender");
		}

		gotconfig = true;
	}

	int offset = GetEntSendPropOffs(entity, prop);

	if (offset <= 0) {
		ThrowError("SetEntityRenderColor not supported by this mod");
	}

	for (int i=0; i < 4; i++)
	{
		color[i] = GetEntData(entity, offset + i, 1);
	}
}
stock Entity_SetRenderColor(entity, r=-1, g=-1, b=-1, a=-1)
{
	static bool gotconfig = false;
	static char prop[32];

	if (!gotconfig) {
		Handle gc = LoadGameConfigFile("core.games");
		bool exists = GameConfGetKeyValue(gc, "m_clrRender", prop, sizeof(prop));
		CloseHandle(gc);

		if (!exists) {
			strcopy(prop, sizeof(prop), "m_clrRender");
		}

		gotconfig = true;
	}

	int offset = GetEntSendPropOffs(entity, prop);

	if (offset <= 0) {
		ThrowError("SetEntityRenderColor not supported by this mod");
	}

	if(r != -1) {
		SetEntData(entity, offset, r, 1, true);
	}

	if(g != -1) {
		SetEntData(entity, offset + 1, g, 1, true);
	}

	if(b != -1) {
		SetEntData(entity, offset + 2, b, 1, true);
	}

	if(a != -1) {
		SetEntData(entity, offset + 3, a, 1, true);
	}
}
stock SetEntityAlpha(index,alpha)
{
	char class[32];
	GetEntityNetClass(index, class, sizeof(class) );
	if(FindSendPropOffs(class,"m_nRenderFX") >- 1)
	{
	  SetEntityRenderMode(index,RENDER_TRANSCOLOR);
	  Entity_SetRenderColor(index,255,255,255,alpha);
	}
}
stock GetPlayerEyeViewPoint(iClient, float fPosition[3])
{
	float fAngles[3];
	GetClientEyeAngles(iClient, fAngles);

	float fOrigin[3];
	GetClientEyePosition(iClient, fOrigin);

	Handle hTrace = TR_TraceRayFilterEx(fOrigin, fAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if(TR_DidHit(hTrace))
	{
		TR_GetEndPosition(fPosition, hTrace);
		CloseHandle(hTrace);
		return true;
	}
	CloseHandle(hTrace);
	return false;
}
public bool TraceEntityFilterPlayer(iEntity, iContentsMask)
{
	return iEntity > GetMaxClients();
}
