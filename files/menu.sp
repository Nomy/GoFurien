public ShowCTSpawnMenu(client)
{
  int points = Furien_GetClientPoints(client);
  char string[64];
  Menu CTSpawnMenu = CreateMenu(h_CTSpawnMenu);
  Format(string, sizeof(string), "- Výběr zbraně [!zbran] - Máš %d$",points);
  CTSpawnMenu.SetTitle(string);
  CTSpawnMenu.AddItem("weapon_nova", "Nova");
  CTSpawnMenu.AddItem("weapon_ump45", "Ump45");

  AddWeaponToMenu(CTSpawnMenu, "weapon_awp", "AWP",points, i_ShopAWPCost);
  AddWeaponToMenu(CTSpawnMenu, "weapon_mp7", "MP7",points, i_ShopMP7Cost);
  AddWeaponToMenu(CTSpawnMenu, "weapon_m4a1", "M4A4",points, i_ShopM4A4Cost);
  AddWeaponToMenu(CTSpawnMenu, "weapon_ak47", "AK47",points, i_ShopAK47Cost);

  CTSpawnMenu.ExitButton = false;
  CTSpawnMenu.Display(client, MENU_TIME_FOREVER);
}
public h_CTSpawnMenu(Menu CTSpawnMenu, MenuAction action, client, Position)
{
  if(action == MenuAction_Select && GetClientTeam(client) == CS_TEAM_CT && IsPlayerAlive(client))
  {
    char Item[20];
    CTSpawnMenu.GetItem(Position, Item, sizeof(Item));
    GivePlayerItem(client,Item);
    PlayerSelectWeapon[client] = true;
    if(GetWeaponCost(Item) > 0) Furien_RemoveClientPoints(client, GetWeaponCost(Item));
    ShowCTSpawnMenuSecondary(client);
  }
}
public ShowCTSpawnMenuSecondary(client)
{
  int points = Furien_GetClientPoints(client);
  char string[64];
  Menu CTSpawnMenuSec = CreateMenu(h_CTSpawnMenuSec);
  Format(string, sizeof(string), "- Výběr pistole [!zbran] - Máš %d$",points);
  CTSpawnMenuSec.SetTitle(string);
  CTSpawnMenuSec.AddItem("weapon_glock", "Glock");
  CTSpawnMenuSec.AddItem("weapon_hkp2000", "USP/P2000");

  AddWeaponToMenu(CTSpawnMenuSec, "weapon_p250", "P250",points, i_ShopP250Cost);
  AddWeaponToMenu(CTSpawnMenuSec, "weapon_fiveseven", "Five-seven",points, i_ShopFSCost);
  AddWeaponToMenu(CTSpawnMenuSec, "weapon_deagle", "Deagle",points, i_ShopDeagleCost);

  CTSpawnMenuSec.ExitButton = false;
  CTSpawnMenuSec.Display(client, MENU_TIME_FOREVER);
}
public h_CTSpawnMenuSec(Menu CTSpawnMenuSec, MenuAction action, client, Position)
{
  if(action == MenuAction_Select && GetClientTeam(client) == CS_TEAM_CT && IsPlayerAlive(client))
  {
    char Item[20];
    CTSpawnMenuSec.GetItem(Position, Item, sizeof(Item));
    GivePlayerItem(client,Item);
    if(GetSecWeaponCost(Item) > 0) Furien_RemoveClientPoints(client, GetSecWeaponCost(Item));
    ShowFurienMenu(client);
  }
}
public ShowTShop(client)
{
  if(IsValidClient(client))
  {
    int points = Furien_GetClientPoints(client);
    char string[256];
    Format(string, sizeof(string), "- Furien Obchod - Máš: %d$", points);
    Menu FurienShop = CreateMenu(h_FurienShop);
    FurienShop.SetTitle(string);

    Format(string, sizeof(string), "HE granát [%d$]", i_ShopHEgrenadeCost);
    if(!b_ShopHeGrenade[client] && points >= i_ShopHEgrenadeCost) FurienShop.AddItem("hegrenade", string);
    else FurienShop.AddItem("hegrenade", string, ITEMDRAW_DISABLED);

    Format(string, sizeof(string), "+40 Životů [%d$]", i_Shop50HPCost);
    if(i_Shop50HP[client] < 1 && points >= i_Shop50HPCost){ FurienShop.AddItem("50hp", string); }
    else { FurienShop.AddItem("50hp", string, ITEMDRAW_DISABLED);  }

    Format(string, sizeof(string), "Super Nůž [%d$]", i_ShopSuperKnifeCost);
    if(!PlayerOneRoundSuperKnife[client] && points >= i_ShopSuperKnifeCost) FurienShop.AddItem("superknife", string);
    else FurienShop.AddItem("superknife", string, ITEMDRAW_DISABLED);

    Format(string, sizeof(string), "Electric Gun [%d$]", i_ShopElectricGunCost);
    if(points >= i_ShopElectricGunCost) FurienShop.AddItem("electricgun", string);
    else FurienShop.AddItem("electricgun", string, ITEMDRAW_DISABLED);

    if(!IsPlayerVIP(client))  FurienShop.AddItem("regenhp", "Regenerace HP [VIP]", ITEMDRAW_DISABLED);
    else
    {
      Format(string, sizeof(string), "Regenerace HP [%d$]", i_VIPShopRegenHPCost);
      if(!b_VipShopRegenHP[client] && points >= i_VIPShopRegenHPCost) FurienShop.AddItem("regenhp", string);
      else  FurienShop.AddItem("regenhp", string, ITEMDRAW_DISABLED);
    }

    if(!IsPlayerVIP(client))  FurienShop.AddItem("multijump", "Multi-Jump [VIP]", ITEMDRAW_DISABLED);
    else
    {
      Format(string, sizeof(string), "Multi-Jump [%d$]", i_VIPShopMultiJumpCost);
      if(!b_VipShopMultiJump[client] && points >= i_VIPShopMultiJumpCost) FurienShop.AddItem("multijump", string);
      else FurienShop.AddItem("multijump", string, ITEMDRAW_DISABLED);
    }
    /*if(!IsPlayerVIP(client))  FurienShop.AddItem("speedup", "Rychlejší běh [VIP]", ITEMDRAW_DISABLED);
    else
    {
      Format(string, sizeof(string), "Rychlejší běh (F) [%d$]", i_VIPShopSpeedUpCost);
      if(!b_VipShopSpeedUp[client] && points >= i_VIPShopSpeedUpCost) FurienShop.AddItem("speedup", string);
      else FurienShop.AddItem("speedup", string, ITEMDRAW_DISABLED);
    }*/

    FurienShop.ExitButton = true;
    FurienShop.Display(client, 10);
  }
}
public h_FurienShop(Menu FurienShop, MenuAction action, client, Position)
{
  if(action == MenuAction_Select && GetClientTeam(client) == CS_TEAM_T)
  {
    char Item[20];
    FurienShop.GetItem(Position, Item, sizeof(Item));
    if(StrEqual(Item, "50hp"))
    {
      SetEntityHealth(client, GetClientHealth(client)+40);
      Furien_RemoveClientPoints(client, i_Shop50HPCost);
      i_Shop50HP[client]++;
      PrintToChat(client, "%s Předmět \x10+40HP\x01 máš pouze na jedno kolo", TAG);
    }
    if(StrEqual(Item, "hegrenade"))
    {
      GivePlayerItem(client, "weapon_hegrenade");
      b_ShopHeGrenade[client] = true;
      Furien_RemoveClientPoints(client, i_ShopHEgrenadeCost);
    }
    if(StrEqual(Item, "superknife"))
    {
      PlayerOneRoundSuperKnife[client] = true;
      Furien_RemoveClientPoints(client, i_ShopSuperKnifeCost);
      PrintToChat(client, "%s Předmět \x10Super Nůž\x01 máš pouze na jedno kolo", TAG);
    }
    if(StrEqual(Item, "electricgun"))
    {
      GivePlayerItem(client, "weapon_taser");
      Furien_RemoveClientPoints(client, i_ShopElectricGunCost);
    }
    if(StrEqual(Item, "multijump"))
    {
      b_VipShopMultiJump[client] = true;
      Furien_RemoveClientPoints(client, i_VIPShopMultiJumpCost);
      Furien_BoughtVIPItem(client, 5);
    }
    if(StrEqual(Item, "speedup"))
    {
      b_VipShopSpeedUp[client] = true;
      Furien_RemoveClientPoints(client, i_VIPShopSpeedUpCost);
      Furien_BoughtVIPItem(client, 4);
    }
    if(StrEqual(Item, "regenhp"))
    {
      b_VipShopRegenHP[client] = true;
      Furien_RemoveClientPoints(client, i_VIPShopRegenHPCost);
      Furien_BoughtVIPItem(client, 6);
    }
    char value[12];
    GetClientCookie(client, g_clientcookie, value, sizeof(value));
    if(StrEqual(value , ""))
    {
      ShowTShop(client);
    }
  }
}
public ShowCTShop(client)
{
  if(IsValidClient(client))
  {
    int points = Furien_GetClientPoints(client);
    char string[256];
    Format(string, sizeof(string), "- Anti-Furien Obchod - Máš: %d$", points);
    Menu AntiFurienShop = CreateMenu(h_AntiFurienShop);
    AntiFurienShop.SetTitle(string);

    Format(string, sizeof(string), "Defusky [%d$]", i_ShopDefuseCost);
    if(GetClientDefuse(client) != 1 && points >= i_ShopDefuseCost){AntiFurienShop.AddItem("defuse", string);}
    else {AntiFurienShop.AddItem("defuse", string, ITEMDRAW_DISABLED);}

    Format(string, sizeof(string), "+100 Vesty+Helma [%d$]", i_ShopArmorCost);
    if(GetClientArmor(client) != 100 && points >= i_ShopArmorCost){AntiFurienShop.AddItem("100ap", string);}
    else {AntiFurienShop.AddItem("100ap", string, ITEMDRAW_DISABLED);}

    Format(string, sizeof(string), "+40 Životů [%d$]", i_Shop50HPCost);
    if(i_Shop50HP[client] < 1 && points >= i_Shop50HPCost) AntiFurienShop.AddItem("50hp", string);
    else AntiFurienShop.AddItem("50hp", string, ITEMDRAW_DISABLED);

    Format(string, sizeof(string), "Rychlost [%d$]", i_ShopAmfetaminCost);
    if(IsPlayerVIP(client))
    {
      if(!PlayerOneRoundAmfetamin[client] && points >= i_ShopAmfetaminCost) AntiFurienShop.AddItem("rychlost", string);
      else AntiFurienShop.AddItem("rychlost", string, ITEMDRAW_DISABLED);
    }
    else AntiFurienShop.AddItem("rychlost", "Rychlost [VIP]", ITEMDRAW_DISABLED);

    if(!IsPlayerVIP(client))  AntiFurienShop.AddItem("regenhp", "Regenerace HP [VIP]", ITEMDRAW_DISABLED);
    else
    {
      Format(string, sizeof(string), "Regenerace HP [%d$]", i_VIPShopRegenHPCost);
      if(!b_VipShopRegenHP[client] && points >= i_VIPShopRegenHPCost) AntiFurienShop.AddItem("regenhp", string);
      else  AntiFurienShop.AddItem("regenhp", string, ITEMDRAW_DISABLED);
    }

    if(!IsPlayerVIP(client))  AntiFurienShop.AddItem("multijump", "Multi-Jump [VIP]", ITEMDRAW_DISABLED);
    else
    {
      Format(string, sizeof(string), "Multi-Jump [%d$]", i_VIPShopMultiJumpCost);
      if(!b_VipShopMultiJump[client] && points >= i_VIPShopMultiJumpCost) AntiFurienShop.AddItem("multijump", string);
      else AntiFurienShop.AddItem("multijump", string, ITEMDRAW_DISABLED);
    }
    /*if(!IsPlayerVIP(client))  AntiFurienShop.AddItem("speedup", "Rychlejší běh [VIP]", ITEMDRAW_DISABLED);
    else
    {
      Format(string, sizeof(string), "Rychlejší běh (F) [%d$]", i_VIPShopSpeedUpCost);
      if(!b_VipShopSpeedUp[client] && points >= i_VIPShopSpeedUpCost) AntiFurienShop.AddItem("speedup", string);
      else AntiFurienShop.AddItem("speedup", string, ITEMDRAW_DISABLED);
    }*/
    AntiFurienShop.ExitButton = true;
    AntiFurienShop.Display(client, MENU_TIME_FOREVER);
  }
}
public h_AntiFurienShop(Menu AntiFurienShop, MenuAction:action, client, Position)
{
  if(action == MenuAction_Select && GetClientTeam(client) == CS_TEAM_CT)
  {
    char Item[20];
    AntiFurienShop.GetItem(Position, Item, sizeof(Item));
    if(StrEqual(Item, "50hp"))
    {
      SetEntityHealth(client, GetClientHealth(client)+40);
      Furien_RemoveClientPoints(client, i_Shop50HPCost);
      i_Shop50HP[client]++;
      PrintToChat(client, "%s Předmět \x10+40HP\x01 máš pouze na jedno kolo", TAG);
    }
    if(StrEqual(Item, "100ap"))
    {
      SetEntProp(client, Prop_Send, "m_ArmorValue", 100);
      SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
      Furien_RemoveClientPoints(client, i_ShopArmorCost);
      PrintToChat(client, "%s Předmět \x10+100 Vesty+Helma\x01 máš pouze na jedno kolo", TAG);
    }
    if(StrEqual(Item, "defuse"))
    {
      SetEntProp(client, Prop_Send, "m_bHasDefuser", 1);
      Furien_RemoveClientPoints(client, i_ShopDefuseCost);
      PrintToChat(client, "%s Předmět \x10Defusky\x01 máš pouze na jedno kolo", TAG);
    }
    if(StrEqual(Item, "rychlost"))
    {
      PlayerOneRoundAmfetamin[client] = true;
      Furien_RemoveClientPoints(client, i_ShopAmfetaminCost);
    }
    if(StrEqual(Item, "multijump"))
    {
      b_VipShopMultiJump[client] = true;
      Furien_RemoveClientPoints(client, i_VIPShopMultiJumpCost);
      Furien_BoughtVIPItem(client, 5);
    }
    if(StrEqual(Item, "speedup"))
    {
      b_VipShopSpeedUp[client] = true;
      Furien_RemoveClientPoints(client, i_VIPShopSpeedUpCost);
      Furien_BoughtVIPItem(client, 4);
    }
    if(StrEqual(Item, "regenhp"))
    {
      b_VipShopRegenHP[client] = true;
      Furien_RemoveClientPoints(client, i_VIPShopRegenHPCost);
      Furien_BoughtVIPItem(client, 6);
    }
    char value[12];
    GetClientCookie(client, g_clientcookie, value, sizeof(value));
    if(StrEqual(value , ""))
    {
      ShowCTShop(client);
    }
  }
}
public ShowFurienMenu(client)
{
  {
    Menu FurienMenu = CreateMenu(h_FurienMenu);
    char buffer[128];
    if(GetClientTeam(client) == CS_TEAM_CT) Format(buffer, sizeof(buffer), "- Anti-Furien Menu - \n ------------------------------------");
    else if(GetClientTeam(client) == CS_TEAM_T) Format(buffer, sizeof(buffer), "- Furien Menu - \n ------------------------------------");
    else Format(buffer, sizeof(buffer), "- Furien Menu - \n ------------------------------------");
    FurienMenu.SetTitle(buffer);
    if(GetClientTeam(client) == CS_TEAM_CT)
    {
      if(!PlayerSelectWeapon[client]) FurienMenu.AddItem("vyberzbrane", "Výběr zbrane");
      else FurienMenu.AddItem("vyberzbrane", "Výběr zbrane", ITEMDRAW_DISABLED);
    }
    else if(GetClientTeam(client) == CS_TEAM_T)
    {
      if(!PlayerHeckle[client]) FurienMenu.AddItem("heckle", "Provokovat");
      else FurienMenu.AddItem("heckle", "Provokovat", ITEMDRAW_DISABLED);
    }
    FurienMenu.AddItem("openshop", "Obchod");
    FurienMenu.AddItem("informace", "Informace");
    FurienMenu.AddItem("popishry", "Popis hry");
    FurienMenu.AddItem("nastaveni", "Nastavení");
    FurienMenu.AddItem("aktivovatvip", "Aktivovat VIP/EVIP");
    FurienMenu.ExitButton = true;
    FurienMenu.Display(client, MENU_TIME_FOREVER);
    /*
    char value[12];
    GetClientCookie(client, g_clientcookie, value, sizeof(value));
    if(StrEqual(value, "")) FurienMenu.AddItem("menu", "Nezavírat menu [ZAPNUTO]");
    else if(StrEqual(value, "1")) FurienMenu.AddItem("menu", "Nezavírat menu [VYPNUTO]");
    */
  }

}
public h_FurienMenu(Menu FurienMenu, MenuAction action, client, Position)
{
  if(action == MenuAction_Select)
  {
    char Item[20];
    FurienMenu.GetItem(Position, Item, sizeof(Item));
    if(StrEqual(Item, "vyberzbrane"))
    {
      ShowCTSpawnMenu(client);
    }
    if(StrEqual(Item, "heckle"))
    {
      ShowHeckleMenu(client);
    }
    if(StrEqual(Item, "openshop"))
    {
      if(GetClientTeam(client) == CS_TEAM_CT) ShowCTShop(client);
      else if(GetClientTeam(client) == CS_TEAM_T) ShowTShop(client);
    }
    if(StrEqual(Item, "informace"))
    {
      ShowHelpMenu(client);
    }
    if(StrEqual(Item, "popishry"))
    {
      if(IsValidClient(client))
      {
        ShowMOTDPanel(client, "www.GameSites.cz", "http://fastdl.gamesites.cz/global/motd/info_furien.html", MOTDPANEL_TYPE_URL);
      }
    }
    if(StrEqual(Item, "nastaveni"))
    {
      ShowSettingsMenu(client);
    }
    if(StrEqual(Item, "aktivovatvip"))
    {
      //ShowHelpMenu(client);
    }
  }
}
public ShowSettingsMenu(client)
{
  Menu FurienSettingsMenu = CreateMenu(h_FurienSettingsMenu);
  FurienSettingsMenu.SetTitle("- Nastavení -");

  char value[12];
  char buffer[64];
  GetClientCookie(client, g_clientcookie, value, sizeof(value));
  Format(buffer, sizeof(buffer), "Nezavírat menu [%s]", (StrEqual(value, "") ? "ZAPNUTO" : "VYPNUTO"));
  FurienSettingsMenu.AddItem("menu", buffer);

  GetClientCookie(client, g_clientcookieSound, value, sizeof(value));
  Format(buffer, sizeof(buffer), "Písničky na konci kola [%s]", (StrEqual(value, "") ? "ZAPNUTO" : "VYPNUTO"));
  FurienSettingsMenu.AddItem("music", buffer);

  FurienSettingsMenu.ExitButton = true;
  FurienSettingsMenu.Display(client, MENU_TIME_FOREVER);
}
public h_FurienSettingsMenu(Menu FurienSettingsMenu, MenuAction action, client, Position)
{
  if(action == MenuAction_Select)
  {
    char Item[20];
    FurienSettingsMenu.GetItem(Position, Item, sizeof(Item));
    if(StrEqual(Item, "menu"))
    {
      char value[12];
      GetClientCookie(client, g_clientcookie, value, sizeof(value));
      if(StrEqual(value , ""))  SetClientCookie(client, g_clientcookie, "1");
      else if(StrEqual(value, "1")) SetClientCookie(client, g_clientcookie, "");
      ShowSettingsMenu(client);
    }
    if(StrEqual(Item, "music"))
    {
      char value[12];
      GetClientCookie(client, g_clientcookieSound, value, sizeof(value));
      if(StrEqual(value , ""))  SetClientCookie(client, g_clientcookieSound, "1");
      else if(StrEqual(value, "1")) SetClientCookie(client, g_clientcookieSound, "");
      ShowSettingsMenu(client);
    }
  }
}
public ShowHelpMenu(client)
{
  Menu FurienNapovedaMenu = CreateMenu(h_FurienNapovedaMenu);
  char buffer[1024];
  Format(buffer,sizeof(buffer),"- Nápověda -");
  Format(buffer,sizeof(buffer),"%s\n---------------------------------------------------",buffer);
  Format(buffer,sizeof(buffer),"%s\nPříkazy:\n  !shop/!obchod - Otevře menu s obchodem\n  !furien - Otevře hlavní menu\n  !zbran - Otevře výběr zbraní (A-F)\n  !help - Otevře menu s nápovědou\n  !music - Zapne/Vypne hudbu na konci kola",buffer);
  Format(buffer,sizeof(buffer),"%s\n---------------------------------------------------",buffer);
  Format(buffer,sizeof(buffer),"%s\nVysvětlivky:\n  A-F = Anti-Furien\n  F = Furien",buffer);
  FurienNapovedaMenu.SetTitle(buffer);
  FurienNapovedaMenu.AddItem("close", "Exit");
  FurienNapovedaMenu.ExitButton = false;
  FurienNapovedaMenu.Display(client, MENU_TIME_FOREVER);
}
public ShowHeckleMenu(client)
{
  Menu FurienHeckleMenu = CreateMenu(h_FurienHeckleMenu);
  FurienHeckleMenu.SetTitle("- Provokovat - \n ---------------------");
  FurienHeckleMenu.AddItem("behindyou", "Behind you");
  FurienHeckleMenu.AddItem("imhere", "I'm Here");
  FurienHeckleMenu.AddItem("iseeyou", "I see you");
  FurienHeckleMenu.AddItem("turnaround", "Turn around");
  if(IsPlayerVIP(client)) FurienHeckleMenu.AddItem("mynameisjeff", "My name is Jeff");
  else FurienHeckleMenu.AddItem("mynameisjeff", "My name is Jeff [VIP]", ITEMDRAW_DISABLED);
  FurienHeckleMenu.ExitButton = true;
  FurienHeckleMenu.Display(client, MENU_TIME_FOREVER);
}
public h_FurienHeckleMenu(Menu FurienHeckleMenu, MenuAction:action, client, Position)
{
  if(action == MenuAction_Select && GetClientTeam(client) == CS_TEAM_T)
  {
    int color[MAXPLAYERS+1][4];
    Entity_GetRenderColor(client,color[client]);
    char Item[20];
    if(PlayerHeckle[client] == false)
    {
      if(color[client][3] == 0 && IsPlayerInvisible[client])
      {
        FurienHeckleMenu.GetItem(Position, Item, sizeof(Item));
        if(StrEqual(Item, "behindyou"))
        {
          EmitSoundToAllAny("GameSites/gs_heckle/behindyou.mp3", client);
        }
        if(StrEqual(Item, "imhere"))
        {
          EmitSoundToAllAny("GameSites/gs_heckle/imhere.mp3", client);
        }
        if(StrEqual(Item, "iseeyou"))
        {
          EmitSoundToAllAny("GameSites/gs_heckle/iseeyou.mp3", client);
        }
        if(StrEqual(Item, "turnaround"))
        {
          EmitSoundToAllAny("GameSites/gs_heckle/turnaround.mp3", client);
        }
        if(StrEqual(Item, "mynameisjeff"))
        {
          EmitSoundToAllAny("GameSites/gs_heckle/mynameisjeff1.mp3", client);
        }
      }
      else PrintToChat(client,"%s Musíš být neviditelný pokud chceš provokovat", TAG);
    }
    else PrintToChat(client,"%s Provokovat lze jednou za 5 vteřin", TAG);
    CreateTimer(5.0, Timer_AllowHeckle, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
    char value[12];
    GetClientCookie(client, g_clientcookie, value, sizeof(value));
    PlayerHeckle[client] = true;
    if(StrEqual(value , ""))
    {
      ShowHeckleMenu(client);
    }
  }
}
public h_FurienNapovedaMenu(Menu FurienNapovedaMenu, MenuAction action, client, Position)
{
  if(action == MenuAction_Select)
  {
    char Item[20];
    FurienNapovedaMenu.GetItem(Position, Item, sizeof(Item));
    if(StrEqual(Item, "close"))
    {
      FurienNapovedaMenu.Close();
    }
  }
}
