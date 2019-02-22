
ENT.Type           		= "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName 			= "[LFS]F4U-4B"
ENT.Author 				= "Gredwitch"
ENT.Information 		= ""
ENT.Category 			= "Gredwitch's Stuff"

ENT.Spawnable			= true -- set to "true" to make it spawnable
ENT.AdminSpawnable		= false

ENT.MDL 				= "models/gredwitch/f4u_lfs/f4u_4.mdl" -- model forward direction must be facing to X+
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
ENT.WheelRadius 	= 	20
ENT.WheelPos_L 		= 	Vector(123.98,82.5847,0)
ENT.WheelPos_R 		= 	Vector(123.98,-82.5847,0)
ENT.WheelPos_C 		= 	Vector(-128.071,0,38.1325)

ENT.AITEAM 				= 2 -- 0 = FFA  1 = bad guys  2 = good guys

ENT.Mass 				= 4600 -- lower this value if you encounter spazz
ENT.Inertia 			= Vector(46000,46000,46000) -- you must increase this when you increase mass or it will spazz
ENT.Drag 				= -48 -- drag is a good air brake but it will make diving speed worse

--ENT.HideDriver 		= true -- hide the driver?
ENT.SeatPos 			= Vector(9.0571,0,101.5)
ENT.SeatAng 			= Angle(0,-90,0)

ENT.IdleRPM 			= 100 -- idle rpm. this can be used to tweak the minimum flight speed
ENT.MaxRPM 				= 2800 -- rpm at 100% throttle
ENT.LimitRPM 			= 3000 -- max rpm when holding throttle key

ENT.RotorPos 			= Vector(206.316,0,87.9999) -- make sure you set these correctly or your plane will act wierd
ENT.WingPos 			= Vector(91.2445,0,58.9222) -- make sure you set these correctly or your plane will act wierd
ENT.ElevatorPos 		= Vector(-197.363,0,106.415) -- make sure you set these correctly or your plane will act wierd
ENT.RudderPos 			= Vector(-166.895,0,154.908) -- make sure you set these correctly or your plane will act wierd

ENT.MaxVelocity 		= 1550 -- max theoretical velocity at 0 degree climb
ENT.MaxPerfVelocity 	= 1550 -- speed in which the plane will have its maximum turning potential

ENT.MaxThrust 			= 750 -- max power of rotor


ENT.MaxTurnPitch 		= 450
ENT.MaxTurnYaw 			= 400
ENT.MaxTurnRoll 		= 350

ENT.MaxHealth 			= 800
--ENT.MaxShield 		= 200  -- uncomment this if you want to use deflector shields. Dont use excessive amounts because it regenerates.

--ENT.Stability 		= 0.7   -- if you uncomment this the plane will always be able to turn at maximum performance. This causes MaxPerfVelocity to get ignored
ENT.MaxStability 		= 0.4 -- lower this value if you encounter spazz. You can increase this up to 1 to aid turning performance at MaxPerfVelocity-speeds but be careful

ENT.MaxSecondaryAmmo 	= 8 -- set to a positive number if you want to use weapons. set to -1 if you dont

ENT.LastChangeSecondary = 0
ENT.BulletPos			= {}
ENT.BulletPos[1]		= Vector(119.944,110.841,58.8995)
ENT.BulletPos[2]		= Vector(119.944,-110.841,58.8995)
ENT.BulletPos[3]		= Vector(118.811,118.289,60.016)
ENT.BulletPos[4]		= Vector(118.811,-118.289,60.016)
ENT.BulletPos[5]		= Vector(117.612,125.723,61.1123)
ENT.BulletPos[6]		= Vector(117.612,-125.723,61.1123)

ENT.MaxPrimaryAmmo 		= 2400

ENT.Loadouts			= 0

ENT.HVARMDL 			= "models/gredwitch/bombs/hvar.mdl"

ENT.BOMBS = {
	[1] = Vector(10,-37.0367,-50),
	[2] = Vector(10,33.8913,-50),
}

ENT.ROCKETS = {
	[1] = {Vector(26.37,-146.39,-42),Vector(26.37,143.29,-42)},
	[2] = {Vector(26.37,-135.258,-43.5),Vector(26.37,132.158,-43.5)},
	[3] = {Vector(25.127,-121.247,-46),Vector(25.127,118.147,-46)},
	[4] = {Vector(25.127,-110.115,-48),Vector(25.127,107.015,-48)},
}

ENT.MaxBombs			= 2

function ENT:AddDataTables()
	self:NetworkVar( "Int",13, "Loadout", { KeyName = "loadout", Edit = { type = "Int", order = 4,min = 0, max = self.Loadouts, category = "Weapons"} } )
	self:NetworkVar( "Int",14, "CurSecondary")
	-- self:NetworkVar( "Int",15, "Bombs", { KeyName = "bombs", Edit = { type = "Int", order = 4,min = 0, max = self.MaxBombs, category = "Weapons"} } )
	if SERVER then
		self:SetLoadout(math.random(0,self.Loadouts))
		self:SetCurSecondary(0)
	end
end