
ENT.Type           		= "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript_heli" )

ENT.PrintName 			= "[LFS]Mi-8 Gunship"
ENT.Author 				= "Gredwitch"
ENT.Information 		= ""
ENT.Category 			= "Gredwitch's Stuff"

ENT.Spawnable			= true -- set to "true" to make it spawnable
ENT.AdminSpawnable		= false

ENT.MDL 				= "models/gredwitch/mi8/mi8.mdl" -- model forward direction must be facing to X+

ENT.AITEAM 				= 1

ENT.Mass 				= 3000
ENT.Inertia 			= Vector(5000,5000,5000)
ENT.Drag 				= 0

ENT.SeatPos 			= Vector(150,-23.792,50)
ENT.SeatAng 			= Angle(0,-90,0)

ENT.WheelMass 		= 	400 -- wheel mass is 1 when the landing gear is retracted
ENT.WheelRadius 	= 	16
ENT.WheelPos_L 		= 	Vector(-53.597,85.9692,21.2763)
ENT.WheelPos_R 		= 	Vector(-53.597,-85.9692,21.2763)
ENT.WheelPos_C 		= 	Vector(106.466,0,10.7301)

ENT.MaxThrustHeli 		= 7
ENT.MaxTurnPitchHeli 	= 30
ENT.MaxTurnYawHeli 		= 50
ENT.MaxTurnRollHeli 	= 100

ENT.ThrustEfficiencyHeli= 0.6

ENT.RotorPos 			= Vector(-11.7829,-2.92705,159.961)
ENT.RotorAngle 			= Angle(0,0,0)
ENT.RotorRadius 		= 390

ENT.MaxHealth 			= 1600

ENT.MaxPrimaryAmmo 		= 192
ENT.MaxSecondaryAmmo 	= -1

ENT.MISSILEENT			= "gb_rocket_hydra"
ENT.MISSILES = {
			[6] = Vector(40.9803,114.766,34.6636),
			[5] = Vector(40.9803,-114.766,34.6636),
			[4] = Vector(40.9803,94.9755,34.6636),
			[3] = Vector(40.9803,-94.9755,34.6636),
			[2] = Vector(40.9803,74.7463,34.6636),
			[1] = Vector(40.9803,-74.7463,34.6636),
}

ENT.Loadouts			= 2

function ENT:AddDataTables()
	self:NetworkVar( "Entity",11, "Gunner2" )
	self:NetworkVar( "Entity",12, "Gunner2Seat" )
	self:NetworkVar( "Entity",13, "Gunner3" )
	self:NetworkVar( "Entity",14, "Gunner3Seat" )
	
	self:NetworkVar( "Int",11, "Loadout", { KeyName = "loadout", Edit = { type = "Int", order = 4,min = 0, max = self.Loadouts, category = "Logistic"} } )
	if SERVER then
		self:SetLoadout(math.random(0,self.Loadouts))
	end
end
