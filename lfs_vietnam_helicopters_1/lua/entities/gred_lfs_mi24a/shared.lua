
ENT.Type           		= "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript_heli" )

ENT.PrintName 			= "[LFS]Mi-24A"
ENT.Author 				= "Gredwitch"
ENT.Information 		= ""
ENT.Category 			= "Gredwitch's Stuff"

ENT.Spawnable			= true -- set to "true" to make it spawnable
ENT.AdminSpawnable		= false

ENT.MDL 				= "models/gredwitch/mi24a/mi24a.mdl" -- model forward direction must be facing to X+

ENT.AITEAM 				= 1

ENT.Mass 				= 3000
ENT.Inertia 			= Vector(5000,5000,5000)
ENT.Drag 				= 0

ENT.SeatPos 			= Vector(228.316,13.284,41.0459)
ENT.SeatAng 			= Angle(0,-90,0)
ENT.WheelPos_R			= Vector(45.9049,-59.3653,10.2134)
ENT.WheelPos_L			= Vector(45.9049,59.3653,10.2134)
ENT.WheelPos_C			= Vector(243.432,0,-17.7661)
ENT.WheelMass 		= 	200 -- wheel mass is 1 when the landing gear is retracted
ENT.WheelRadius 	= 	17

ENT.MaxThrustHeli 		= 7
ENT.MaxTurnPitchHeli 	= 30
ENT.MaxTurnYawHeli 		= 50
ENT.MaxTurnRollHeli 	= 100

ENT.ThrustEfficiencyHeli= 0.6

ENT.RotorPos 			= Vector(99.0576,-5.28157,163.759)
ENT.RotorAngle 			= Angle(0,0,0)
ENT.RotorRadius 		= 395

ENT.MaxHealth 			= 1600

-- 400 bullets/UPK-23 pod

ENT.MaxPrimaryAmmo 		= 1600
ENT.MaxSecondaryAmmo 	= 800
ENT.MaxMissiles			= 4
ENT.Loadouts			= 9

ENT.BulletPos 			= {}
ENT.BulletPos[1] 		= Vector(110.836,103.039,30.6701)
ENT.BulletPos[2] 		= Vector(110.836,105.67,30.5088)
ENT.BulletPos[3] 		= Vector(110.836,-103.039,30.6701)
ENT.BulletPos[4] 		= Vector(110.836,-105.67,30.5088)

ENT.BulletPos[5] 		= Vector(110.836,77.039,36.7625)
ENT.BulletPos[6] 		= Vector(110.836,79.6709,36.7625)
ENT.BulletPos[7] 		= Vector(110.836,-77.039,36.7625)
ENT.BulletPos[8] 		= Vector(110.836,-79.6709,36.7625)

ENT.ROCKETENT			= "gb_rocket_hydra"
ENT.MISSILEENT			= "gb_rocket_nebel"
ENT.ROCKETS			= {
						[1] = Vector(95.5963,78.2293,32.0327),
						[2] = Vector(95.5963,-78.2293,32.0327),
						[3] = Vector(86.3742,-104.086,26.0522),
						[4] = Vector(86.3742,104.086,26.0522),
}

ENT.MISSILES			= {
						[1] = Vector(48.928,158.91,21.334),
						[2] = Vector(48.928,-158.91,21.334),
						[3] = Vector(48.928,131.333,22.28),
						[4] = Vector(48.928,-131.333,22.28),
}
ENT.BOMBS				= {
						[1] = Vector(37.6873,78.7248,40.9353),
						[2] = Vector(37.6873,-78.7248,35.9353),
						[3] = Vector(37.6873,104.489,34.8316),
						[4] = Vector(37.6873,-104.489,29.8316),
}

-- ENT.BOMBS = {
	-- [1] = Vector(54,-1.59472,-49),
-- }

function ENT:AddDataTables()
	self:NetworkVar( "Int",11, "Loadout", { KeyName = "loadout", Edit = { type = "Int", order = 4,min = 0, max = self.Loadouts, category = "Weapons"} } )
	self:NetworkVar( "Int",12, "CurSecondary")
	self:NetworkVar( "Bool",11, "Missiles", { KeyName = "missiles", Edit = { type = "Boolean",	order = 4,	category = "Weapons"} } )
	self:NetworkVar( "Int",13, "MissileCount", { KeyName = "missilecout", Edit = { type = "Int", order = 4,min = 0, max = self.MaxMissiles, category = "Weapons"} } )
	self:NetworkVar("Entity", 11, "Target")
	self:NetworkVar("Vector", 11, "TargetOffset")
	if SERVER then
		self:SetLoadout(math.random(0,self.Loadouts))
		self:SetCurSecondary(0)
		self:SetMissiles(Either(math.random(0,1)==1,true,false))
	end
end
