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
for i = 1,3 do
sound.Add( 	{
	name = "GRED_VO_HOLE_LEFT_WING_0"..i,
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "gredwitch/voice/eng_left_wing_v1_r"..i.."_t1_mood_high.wav"
} )
sound.Add( 	{
	name = "GRED_VO_HOLE_RIGHT_WING_0"..i,
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "gredwitch/voice/eng_right_wing_v1_r"..i.."_t1_mood_high.wav"
} )
sound.Add( 	{
	name = "GRED_VO_BAILOUT_0"..i,
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/voice/eng_bailout_v1_r"..i.."_t1_mood_high.wav"
} )
end

gred = gred or {}
local tableinsert = table.insert
gred.AddonList = gred.AddonList or {}
tableinsert(gred.AddonList,1131455085) -- Base
tableinsert(gred.AddonList,1571918906) -- LFS Base
tableinsert(gred.AddonList,971538203) -- Content

if SERVER then
	util.AddNetworkString("gred_lfs_setparts")
	util.AddNetworkString("gred_lfs_remparts")
end
if CLIENT then
	net.Receive("gred_lfs_setparts",function()
		local self = net.ReadEntity()
		if not self then print("[F-86] ERROR! ENTITY NOT INITALIZED CLIENT SIDE! PLEASE, RE-SPAWN!") return end
		self.Parts = {}
		for k,v in pairs(net.ReadTable()) do
			self.Parts[k] = v
		end
	end)
	net.Receive("gred_lfs_remparts",function()
		local self = net.ReadEntity()
		local k = net.ReadString()
		
		self.EmitNow = self.EmitNow or {}
		if (k == "wing_l" or k == "wing_r") and self.EmitNow[k] != "CEASE" then
			self.EmitNow[k] = true
		end
		if self.Parts then
			self.Parts[k] = nil
		end
	end)
end