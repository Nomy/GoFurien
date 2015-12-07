int	i_JumpsCount[MAXPLAYERS+1];
int	i_LastButtons[MAXPLAYERS+1];
int	i_LastFlags[MAXPLAYERS+1];

public Action OnPlayerRunCmd(client, &buttons, &impulse, float vel[3], float angles[3], &weapon)
{
	if(IsValidClient(client, true) && GetClientTeam(client) == CS_TEAM_T)
	{
		int flags = GetEntityFlags(client);
		if(IsPlayerInAir(flags, client))
		{
			float vVel[3];
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
			if(vVel[2] < -1.0)
			{
				vVel[2] += 3.0;
				SetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
				TeleportEntity(client, NULL_VECTOR,NULL_VECTOR,vVel);
			}
		}
	}
	//////////////////////// Wallhang ////////////////////////
	if(IsValidClient(client, true))
	{
		if(GetClientTeam(client) == CS_TEAM_T)
		{
			int b_CurButtons = GetClientButtons(client);
			if(b_CurButtons & IN_USE && !b_WallHang[client])
			{
				float fVector[3];
				float fClientEyePosition[3];
				float fClientEyeViewPoint[3];
				GetClientEyePosition(client, fClientEyePosition);
				GetPlayerEyeViewPoint(client, fClientEyeViewPoint);
				MakeVectorFromPoints(fClientEyeViewPoint, fClientEyePosition, fVector);
				if(GetVectorLength(fVector) < 30)
				{
					b_WallHang[client] = true;
				}
			}
			if(b_CurButtons & IN_RELOAD && b_WallHang[client])
			{
				int i_wep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				SetEntDataFloat(i_wep, g_offsNextPrimaryAttack, 0.0);
				SetEntDataFloat(i_wep, g_offsNextSecondaryAttack, 0.0);
				b_WallHang[client] = false;
				SetEntityMoveType(client, MOVETYPE_WALK);
			}
			if(b_WallHang[client])
			{
				int i_wep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
				float f_gametime = GetGameTime();
				SetEntDataFloat(i_wep, g_offsNextPrimaryAttack, f_gametime*2);
				SetEntDataFloat(i_wep, g_offsNextSecondaryAttack, f_gametime*2);
				SetEntityMoveType(client,MOVETYPE_NONE);
				float clientOrgs[3];
				float clientvel[3] = {0.0, 0.0, 0.0};
				GetClientAbsOrigin(client, clientOrgs);
				TeleportEntity(client, clientOrgs, NULL_VECTOR, clientvel);
			}
		}
	}
	//////////////////////// DoubleJump ////////////////////////
	if (IsValidClient(client, true))
	{
    int f_CurFlags = GetEntityFlags(client);
    int b_CurButtons = GetClientButtons(client);
    if (i_LastFlags[client] & FL_ONGROUND)
    {
      if (!(f_CurFlags & FL_ONGROUND) && !(i_LastButtons[client] & IN_JUMP) && b_CurButtons & IN_JUMP)
      {
				i_JumpsCount[client]++;
      }
    }
    else if (f_CurFlags & FL_ONGROUND)
    {
			i_JumpsCount[client] = 0;
    }
    else if (!(i_LastButtons[client] & IN_JUMP) && b_CurButtons & IN_JUMP)
    {
			int maxjump;
			if(b_VipShopMultiJump[client] && IsPlayerVIP(client)) maxjump = 3;
			else maxjump = 1;
			if ( 1 <= i_JumpsCount[client] <= maxjump)
			{
				i_JumpsCount[client]++;
				float vVel[3];
				GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
				vVel[2] = 250.0;
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);
      }
    }
    i_LastFlags[client]	= f_CurFlags;
    i_LastButtons[client]	= b_CurButtons;
	}
	//////////////////////// Invisible ////////////////////////
	char wepname[32];
	GetClientWeapon(client, wepname, sizeof(wepname));
	int flags = GetEntityFlags(client);
	bool CanBePlayerInvisible = IsPlayerNotMoving(buttons) && !IsPlayerInAir(flags, client) && StrEqual(wepname, "weapon_knife");
	if (CanBePlayerInvisible)
	{
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			if(!IsPlayerInvisible[client])
			{
				FadeClient(client, 75,0,130,35);
				if(!IsPlayerComingToInvisible[client])
				{
					PlayerInvisTime[client] = GetGameTime();
					IsPlayerComingToInvisible[client] = true;
				}
				else if(IsPlayerComingToInvisible[client])
				{
					if(IsValidClient(client, true) && GetClientTeam(client) == CS_TEAM_T && !IsPlayerInvisible[client])
					{
						int color[MAXPLAYERS+1][4];
						Entity_GetRenderColor(client,color[client]);
						float time = 0.09;
						float timeleft[MAXPLAYERS+1];
						timeleft[client] = PlayerInvisTime[client] - GetGameTime() + time;
						if(timeleft[client] < 0.01 && (color[client][3] - 26) <= 0 )
						{
							Entity_SetRenderColor(client,-1,-1,-1,0);
							SetClientWeaponsVisibility(client,0);
							FadeClient(client, 35,0,130,60);
							IsPlayerInvisible[client] = true;
						}
						else if(timeleft[client] < 0.01 && color[client][3] > 1)
						{
							Entity_SetRenderColor(client,-1,-1,-1,color[client][3]-26);
							SetClientWeaponsVisibility(client,color[client][3]-26);
							PlayerInvisTime[client] = GetGameTime();
						}
					}
				}
			}
		}
	}
	else
	{
		if(GetClientTeam(client) == CS_TEAM_T)
		{
			//SetEntityModel(client, "models/player/kuristaja/nanosuit/nanosuit.mdl");
			SetClientWeaponsVisibility(client, true);
			FadeClient(client, 75,0,130,35);
		}
		Entity_SetRenderColor(client,-1,-1,-1,255);
		IsPlayerComingToInvisible[client] = false;
		IsPlayerInvisible[client] = false;
	}
	//////////////////////// RegenHP Timer ////////////////////////
	if(GetClientHealth(client) < MaxHealth[client] && b_VipShopRegenHP[client] && IsPlayerAlive(client) && IsPlayerVIP(client))
	{
		float time = 1.5;
		float timeleft = PlayerRegenHPStart[client] - GetGameTime() + time;
		if(timeleft < 0.01)
		{
			if(GetClientHealth(client)+4 >= MaxHealth[client])
			{
				SetEntityHealth(client, MaxHealth[client]);
			}
			else
			{
				SetEntityHealth(client, GetClientHealth(client)+4);
				PlayerRegenHPStart[client] = GetGameTime();
			}
		}
	}
	return Plugin_Continue;

}
bool IsPlayerNotMoving(int buttons)
{
	return !IsMoveButtonsPressed(buttons);
}
bool IsPlayerInAir(int flags, int client)
{
	return !(flags & FL_ONGROUND || b_WallHang[client]);
}

bool IsMoveButtonsPressed(int buttons)
{
	//|| buttons & IN_ATTACK || buttons & IN_ATTACK2;
	return buttons & IN_FORWARD || buttons & IN_BACK || buttons & IN_MOVELEFT || buttons & IN_MOVERIGHT;
}
