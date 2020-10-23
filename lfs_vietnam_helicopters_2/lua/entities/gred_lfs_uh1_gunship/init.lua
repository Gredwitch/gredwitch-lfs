--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

ENT.rotorHP = 300
ENT.TailRotorPos = Vector(-281,3,110)

local BaseClass = baseclass.Get("lunasflightschool_basescript_heli")
function ENT:OnTakeDamage(dmginfo)
	BaseClass.OnTakeDamage(self,dmginfo)
	
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

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 10 )
	ent:Spawn()
	ent:Activate()
	ent:SetSkin(math.random(0,3))
	return ent
end

function ENT:OnTick()
	local loadout = self:GetLoadout()
	
	for i = 13,14 do
		local b = self:GetBodygroup(i)
		if b == 0 then
			self:SetBodygroup(i,1)
		elseif b == 2 then
			self:SetBodygroup(i,math.random(3,4))
		end
	end
	if loadout == 0 then
		self:SetBodygroup(2,0)
		self:SetBodygroup(3,0)
		self:SetBodygroup(4,0)
		self:SetBodygroup(5,1)
		self:SetBodygroup(6,0)
		self:SetBodygroup(7,0)
		self:SetBodygroup(8,1)
		self:SetBodygroup(15,1)
		self:SetBodygroup(16,1)
		self:SetBodygroup(17,2)
		self:SetBodygroup(19,1)
		self:SetBodygroup(20,1)
	elseif loadout == 1 then
		self:SetBodygroup(2,0)
		self:SetBodygroup(3,0)
		self:SetBodygroup(4,0)
		self:SetBodygroup(5,0)
		self:SetBodygroup(6,0)
		self:SetBodygroup(7,0)
		self:SetBodygroup(15,1)
		self:SetBodygroup(16,1)
		self:SetBodygroup(17,2)
		self:SetBodygroup(19,1)
		self:SetBodygroup(20,1)
	end
	self.OldLoadout = loadout
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
			p:AddAngleVelocity(Vector(angvel.x > 100 and 0 or RPM*0.01,0,angvel.z > 200 and 0 or math.Clamp(RPM,0,2000)*0.04))
			local vel = p:GetVelocity()
			p:AddVelocity(Vector(0,0,vel.z < -600 and 0 or -RPM*0.005))
		end
	end
end

function ENT:RemoveSeat(seat)
	self.pPodKeyIndex = self.pPodKeyIndex and self.pPodKeyIndex - 1 or 2
	seat:SetNWInt( "pPodIndex", self.pPodKeyIndex )
	
	table.RemoveByValue(self.pSeats,seat)
	seat:Remove()
	seat = nil
end

function ENT:RunOnSpawn()
	self.CRASHSND = "HELICOPTER_CRASHING_"..math.random(1,10)
	self.FILTER = {self}
	self.MUZZLEEFFECT = table.KeyFromValue(gred.Particles,"muzzleflash_bar_3p")
	self.TracerConvar = GetConVar("gred_sv_tracers")
	self:SetGrenadierSeat(self:AddPassengerSeat( Vector(81.3078,19.2824,34.8398), Angle(0,-90,0) ))
	self:SetGunnerSeat(self:AddPassengerSeat(Vector(11.3039,28.495,21.9157),Angle(0,0,0)))
	self:SetGunner2Seat(self:AddPassengerSeat(Vector(11.3039,-28.495,21.9157),Angle(0,180,0)))
	for i = 2, 6 do
		self:SetBodygroup(i,1)
	end
	self:SetBodygroup(9,3)
	self:SetBodygroup(10,12)
	self:SetBodygroup(13,3)
	self:SetBodygroup(14,3)
	self:SetBodygroup(8,1)
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

function ENT:OnRemove()
	self:StopSound(self.CRASHSND)
	self:StopSound("UH1_START")
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimary(0.04)
	
	local Driver = self:GetDriver()
	local tracer = self:UpdateTracers_1()
	for k,v in pairs (self.BulletPos) do
		local pos2=self:LocalToWorld(v)
		local num = 0.3
		local localang = Angle(-0.5,(v.y > 0 and -1 or 1),0)
		local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num))) + localang
		gred.CreateBullet(Driver,pos2,ang,"wac_base_7mm",self.FILTER,nil,false,tracer,15)
		self:TakePrimaryAmmo()
		local effectdata = EffectData()
		effectdata:SetOrigin(pos2)
		effectdata:SetAngles(ang)
		effectdata:SetEntity(self)
		util.Effect("gred_particle_aircraft_muzzle",effectdata)
	end
