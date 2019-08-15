
ENT.Type           		= "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName 			= "[LFS]Fw 190D-12"
ENT.Author 				= "Gredwitch"
ENT.Information 		= ""
ENT.Category 			= "Gredwitch's Stuff"

ENT.Spawnable			= true -- set to "true" to make it spawnable
ENT.AdminSpawnable		= false

ENT.MDL 				= "models/gredwitch/fw190_lfs/fw190.mdl" -- model forward direction must be facing to X+
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
ENT.WheelPos_L 		= 	Vector(79.93,-101.561,-87.2068)
ENT.WheelPos_R 		= 	Vector(79.93,101.561,-87.2068)
ENT.WheelPos_C 		= 	Vector(-198.527,0,-21.96124)

ENT.AITEAM 				= 1 -- 0 = FFA  1 = bad guys  2 = good guys

ENT.Mass 				= 2000 -- lower this value if you encounter spazz
ENT.Inertia 			= Vector(20000,20000,20000) -- you must increase this when you increase mass or it will spazz
ENT.Drag 				= -40 -- drag is a good air brake but it will make diving speed worse

--ENT.HideDriver 		= true -- hide the driver?
ENT.SeatPos 			= Vector(0,-1.62,3.67)
ENT.SeatAng 			= Angle(0,-90,0)

ENT.IdleRPM 			= 300 -- idle rpm. this can be used to tweak the minimum flight speed
ENT.MaxRPM 				= 2800 -- rpm at 100% throttle
ENT.LimitRPM 			= 3000 -- max rpm when holding throttle key

ENT.RotorPos 			= Vector(150,0,7.89529) -- make sure you set these correctly or your plane will act wierd
ENT.WingPos 			= Vector(43.2872,-2.60299,-8.27187) -- make sure you set these correctly or your plane will act wierd
ENT.ElevatorPos 		= Vector(-218.529,0,30.7348	) -- make sure you set these correctly or your plane will act wierd
ENT.RudderPos 			= Vector(-193.578,0,13.7062) -- make sure you set these correctly or your plane will act wierd

ENT.MaxVelocity 		= 1500 -- max theoretical velocity at 0 degree climb
ENT.MaxPerfVelocity 	= 1500 -- speed in which the plane will have its maximum turning potential

ENT.MaxThrust 			= 850 -- max power of rotor


ENT.MaxTurnPitch 		= 500
ENT.MaxTurnYaw 			= 400
ENT.MaxTurnRoll 		= 300

ENT.MaxHealth 			= 800
--ENT.MaxShield 		= 200  -- uncomment this if you want to use deflector shields. Dont use excessive amounts because it regenerates.

--ENT.Stability 		= 0.7   -- if you uncomment this the plane will always be able to turn at maximum performance. This causes MaxPerfVelocity to get ignored
ENT.MaxStability 		= 0.4 -- lower this value if you encounter spazz. You can increase this up to 1 to aid turning performance at MaxPerfVelocity-speeds but be careful

ENT.MaxSecondaryAmmo 	= 8 -- set to a positive number if you want to use weapons. set to -1 if you dont

ENT.BulletPos			= {}
-- ENT.BulletPos[1]		= Vector(89.94,5.63,30.58)
ENT.BulletPos[1]		= Vector(89.94,-5.63,30.58)

ENT.NextCannon			= 0
ENT.AmmoCannon			= 440
ENT.MaxPrimaryAmmo 		= 85

ENT.CannonPos			= {}
-- ENT.CannonPos[1]		= Vector(83.8659,-106.278,-9.00239)
-- ENT.CannonPos[2]		= Vector(83.8659,106.278,-9.00239)
ENT.CannonPos[1]		= Vector(97.1099,-42.0802,-15.886)
ENT.CannonPos[2]		= Vector(97.1099,42.0802,-15.886)

ENT.Loadouts			= 6 -- 2 loaoduts

ENT.BOMBS = {
	[1] = Vector(42.9327,0,-40.8034),
	[2] = Vector(75.8759,-4.748,-50.52),
	[3] = Vector(75.8759,4.748,-50.52),
	[4] = Vector(12.4919,-4.748,-47.308),
	[5] = Vector(12.4919,4.748,-47.308),
	[6] = Vector(30.5611,-119.483,-18.4986),
	[7] = Vector(32.1203,-103.998,-20.7425),
	[8] = Vector(30.5611,119.483,-18.4986),
	[9] = Vector(32.1203,103.998,-20.7425),
}
function ENT:GetCalcViewFilter(ent)
	return not ent.ClassName == "gred_prop_part"
end

function ENT:GetPartModelPath(k)
	return "models/gredwitch/fw190_lfs/fw190_"..k..".mdl"
end

ENT.PartParents = {
	
	gear_l2 	=	"gear_l3",
	gear_l3 	=	"wing_l",
	wheel_l 	=	"gear_l",
	gear_l 		=	"wing_l",
	gear_l4 	=	"wing_l",
	aileron_l 	=	"wing_l",
	flap_l 		=	"wing_l",
	gear_11 	=	false,
	
	gear_r2 	=	"gear_r3",
	gear_r3 	=	"wing_r",
	wheel_r 	=	"gear_r",
	gear_r 		=	"wing_r",
	gear_r4 	=	"wing_r",
	aileron_r 	=	"wing_r",
	flap_r 		=	"wing_r",
	gear_11 	=	false,
	
	wheel_c 	=	"gear_c",
	gear_c 		=	"tail",
	rudder 		=	"tail",
	elevator	=	"tail",
	
	tail 		=	false,
	wing_l 		=	false,
	wing_r 		=	false,
}


function ENT:AddDataTables()
	self:NetworkVar( "Int",11, "AmmoCannon", { KeyName = "cannonammo", Edit = { type = "Int", order = 3,min = 0, max = self.AmmoCannon, category = "Weapons"} } )
	self:NetworkVar( "Int",13, "Loadout", { KeyName = "loadout", Edit = { type = "Int", order = 4,min = 0, max = self.Loadouts, category = "Weapons"} } )
	
	if SERVER then
		self:SetAmmoCannon(self:GetMaxAmmoCannon())
		self:SetLoadout(math.random(0,self.Loadouts))
	end
end