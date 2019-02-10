
ENT.Type           		= "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName 			= "[LFS]P-51D-5"
ENT.Author 				= "Gredwitch"
ENT.Information 		= ""
ENT.Category 			= "Gredwitch's Stuff"

ENT.Spawnable			= true -- set to "true" to make it spawnable
ENT.AdminSpawnable		= false

ENT.MDL 				= "models/gredwitch/p51_lfs/p51d.mdl" -- model forward direction must be facing to X+
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
ENT.WheelPos_L 		= 	Vector(33.25,-77.5104,-72.9754)
ENT.WheelPos_R 		= 	Vector(33.25,77.5104,-72.9754)
ENT.WheelPos_C 		= 	Vector(-199.683,0,-31.3769)

ENT.AITEAM 				= 2 -- 0 = FFA  1 = bad guys  2 = good guys

ENT.Mass 				= 2000 -- lower this value if you encounter spazz
ENT.Inertia 			= Vector(20000,20000,20000) -- you must increase this when you increase mass or it will spazz
ENT.Drag 				= -40 -- drag is a good air brake but it will make diving speed worse

--ENT.HideDriver 		= true -- hide the driver?
ENT.SeatPos 			= Vector(-28.5223,0,7.8)
ENT.SeatAng 			= Angle(0,-90,0)

ENT.IdleRPM 			= 200 -- idle rpm. this can be used to tweak the minimum flight speed
ENT.MaxRPM 				= 2800 -- rpm at 100% throttle
ENT.LimitRPM 			= 3000 -- max rpm when holding throttle key

ENT.RotorPos 			= Vector(130.844,0,15.3212) -- make sure you set these correctly or your plane will act wierd
ENT.WingPos 			= Vector(10.8453,-1.52084,-7.87378) -- make sure you set these correctly or your plane will act wierd
ENT.ElevatorPos 		= Vector(-236.925,0,18.7267) -- make sure you set these correctly or your plane will act wierd
ENT.RudderPos 			= Vector(-267.063,0,35.4366) -- make sure you set these correctly or your plane will act wierd

ENT.MaxVelocity 		= 1500 -- max theoretical velocity at 0 degree climb
ENT.MaxPerfVelocity 	= 1500 -- speed in which the plane will have its maximum turning potential

ENT.MaxThrust 			= 850 -- max power of rotor


ENT.MaxTurnPitch 		= 450
ENT.MaxTurnYaw 			= 400
ENT.MaxTurnRoll 		= 350

ENT.MaxHealth 			= 800
--ENT.MaxShield 		= 200  -- uncomment this if you want to use deflector shields. Dont use excessive amounts because it regenerates.

--ENT.Stability 		= 0.7   -- if you uncomment this the plane will always be able to turn at maximum performance. This causes MaxPerfVelocity to get ignored
ENT.MaxStability 		= 0.4 -- lower this value if you encounter spazz. You can increase this up to 1 to aid turning performance at MaxPerfVelocity-speeds but be careful

ENT.MaxSecondaryAmmo 	= 6 -- set to a positive number if you want to use weapons. set to -1 if you dont

ENT.LastChangeSecondary = 0
ENT.BulletPos			= {}
ENT.BulletPos[1]		= Vector(24.9609,89.518,-8.91509)
ENT.BulletPos[2]		= Vector(24.9609,-89.518,-8.91509)
ENT.BulletPos[3]		= Vector(27.5129,98.67,-8.00759)
ENT.BulletPos[4]		= Vector(27.5129,-98.67,-8.00759)
ENT.BulletPos[5]		= Vector(28.2169,107.976,-7.11659)
ENT.BulletPos[6]		= Vector(28.2169,-107.976,-7.11659)

ENT.MaxPrimaryAmmo 		= 2080

ENT.M8MDL 				= "models/hawx/zuni mk16.mdl"
ENT.HVARMDL 			= "models/gredwitch/bombs/hvar.mdl"
ENT.HVAR			= {
			[1]			= { Vector(-11.8671,-131.107,-19.3171), Vector(-11.8671,131.107,-19.3171), },
			[2]			= { Vector(-11.8671,-117.084,-20.9849), Vector(-11.8671,117.084,-20.9849), },
			[3]			= { Vector(-8.8671,-145.156,-17.6891), Vector(-8.8671,145.156,-17.6891), },
			[4]			= { Vector(-11.8671,-102.916,-22.6569), Vector(-11.8671,102.916,-22.6569), },
			[5]			= { Vector(-11.8671,-88.8884,-24.3289), Vector(-11.8671,88.8884,-24.3289), },
}

ENT.M8				= {
			[1]			= { Vector(3.0269,-129.965,-27.5649), Vector(3.0269,129.965,-27.5649), },
			[2]			= { Vector(3.0269,-132.669,-32.2835), Vector(3.0269,132.669,-32.2835), },
			[3]			= { Vector(3.0269,-127.262,-32.2835), Vector(3.0269,127.262,-32.2835), }
}

ENT.Loadouts			= 7

ENT.BOMBS = {
	[1] = Vector(0,104.801,-32),
	[2] = Vector(0,-104.801,-32),
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