end

function ENT:SecondaryAttack()
	if self:GetAI() then return end
	if not self:CanSecondaryAttack() then return end
	self:SetNextSecondary( 0.2 )
	self:TakeSecondaryAmmo()
	
	if p == nil or p >  table.Count(self.MISSILES) or p == 0 then p = 1 end
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
	local ang = self:GetAngles()
	local EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() ) - ang
	local EyeA = EyeAngles
	EyeA:Normalize()
	
	if (EyeA.y > 90 or EyeA.y < -90) or (EyeA.p < -3 or EyeA.p > 43) then self.NoTurretSound = true return else self.NoTurretSound = false end
	
	self:SetNextAltSecondary( 0.5 )
	local MuzzlePos = self:LocalToWorld(Vector(144.005,0,30) + EyeAngles:Forward()*24)

	local num = 0.3
	local ang = (EyeAngles + ang + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
	
	gred.CreateShell(MuzzlePos,ang,Driver,self.FILTER,40,"HE",260,0.33,"white",nil,nil,nil,0.045,51):Launch()
	
	self:EmitSound("GRED_SHOOT_40MM")
end

function ENT:HandleWeapons(Fire1, Fire2)
	local Driver = self:GetDriver()
	local secAmmo = self:GetAmmoSecondary()
	local Gunner = self:GetGunner()
	local Gunner2 = self:GetGunner2()
	local Grenadier = self:GetGrenadier()
	local HasGrenadier = IsValid(Grenadier)
	local HasGunner = IsValid( Gunner )
	local HasGunner2 = IsValid(Gunner2)
	local loadout = self:GetLoadout()
	local TurretSnd = false
	local TurretSnd2 = false
	
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
		if FireTurret then
			if not HasGunner then
				self:LeftM60Attack(Driver)
				TurretSnd = true
			end
			if not HasGunner2 then
				self:RightM60Attack(Driver)
				TurretSnd2 = true
			end
		else
			self:PrimaryAttack()
		end
	end
	
	if Fire2 then
		if loadout == 1 then
			if FireTurret and not HasGrenadier then
				self:AltSecondaryAttack(Driver)
			else
				self:SecondaryAttack(secAmmo)
			end
		else
			self:SecondaryAttack(secAmmo)
		end
	end
	
	if self.OldFire ~= Fire1 and not FireTurret then
		
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
	if HasGunner then
		if Gunner:KeyDown( IN_ATTACK ) then
			self:LeftM60Attack( Gunner, self:GetGunnerSeat() )
			TurretSnd = true
		end
	end
	if HasGunner2 then
		if Gunner2:KeyDown( IN_ATTACK ) then
			self:RightM60Attack( Gunner2, self:GetGunnerSeat() )
			TurretSnd2 = true
		end
	end
	if HasGrenadier then
		if loadout == 1 then
			if Grenadier:KeyDown( IN_ATTACK ) then
				self:AltSecondaryAttack(Grenadier)
			end
		end
	end
	if self.OldFire2 ~= Fire2 and not FireTurret then
		if Fire2 then
			self:SecondaryAttack(secAmmo)
		end
		self.OldFire2 = Fire2
	end
	
	if self.NoTurretSound then
		if self.turret1 then
			self.turret1:Stop()
		end
	else
		if TurretSnd then
			self.turret1 = CreateSound(self,"M60_SHOOT")
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
				self:EmitSound("M60_STOP")
			end
		end
	end
	
	if self.NoTurretSound2 then
		if self.turret2 then
			self.turret2:Stop()
		end
	else
		if TurretSnd2 then
			self.turret2 = CreateSound(self,"M60_SHOOT")
			self.turret2:Play()
			self:CallOnRemove( "stopmesounds3", function( ent )
				if ent.turret2 then
					ent.turret2:Stop()
				end
			end)
		else
			if self.turret2 then
				self.turret2:Stop()
			end
			if self.OldTurretSnd2 == true then
				self.turret2 = nil
				self:EmitSound("M60_STOP")
			end
		end
	end
	self.OldTurretSnd = TurretSnd
	self.OldTurretSnd2 = TurretSnd2
end

function ENT:OnEngineStartInitialized()
	self:EmitSound("UH1_START")
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

function ENT:SetNextLeftM60( delay )
	self.NextLeftM60 = CurTime() + delay
end

function ENT:CanLeftM60Attack()
	self.NextLeftM60 = self.NextLeftM60 or 0
	return self.NextLeftM60 < CurTime()
end

function ENT:LeftM60Attack( Driver, Pod )
	if not self:CanLeftM60Attack() then return end
	
	if not IsValid( Pod ) then Pod = self:GetDriverSeat() end
	if not IsValid( Driver ) then Driver = Pod:GetDriver() end
	
	if not IsValid( Pod ) then return end
	if not IsValid( Driver ) then return end
	local ang = self:GetAngles()
	local EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() ) - ang
	local EyeA = EyeAngles
	EyeA:Normalize()
	
	if EyeA.y < 0 or (EyeA.p > 90 or EyeA.p < -90) then self.NoTurretSound = true return else self.NoTurretSound = false end
	self:SetNextLeftM60( 0.092 )
	
	local MuzzlePos = self:LocalToWorld(Vector(12.2424,53.9521,50.8121) + EyeAngles:Forward()*32)

	local pos2=MuzzlePos
	local num = 0.3
	local ang = (EyeAngles + ang + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
	gred.CreateBullet(Driver,pos2,ang,"wac_base_7mm",self.FILTER,nil,false,self:UpdateTracers_2(),15)
	local effectdata = EffectData()
	effectdata:SetFlags(self.MUZZLEEFFECT)
	effectdata:SetOrigin(pos2)
	effectdata:SetAngles(ang)
	effectdata:SetSurfaceProp(0)
	util.Effect("gred_particle_simple",effectdata)
end

function ENT:SetNextRightM60( delay )
	self.NextRightM60 = CurTime() + delay
end

function ENT:CanRightM60Attack()
	self.NextRightM60 = self.NextRightM60 or 0
	return self.NextRightM60 < CurTime()
end

function ENT:RightM60Attack( Driver, Pod )
	if not self:CanRightM60Attack() then return end
	
	if not IsValid( Pod ) then Pod = self:GetDriverSeat() end
	if not IsValid( Driver ) then Driver = Pod:GetDriver() end
	
	if not IsValid( Pod ) then return end
	if not IsValid( Driver ) then return end
	local ang = self:GetAngles()
	local EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() ) - ang
	local EyeA = EyeAngles
	EyeA:Normalize()
	
	if Driver == self:GetDriver() then EyeA.y = EyeA.y+180 end
	ang = ang - Angle(0,180)
	if EyeA.y < 0 or (EyeA.p > 90 or EyeA.p < -90) then self.NoTurretSound2 = true return else self.NoTurretSound2 = false end
	self:SetNextRightM60( 0.092 )
	
	local MuzzlePos = self:LocalToWorld(Vector(12.2424,-53.9521,50.8121) + EyeAngles:Forward()*-32)

	local pos2=MuzzlePos
	local num = 0.3
	local ang = (EyeAngles + ang + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
	gred.CreateBullet(Driver,pos2,ang,"wac_base_7mm",self.FILTER,nil,false,self:UpdateTracers_3(),15)
	local effectdata = EffectData()
	effectdata:SetFlags(self.MUZZLEEFFECT)
	effectdata:SetOrigin(pos2)
	effectdata:SetAngles(ang)
	effectdata:SetSurfaceProp(0)
	util.Effect("gred_particle_simple",effectdata)
end

function ENT:HandleActive()
	local gtPod = self:GetGunner2Seat()
	if IsValid( gtPod ) then
		local Gunner2 = gtPod:GetDriver()
		
		if Gunner2 ~= self:GetGunner() then
			self:SetGunner2( Gunner2 )
			
			if IsValid( Gunner2 ) then
				Gunner2:CrosshairEnable() 
			end
		else
			self:SetGunner2(nil)
		end
	end
	local grePod = self:GetGrenadierSeat()
	if IsValid( grePod ) then
		local Grenadier = grePod:GetDriver()
		
		if Grenadier ~= self:GetGrenadier() then
			self:SetGrenadier( Grenadier )
			
			if IsValid( Grenadier ) then
				Grenadier:CrosshairEnable() 
			end
		else
			self:SetGrenadier(nil)
		end
	end
	return BaseClass.HandleActive(self)
end

function ENT:Explode()
	BaseClass.Explode(self)
	
	local Gunner2 = self:GetGunner2()
	
	if IsValid( Gunner2 ) then
		Gunner2:TakeDamage( 200, self.FinalAttacker or Entity(0), self.FinalInflictor or Entity(0) )
	end
	
end
