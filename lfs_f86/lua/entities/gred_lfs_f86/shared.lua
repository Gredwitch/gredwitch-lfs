
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.Type            = 	"anim"

ENT.PrintName 		= 	"[LFS]F-86"
ENT.Author 			= 	"Gredwitch"
ENT.Information 	= 	""
ENT.Category 		= 	"Gredwitch's Stuff"

ENT.Spawnable		= 	true -- set to "true" to make it spawnable
ENT.AdminSpawnable	= 	false

ENT.MDL 			= 	"models/gredwitch/f86_lfs/f86_fuse.mdl" -- model forward direction must be facing to X+

ENT.GibModels = {}

ENT.AITEAM 			= 	2 -- 0 = FFA  1 = bad guys  2 = good guys
ENT.Parts 			=	{}
ENT.Mass 			= 	6894 -- lower this value if you encounter spazz
ENT.Inertia 		= 	Vector(500000,500000,500000) -- you must increase this when you increase mass or it will spazz
ENT.Drag 			= 	30 -- drag is a good air brake but it will make diving speed worse

ENT.SeatPos 		= 	Vector(137.83,0,48.4)
ENT.SeatAng 		= 	Angle(0,-90,0)

ENT.WheelMass 		= 	200 -- wheel mass is 1 when the landing gear is retracted
ENT.WheelRadius 	= 	15
ENT.WheelPos_L 		= 	Vector(36.0389,-68.2915,-39.2766)
ENT.WheelPos_R 		= 	Vector(36.0389,68.2915,-39.2766)
ENT.WheelPos_C 		= 	Vector(224.812,0,-28.4728)

ENT.IdleRPM 		= 	0 -- idle rpm. this can be used to tweak the minimum flight speed
ENT.MaxRPM 			= 	3000 -- rpm at 100% throttle
ENT.LimitRPM 		= 	3500 -- max rpm when holding throttle key

ENT.RotorPos 		=	Vector(-207.592,0,36.7923)
ENT.TailPos 		=	Vector(-60.237179,-0.451202,43.682617)
ENT.WingPos 		= 	Vector(10.4835,1,19.4119) -- make sure you set these correctly or your plane will act wierd
ENT.ElevatorPos 	= 	Vector(-179.916,0,56.364) -- make sure you set these correctly or your plane will act wierd
ENT.RudderPos		= 	Vector(-228.14,0,139.48) -- make sure you set these correctly or your plane will act wierd

ENT.MaxVelocity 	= 	10000 -- max theoretical velocity at 0 degree climb
ENT.MaxPerfVelocity = 	3000 -- speed in which the plane will have its maximum turning potential

ENT.MaxThrust 		= 	8000 -- max power per rotor

ENT.MaxTurnPitch 	= 	550 -- max turning force in pitch, lower this value if you encounter spazz
ENT.MaxTurnYaw 		= 	200 -- max turning force in yaw, lower this value if you encounter spazz
ENT.MaxTurnRoll 	= 	600 -- max turning force in roll, lower this value if you encounter spazz

ENT.MaxHealth 		= 	1400
-- ENT.MaxShield 	= 	200  -- uncomment this if you want to use deflector shields. Dont use excessive amounts because it regenerates.

--ENT.Stability 	= 	0.7   -- if you uncomment this the plane will always be able to turn at maximum performance. This causes MaxPerfVelocity to get ignored
ENT.MaxStability 	= 	0.5 -- lower this value if you encounter spazz. You can increase this up to 1 to aid turning performance at MaxPerfVelocity-speeds but be careful

ENT.MaxPrimaryAmmo 	= 	1800   -- set to a positive number if you want to use weapons. set to -1 if you dont
ENT.MaxSecondaryAmmo= 	16 -- set to a positive number if you want to use weapons. set to -1 if you dont

ENT.altitude 		=	0
ENT.Loadouts		=	3
ENT.BulletPos 		= 	{
						Vector(195.58,24.266,55.55),
						Vector(200.552,25.454,49.478),
						Vector(199.496,27.082,42.042),
						Vector(195.58,-24.266,55.55),
						Vector(200.552,-25.454,49.478),
						Vector(199.496,-27.082,42.042),
}
ENT.HVARMDL = "models/gredwitch/bombs/hvar.mdl"
ENT.HVAR = "gb_rocket_hvar"
ENT.ROCKETS = {}
ENT.ROCKETS[1] = Vector(40.656,74.536,1.5)
ENT.ROCKETS[3] = Vector(29.546,89.672,2.7)
ENT.ROCKETS[5] = Vector(19.668,104.632,3.6)
ENT.ROCKETS[7] = Vector(9.34999,119.856,4.5)
ENT.ROCKETS[9] = Vector(-1.364,135.388,5.1)
ENT.ROCKETS[11] = Vector(-12.188,150.854,6.2)
ENT.ROCKETS[13] = Vector(-23.408,167.552,7.4)
ENT.ROCKETS[15] = Vector(-35.024,184.448,7.8)

ENT.ROCKETS[2] = Vector(40.656,-74.536,1.5)
ENT.ROCKETS[4] = Vector(29.546,-89.672,2.7)
ENT.ROCKETS[6] = Vector(19.668,-104.632,3.6)
ENT.ROCKETS[8] = Vector(9.34999,-119.856,4.5)
ENT.ROCKETS[10] = Vector(-1.364,-135.388,5.1)
ENT.ROCKETS[12] = Vector(-12.188,-150.854,6.2)
ENT.ROCKETS[14] = Vector(-23.408,-167.552,7.4)
ENT.ROCKETS[16] = Vector(-35.024,-184.448,7.8)


ENT.BOMBS = {
	[1] = Vector(50.27,83.776,-3.5),
	[2] = Vector(50.27,-83.776,-3.5),
}
function ENT:AddDataTables()
	self:NetworkVar( "Int",11, "Loadout", { KeyName = "loadout", Edit = { type = "Int", order = 4,min = 0, max = self.Loadouts, category = "Weapons"} } )
	if SERVER then
		self:SetLoadout(math.random(0,self.Loadouts))
	end
end

function ENT:GetRotorPos()
	if not self.Parts.tail then
		self.RotorPos = self.TailPos
	end
	return self:LocalToWorld(self.RotorPos)
end

function ENT:GetCalcViewFilter(ent)
	return not ent.ClassName == "gred_prop_part"
end

function ENT:GetPartModelPath(k)
	return "models/gredwitch/f86_lfs/f86_"..k..".mdl"
end

ENT.PartParents = {
	gear_c1 	= false,
	gear_c3 	= false,
	gear_c2 	= "gear_c3",
	wheel_c 	= "gear_c3",
	
	tail 		= false,
	rudder 		= "tail",
	elevator 	= "tail",
	airbrake_l1 = "tail",
	airbrake_l2 = "tail",
	airbrake_l3 = "tail",
	airbrake_r1 = "tail",
	airbrake_r2 = "tail",
	airbrake_r3 = "tail",
	
	wing_l 		= "wing_l",
	aileron_l 	= "wing_l",
	flap_l 		= "wing_l",
	gear_l2 	= "wing_l",
	wheel_l 	= "gear_l1",
	gear_l1 	= "wing_l",
	gear_r1 	= "wing_r",
	
	wing_r 		= "wing_r",
	aileron_r 	= "wing_r",
	flap_r 		= "wing_r",
	gear_r2 	= "wing_r",
	wheel_r 	= "gear_r1",
}