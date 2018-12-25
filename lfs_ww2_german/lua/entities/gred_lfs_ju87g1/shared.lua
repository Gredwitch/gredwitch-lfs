
ENT.Type           		= "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName 			= "[LFS]Ju 87G-1/2"
ENT.Author 				= "Gredwitch"
ENT.Information 		= ""
ENT.Category 			= "Gredwitch's Stuff"

ENT.Spawnable			= true -- set to "true" to make it spawnable
ENT.AdminSpawnable		= false

ENT.MDL 				= "models/gredwitch/ju87_lfs/ju87d.mdl" -- model forward direction must be facing to X+
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
ENT.WheelPos_L 		= 	Vector(-28.1973,61.7571,-76.8927)
ENT.WheelPos_R 		= 	Vector(-28.1973,-61.7571,-76.8927)
ENT.WheelPos_C 		= 	Vector(-295.121,0,-19.7179)

ENT.AITEAM 				= 1 -- 0 = FFA  1 = bad guys  2 = good guys

ENT.Mass 				= 2000 -- lower this value if you encounter spazz
ENT.Inertia 			= Vector(20000,20000,20000) -- you must increase this when you increase mass or it will spazz
ENT.Drag 				= -40 -- drag is a good air brake but it will make diving speed worse

--ENT.HideDriver 		= true -- hide the driver?
ENT.SeatPos 			= Vector(-22.7167,-2.3,11.7)
ENT.SeatAng 			= Angle(0,-90,0)

ENT.IdleRPM 			= 300 -- idle rpm. this can be used to tweak the minimum flight speed
ENT.MaxRPM 				= 2800 -- rpm at 100% throttle
ENT.LimitRPM 			= 3000 -- max rpm when holding throttle key

ENT.RotorPos 			= Vector(106.8,0,73.35) -- make sure you set these correctly or your plane will act wierd
ENT.WingPos 			= Vector(50,5,20) -- make sure you set these correctly or your plane will act wierd
ENT.ElevatorPos 		= Vector(-150,5,20) -- make sure you set these correctly or your plane will act wierd
ENT.RudderPos 			= Vector(-150,5,20) -- make sure you set these correctly or your plane will act wierd

ENT.MaxVelocity 		= 1500 -- max theoretical velocity at 0 degree climb
ENT.MaxPerfVelocity 	= 1000 -- speed in which the plane will have its maximum turning potential

ENT.MaxThrust 			= 500 -- max power of rotor

ENT.MaxTurnPitch 		= 200 -- max turning force in pitch, lower this value if you encounter spazz
ENT.MaxTurnYaw 			= 100 -- max turning force in yaw, lower this value if you encounter spazz
ENT.MaxTurnRoll 		= 120 -- max turning force in roll, lower this value if you encounter spazz

ENT.MaxHealth 			= 700
--ENT.MaxShield 		= 200  -- uncomment this if you want to use deflector shields. Dont use excessive amounts because it regenerates.

--ENT.Stability 		= 0.7   -- if you uncomment this the plane will always be able to turn at maximum performance. This causes MaxPerfVelocity to get ignored
ENT.MaxStability 		= 0.7 -- lower this value if you encounter spazz. You can increase this up to 1 to aid turning performance at MaxPerfVelocity-speeds but be careful

ENT.MaxPrimaryAmmo 		= 24   -- set to a positive number if you want to use weapons. set to -1 if you dont
ENT.MaxSecondaryAmmo 	= -1 -- set to a positive number if you want to use weapons. set to -1 if you dont

ENT.BulletPos			= {}
ENT.BulletPos[1]		= Vector(132.368,-100.469,-46.0132)
ENT.BulletPos[2]		= Vector(132.368,100.469,-46.0132)


ENT.TurretMuzzle		= {}
ENT.TurretMuzzle[1]		= Vector(-103.85,-1.28882,36.5571)
ENT.TurretMuzzle[2]		= Vector(-103.85,1.28882,36.5571)
