
ENT.Type           		= "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName 			= "[LFS]Ju 88A-1"
ENT.Author 				= "Gredwitch"
ENT.Information 		= ""
ENT.Category 			= "Gredwitch's Stuff"

ENT.Spawnable			= true -- set to "true" to make it spawnable
ENT.AdminSpawnable		= false

ENT.MDL 				= "models/gredwitch/ju88_lfs/ju88.mdl" -- model forward direction must be facing to X+
--[[
ENT.GibModels = {
	"models/XQM/wingpiece2.mdl",
	"models/XQM/wingpiece2.mdl",
	"models/XQM/jetwing2medium.mdl",
	"models/XQM/jetwing2medium.mdl",
	"models/props_phx/misc/propeller3x_small.mdl",
	"models/props_c17/TrapPropeller_Engine.mdl",
	"models/props_junk/Shoe001a.mdl",
	"models/XQM/jetbody2fuselage.mdl",
	"models/XQM/jettailpiece1medium.mdl",
	"models/XQM/pistontype1huge.mdl",
}
]]
ENT.WheelMass 		= 	200 -- wheel mass is 1 when the landing gear is retracted
ENT.WheelRadius 	= 	30
ENT.WheelPos_L 		= 	Vector(139.541,-127.43,-10.6869)
ENT.WheelPos_R 		= 	Vector(139.541,127.43,-10.6869)
ENT.WheelPos_C 		= 	Vector(-250.585,0,43.4815)

ENT.AITEAM 				= 1 -- 0 = FFA  1 = bad guys  2 = good guys

ENT.Mass 				= 7854  -- lower this value if you encounter spazz
ENT.Inertia 			= Vector(900000,900000,900000) -- you must increase this when you increase mass or it will spazz
ENT.Drag 				= 1 -- drag is a good air brake but it will make diving speed worse

--ENT.HideDriver 		= true -- hide the driver?
ENT.SeatPos 			= Vector(210,9,80)
ENT.SeatAng 			= Angle(0,-90,0)

ENT.IdleRPM 			= 300 -- idle rpm. this can be used to tweak the minimum flight speed
ENT.MaxRPM 				= 3000 -- rpm at 100% throttle
ENT.LimitRPM 			= 3500 -- max rpm when holding throttle key

ENT.RotorPos 			= Vector(106.8,0,73.35) -- make sure you set these correctly or your plane will act wierd
ENT.WingPos 			= Vector(148.235,6.41604,77.7547) -- make sure you set these correctly or your plane will act wierd
ENT.ElevatorPos 		= Vector(-282.785,0,104.629) -- make sure you set these correctly or your plane will act wierd
ENT.RudderPos 			= Vector(-339.694,0,123.39) -- make sure you set these correctly or your plane will act wierd

ENT.MaxVelocity 		= 2000 -- max theoretical velocity at 0 degree climb
ENT.MaxPerfVelocity 	= 1500 -- speed in which the plane will have its maximum turning potential

ENT.MaxThrust 			= 1500 -- max power of rotor

ENT.MaxTurnPitch 		= 350 -- max turning force in pitch, lower this value if you encounter spazz
ENT.MaxTurnYaw 			= 200 -- max turning force in yaw, lower this value if you encounter spazz
ENT.MaxTurnRoll 		= 150 -- max turning force in roll, lower this value if you encounter spazz

ENT.MaxHealth 			= 1200
--ENT.MaxShield 		= 200  -- uncomment this if you want to use deflector shields. Dont use excessive amounts because it regenerates.

--ENT.Stability 		= 0.7   -- if you uncomment this the plane will always be able to turn at maximum performance. This causes MaxPerfVelocity to get ignored
ENT.MaxStability 		= 0.7 -- lower this value if you encounter spazz. You can increase this up to 1 to aid turning performance at MaxPerfVelocity-speeds but be careful

