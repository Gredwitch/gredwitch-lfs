
ENT.Type           		= "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName 			= "[LFS]Ju 87R-2"
ENT.Author 				= "Gredwitch"
ENT.Information 		= ""
ENT.Category 			= "Gredwitch's Stuff"

ENT.Spawnable			= true -- set to "true" to make it spawnable
ENT.AdminSpawnable		= false

ENT.MDL 				= "models/gredwitch/ju87_lfs/ju87.mdl" -- model forward direction must be facing to X+
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
ENT.WheelRadius 	= 	15
ENT.WheelPos_L 		= 	Vector(-50,61.7,30)
ENT.WheelPos_R 		= 	Vector(-50,-61.7,30)
ENT.WheelPos_F 		= 	Vector(-270,0,75.82)

ENT.AITEAM 				= 1 -- 0 = FFA  1 = bad guys  2 = good guys

ENT.Mass 				= 2000 -- lower this value if you encounter spazz
ENT.Inertia 			= Vector(20000,20000,20000) -- you must increase this when you increase mass or it will spazz
ENT.Drag 				= 1 -- drag is a good air brake but it will make diving speed worse

--ENT.HideDriver 		= true -- hide the driver?
ENT.SeatPos 			= Vector(4,-2.345,107.909)
ENT.SeatAng 			= Angle(0,-90,0)

ENT.IdleRPM 			= 300 -- idle rpm. this can be used to tweak the minimum flight speed
ENT.MaxRPM 				= 2800 -- rpm at 100% throttle
ENT.LimitRPM 			= 3000 -- max rpm when holding throttle key

ENT.RotorPos 			= Vector(106.8,0,73.35) -- make sure you set these correctly or your plane will act wierd
ENT.WingPos 			= Vector(50,5,20) -- make sure you set these correctly or your plane will act wierd
ENT.ElevatorPos 		= Vector(-150,5,20) -- make sure you set these correctly or your plane will act wierd
ENT.RudderPos 			= Vector(-150,5,20) -- make sure you set these correctly or your plane will act wierd

ENT.MaxVelocity 		= 1600 -- max theoretical velocity at 0 degree climb
ENT.MaxPerfVelocity 	= 1600 -- speed in which the plane will have its maximum turning potential

ENT.MaxThrust 			= 350 -- max power of rotor

ENT.MaxTurnPitch 		= 200 -- max turning force in pitch, lower this value if you encounter spazz
ENT.MaxTurnYaw 			= 200 -- max turning force in yaw, lower this value if you encounter spazz
ENT.MaxTurnRoll 		= 150 -- max turning force in roll, lower this value if you encounter spazz

ENT.MaxHealth 			= 700
--ENT.MaxShield 		= 200  -- uncomment this if you want to use deflector shields. Dont use excessive amounts because it regenerates.

--ENT.Stability 		= 0.7   -- if you uncomment this the plane will always be able to turn at maximum performance. This causes MaxPerfVelocity to get ignored
ENT.MaxStability 		= 0.7 -- lower this value if you encounter spazz. You can increase this up to 1 to aid turning performance at MaxPerfVelocity-speeds but be careful

ENT.MaxPrimaryAmmo 		= 1000   -- set to a positive number if you want to use weapons. set to -1 if you dont
ENT.MaxSecondaryAmmo 	= 1 -- set to a positive number if you want to use weapons. set to -1 if you dont

ENT.BulletPos			= {}
ENT.BulletPos[1]		= Vector(58.3,89.6,88)
ENT.BulletPos[2]		= Vector(58.3,-89.6,88)

ENT.BOMBS = {
	[1] = Vector(44.3,0,68),
}
ENT.Loadouts			= 2
function ENT:AddDataTables()
	self:NetworkVar( "Int",13, "Loadout", { KeyName = "loadout", Edit = { type = "Int", order = 4,min = 0, max = self.Loadouts, category = "Weapons"} } )
	
	if SERVER then
		self:SetLoadout(math.random(0,self.Loadouts))
	end
end