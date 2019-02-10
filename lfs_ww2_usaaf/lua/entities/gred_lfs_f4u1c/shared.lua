
ENT.Type           		= "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName 			= "[LFS]F4U-1C"
ENT.Author 				= "Gredwitch"
ENT.Information 		= ""
ENT.Category 			= "Gredwitch's Stuff"

ENT.Spawnable			= true -- set to "true" to make it spawnable
ENT.AdminSpawnable		= false

ENT.MDL 				= "models/gredwitch/f4u_lfs/f4u.mdl" -- model forward direction must be facing to X+
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
ENT.WheelPos_L 		= 	Vector(62.5883,85.1876,-81.3714)
ENT.WheelPos_R 		= 	Vector(62.5883,-83.6876,-81.3714)
ENT.WheelPos_C 		= 	Vector(-208.09,-1.57273,-34.1648)

ENT.AITEAM 				= 2 -- 0 = FFA  1 = bad guys  2 = good guys

ENT.Mass 				= 4600 -- lower this value if you encounter spazz
ENT.Inertia 			= Vector(46000,46000,46000) -- you must increase this when you increase mass or it will spazz
ENT.Drag 				= -48 -- drag is a good air brake but it will make diving speed worse

--ENT.HideDriver 		= true -- hide the driver?
ENT.SeatPos 			= Vector(-44.9579,-1.65,11.23)
ENT.SeatAng 			= Angle(0,-90,0)

ENT.IdleRPM 			= 200 -- idle rpm. this can be used to tweak the minimum flight speed
ENT.MaxRPM 				= 2800 -- rpm at 100% throttle
ENT.LimitRPM 			= 3000 -- max rpm when holding throttle key

ENT.RotorPos 			= Vector(146.209,-1.57272,0.483673) -- make sure you set these correctly or your plane will act wierd
ENT.WingPos 			= Vector(34.1327,1.12711,-25.5001) -- make sure you set these correctly or your plane will act wierd
ENT.ElevatorPos 		= Vector(-242.687,-1.57272,19.1757) -- make sure you set these correctly or your plane will act wierd
ENT.RudderPos 			= Vector(-205.729,-1.57272,105.274) -- make sure you set these correctly or your plane will act wierd

ENT.MaxVelocity 		= 1500 -- max theoretical velocity at 0 degree climb
ENT.MaxPerfVelocity 	= 1500 -- speed in which the plane will have its maximum turning potential

ENT.MaxThrust 			= 750 -- max power of rotor


ENT.MaxTurnPitch 		= 450
ENT.MaxTurnYaw 			= 400
ENT.MaxTurnRoll 		= 350

ENT.MaxHealth 			= 800
--ENT.MaxShield 		= 200  -- uncomment this if you want to use deflector shields. Dont use excessive amounts because it regenerates.

--ENT.Stability 		= 0.7   -- if you uncomment this the plane will always be able to turn at maximum performance. This causes MaxPerfVelocity to get ignored
ENT.MaxStability 		= 0.4 -- lower this value if you encounter spazz. You can increase this up to 1 to aid turning performance at MaxPerfVelocity-speeds but be careful

ENT.MaxSecondaryAmmo 	= -1 -- set to a positive number if you want to use weapons. set to -1 if you dont

ENT.BulletPos			= {}
ENT.BulletPos[1]		= Vector(100.889,112.866,-28.6923)
ENT.BulletPos[2]		= Vector(100.889,-111.266,-28.6923)
ENT.BulletPos[3]		= Vector(90.4175,122.075,-27.9333)
ENT.BulletPos[4]		= Vector(90.4175,-120.475,-27.9333)

ENT.MaxPrimaryAmmo 		= 924
