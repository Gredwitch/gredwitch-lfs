
ENT.Type           		= "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript_heli" )

ENT.PrintName 			= "[LFS]AH-1G"
ENT.Author 				= "Gredwitch"
ENT.Information 		= ""
ENT.Category 			= "Gredwitch's Stuff"

ENT.Spawnable			= true -- set to "true" to make it spawnable
ENT.AdminSpawnable		= false

ENT.MDL 				= "models/gredwitch/ah1g/ah1g.mdl" -- model forward direction must be facing to X+

ENT.AITEAM 				= 2

ENT.Mass 				= 3000
ENT.Inertia 			= Vector(5000,5000,5000)
ENT.Drag 				= 0

ENT.SeatPos 			= Vector(55,0,52.1)
ENT.SeatAng 			= Angle(0,-90,0)

ENT.MaxThrustHeli 		= 7
ENT.MaxTurnPitchHeli 	= 30
ENT.MaxTurnYawHeli 		= 50
ENT.MaxTurnRollHeli 	= 100

ENT.ThrustEfficiencyHeli= 0.6

ENT.RotorPos 			= Vector(0,0,118.5)
ENT.RotorAngle 			= Angle(0,0,0)
ENT.RotorRadius 		= 280
ENT.TailRotorPos		= Vector(-362.91,33.177,106.752)

ENT.MaxHealth 			= 1600

ENT.MaxPrimaryAmmo 		= 1900
ENT.MaxSecondaryAmmo 	= 21

ENT.BulletPos 			= Vector(51.5028,41.33,40.7203)

ENT.MISSILEENT			= "gb_rocket_hydra"
ENT.MISSILES			= {
						[1] = Vector(-27.6002,57.1767,42.3694),
						[2] = Vector(-27.6002,-57.1767,42.3694),
						[3] = Vector(-27.6002,-57.1767,42.3694)
}

ENT.TailPos = Vector(-100,0,40)

ENT.TailProperties = {
	pos = Vector(0,0,0),
	model = "models/gredwitch/ah1g/ah1g_tail.mdl",
	angles = Angle(0, 0, 0),
	damage_rip = "models/sentry/ah1g_tail_destroyed.mdl",
	damage_explosion = "models/sentry/ah1g_tail_destroyed.mdl"
}

function ENT:GetTail()
	if SERVER then
		net.Start("gred_net_getserverprop")
			net.WriteEntity(self.Tail)
			net.WriteEntity(self)
		net.Broadcast()
	end
end

