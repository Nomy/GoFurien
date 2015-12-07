public Knife_OnPluginStart()
{
	h_KnifeCookies = RegClientCookie("furien_knife", "", CookieAccess_Private);
}
public Knife_OnClientPutInServer(client)
{
	char value[16];
	GetClientCookie(client, h_KnifeCookies, value, sizeof(value));
	if(strlen(value) > 0)
	{
		furien_knife[client] = StringToInt(value);
	}
}
public Action:Event_OnPlayerSpawn_Post(Handle event, const char[] name, bool dontbroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsValidClient(client) && !IsFakeClient(client))
	{
		CreateTimer(0.0, CheckKnife, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Furien_KnifeMenu(client)
{
	Menu FurienKnife = CreateMenu(h_FurienKnife);
	FurienKnife.SetTitle("Zvol si jeden nůž");
	FurienKnife.AddItem("default","Default");
	FurienKnife.AddItem("bayonet","Bayonet");
	FurienKnife.AddItem("gut","Gut");
	FurienKnife.AddItem("flip","Flip");
	FurienKnife.AddItem("m9bayonet","M9-Bayonet");
	FurienKnife.AddItem("karambit","Karambit");
	FurienKnife.AddItem("huntsman","Huntsman");
	FurienKnife.AddItem("butterfly","Butterfly");
	FurienKnife.AddItem("gold","Gold");
	FurienKnife.ExitButton = true;
	FurienKnife.Display(client, 15);
}
public h_FurienKnife(Handle FurienKnife, MenuAction:action, client, Position)
{
	if(action == MenuAction_Select)
	{
		char Item[32];
		GetMenuItem(FurienKnife, Position, Item, sizeof(Item));
		if(StrEqual(Item, "default")){ SetDefault(client); }
		if(StrEqual(Item, "bayonet")){ SetBayonet(client); }
		if(StrEqual(Item, "gut")){ SetGut(client); }
		if(StrEqual(Item, "flip")){ SetFlip(client); }
		if(StrEqual(Item, "m9bayonet")){ SetM9(client); }
		if(StrEqual(Item, "karambit")){ SetKarambit(client); }
		if(StrEqual(Item, "huntsman")){ SetHuntsman(client); }
		if(StrEqual(Item, "butterfly")){ SetButterfly(client); }
		if(StrEqual(Item, "gold")){ SetGolden(client); }
	}
}
SetDefault(client)
{
	furien_knife[client] = 0;
	SetClientCookie(client, h_KnifeCookies, "0");
	CreateTimer(0.1, CheckKnife, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
}
SetBayonet(client)
{
	furien_knife[client] = 1;
	SetClientCookie(client, h_KnifeCookies, "1");
	CreateTimer(0.1, CheckKnife, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
}
SetGut(client)
{
	furien_knife[client] = 2;
	SetClientCookie(client, h_KnifeCookies, "2");
	CreateTimer(0.1, CheckKnife, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
}
SetFlip(client)
{
	furien_knife[client] = 3;
	SetClientCookie(client, h_KnifeCookies, "3");
	CreateTimer(0.1, CheckKnife, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
}
SetM9(client)
{
	furien_knife[client] = 4;
	SetClientCookie(client, h_KnifeCookies, "4");
	CreateTimer(0.1, CheckKnife, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
}
SetKarambit(client)
{
	furien_knife[client] = 5;
	SetClientCookie(client, h_KnifeCookies, "5");
	CreateTimer(0.1, CheckKnife, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
}
SetHuntsman(client)
{
	furien_knife[client] = 6;
	SetClientCookie(client, h_KnifeCookies, "6");
	CreateTimer(0.1, CheckKnife, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
}
SetButterfly(client)
{
	furien_knife[client] = 7;
	SetClientCookie(client, h_KnifeCookies, "7");
	CreateTimer(0.1, CheckKnife, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
}
SetGolden(client)
{
	furien_knife[client] = 8;
	SetClientCookie(client, h_KnifeCookies, "8");
	CreateTimer(0.1, CheckKnife, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);
}
public Action:CheckKnife(Handle:timer, any:serial)
{
	int client = GetClientFromSerial(serial);

	if(IsValidClient(client,true) && !IsFakeClient(client))
	{
		if(Client_RemoveWeaponKnife(client, "weapon_knife", true))
		{
			Equipknife(client);
		}
		else
		{
			Equipknife(client);
		}
	}
	return Plugin_Handled;
}
public Action:Equipknife(client)
{
	if (furien_knife[client] < 0 || furien_knife[client] > 9) furien_knife[client] = 0;
	if (furien_knife[client] >= 0)
	{
		int iItem;
		switch(furien_knife[client])
		{
			case 0:iItem = GivePlayerItem(client, "weapon_knife");
			case 1:iItem = GivePlayerItem(client, "weapon_bayonet");
			case 2:iItem = GivePlayerItem(client, "weapon_knife_gut");
			case 3:iItem = GivePlayerItem(client, "weapon_knife_flip");
			case 4:iItem = GivePlayerItem(client, "weapon_knife_m9_bayonet");
			case 5:iItem = GivePlayerItem(client, "weapon_knife_karambit");
			case 6:iItem = GivePlayerItem(client, "weapon_knife_tactical");
			case 7:iItem = GivePlayerItem(client, "weapon_knife_butterfly");
			case 8:iItem = GivePlayerItem(client, "weapon_knifegg");
			default: return;
		}
		if (iItem > 0)
		{
			EquipPlayerWeapon(client, iItem);
		}
	}
}
