Handle hAdminMenu = INVALID_HANDLE;
public AdminMenu_OnPluginStart()
{
  Handle topmenu;
  if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != INVALID_HANDLE))
  {
    OnAdminMenuReady(topmenu);
  }
}
public OnLibraryRemoved(const String:name[])
{
	if (StrEqual(name, "adminmenu"))
    hAdminMenu = INVALID_HANDLE;
}
public OnAdminMenuReady(Handle topmenu)
{
  if (topmenu == hAdminMenu) {return;}

  hAdminMenu = topmenu;
  new TopMenuObject:furienCmds = FindTopMenuCategory(hAdminMenu, ADMINMENU_SERVERCOMMANDS);
  AddToTopMenu(hAdminMenu, "sm_adminfurien", TopMenuObject_Item, FurienAdminMenuHandled, furienCmds, "sm_adminfurien", ADMFLAG_RCON);
}
public FurienAdminMenuHandled(Handle topmenu, TopMenuAction:action, TopMenuObject:object_id, client, char[] buffer, maxlength)
{
	if (action == TopMenuAction_DisplayOption)
  {
    Format(buffer, maxlength, "Furien Admin-Commands");
  }
	else if (action == TopMenuAction_SelectOption)
  {
    ShowFurienAdminMenu(client);
  }
}
ShowFurienAdminMenu(client)
{
  Menu FurienAdminMenu = CreateMenu(h_FurienAdminMenu);
  FurienAdminMenu.SetTitle("- Furien AdminMenu - \n ------------------------------------");
  FurienAdminMenu.AddItem("addpointsall", "Přidat body všem");
  FurienAdminMenu.AddItem("resetallstats", "Smazat veškerá data");
  FurienAdminMenu.ExitButton = true;
  FurienAdminMenu.Display(client, MENU_TIME_FOREVER);
}
public h_FurienAdminMenu(Handle FurienAdminMenu, MenuAction:action, client, Position)
{
  if(action == MenuAction_Select)
  {
    char Item[32];
    GetMenuItem(FurienAdminMenu, Position, Item, sizeof(Item));
    if(StrEqual(Item, "addpointsall"))
    {
      Menu FurienAdminMenuAddPointsAll = CreateMenu(h_FurienAdminMenuMenuAddPointsAll);
      FurienAdminMenuAddPointsAll.SetTitle("- Furien AdminMenu / Přidat body všem - \n ------------------------------------");
      FurienAdminMenuAddPointsAll.AddItem("10", "10");
      FurienAdminMenuAddPointsAll.AddItem("15", "15");
      FurienAdminMenuAddPointsAll.AddItem("20", "20");
      FurienAdminMenuAddPointsAll.AddItem("25", "25");
      FurienAdminMenuAddPointsAll.AddItem("50", "50");
      FurienAdminMenuAddPointsAll.AddItem("100", "100");
      FurienAdminMenuAddPointsAll.ExitButton = true;
      FurienAdminMenuAddPointsAll.Display(client, MENU_TIME_FOREVER);
    }
    if(StrEqual(Item, "resetallstats"))
    {
      Menu FurienAdminMenuWipe = CreateMenu(h_FurienAdminMenuMenuWipe);
      FurienAdminMenuWipe.SetTitle("- Furien AdminMenu / Opravdu smazat veškeré data - \n ------------------------------------");
      FurienAdminMenuWipe.AddItem("ne", "Ne");
      FurienAdminMenuWipe.AddItem("ne", "Ne");
      FurienAdminMenuWipe.AddItem("ne", "Ne");
      FurienAdminMenuWipe.AddItem("ano", "Ano");
      FurienAdminMenuWipe.AddItem("ne", "Ne");
      FurienAdminMenuWipe.AddItem("ne", "Ne");
      FurienAdminMenuWipe.ExitButton = true;
      FurienAdminMenuWipe.Display(client, MENU_TIME_FOREVER);
    }
  }
}
public h_FurienAdminMenuMenuWipe(Handle FurienAdminMenuWipe, MenuAction:action, client, Position)
{
  if(action == MenuAction_Select)
  {
    char Item[20];
    GetMenuItem(FurienAdminMenuWipe, Position, Item, sizeof(Item));
    if(StrEqual(Item, "ano"))
    {
      Furien_WipeMysqlData(client);
    }
  }
}
public h_FurienAdminMenuMenuAddPointsAll(Handle FurienAdminMenuAddPointsAll, MenuAction:action, client, Position)
{
  if(action == MenuAction_Select)
  {
    char Item[20];
    GetMenuItem(FurienAdminMenuAddPointsAll, Position, Item, sizeof(Item));
    if(StrEqual(Item, "10"))
    {
      Furien_AddPointsToAll(10);
    }
    if(StrEqual(Item, "15"))
    {
      Furien_AddPointsToAll(15);
    }
    if(StrEqual(Item, "20"))
    {
      Furien_AddPointsToAll(20);
    }
    if(StrEqual(Item, "25"))
    {
      Furien_AddPointsToAll(25);
    }
    if(StrEqual(Item, "50"))
    {
      Furien_AddPointsToAll(50);
    }
    if(StrEqual(Item, "100"))
    {
      Furien_AddPointsToAll(100);
    }
  }
}
