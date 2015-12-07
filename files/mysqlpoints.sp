public SQLlite_OnMapStart()
{
  db = SQL_Connect("furien",true, Error, sizeof(Error));

  if(db == INVALID_HANDLE)
  {
    SQL_GetError(db, Error, sizeof(Error));
    SetFailState("\n\n\n[Furien] Cannost connect to the DB: %s\n\n\n", Error);
  }

  SQL_Query(db, "CREATE TABLE IF NOT EXISTS furiendata (username VARCHAR(128), steamid VARCHAR(32), points INT(32), vip_roundstarthp INT(32), vip_speedup INT(32), vip_multijump INT(32), vip_healthregen INT(32))");
  SQL_Query(db, "SET CHARACTER SET utf8");
  PrintToServer("[FurienMod] Connected to MySQL successfuly");
}
public SQLlite_OnClientPutInServer(client)
{
  if(IsValidClient(client) && !IsFakeClient(client))
  {
    GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
    Format (s_query, sizeof(s_query), "SELECT * FROM furiendata WHERE steamid='%s'", steamid);
    SQL_TQuery(db, SQLlite_OnGetPlayer, s_query, client);
    LoadVIPShop(client);
  }
}
public SQLlite_OnGetPlayer(Handle owner, Handle query, const char[] error, any client)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[Furien] SQL-Query failed! Error: %s", error);
  }
  else
  {
    if(!SQL_FetchRow(query))
    {
      GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
      Format(s_query, sizeof(s_query), "INSERT INTO furiendata (username,steamid,points,vip_roundstarthp,vip_speedup,vip_multijump,vip_healthregen) VALUES ('%N','%s','0','0','0','0','0')",client, steamid);
      SQL_TQuery(db, SQLlite_OnInsertPlayerToDB, s_query, client);
    }
    else
    {
      char username[32];
      char current_username[32];
      GetClientName(client, current_username, sizeof(current_username));
      SQL_FetchString(query, 0, username, sizeof(username));
      if(!StrEqual(username, current_username))
      {
        Handle datapack = CreateDataPack();
        WritePackString(datapack, username);
        WritePackString(datapack, current_username);
        Format(s_query, sizeof(s_query), "UPDATE furiendata SET username='%N' WHERE steamid='%s'", client, steamid);
        SQL_TQuery(db, SQLlite_OnUpdatePlayerName, s_query, datapack);
      }
    }
  }
  CloseHandle(query);
}
public SQLlite_OnInsertPlayerToDB(Handle owner, Handle query, const char[] error, any client)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[Furien] SQL-Query failed! Error: %s", Error);
  }
  else
  {
    GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
    LogToFile(logfile, "[Furien] Creating new player. Name: %N | SteamID: %s ", client, steamid);
  }
}
public SQLlite_OnUpdatePlayerName(Handle owner, Handle query, const char[] error, any datapack)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[Furien] SQL-Query failed! Error: %s", Error);
  }
  else
  {
    char oldname[32];
    char newname[32];
    ResetPack(datapack);
    ReadPackString(datapack, oldname, sizeof(oldname));
    ReadPackString(datapack, newname, sizeof(newname));
    LogToFile(logfile, "[Furien] Updating client name. Old Name: %s | New name: %s ", oldname, newname);
  }
}
public LoadVIPShop(client)
{
  if(IsValidClient(client) && !IsFakeClient(client))
  {
    GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
    Format (s_query, sizeof(s_query), "SELECT * FROM furiendata WHERE steamid='%s'", steamid);
    SQL_TQuery(db, SQLlite_OnLoadVIPShop, s_query, client);
  }
}
public SQLlite_OnLoadVIPShop(Handle owner, Handle query, const char[] error, any client)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[Furien] SQL-Query failed! Error: %s", Error);
  }
  else
  {
    if(SQL_FetchRow(query))
    {
      int i_vipshopCheck;

      i_vipshopCheck = SQL_FetchInt(query, 4);
      if(i_vipshopCheck == 1)
      {
        b_VipShopSpeedUp[client] = true;
      }
      else b_VipShopSpeedUp[client] = false;

      i_vipshopCheck = SQL_FetchInt(query, 5);
      if(i_vipshopCheck == 1)
      {
        b_VipShopMultiJump[client] = true;
      }
      else b_VipShopMultiJump[client] = false;

      i_vipshopCheck = SQL_FetchInt(query, 6);
      if(i_vipshopCheck == 1)
      {
        b_VipShopRegenHP[client] = true;
      }
      else b_VipShopRegenHP[client] = false;
    }
  }
}
stock Furien_WipeMysqlData(client)
{
  Format (s_query, sizeof(s_query), "TRUNCATE TABLE furiendata");
  Handle hQuery = SQL_Query(db, s_query);
  if(hQuery == INVALID_HANDLE)
  {
    SQL_GetError(db, Error, sizeof(Error));
    LogError("[Furien] SQL-Query failed! Error: %s", Error);
  }
  PrintToChat(client, "[Furien] MySQL databáze byla promazána");
  CloseHandle(hQuery);
}
stock Furien_BoughtVIPItem(client, item)
{
  GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
  Format (s_query, sizeof(s_query), "SELECT * FROM furiendata WHERE steamid='%s'", steamid);
  Handle datapack = CreateDataPack();
  WritePackCell(datapack, client);
  WritePackCell(datapack, item);
  SQL_TQuery(db, SQLlite_BoughtVIPItem, s_query, datapack);
}
public SQLlite_BoughtVIPItem(Handle owner, Handle query, const char[] error, any datapack)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[Furien] SQL-Query failed! Error: %s", Error);
  }
  else
  {
    if(SQL_FetchRow(query))
    {
      ResetPack(datapack);
      int client = ReadPackCell(datapack);
      int item = ReadPackCell(datapack);
      GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
      switch(item)
      {
        case 3: Format (s_query, sizeof(s_query), "UPDATE furiendata SET vip_roundstarthp='1' WHERE steamid='%s'",steamid);
        case 4: Format (s_query, sizeof(s_query), "UPDATE furiendata SET vip_speedup='1' WHERE steamid='%s'",steamid);
        case 5: Format (s_query, sizeof(s_query), "UPDATE furiendata SET vip_multijump='1' WHERE steamid='%s'",steamid);
        case 6: Format (s_query, sizeof(s_query), "UPDATE furiendata SET vip_healthregen='1' WHERE steamid='%s'",steamid);
      }
      SQL_TQuery(db, SQLlite_BoughtVIPIteamThread, s_query, client);
    }
  }
  CloseHandle(datapack);
  CloseHandle(query);
}
public SQLlite_BoughtVIPIteamThread(Handle owner, Handle query, const char[] error, any:client)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[Furien] SQL-Query failed! Error: %s", Error);
  }
  CloseHandle(query);
}
stock Furien_AddPointsToClient(client, points)
{
  GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
  Format (s_query, sizeof(s_query), "SELECT * FROM furiendata WHERE steamid='%s'", steamid);
  Handle datapack = CreateDataPack();
  WritePackCell(datapack, client);
  WritePackCell(datapack, points);
  SQL_TQuery(db, SQLlite_AddPointsToClient, s_query, datapack);
}
stock Furien_AddPointsToSteamID(const char[] s_steamid, points)
{
  Format (s_query, sizeof(s_query), "SELECT * FROM furiendata WHERE steamid='%s'", s_steamid);
  Handle datapack = CreateDataPack();
  WritePackString(datapack, s_steamid);
  WritePackCell(datapack, points);
  SQL_TQuery(db, SQLlite_AddPointsToSteamID, s_query, datapack);
}
public SQLlite_AddPointsToSteamID(Handle owner, Handle query, const char[] error, any datapack)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[Furien] SQL-Query failed! Error: %s", Error);
  }
  else
  {
    if(SQL_FetchRow(query))
    {
      ResetPack(datapack);
      ReadPackString(datapack, steamid, sizeof(steamid));
      int points = ReadPackCell(datapack);
      int query_points = SQL_FetchInt(query, 2);
      Format (s_query, sizeof(s_query), "UPDATE furiendata SET points='%d' WHERE steamid='%s'",query_points+points, steamid);
      SQL_Query(db, s_query);
    }
  }
  CloseHandle(datapack);
  CloseHandle(query);
}

