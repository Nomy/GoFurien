PrecacheModels()
{
  //origo
  AddFileToDownloadsTable("materials/models/player/altair/boots.vmt");
  AddFileToDownloadsTable("materials/models/player/altair/boots.vtf");
  AddFileToDownloadsTable("materials/models/player/altair/boots_n.vtf");
  AddFileToDownloadsTable("materials/models/player/altair/eyes.vmt");
  AddFileToDownloadsTable("materials/models/player/altair/eyes.vtf");
  AddFileToDownloadsTable("materials/models/player/altair/gloves.vmt");
  AddFileToDownloadsTable("materials/models/player/altair/gloves.vtf");
  AddFileToDownloadsTable("materials/models/player/altair/gloves_n.vtf");
  AddFileToDownloadsTable("materials/models/player/altair/head.vmt");
  AddFileToDownloadsTable("materials/models/player/altair/head.vtf");
  AddFileToDownloadsTable("materials/models/player/altair/head_n.vtf");
  AddFileToDownloadsTable("materials/models/player/altair/hood.vmt");
  AddFileToDownloadsTable("materials/models/player/altair/hood.vtf");
  AddFileToDownloadsTable("materials/models/player/altair/hood_n.vtf");
  AddFileToDownloadsTable("materials/models/player/altair/robepants.vmt");
  AddFileToDownloadsTable("materials/models/player/altair/robepants.vtf");
  AddFileToDownloadsTable("materials/models/player/altair/robepants_n.vtf");
  AddFileToDownloadsTable("materials/models/player/altair/robeshirt.vmt");
  AddFileToDownloadsTable("materials/models/player/altair/robeshirt.vtf");
  AddFileToDownloadsTable("materials/models/player/altair/robeshirt_n.vtf");
  AddFileToDownloadsTable("materials/models/player/altair/shortsword.vmt");
  AddFileToDownloadsTable("materials/models/player/altair/shortsword.vtf");
  AddFileToDownloadsTable("materials/models/player/altair/shortsword_n.vtf");
  AddFileToDownloadsTable("materials/models/player/altair/swordsaber.vmt");
  AddFileToDownloadsTable("materials/models/player/altair/swordsaber.vtf");
  AddFileToDownloadsTable("materials/models/player/altair/swordsaber_n.vtf");

  AddFileToDownloadsTable("models/player/altair/altair.dx90.vtx");
  AddFileToDownloadsTable("models/player/altair/altair.mdl");
  AddFileToDownloadsTable("models/player/altair/altair.phy");
  AddFileToDownloadsTable("models/player/altair/altair.vvd");

  // precahe models
  PrecacheModel("models/player/altair/altair.mdl");
  PrecacheModel("models/player/ctm_fbi.mdl");
}
PrecacheSounds()
{
  AddFileToDownloadsTable("sound/GameSites/gs_heckle/behindyou.mp3");
  AddFileToDownloadsTable("sound/GameSites/gs_heckle/imhere.mp3");
  AddFileToDownloadsTable("sound/GameSites/gs_heckle/iseeyou.mp3");
  AddFileToDownloadsTable("sound/GameSites/gs_heckle/turnaround.mp3");
  AddFileToDownloadsTable("sound/GameSites/gs_heckle/mynameisjeff1.mp3");
  PrecacheSoundAny("GameSites/gs_heckle/behindyou.mp3");
  PrecacheSoundAny("GameSites/gs_heckle/imhere.mp3");
  PrecacheSoundAny("GameSites/gs_heckle/iseeyou.mp3");
  PrecacheSoundAny("GameSites/gs_heckle/turnaround.mp3");
  PrecacheSoundAny("GameSites/gs_heckle/mynameisjeff1.mp3");
}