ENT.MaxPrimaryAmmo 		= 375   -- set to a positive number if you want to use weapons. set to -1 if you dont
ENT.MaxSecondaryAmmo 	= 30 -- set to a positive number if you want to use weapons. set to -1 if you dont

ENT.BulletPos			= {}
ENT.BulletPos[1]		= Vector(257.97,-6.39709,119.975)

ENT.BOMBS = {
	[1] = Vector(117.129,49.9486,57.2176),
	[2] = Vector(117.129,-49.9486,57.2176),
	[3] = Vector(117.129,75.0212,59.8515),
	[4] = Vector(117.129,-75.0212,59.8515),
	 -- + 10.3675
	[5] = Vector(37.5082,21.9866,73.8857),
	[6] = Vector(37.5082,-21.9866,73.8857),
	
	[7] = Vector(37.5082,21.6786,84.2532),
	[8] = Vector(37.5082,-21.6786,84.2532),
	
	[9] = Vector(37.5082,21.6786,94.6207),
	[10] = Vector(37.5082,-21.6786,94.6207),
	
	[11] = Vector(37.5082,21.6786,104.9882),
	[12] = Vector(37.5082,-21.6786,104.9882),
	
	[13] = Vector(37.5082,8.68208,73.8857),
	[14] = Vector(37.5082,-8.68208,73.8857),
	
	[5] = Vector(37.5082,21.9866,73.8857),
	[6] = Vector(37.5082,-21.9866,73.8857),
	
	[7] = Vector(37.5082,21.6786,84.2532),
	[8] = Vector(37.5082,-21.6786,84.2532),
	
	[9] = Vector(37.5082,21.6786,94.6207),
	[10] = Vector(37.5082,-21.6786,94.6207),
	
	[11] = Vector(37.5082,21.6786,104.9882),
	[12] = Vector(37.5082,-21.6786,104.9882),
	
	[13] = Vector(37.5082,8.68208,73.8857),
	[14] = Vector(37.5082,-8.68208,73.8857),
	
	[15] = Vector(95.4232,23.2873,73.0772),
	[16] = Vector(95.4232,-23.2873,73.0772),
	
	[17] = Vector(95.4232,23.2873,83.4447),
	[18] = Vector(95.4232,-23.2873,83.4447),
	
	[17] = Vector(95.4232,23.2873,93.8122),
	[18] = Vector(95.4232,-23.2873,93.8122),
	
	[19] = Vector(95.4232,23.2873,104.1797),
	[20] = Vector(95.4232,-23.2873,104.1797),
	
	[21] = Vector(95.4232,6.36585,73.0772),
	[22] = Vector(95.4232,-6.36585,73.0772),
	
	[23] = Vector(95.4232,6.36585,83.4447),
	[24] = Vector(95.4232,-6.36585,83.4447),
	
	[25] = Vector(95.4232,6.36585,93.8122),
	[26] = Vector(95.4232,-6.36585,93.8122),
	
	[27] = Vector(95.4232,6.36585,104.1797),
	[28] = Vector(95.4232,-6.36585,104.1797),
	
	[27] = Vector(95.4232,6.36585,114.5472),
	[28] = Vector(95.4232,-6.36585,114.5472),
	
	[29] = Vector(95.4232,6.36585,114.5472),
	[30] = Vector(95.4232,-6.36585,114.5472),
	
	[31] = Vector(95.4232,6.36585,114.5472),
	[32] = Vector(95.4232,-6.36585,114.5472),
}
ENT.Loadouts			= 4
function ENT:AddDataTables()
	self:NetworkVar( "Int",13, "Loadout", { KeyName = "loadout", Edit = { type = "Int", order = 4,min = 0, max = self.Loadouts, category = "Weapons"} } )
	self:NetworkVar( "Entity",11, "Gunter" )
	self:NetworkVar( "Entity",12, "GunterSeat" )
	self:NetworkVar( "Bool",11, "IsBombing" )
	if SERVER then
		self:SetLoadout(math.random(0,self.Loadouts))
	end
end