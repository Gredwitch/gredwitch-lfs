
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.Type            = 	"anim"

ENT.PrintName 		= 	"[LFS] A-10 Thunderbolt II"
ENT.Author 			= 	"Gredwitch"
ENT.Information 	= 	""
ENT.Category 		= 	"Gredwitch's Stuff"

ENT.Spawnable		= 	true -- set to "true" to make it spawnable
ENT.AdminSpawnable	= 	false

ENT.MDL 			= 	"models/gredwitch/a10/a10_lfs.mdl" -- model forward direction must be facing to X+
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

ENT.AITEAM 			= 	2 -- 0 = FFA  1 = bad guys  2 = good guys

ENT.Mass 			= 	1485 -- lower this value if you encounter spazz
ENT.Inertia 		= 	Vector(20000,20000,20000) -- you must increase this when you increase mass or it will spazz
ENT.Drag 			= 	1 -- drag is a good air brake but it will make diving speed worse

ENT.SeatPos 		= 	Vector(171,0,15)
ENT.SeatAng 		= 	Angle(0,-90,0)

ENT.WheelMass 		= 	200 -- wheel mass is 1 when the landing gear is retracted
ENT.WheelRadius 	= 	15
ENT.WheelPos_L 		= 	Vector(-36,98.5,-71.5)
ENT.WheelPos_R 		= 	Vector(-36,-98.5,-71.5)
ENT.WheelPos_F 		= 	Vector(179,-15,-78)

ENT.IdleRPM 		= 	200 -- idle rpm. this can be used to tweak the minimum flight speed
ENT.MaxRPM 			= 	4800 -- rpm at 100% throttle
ENT.LimitRPM 		= 	5000 -- max rpm when holding throttle key

-- ENT.RotorPos 		=	{}  -- these wheels are invisible spherical entities
-- ENT.RotorPos[1] 	=	Vector(-103,57,41)
-- ENT.RotorPos[2] 	=	Vector(-103,-57,41)
ENT.RotorPos 		=	Vector(-103,0,41)

ENT.WingPos 		= 	Vector(50,5,20) -- make sure you set these correctly or your plane will act wierd
ENT.ElevatorPos 	= 	Vector(-150,5,20) -- make sure you set these correctly or your plane will act wierd
ENT.RudderPos		= 	Vector(-150,5,20) -- make sure you set these correctly or your plane will act wierd

ENT.MaxVelocity 	= 	1000000 -- max theoretical velocity at 0 degree climb
ENT.MaxPerfVelocity = 	1500 -- speed in which the plane will have its maximum turning potential

ENT.MaxThrust 		= 	400 -- max power per rotor

ENT.MaxTurnPitch 	= 	200 -- max turning force in pitch, lower this value if you encounter spazz
ENT.MaxTurnYaw 		= 	600 -- max turning force in yaw, lower this value if you encounter spazz
ENT.MaxTurnRoll 	= 	150 -- max turning force in roll, lower this value if you encounter spazz

ENT.MaxHealth 		= 	1400
-- ENT.MaxShield 	= 	200  -- uncomment this if you want to use deflector shields. Dont use excessive amounts because it regenerates.

--ENT.Stability 	= 	0.7   -- if you uncomment this the plane will always be able to turn at maximum performance. This causes MaxPerfVelocity to get ignored
ENT.MaxStability 	= 	0.5 -- lower this value if you encounter spazz. You can increase this up to 1 to aid turning performance at MaxPerfVelocity-speeds but be careful

ENT.MaxPrimaryAmmo 	= 	1300   -- set to a positive number if you want to use weapons. set to -1 if you dont
ENT.MaxSecondaryAmmo= 	42 -- set to a positive number if you want to use weapons. set to -1 if you dont

ENT.altitude 		=	0
ENT.BulletPos 		= Vector(295,0,-16)

ENT.MISSILEENT = "gb_rocket_hydra"
ENT.MISSILES = {}
ENT.MISSILES[1] = Vector(22.14,-196.6,-18.44)
ENT.MISSILES[2] = Vector(22.14,196.6,-18.44)
ENT.MISSILES[3] = Vector(25.26,-146.05,-25.2)
ENT.MISSILES[4] = Vector(25.26,146.05,-25.2)
ENT.MISSILES[5] = Vector(28.73,-64.12,-30)
ENT.MISSILES[6] = Vector(28.73,64.12,-30)