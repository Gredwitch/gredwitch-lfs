
ENT.Type           		= "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript_heli" )

ENT.PrintName 			= "[LFS]UH-1P"
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

ENT.MaxPrimaryAmmo 		= -1
ENT.MaxSecondaryAmmo 	= -1


ENT.Loadouts			= 4

function ENT:AddDataTables()
	self:NetworkVar( "Int",13, "Loadout", { KeyName = "loadout", Edit = { type = "Int", order = 4,min = 0, max = self.Loadouts, category = "Logistic"} } )
	self:NetworkVar( "Bool",11, "LeftSeat",	{ KeyName = "LeftSeat",	Edit = { type = "Boolean",	order = 4,	category = "Logistic"} } )
	self:NetworkVar( "Bool",12, "RightSeat",	{ KeyName = "RightSeat",	Edit = { type = "Boolean",	order = 4,	category = "Logistic"} } )
	if SERVER then
		self:SetLoadout(math.random(0,self.Loadouts))
		-- self:SetCurSecondary(0)
	end
end