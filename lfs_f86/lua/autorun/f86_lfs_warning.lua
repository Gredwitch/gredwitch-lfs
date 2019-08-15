AddCSLuaFile()

sound.Add( 	{
	name = "LFS_M3_BROWNING_STOP",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/common/m2_stop.wav"
} )
sound.Add( 	{
	name = "LFS_M3_BROWNING_SHOOT",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/common/m3_shoot.wav"
} )

---------------------------------------------------------------

sound.Add( 	{
	name = "LFS_PART_DESTROYED_01",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 130,
	sound = "gredwitch/common/plane_explosion_1.wav"
} )
sound.Add( 	{
	name = "LFS_PART_DESTROYED_02",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 130,
	sound = "gredwitch/common/plane_explosion_2.wav"
} )
sound.Add( 	{
	name = "LFS_PART_DESTROYED_03",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 130,
	sound = "gredwitch/common/plane_explosion_3.wav"
} )

---------------------------------------------------------------

sound.Add( 	{
	name = "LFS_JET_PASSBY_CLOSE_01",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 0,
	sound = "gredwitch/common/passby_jet_close-001.wav"
} )
sound.Add( 	{
	name = "LFS_JET_PASSBY_CLOSE_02",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 0,
	sound = "gredwitch/common/passby_jet_close-002.wav"
} )
sound.Add( 	{
	name = "LFS_JET_PASSBY_CLOSE_03",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 0,
	sound = "gredwitch/common/passby_jet_close-003.wav"
} )
sound.Add( 	{
	name = "LFS_JET_PASSBY_DISTANT_01",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 0,
	sound = "gredwitch/common/passby_jet_distant-001.wav"
} )
sound.Add( 	{
	name = "LFS_JET_PASSBY_DISTANT_02",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 0,
	sound = "gredwitch/common/passby_jet_distant-002.wav"
} )
sound.Add( 	{
	name = "LFS_JET_PASSBY_DISTANT_03",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 0,
	sound = "gredwitch/common/passby_jet_distant-003.wav"
} )

---------------------------------------------------------------

sound.Add( 	{
	name = "F86_RPM0",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/f86_lfs/f86_rpm0.wav"
} )
sound.Add( 	{
	name = "F86_RPM1",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/f86_lfs/f86_rpm1.wav"
} )
sound.Add( 	{
	name = "F86_RPM2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/f86_lfs/f86_rpm2.wav"
} )
sound.Add( 	{
	name = "F86_RPM3",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/f86_lfs/f86_rpm3.wav"
} )
sound.Add( 	{
	name = "F86_START",
	channel = CHAN_STATIC,
	volume = 0.1,
	level = 125,
	sound = "gredwitch/f86_lfs/f86_start.wav"
} )
sound.Add( 	{
	name = "F86_STOP",
	channel = CHAN_STATIC,
	volume = 0.1,
	level = 125,
	sound = "gredwitch/f86_lfs/f86_stop.wav"
} )

---------------------------------------------------------------

gred = gred or {}
local tableinsert = table.insert
gred.AddonList = gred.AddonList or {}
tableinsert(gred.AddonList,1131455085) -- Base
tableinsert(gred.AddonList,1571918906) -- LFS Base
tableinsert(gred.AddonList,971538203) -- Content