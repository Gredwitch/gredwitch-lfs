
ENT.Type           		= "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName 			= "[LFS]P-51A"
ENT.Author 				= "Gredwitch"
ENT.Information 		= ""
ENT.Category 			= "Gredwitch's Stuff"

ENT.Spawnable			= true -- set to "true" to make it spawnable
ENT.AdminSpawnable		= false

ENT.MDL 				= "models/gredwitch/p51_lfs/p51a.mdl" -- model forward direction must be facing to X+
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
ENT.WheelPos_L 		= 	Vector(73.4793,79.7006,-54.5762)
ENT.WheelPos_R 		= 	Vector(73.4793,-79.7006,-54.5762)
ENT.WheelPos_C 		= 	Vector(-137.475,0,-6.15717)

ENT.AITEAM 				= 2 -- 0 = FFA  1 = bad guys  2 = good guys

ENT.Mass 				= 2000 -- lower this value if you encounter spazz
ENT.Inertia 			= Vector(20000,20000,20000) -- you must increase this when you increase mass or it will spazz
ENT.Drag 				= -40 -- drag is a good air brake but it will make diving speed worse

--ENT.HideDriver 		= true -- hide the driver?
ENT.SeatPos 			= Vector(16.1374,0,21.83)
ENT.SeatAng 			= Angle(0,-90,0)

ENT.IdleRPM 			= 300 -- idle rpm. this can be used to tweak the minimum flight speed
ENT.MaxRPM 				= 2800 -- rpm at 100% throttle
ENT.LimitRPM 			= 3000 -- max rpm when holding throttle key

ENT.RotorPos 			= Vector(180.186,0,24.535) -- make sure you set these correctly or your plane will act wierd
ENT.WingPos 			= Vector(61.6007,10.2201,4.09227) -- make sure you set these correctly or your plane will act wierd
ENT.ElevatorPos 		= Vector(-175.761,1.16138,38.6499) -- make sure you set these correctly or your plane will act wierd
ENT.RudderPos 			= Vector(-208.266,0,59.986) -- make sure you set these correctly or your plane will act wierd

ENT.MaxVelocity 		= 1300 -- max theoretical velocity at 0 degree climb
ENT.MaxPerfVelocity 	= 1300 -- speed in which the plane will have its maximum turning potential

ENT.MaxThrust 			= 850 -- max power of rotor


ENT.MaxTurnPitch 		= 350
ENT.MaxTurnYaw 			= 400
ENT.MaxTurnRoll 		= 300

ENT.MaxHealth 			= 800
--ENT.MaxShield 		= 200  -- uncomment this if you want to use deflector shields. Dont use excessive amounts because it regenerates.

--ENT.Stability 		= 0.7   -- if you uncomment this the plane will always be able to turn at maximum performance. This causes MaxPerfVelocity to get ignored
ENT.MaxStability 		= 0.4 -- lower this value if you encounter spazz. You can increase this up to 1 to aid turning performance at MaxPerfVelocity-speeds but be careful

ENT.MaxSecondaryAmmo 	= -1 -- set to a positive number if you want to use weapons. set to -1 if you dont

ENT.BulletPos			= {}
ENT.BulletPos[1]		= Vector(75.9057,96.448,5.42484)
ENT.BulletPos[2]		= Vector(75.9057,87.56,5.29284)
ENT.BulletPos[3]		= Vector(75.9057,-96.448,5.42484)
ENT.BulletPos[4]		= Vector(75.9057,-87.56,5.29284)

ENT.MaxPrimaryAmmo 		= 1260
