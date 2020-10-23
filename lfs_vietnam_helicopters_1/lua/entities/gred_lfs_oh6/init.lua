--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

ENT.rotorHP = 300
ENT.TailRotorPos = Vector(-198,14,65)

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 50 )
	ent:Spawn()
	ent:Activate()
	
	return ent
end

function ENT:OnTick()
	if self.TailEffectTime then
		if self:GetEngineActive() then
			local ct = CurTime()
			if self.TailEffectTime < ct then
				local effect = EffectData()
				effect:SetOrigin(self:LocalToWorld(self.TailRotorPos))
				effect:SetNormal(-self:GetRight())
				util.Effect("ManhackSparks",effect)
				self.TailEffectTime = ct + math.random(0.1,0.3)
			end
		end
		
		local RPM = self:GetRPM()
		local p = self:GetPhysicsObject()
		if IsValid(p) then
			local angvel = p:GetAngleVelocity()
			p:AddAngleVelocity(Vector(angvel.x > 50 and 0 or RPM*0.01,0,angvel.z > 200 and 0 or math.Clamp(RPM,0,2000)*0.04))
			local vel = p:GetVelocity()
			p:AddVelocity(Vector(0,0,vel.z < -600 and 0 or -RPM*0.005))
		end
	end
end

local tracer_1 = 0
function ENT:UpdateTracers_1()
	tracer_1 = tracer_1 + 1
	if tracer_1 >= self.TracerConvar:GetInt() then
		tracer_1 = 0
		return "red"
	else
		return false
	end
end

local baseclass = baseclass.Get("lunasflightschool_basescript_heli")
function ENT:OnTakeDamage(dmginfo)
	baseclass.OnTakeDamage(self,dmginfo)
	
	if self.TailEffectTime then return end
	
	local dist = self.TailRotorPos:Distance(self:WorldToLocal(dmginfo:GetDamagePosition()))
	if dist <= 45 then
		local dmg = dmginfo:GetDamage()
		self.rotorHP = self.rotorHP - dmg
		if self.rotorHP <= 100 then
			self.MaxYaw = 0
			self.TailEffectTime = CurTime()
			if !self.SoundPlayed and self:GetEngineActive() then
				self:EmitSound(self.CRASHSND)
				self.SoundPlayed = true
			end
		end
	end
end

function ENT:RunOnSpawn()
	self.CRASHSND = "HELICOPTER_CRASHING_"..math.random(1,10)
	self.TracerConvar = GetConVar("gred_sv_tracers")
	self:AddPassengerSeat( Vector(34.5192,-15.1706,43.2718), Angle(0,-90,0) )
	self:AddPassengerSeat( Vector(-3.30247,-14.5148,39.6633), Angle(0,-90,0) )
	self.NextSpin = 0
	-- local pos = self:LocalToWorld(Vector(-90,0,0))
	-- local wedge = ents.Create( "prop_physics" )
	-- wedge:SetModel("models/props_junk/PlasticCrate01a.mdl")
	-- wedge:SetPos(pos)
	-- wedge:SetAngles( self:GetAngles() )
	-- wedge:SetMoveType( MOVETYPE_NONE )
	-- wedge:Spawn()
	-- wedge:Activate()
	-- wedge:SetNotSolid( true )
	-- wedge:DrawShadow( false )
	-- wedge.DoNotDuplicate = true
	-- wedge:SetRenderMode(RENDERMODE_NONE)
	-- constraint.Axis(wedge,self,0,0,self:GetPos(),pos,0,0,0)
	-- self:SetParent(wedge)
	-- wedge:SetParent(self)
	
	-- self:dOwner( wedge )
end

function ENT:CanPrimaryAttack(ct)
	self.NextPrimary = self.NextPrimary or 0
	return self.NextPrimary <= ct
end

function ENT:SetNextPrimary(ct,time)
	self.NextPrimary = self.NextPrimary or 0
	self.NextPrimary = ct + time
end

function ENT:PrimaryAttack()
	local ct = CurTime()
	if not self:CanPrimaryAttack(ct) then return end
	
	if self.NextSpin <= ct then
		self.NextSpin = ct + 0.05
		self:ResetSequence("shoot")
	end
	self:SetNextPrimary(ct,0.04)
	
	local Driver = self:GetDriver()
	local pos2=self:LocalToWorld(self.BulletPos)
	local num = 0.3
	-- local localang = Angle(-0.5,(self.BulletPos.y > 0 and -1 or 1),0)
	local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num))) --+ localang
	gred.CreateBullet(Driver,pos2,ang,"wac_base_7mm",{self},nil,false,self:UpdateTracers_1(),15)
	self:TakePrimaryAmmo()
	local effectdata = EffectData()
	effectdata:SetOrigin(pos2)
	effectdata:SetAngles(ang)
	effectdata:SetEntity(self)
	util.Effect("gred_particle_aircraft_muzzle",effectdata)
end


function ENT:CreateAI()
end

function ENT:RemoveAI()
end

function ENT:OnEngineStarted()
end

function ENT:OnEngineStopped()
end

function ENT:OnRemove()
	self:StopSound(self.CRASHSND)
	self:StopSound("OH6_START")
end

function ENT:HandleWeapons(Fire1, Fire2)
	local Driver = self:GetDriver()
	
	if IsValid( Driver ) then
		
		if self:GetAmmoPrimary() > 0 then
			Fire1 = Driver:KeyDown( IN_ATTACK )
		end
		
	end
	if Fire1 then
		self:PrimaryAttack()
	end
	if self.OldFire ~= Fire1 then
		
		if Fire1 then
			self.wpn1 = CreateSound( self, "M134_SHOOT" )
			self.wpn1:Play()
			self:CallOnRemove( "stopmesounds1", function( ent )
				if ent.wpn1 then
					ent.wpn1:Stop()
				end
			end)
		else
			if self.OldFire == true then
				if self.wpn1 then
					self.wpn1:Stop()
				end
				self.wpn1 = nil
					
				self:EmitSound( "M134_STOP" )
			end
		end
		
		self.OldFire = Fire1
	end
end

function ENT:OnEngineStartInitialized()
	self:EmitSound("OH6_START")
end

--[[
function ENT:OnEngineStopInitialized()
end

function ENT:OnRotorDestroyed()
	self:EmitSound( "physics/metal/metal_box_break2.wav" )
	
	self:SetHP(1)
	
	timer.Simple(2, function()
		if not IsValid( self ) then return end
		self:Destroy()
	end)
end

function ENT:OnRotorCollide( Pos, Dir )
	local effectdata = EffectData()
		effectdata:SetOrigin( Pos )
		effectdata:SetNormal( Dir )
	util.Effect( "manhacksparks", effectdata, true, true )

	self:EmitSound( "ambient/materials/roust_crash"..math.random(1,2)..".wav" )
end
]]