stock Furien_AddPointsToAll(points)
{
  LoopClients(i)
  {
    if(IsValidClient(i) && !IsFakeClient(i))
    {
      Furien_AddPointsToClient(i, points);
    }
  }
}
public SQLlite_AddPointsToClient(Handle owner, Handle query, const char[] error, any datapack)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[Furien] SQL-Query failed! Error: %s", Error);
  }
  else
  {
    if(SQL_FetchRow(query))
    {
      ResetPack(datapack);
      int client = ReadPackCell(datapack);
      int points = ReadPackCell(datapack);
      int query_points = SQL_FetchInt(query, 2);
      GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
      Format (s_query, sizeof(s_query), "UPDATE furiendata SET points='%d' WHERE steamid='%s'",query_points+points, steamid);
      SQL_TQuery(db, SQLlite_AddedPointsToClient, s_query, client);
    }
  }
  CloseHandle(datapack);
  CloseHandle(query);
}
public SQLlite_AddedPointsToClient(Handle owner, Handle query, const char[] error, any:client)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[Furien] SQL-Query failed! Error: %s", Error);
  }
  CloseHandle(query);
}
stock Furien_GetClientPoints(client)
{
  int query_points = 0;
  if(IsValidClient(client))
  {
    GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
    Format (s_query, sizeof(s_query), "SELECT * FROM furiendata WHERE steamid='%s'", steamid);
    Handle querydb = SQL_Query(db, s_query);
    if(querydb == INVALID_HANDLE)
    {
      SQL_GetError(db, Error, sizeof(Error));
      LogError("[Furien] SQL-Query failed! Error: %s", Error);
    }
    else
    {
      if(SQL_FetchRow(querydb))
      {
        query_points = SQL_FetchInt(querydb, 2);
      }
    }
    CloseHandle(querydb);
  }
  return query_points;
}
stock Furien_RemoveClientPoints(client, points)
{
  if(IsValidClient(client))
  {
    GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
    Format (s_query, sizeof(s_query), "SELECT * FROM furiendata WHERE steamid='%s'", steamid);
    Handle datapack = CreateDataPack();
    WritePackCell(datapack, client);
    WritePackCell(datapack, points);
    SQL_TQuery(db, SQLlite_RemoveClientPoints, s_query, datapack);
  }
}
public SQLlite_RemoveClientPoints(Handle owner, Handle query, const char[] error, any datapack)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[Furien] SQL-Query failed! Error: %s", Error);
  }
  else
  {
    if(SQL_FetchRow(query))
    {
      ResetPack(datapack);
      int client = ReadPackCell(datapack);
      int points = ReadPackCell(datapack);
      int query_points = SQL_FetchInt(query, 2);
      GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid));
      Format (s_query, sizeof(s_query), "UPDATE furiendata SET points='%d' WHERE steamid='%s'",query_points-points, steamid);

      SQL_TQuery(db, SQLlite_RemovingClientPoints, s_query, client);
    }
  }
  CloseHandle(datapack);
  CloseHandle(query);
}
public SQLlite_RemovingClientPoints(Handle owner, Handle query, const char[] error, any:client)
{
  if(query == INVALID_HANDLE)
  {
    LogError("[Furien] SQL-Query failed! Error: %s", Error);
  }
  CloseHandle(query);
}
