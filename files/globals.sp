//#define MODEL_FURIEN "models/player/scarecrow/scarecrow_new.mdl"
#define MODEL_FURIEN "models/player/altair/altair.mdl"


char s_query[1024];
char steamid[32];
char logfile[256];
char Error[256];

char g_sRadioCommands[][] = {"coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "go", "fallback", "sticktog", "getinpos", "stormfront", "report", "roger", "enemyspot", "needbackup", "sectorclear", "inposition", "reportingin", "getout", "negative","enemydown", "compliment", "thanks", "cheer"};


Handle db = INVALID_HANDLE;
Handle g_clientcookie;
Handle g_clientcookieSound;

int FurienWinStreak = 0;
float StartAdvertTime;

bool b_EnableBombZone = false;
float f_EnableBombZone;

bool IsPlayerInvisible[MAXPLAYERS+1] = false;
bool IsPlayerComingToInvisible[MAXPLAYERS+1] = false;


bool PlayerOneRoundSuperKnife[MAXPLAYERS+1] = false;
bool PlayerOneRoundAmfetamin[MAXPLAYERS+1] = false;

bool PlayerHeckle[MAXPLAYERS+1] = false;


bool PlayerSelectWeapon[MAXPLAYERS+1] = false;

bool switchteams = false;

bool b_WallHang[MAXPLAYERS+1] = false;

int g_offsNextPrimaryAttack;
int g_offsNextSecondaryAttack;

float PlayerInvisTime[MAXPLAYERS+1];

float PlayerRegenHPStart[MAXPLAYERS+1];

int i_FlashAlpha = -1;
int MinPlayers = 4;

int MaxHealth[MAXPLAYERS+1];

//////////////// VIP SHOP ////////////////

bool b_VipShopSpeedUp[MAXPLAYERS+1] = false;
bool b_VipShopMultiJump[MAXPLAYERS+1] = false;
bool b_VipShopRegenHP[MAXPLAYERS+1] = false;

int i_VIPShopSpeedUpCost = 100;
int i_VIPShopMultiJumpCost = 300;
int i_VIPShopRegenHPCost = 230;

//////////////// SHOP ////////////////
int i_Shop50HP[MAXPLAYERS+1] = 0;
bool b_ShopHeGrenade[MAXPLAYERS+1] = false;

int i_Shop50HPCost = 50;
int i_ShopArmorCost = 30;
int i_ShopDefuseCost = 10;
int i_ShopHEgrenadeCost = 20;
int i_ShopSuperKnifeCost = 90;
int i_ShopAmfetaminCost = 85;
int i_ShopElectricGunCost = 125;

int i_ShopMP7Cost = 25;
int i_ShopM4A4Cost = 35;
int i_ShopAWPCost = 15;
int i_ShopAK47Cost = 35;

int i_ShopP250Cost = 5;
int i_ShopFSCost = 7;
int i_ShopDeagleCost = 15;



/////////////////////////////////////
