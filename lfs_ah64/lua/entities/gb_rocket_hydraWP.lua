AddCSLuaFile()

DEFINE_BASECLASS( "base_rocket" )

local ExploSnds = {}
ExploSnds[1]						 =  "gredwitch/common/bazooka_detonate_wp_dist_01.wav"
ExploSnds[2]						 =  "gredwitch/common/bazooka_detonate_wp_dist_02.wav"
ExploSnds[3]						 =  "gredwitch/common/bazooka_detonate_wp_dist_03.wav"
                                     
local CloseExploSnds = {}            
CloseExploSnds[1]					 =  "gredwitch/common/bazooka_detonate_wp_01.wav"
CloseExploSnds[2]					 =  "gredwitch/common/bazooka_detonate_wp_02.wav"
CloseExploSnds[3]					 =  "gredwitch/common/bazooka_detonate_wp_03.wav"
                                     
local DistExploSnds = {}             
DistExploSnds[1]					 =  "gredwitch/common/bazooka_detonate_wp_far_dist_01.wav"
DistExploSnds[2]					 =  "gredwitch/common/bazooka_detonate_wp_far_dist_02.wav"
DistExploSnds[3]					 =  "gredwitch/common/bazooka_detonate_wp_far_dist_03.wav"

ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "[ROCKETS]WP Hydra 70"
ENT.Author			                 =  ""
ENT.Contact			                 =  ""
ENT.Category                         =  "Gredwitch's Stuff"

ENT.Model                  		     =  "models/gredwitch/ah64_lfs/hydra70.mdl"
ENT.RocketTrail                      =  "ins_rockettrail"
ENT.RocketBurnoutTrail               =  "grenadetrail"
ENT.Effect                           =  "doi_wprocket_explosion"
ENT.EffectAir                        =  "doi_wprocket_explosion"
ENT.EffectWater                      =  "doi_wprocket_explosion" 
ENT.AngEffect						 =	true

ENT.ExplosionSound                   =  table.Random(CloseExploSnds)
ENT.FarExplosionSound				 =  table.Random(ExploSnds)
ENT.DistExplosionSound				 =  table.Random(DistExploSnds)
ENT.RSound							 = 0

ENT.StartSound                       =  ""          
ENT.ArmSound                         =  "helicoptervehicle/missileshoot.mp3"            
ENT.ActivationSound                  =  "buttons/button14.wav"

ENT.EngineSound                  	 =  "Hydra_Engine"

ENT.ShouldUnweld                     =  true          
ENT.ShouldIgnite                     =  false                
ENT.SmartLaunch                      =  true  
ENT.Timed                            =  false 

ENT.ExplosionDamage                  =  50
ENT.ExplosionRadius                  =  250
ENT.PhysForce                        =  50
ENT.SpecialRadius                    =  50
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  1
ENT.MaxDelay                         =  0
ENT.TraceLength                      =  1000
ENT.ImpactSpeed                      =  50         
ENT.Mass                             =  7             
ENT.EnginePower                      =  300
ENT.FuelBurnoutTime                  =  12         
ENT.IgnitionDelay                    =  0.1           
ENT.ArmDelay                         =  0
ENT.RotationalForce                  =  500  
ENT.ForceOrientation                 =  "NORMAL"
ENT.Timer                            =  0

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:SpawnFunction( ply, tr )
    if ( !tr.Hit ) then return end
	self.GBOWNER = ply
    local ent = ents.Create(self.ClassName)
	ent:SetPhysicsAttacker(ply)
    ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
    ent:Spawn()
    ent:Activate()
	
	ent.ExplosionSound = table.Random(CloseExploSnds)
	ent.FarExplosionSound	= table.Random(ExploSnds)
	ent.DistExplosionSound	= table.Random(DistExploSnds)
    return ent
end

function ENT:AddOnExplode()
	local ent = ents.Create("base_napalm")
	local pos = self:GetPos()
	ent:SetPos(pos)
	ent.Radius	 = 450
	ent.Rate  	 = 1
	ent.Lifetime = 17
	ent:Spawn()
	ent:Activate()
	ent:SetVar("GBOWNER",self.GBOWNER)
end