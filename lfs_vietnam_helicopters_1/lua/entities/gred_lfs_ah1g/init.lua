--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

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

local tracer_2 = 0
function ENT:UpdateTracers_2()
	tracer_2 = tracer_2 + 1
	if tracer_2 >= self.TracerConvar:GetInt() then
		tracer_2 = 0
		return "red"
	else
		return false
	end
end

local tracer_3 = 0
function ENT:UpdateTracers_3()
	tracer_3 = tracer_3 + 1
	if tracer_3 >= self.TracerConvar:GetInt() then
		tracer_3 = 0
		return "red"
	else
		return false
	end
end

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 10 )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:OnTick()
	local ct = CurTime()
	self:HandleModels(ct)
end

function ENT:HandleModels(ct)
	local TailValid = IsValid(self.Tail)
	local skin = self:GetSkin()
	
	if !TailValid and !self.TailDestroyed then
		if !self.InfoSent then
			net.Start("gred_apache_tail_destroyed")
				net.WriteEntity(self)
				net.WriteEntity(nil)
			net.Broadcast()
			
			if IsValid(self.wheel_C) then
				self.wheel_C:Remove()
			end
			if IsValid(self.wheel_C_master) then
				self.wheel_C_master:Remove()
			end
			if self:GetEngineActive() then
				if self.CRASHSND then self:StopSound(self.CRASHSND) end
				self.CRASHSND = "HELICOPTER_CRASHING_"..math.random(1,10)
				self:EmitSound(self.CRASHSND)
			end
			self.TailRotorDownLevel = 2
			self.MaxTurnYawHeli = 0
			self.TailDestroyed = true
			self.Tail = nil
			self.InfoSent = true
			
			local effect = EffectData()
			effect:SetOrigin(self:LocalToWorld(self.TailPos))
			effect:SetNormal(-self:GetForward())
			util.Effect("ManhackSparks",effect)
		end
	elseif TailValid then
		self.Tail:SetSkin(skin)
	elseif self.TailDestroyed then
		local RPM = self:GetRPM()
		local p = self:GetPhysicsObject()
		if IsValid(p) then
			-- p:ApplyForceCenter(Vector(RPM * 30))
			self.MaxPitch = 0
			self.MaxYaw = 0
			self.MaxRoll = 0
			p:AddAngleVelocity(Vector(0,RPM*0.01))
			-- p:AddVelocity(Vector(0,0,)
		end
	end
	if self.TailRotorDownLevel == 1 then
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

function ENT:OnRemove()
	if self.CRASHSND then
		self:StopSound(self.CRASHSND)
	end
end

function ENT:RunOnSpawn()
	self.MUZZLEEFFECT = table.KeyFromValue(gred.Particles,"muzzleflash_bar_3p")
	self.TracerConvar = GetConVar("gred_sv_tracers")
	self:SetGunnerSeat(self:AddPassengerSeat(Vector(105,0,40),Angle(0,-90,0)))
	self.FILTER = {self}
	
	local ent = ents.Create("gred_prop_tail")
	ent.Model = self.TailProperties.model
	ent:SetPos(self:LocalToWorld(self.TailProperties.pos))
	ent:SetAngles(self:LocalToWorldAngles(self.TailProperties.angles))
	ent.OnTakeDamage = function(self,dmg)
		local dist = self.RotorPos:Distance(self:WorldToLocal(dmg:GetDamagePosition()))
		local damage = dmg:GetDamage()
		if dist < 60 then
			local Owner = self:GetOwner()
			local OwnerValid = IsValid(Owner)
			local rotorHP = self:GetRotorHP()
			self:SetRotorHP(rotorHP - damage)
			rotorHP = rotorHP - damage
			
			if rotorHP < 100 then
				if OwnerValid then
					Owner.TailRotorDownLevel = 1
					Owner.MaxYaw = 0
					self.TailEffectTime = self.TailEffectTime or CurTime()
					if !self.SoundPlayed then
						if Owner.CRASHSND then Owner:StopSound(Owner.CRASHSND) end
						Owner.CRASHSND = "HELICOPTER_CRASHING_"..math.random(1,10)
						Owner:EmitSound(Owner.CRASHSND)
						self.SoundPlayed = true
					end
				end
				-- if rotorHP <= 0 then
					-- if OwnerValid then
						-- if Owner.CRASHSND then Owner:StopSound(Owner.CRASHSND) end
						-- Owner.MaxYaw = 0
						-- Owner.TailRotorDownLevel = 2
						-- Owner.MaxTurnYawHeli = 0
					-- end
					-- self.TailEffectTime = nil
					-- self.RotorDestroyed = true
					-- if !self.InfoSent then
						-- self.InfoSent = true
						-- net.Start("gred_apache_rotor_destroyed")
							-- net.WriteEntity(self)
						-- net.Broadcast()
					-- end
				-- else
					-- self.TailRotorDestroyed = false
					-- self.SoundPlayed = false
				-- end
			else
				self.TailEffectTime = nil
			end
		else
			if not self.TailDestroyed then
				local Owner = self:GetOwner()
				local OwnerValid = IsValid(Owner)
				local tailHP = self:GetTailHP()
				self:SetTailHP(tailHP - damage)
				tailHP = tailHP - damage
				if tailHP <= 0 then
					if OwnerValid then
						if IsValid(Owner.wheel_C) then
							Owner.wheel_C:Remove()
						end
						if IsValid(Owner.wheel_C_master) then
							Owner.wheel_C_master:Remove()
						end
						if Owner:GetEngineActive() then
							if Owner.CRASHSND then Owner:StopSound(Owner.CRASHSND) end
							Owner.CRASHSND = "HELICOPTER_CRASHING_"..math.random(1,10)
							Owner:EmitSound(Owner.CRASHSND)
						end
						Owner.TailRotorDownLevel = 2
						Owner.MaxTurnYawHeli = 0
						Owner.TailDestroyed = true
						Owner.Tail = nil
					end
					
					self.EffectTime = CurTime()
					timer.Simple(3,function()
						if IsValid(self) then self.EffectTime = nil end
					end)
					
					net.Start("gred_apache_tail_destroyed")
						net.WriteEntity(Owner)
						net.WriteEntity(self)
					net.Broadcast()
					
					self:EmitSound("LFS_PART_DESTROYED_0"..math.random(1,3))
					self.TailDestroyed = true
					self:SetOwner(nil)
					if IsValid(self.phys) then
						self.phys:SetMass(2000)
						self.phys:EnableGravity(true)
						self.phys:EnableDrag(true)
					end
					constraint.RemoveAll(self)
				end
			end
		end
	end
	ent:Spawn()
	ent:Activate()
	ent:SetOwner(self)
	ent.TailPos = self.TailPos
	ent.RotorPos = Vector(-307,-24.340931,106.794075)
	self.Tail = ent
	self:DeleteOnRemove(ent)
	
	local p = self.Tail:GetPhysicsObject( )
	if IsValid(p) then
		p:SetMass(50)
		p:EnableGravity(false)
		p:EnableDrag(false)
		p:EnableCollisions(true)
		p:Wake()
	end
	
	self.TailWeld = constraint.Weld(ent,self,0,0,0,true,true)
	timer.Simple(0.1,function() self:GetTail() end)
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimary(0.04)
	
	local Driver = self:GetDriver()
	local pos2=self:LocalToWorld(self.BulletPos)
	local num = 0.7
	local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
	gred.CreateBullet(Driver,pos2,ang,"wac_base_20mm",self.FILTER,nil,false,self:UpdateTracers_1())
	self:TakePrimaryAmmo()
	local effectdata = EffectData()
	effectdata:SetOrigin(pos2)
	effectdata:SetAngles(ang)
	effectdata:SetEntity(self)
	util.Effect("gred_particle_aircraft_muzzle",effectdata)
end

local baseclass = baseclass.Get("lunasflightschool_basescript_heli")

function ENT:PhysicsCollide(data,col)
	timer.Simple(0,function() if !IsValid(self) then return end
		if self.TailDestroyed or (self.TailRotorDownLevel and self.TailRotorDownLevel > 0) then
			if data.Speed > 1000 and (!data.HitEntity:IsPlayer() and !data.HitEntity:IsNPC() and !string.StartWith(data.HitEntity:GetClass(),"vfire")) then
				self:Explode()
			end
		end
		baseclass.PhysicsCollide(self,data,col)
	end)
end

function ENT:SecondaryAttack()
	if self:GetAI() then return end
	if not self:CanSecondaryAttack() then return end
	self:SetNextSecondary( 0.2 )
	self:TakeSecondaryAmmo()
	
	if p == nil or p > #self.MISSILES or p == 0 then p = 1 end
	local mpos = self:LocalToWorld(self.MISSILES[p])
	local Ang = self:WorldToLocal( mpos ).y > 0 and -1 or 1
	local ent = ents.Create(self.MISSILEENT)
	ent:SetPos(mpos)
	
	ent:SetAngles(self:GetAngles()-Angle(2.5))
	ent.IsOnPlane = true
	ent:SetOwner(self:GetDriver())
	ent:Spawn()
	ent:Activate()
	ent:Launch()
	constraint.NoCollide( ent, self, 0, 0 )
	if IsValid(self.Tail) then constraint.NoCollide( ent, self.Tail, 0, 0 ) end
	p = p + 1
end

function ENT:CreateAI()
end

function ENT:RemoveAI()
end

function ENT:OnEngineStarted()
end

function ENT:OnEngineStopped()
end


function ENT:CheckRotorClearance()
	if self.BreakRotor then
		if self.BreakRotor ~= self:GetRotorDestroyed() then
			self:SetRotorDestroyed( self.BreakRotor )
			self:OnRotorDestroyed()
		end
		
		return
	end
	
	local angUp = self:GetRotorAngle()
	local Up = angUp:Up()
	local Forward = angUp
	Forward:RotateAroundAxis( Up, -CurTime() * 2000 )
	Forward = Forward:Forward()
	
	local position = self:GetRotorPos()

	local tr = util.TraceLine( {
		start = position,
		endpos = (position + Forward * self:GetRotorRadius()),
		filter = function( ent ) 
			if ent == self or ent:IsPlayer() or ent == self.Tail then 
				return false
			end
			
			return true
		end
	} )
	
	self.RotorHitCount = self.RotorHitCount or 0
	
	if tr.Hit then
		self.RotorHit = true
		
		self.RotorHitCount = self.RotorHitCount + 1
	else 
		self.RotorHit = false
		
		self.RotorHitCount = math.max(self.RotorHitCount - 1 * FrameTime(),0)
	end
	
	if self.RotorHitCount > 20 then
		self.BreakRotor = true
	end
	
	if self.RotorHit ~= self.oldRotorHit then
		self.oldRotorHit = self.RotorHit
		if self.RotorHit then
			self:OnRotorCollide( tr.HitPos, tr.HitNormal )
		end
	end
end

function ENT:HandleWeapons(Fire1, Fire2)
	local Driver = self:GetDriver()
	local secAmmo = self:GetAmmoSecondary()
	local Gunner = self:GetGunner()
	local HasGunner = IsValid( Gunner )
	local TurretSnd = false
	
	if IsValid( Driver ) then
		FireTurret = Driver:lfsGetInput("FREELOOK")
		
		if self:GetAmmoPrimary() > 0 or FireTurret then
			Fire1 = Driver:KeyDown( IN_ATTACK )
		end
		
		if secAmmo > 0 or FireTurret then
			Fire2 = Driver:KeyDown( IN_ATTACK2 )
		end
		self.Firing = Fire2
	end
	if Fire1 then
		if FireTurret and not HasGunner then
			self:AltPrimaryAttack(Driver)
			TurretSnd = true
		else
			self:PrimaryAttack()
		end
	end
	if Fire2 then
		if FireTurret and not HasGunner then
			self:AltSecondaryAttack(Driver)
		else
			self:SecondaryAttack(secAmmo)
		end
	end
	
	if self.OldFire ~= Fire1 and not FireTurret then
		
		if Fire1 then
			self.wpn1 = CreateSound( self, "M61_SHOOT" )
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
					
				self:EmitSound( "M61_STOP" )
			end
		end
		
		self.OldFire = Fire1
	end
	if HasGunner then
		if Gunner:KeyDown( IN_ATTACK ) then
			self:AltPrimaryAttack( Gunner, self:GetGunnerSeat() )
			TurretSnd = true
		end
		if Gunner:KeyDown(IN_ATTACK2) then
			self:AltSecondaryAttack( Gunner, self:GetGunnerSeat() )
		end
	end
	if self.NoTurretSound then
		if self.turret1 then
			self.turret1:Stop()
		end
	else
		if TurretSnd then
			self.turret1 = CreateSound(self,"M134_SHOOT")
			self.turret1:Play()
			self:CallOnRemove( "stopmesounds2", function( ent )
				if ent.turret1 then
					ent.turret1:Stop()
				end
			end)
		else
			if self.turret1 then
				self.turret1:Stop()
			end
			if self.OldTurretSnd == true then
				self.turret1 = nil
				self:EmitSound("M134_STOP")
			end
		end
	end
	self.OldTurretSnd = TurretSnd
	if self.OldFire2 ~= Fire2 and not FireTurret then
		if Fire2 then
			self:SecondaryAttack(secAmmo)
		end
		self.OldFire2 = Fire2
	end
end

function ENT:OnEngineStartInitialized()
	self:EmitSound("AH1G_START")
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


function ENT:SetNextAltPrimary( delay )
	self.NextAltPrimary = CurTime() + delay
end

function ENT:CanAltPrimaryAttack()
	self.NextAltPrimary = self.NextAltPrimary or 0
	return self.NextAltPrimary < CurTime()
end

function ENT:SetNextAltSecondary( delay )
	self.NextAltSecondary = CurTime() + delay
end

function ENT:CanAltSecondaryAttack()
	self.NextAltSecondary = self.NextAltSecondary or 0
	return self.NextAltSecondary < CurTime()
end

function ENT:AltSecondaryAttack( Driver, Pod )
	if not self:CanAltSecondaryAttack() then return end
	
	if not IsValid( Pod ) then Pod = self:GetDriverSeat() end
	if not IsValid( Driver ) then Driver = Pod:GetDriver() end
	
	if not IsValid( Pod ) then return end
	if not IsValid( Driver ) then return end
	local EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() )
	local Forward = -self:GetForward()
	local Up = -self:GetUp()
	
	local AimDirToForwardDir = math.deg( math.acos( math.Clamp( Forward:Dot( EyeAngles:Forward() ) ,-1,1) ) )
	local AimDirToUpDir = math.deg( math.acos( math.Clamp( Up:Dot( EyeAngles:Up() ) ,-1,1) ) )
	
	if AimDirToForwardDir < 120 or AimDirToUpDir < 120 then self.NoTurretSound = true return else self.NoTurretSound = false end
	
	self:SetNextAltSecondary( 0.5 )
	
	local MuzzlePos = self:LocalToWorld(Vector(119.5,7.43675,20.5202) + EyeAngles:Forward()*17)

	local num = 0.3
	local ang = (EyeAngles + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
	
	gred.CreateShell(MuzzlePos,ang,Driver,self.FILTER,40,"HE",260,0.33,"white",nil,nil,nil,0.045,51):Launch()
	
	self:EmitSound("GRED_SHOOT_40MM")
end

function ENT:AltPrimaryAttack( Driver, Pod )
	if not self:CanAltPrimaryAttack() then return end
	
	if not IsValid( Pod ) then Pod = self:GetDriverSeat() end
	if not IsValid( Driver ) then Driver = Pod:GetDriver() end
	
	if not IsValid( Pod ) then return end
	if not IsValid( Driver ) then return end
	local EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() )
	local Forward = -self:GetForward()
	local Up = -self:GetUp()
	
	local AimDirToForwardDir = math.deg( math.acos( math.Clamp( Forward:Dot( EyeAngles:Forward() ) ,-1,1) ) )
	local AimDirToUpDir = math.deg( math.acos( math.Clamp( Up:Dot( EyeAngles:Up() ) ,-1,1) ) )
	
	if AimDirToForwardDir < 120 or AimDirToUpDir < 120 then self.NoTurretSound = true return else self.NoTurretSound = false end
	
	self:SetNextAltPrimary( 0.015 )
	
	local MuzzlePos = self:LocalToWorld(Vector(119.5,-7.49672,20.3738) + EyeAngles:Forward()*27)

	local pos2=MuzzlePos
	local num = 0.3
	local ang = (EyeAngles + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
	gred.CreateBullet(Driver,pos2,ang,"wac_base_7mm",self.FILTER,nil,false,self:UpdateTracers_2())
	local effectdata = EffectData()
	effectdata:SetFlags(self.MUZZLEEFFECT)
	effectdata:SetOrigin(pos2)
	effectdata:SetAngles(ang)
	effectdata:SetSurfaceProp(0)
	util.Effect("gred_particle_simple",effectdata)
end

function ENT:GetMissileOffset()
	return Vector(-60,0,0)
end