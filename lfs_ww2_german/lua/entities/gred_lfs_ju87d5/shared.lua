
ENT.Type           		= "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName 			= "[LFS]Ju 87D-5"
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

ENT.RotorPos 			= Vector(150.241,0,7.08415) -- make sure you set these correctly or your plane will act wierd
ENT.WingPos 			= Vector(-2.32511,13.4984,-4.5694) -- make sure you set these correctly or your plane will act wierd
ENT.ElevatorPos 		= Vector(-291.735,0,30.6403) -- make sure you set these correctly or your plane will act wierd
ENT.RudderPos 			= Vector(-317.832,0,39.1543) -- make sure you set these correctly or your plane will act wierd

ENT.MaxVelocity 		= 1500 -- max theoretical velocity at 0 degree climb
ENT.MaxPerfVelocity 	= 1500 -- speed in which the plane will have its maximum turning potential

ENT.MaxThrust 			= 520 -- max power of rotor

ENT.MaxTurnPitch 		= 300 -- max turning force in pitch, lower this value if you encounter spazz
ENT.MaxTurnYaw 			= 100 -- max turning force in yaw, lower this value if you encounter spazz
ENT.MaxTurnRoll 		= 150 -- max turning force in roll, lower this value if you encounter spazz

ENT.MaxHealth 			= 700
--ENT.MaxShield 		= 200  -- uncomment this if you want to use deflector shields. Dont use excessive amounts because it regenerates.

--ENT.Stability 		= 0.7   -- if you uncomment this the plane will always be able to turn at maximum performance. This causes MaxPerfVelocity to get ignored
ENT.MaxStability 		= 0.4 -- lower this value if you encounter spazz. You can increase this up to 1 to aid turning performance at MaxPerfVelocity-speeds but be careful

ENT.MaxPrimaryAmmo 		= 1000   -- set to a positive number if you want to use weapons. set to -1 if you dont
ENT.MaxSecondaryAmmo 	= 3000 -- set to a positive number if you want to use weapons. set to -1 if you dont

ENT.BulletPos			= {}
ENT.BulletPos[1]		= Vector(61.7917,-85.0942,-12.3775)
ENT.BulletPos[2]		= Vector(61.7917,85.0942,-12.3775)

ENT.MG151Pos			= {}
ENT.MG151Pos[1]			= Vector(64.784,192.998,-30.7511)
ENT.MG151Pos[2]			= Vector(64.784,-192.998,-30.7511)
ENT.MG151Pos[3]			= Vector(64.784,-178.823,-30.7511)
ENT.MG151Pos[4]			= Vector(64.784,178.823,-30.7511)

ENT.MG81Pos				= {}
ENT.MG81Pos[1]			= Vector(38.208,184.793,-26.2772)
ENT.MG81Pos[2]			= Vector(38.208,-184.793,-26.2772)
ENT.MG81Pos[3]			= Vector(38.208,187.349,-26.2772)
ENT.MG81Pos[4]			= Vector(38.208,-187.349,-26.2772)
ENT.MG81Pos[5]			= Vector(27.472,193.945,-30.6842)
ENT.MG81Pos[6]			= Vector(27.472,-193.945,-30.6842)
ENT.MG81Pos[7]			= Vector(27.472,191.467,-30.6842)
ENT.MG81Pos[8]			= Vector(27.472,-191.467,-30.6842)
ENT.MG81Pos[9]			= Vector(27.472,180.671,-30.6842)
ENT.MG81Pos[10]			= Vector(27.472,-180.671,-30.6842)
ENT.MG81Pos[11]			= Vector(27.472,178.2,-30.6842)
ENT.MG81Pos[12]			= Vector(27.472,-178.2,-30.6842)

ENT.BOMBS = {
	[1] = Vector(-7.89679,-194.302,-15),
	[2] = Vector(-7.89679,194.302,-15),
	[3] = Vector(-7.83803,-181.641,-17),
	[4] = Vector(-7.83803,181.641,-17),
	[5] = Vector(0,0,-34),
	[6] = Vector(-5.7,-186.053,-22),
	[7] = Vector(-5.7,186.053,-22),
}

ENT.TurretMuzzle		= {}
ENT.TurretMuzzle[1]		= Vector(-103.85,-1.28882,36.5571)
ENT.TurretMuzzle[2]		= Vector(-103.85,1.28882,36.5571)
ENT.Loadouts			= 7
function ENT:AddDataTables()
	self:NetworkVar( "Int",13, "Loadout", { KeyName = "loadout", Edit = { type = "Int", order = 4,min = 0, max = self.Loadouts, category = "Weapons"} } )
	
	if SERVER then
		self:SetLoadout(math.random(0,self.Loadouts))
	end
end