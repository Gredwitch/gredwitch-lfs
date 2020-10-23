
ENT.Type           		= "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript_heli" )

ENT.PrintName 			= "[LFS]UH-1P Gunship"
ENT.Author 				= "Gredwitch"
ENT.Information 		= ""
ENT.Category 			= "Gredwitch's Stuff"

ENT.Spawnable			= true -- set to "true" to make it spawnable
ENT.AdminSpawnable		= false

ENT.MDL 				= "models/gredwitch/uh1/uh1.mdl" -- model forward direction must be facing to X+

ENT.AITEAM 				= 2

ENT.Mass 				= 3000
ENT.Inertia 			= Vector(5000,5000,5000)
ENT.Drag 				= 0

ENT.SeatPos 			= Vector(81.3078,-20.7393,34.8398)
ENT.SeatAng 			= Angle(0,-90,0)

ENT.MaxThrustHeli 		= 7
ENT.MaxTurnPitchHeli 	= 30
ENT.MaxTurnYawHeli 		= 50
ENT.MaxTurnRollHeli 	= 100

ENT.ThrustEfficiencyHeli= 0.6

ENT.RotorPos 			= Vector(-5.76219,0,97.138)
ENT.RotorAngle 			= Angle(0,0,0)
ENT.RotorRadius 		= 350

ENT.MaxHealth 			= 1600

ENT.MaxPrimaryAmmo 		= 1900
ENT.MaxSecondaryAmmo 	= 14

ENT.BulletPos 			= {
						[1] = Vector(8.06235,74.1922,21.3797),
						[2] = Vector(8.06235,-74.1922,21.3797),
}

ENT.MISSILEENT			= "gb_rocket_hydra"
ENT.MISSILES			= {
						[1] = Vector(-8.65226,63.681,14.273),
						[2] = Vector(-8.65226,-63.681,14.273),
						[3] = Vector(-8.65226,60.501,14.273),
						[4] = Vector(-8.65226,-60.501,14.273),
						[5] = Vector(-8.65226,66.831,14.273),
						[6] = Vector(-8.65226,-66.831,14.273),
						[7] = Vector(-8.65226,62.1059,16.973),
						[8] = Vector(-8.65226,-62.1059,16.973),
						[9] = Vector(-8.65226,65.2559,16.973),
						[10] = Vector(-8.65226,-65.2559,16.973),
						[11] = Vector(-8.65226,62.1059,11.5463),
						[12] = Vector(-8.65226,-62.1059,11.5463),
						[13] = Vector(-8.65226,65.2559,11.5463),
}

ENT.Loadouts			= 1

function ENT:AddDataTables()
	self:NetworkVar( "Int",13, "Loadout", { KeyName = "loadout", Edit = { type = "Int", order = 4,min = 0, max = self.Loadouts, category = "Weapons"} } )
	self:NetworkVar( "Entity",11, "Gunner2" )
	self:NetworkVar( "Entity",13, "Grenadier" )
	self:NetworkVar( "Entity",12, "Gunner2Seat" )
	self:NetworkVar( "Entity",14, "GrenadierSeat" )
	if SERVER then
		self:SetLoadout(math.random(0,self.Loadouts))
	end
end
