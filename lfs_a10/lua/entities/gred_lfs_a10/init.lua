
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName ) -- called by garry
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 80 ) -- spawn 20 units above ground
	ent:Spawn()
	ent:Activate()
	ent:SetSkin(math.random(0,3))
	return ent
end
local tracers = 0

function ENT:RunOnSpawn() -- called when the vehicle is spawned
	self.sounds_a10 = {}
	self.sounds_a10["close_shoot"] = CreateSound(self,"^gredwitch/a10_lfs/a10_gun_close_shoot.wav")
	self.sounds_a10["far_shoot"] = CreateSound(self,"^gredwitch/a10_lfs/a10_gun_far_shoot.wav")
	self.sounds_a10["close_stop"] = CreateSound(self,"^gredwitch/a10_lfs/a10_gun_close_stop.wav")
	self.sounds_a10["far_stop"] = CreateSound(self,"^gredwitch/a10_lfs/a10_gun_far_stop.wav")
	
	self.sounds_a10.close_shoot:SetSoundLevel(80)
	self.sounds_a10.close_stop:SetSoundLevel(80)
	self.sounds_a10.far_shoot:SetSoundLevel(120)
	self.sounds_a10.far_stop:SetSoundLevel(120)
	
	self.TracerConvar = GetConVar("gred_sv_tracers"):GetInt()
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimary( 0.015 )
	self.Firing = true
	self.ShouldPlayStopSound = false
	
	-- self:EmitSound("gred_a10_far_shoot")
	-- self:EmitSound("gred_a10_close_shoot")
	self.sounds_a10.close_stop:Stop()
	self.sounds_a10.far_stop:Stop()
	self.sounds_a10.close_shoot:PlayEx(1,100)
	self.sounds_a10.far_shoot:PlayEx(1,100)
	
	local Driver = self:GetDriver()
	
	local pos2=self:LocalToWorld(self.BulletPos)
	local num = 2.5
	local ang = self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num))
	gred.CreateBullet(Driver,pos2,ang,"wac_base_30mm",{self},nil,false,self:UpdateTracers())
	self:TakePrimaryAmmo()
	local effectdata = EffectData()
	effectdata:SetOrigin(pos2)
	effectdata:SetAngles(ang)
	effectdata:SetEntity(self)
	util.Effect("gred_particle_aircraft_muzzle",effectdata)
end

function ENT:UpdateTracers()
	tracers = tracers + 1
	if tracers >= self.TracerConvar then
		tracers = 0
		return "red"
	else
		return false
	end
end

function ENT:OnTick()
	if self:CanPrimaryAttack() and self.Firing then 
		self.Firing = false
		self.ShouldPlayStopSound = true
	end
	if !self.Firing and self.ShouldPlayStopSound and self.sounds_a10 then
		self.sounds_a10.close_shoot:Stop()
		self.sounds_a10.far_shoot:Stop()
		self.sounds_a10.close_stop:PlayEx(1,100)
		self.sounds_a10.far_stop:PlayEx(1,100)
		self.ShouldPlayStopSound = false
		for k,v in pairs(player.GetHumans()) do
			local d = self:GetDriver()
			if IsValid(d) && v == d:GetViewEntity() then return end
			timer.Simple(2,function()
				net.Start("gred_net_sound_lowsh")
					net.WriteString("gunsounds/brrt_0"..math.random(1,4)..".wav")
				net.Send(v)
			end)
		end
		
	end
end
function ENT:OnRemove()
	for k,v in pairs(self.sounds_a10) do v:Stop() v = nil end
end


function ENT:SecondaryAttack()
	if self:GetAI() then return end
	if not self:CanSecondaryAttack() then return end
	self:SetNextSecondary( 0.2 )
	self:TakeSecondaryAmmo()
	
	if m == nil or m >  table.Count(self.MISSILES) or m == 0 then m = 1 end
	local mpos = self:LocalToWorld(self.MISSILES[m])
	local Ang = self:WorldToLocal( mpos ).y > 0 and -1 or 1
	local ent = ents.Create(self.MISSILEENT)
	ent:SetPos(mpos)
	
	ent:SetAngles( self:LocalToWorldAngles( Angle(-2,Ang,0) ) )
	ent.IsOnPlane = true
	ent:SetOwner(self:GetDriver())
	ent:Spawn()
	ent:Activate()
	ent:Launch()
	constraint.NoCollide( ent, self, 0, 0 ) 
	if IsValid( self.wheel_R ) then
		constraint.NoCollide( ent, self.wheel_R, 0, 0 ) 
	end
	if IsValid( self.wheel_L ) then
		constraint.NoCollide( ent, self.wheel_L, 0, 0 ) 
	end
	if IsValid( self.wheel_C ) then
		constraint.NoCollide( ent, self.wheel_C, 0, 0 ) 
	end
	m = m + 1
end

function ENT:CreateAI() -- called when the ai gets enabled
end

function ENT:RemoveAI() -- called when the ai gets disabled
end

function ENT:OnEngineStarted()
	--[[ play engine start sound? ]]--
	-- self:EmitSound( "vehicles/airboat/fan_motor_start1.wav" )
end

function ENT:OnEngineStopped()
	--[[ play engine stop sound? ]]--
	-- self:EmitSound( "vehicles/airboat/fan_motor_shut_off1.wav" )
end

function ENT:OnLandingGearToggled( bOn )
	self:EmitSound( "vehicles/tank_readyfire1.wav" )
	
	if bOn then
		--[[ set bodygroup of landing gear down? ]]--
	else
		--[[ set bodygroup of landing gear up? ]]--
	end
end
