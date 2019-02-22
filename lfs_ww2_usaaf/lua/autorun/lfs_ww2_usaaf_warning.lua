AddCSLuaFile()

sound.Add( 	{
	name = "LFS_M2_BROWNING_SHOOT",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/common/m2_shoot.wav"
} )
sound.Add( 	{
	name = "LFS_M2_BROWNING_STOP",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/common/m2_stop.wav"
} )
sound.Add( 	{
	name = "LFS_HS_MK2_SHOOT",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/common/hs_mk2_shoot.wav"
} )
sound.Add( 	{
	name = "LFS_HS_MK2_STOP",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/common/hs_mk2_stop.wav"
} )

---------------
sound.Add( 	{
	name = "P51A_RPM0",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/p51_lfs/mtg_rpm0.wav"
} )
sound.Add( 	{
	name = "P51A_RPM1",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/p51_lfs/mtg_rpm1.wav"
} )
sound.Add( 	{	
	name = "P51A_RPM2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/p51_lfs/mtg_rpm2.wav"
} )
sound.Add( 	{
	name = "P51A_RPM3",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/p51_lfs/mtg_rpm3.wav"
} )
------------------------------------
sound.Add( 	{
	name = "F4U_RPM0",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/f4u_lfs/f4u_rpm0.wav"
} )
sound.Add( 	{
	name = "F4U_RPM1",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/f4u_lfs/f4u_rpm1.wav"
} )
sound.Add( 	{	
	name = "F4U_RPM2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/f4u_lfs/f4u_rpm2.wav"
} )
sound.Add( 	{
	name = "F4U_RPM3",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/f4u_lfs/f4u_rpm3.wav"
} )
------------------------------------
sound.Add( 	{
	name = "P51D_RPM0",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/p51_lfs/mtg2_rpm0.wav"
} )
sound.Add( 	{
	name = "P51D_RPM1",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/p51_lfs/mtg2_rpm1.wav"
} )
sound.Add( 	{	
	name = "P51D_RPM2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/p51_lfs/mtg2_rpm2.wav"
} )
sound.Add( 	{
	name = "P51D_RPM3",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/p51_lfs/mtg2_rpm3.wav"
} )
------------------------------------
sound.Add( 	{
	name = "P51D_START",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/p51_lfs/mtg2_start.wav"
} )
sound.Add( 	{
	name = "P51D_STOP",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/p51_lfs/mtg2_stop.wav"
} )
sound.Add( 	{
	name = "P51A_START",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/p51_lfs/mtg_start.wav"
} )
sound.Add( 	{
	name = "P51A_STOP",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/p51_lfs/mtg_stop.wav"
} )
sound.Add( 	{
	name = "F4U_START",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/f4u_lfs/f4u_start.wav"
} )
sound.Add( 	{
	name = "F4U_STOP",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/f4u_lfs/f4u_stop.wav"
} )
sound.Add( 	{
	name = "P51_DIST",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/p51_lfs/p51_distant.wav"
} )
sound.Add( 	{
	name = "F4U_DIST",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/f4u_lfs/f4u_distant.wav"
} )

gred = gred or {}
local tableinsert = table.insert
gred.AddonList = gred.AddonList or {}
tableinsert(gred.AddonList,1131455085) -- Base
tableinsert(gred.AddonList,1571918906) -- LFS Base
-- tableinsert(gred.AddonList,) -- Content
-- tableinsert(gred.AddonList,) -- Content
-- tableinsert(gred.AddonList,) -- Content
