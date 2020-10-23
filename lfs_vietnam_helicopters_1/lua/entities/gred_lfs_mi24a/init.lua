--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 20 )
	ent:Spawn()
	ent:Activate()

	return ent
end

local tracer_1 = 0
function ENT:UpdateTracers_1()
	tracer_1 = tracer_1 + 1
	if tracer_1 >= self.TracerConvar:GetInt() then
		tracer_1 = 0
		return "green"
	else
		return false
	end
end

local tracer_2 = 0
function ENT:UpdateTracers_2()
	tracer_2 = tracer_2 + 1
	if tracer_2 >= self.TracerConvar:GetInt() then
		tracer_2 = 0
		return "green"
	else
		return false
	end
end

function ENT:OnTick()
	if not self.CurSeq then
		self.CurSeq = self:GetSequenceName(self:GetSequence())
	end
	if self.CurSeq != "gears" then
		self:ResetSequence("gears")
		self.CurSeq = self:GetSequenceName(self:GetSequence())
	end
	self.SMLG = self.SMLG and self.SMLG + (self:GetLGear() - self.SMLG) * FrameTime() * 2 or 0
	self:SetCycle(self.SMLG)
	local loadout = self:GetLoadout()
	local priAmmo = self:GetAmmoPrimary()
	local secAmmo = self:GetAmmoSecondary()
	local missiles = self:GetMissiles()
	if missiles then
		if missiles != self.OldMissiles then
			self:SetMissileCount(self.MaxMissiles)
		end
		for i=4,7 do
			self:SetBodygroup(i,1)
		end
	else
		for i=4,7 do
			self:SetBodygroup(i,0)
		end
		self:SetMissileCount(0)
	end
	if loadout == 0 then
		self:SetBodygroup(2,0)
		self:SetBodygroup(3,0)
		for i = 8,15 do
			self:SetBodygroup(i,0)
		end
		if loadout != self.OldLoadout then
			self:SetAmmoPrimary(0)
			self:SetAmmoSecondary(0)
			self:RemoveBombs()
		end
	elseif loadout == 1 then
		self:SetBodygroup(2,1)
		self:SetBodygroup(9,1)
		self:SetBodygroup(10,1)
		self:SetBodygroup(3,0)
		self:SetBodygroup(8,0)
		for i = 11,15 do
			self:SetBodygroup(i,0)
		end
		if loadout != self.OldLoadout then
			self:SetAmmoPrimary(64)
			self:RemoveBombs()
		end
		self:SetAmmoSecondary(0)
		if priAmmo > 64 then self:SetAmmoPrimary(64) end
	elseif loadout == 2 then
		self:SetBodygroup(2,1)
		self:SetBodygroup(3,1)
		for i = 8,15 do
			self:SetBodygroup(i,0)
		end
		self:SetAmmoSecondary(0)
		if loadout != self.OldLoadout then
			self:SetAmmoPrimary(2)
			self:AddBombs(0)
		else
			if priAmmo > 2 then self:SetAmmoPrimary(2) end
			if priAmmo != self.OldAmmoPrimary and not self.Firing then
				self:AddBombs(1,priAmmo)
			end
		end
	elseif loadout == 3 then
		self:SetBodygroup(2,1)
		self:SetBodygroup(3,0)
		for i = 8,15 do
			self:SetBodygroup(i,0)
		end
		self:SetAmmoSecondary(0)
		if loadout != self.OldLoadout then
			self:SetAmmoPrimary(4)
			self:AddBombs(0)
		else
			if priAmmo > 4 then self:SetAmmoPrimary(4) end
			if priAmmo != self.OldAmmoPrimary and not self.Firing then
				self:AddBombs(1,priAmmo)
			end
		end
	elseif loadout == 4 then
		self:SetBodygroup(2,1)
		self:SetBodygroup(3,0)
		self:SetBodygroup(10,0)
		self:SetBodygroup(9,0)
		self:SetBodygroup(12,0)
		self:SetBodygroup(13,0)
		self:SetBodygroup(14,0)
		self:SetBodygroup(15,0)
		self:SetBodygroup(8,1)
		self:SetBodygroup(11,1)
		if loadout != self.OldLoadout then
			self:SetAmmoPrimary(64)
			self:SetAmmoSecondary(2)
			self:AddBombs(0,2)
		else
			if priAmmo > 64 then self:SetAmmoPrimary(64) end
			if secAmmo > 2 then self:SetAmmoSecondary(2) end
			if secAmmo != self.OldAmmoSecondary and not self.Firing2 then
				self:AddBombs(0,secAmmo)
			end
		end
	elseif loadout == 5 then
		self:SetBodygroup(2,1)
		self:SetBodygroup(3,0)
		self:SetBodygroup(10,0)
		self:SetBodygroup(9,0)
		self:SetBodygroup(12,0)
		self:SetBodygroup(13,0)
		self:SetBodygroup(14,0)
		self:SetBodygroup(15,0)
		self:SetBodygroup(8,1)
		self:SetBodygroup(11,1)
		if loadout != self.OldLoadout then
			self:SetAmmoPrimary(64)
			self:SetAmmoSecondary(2)
			self:AddBombs(1,2)
		else
			if priAmmo > 64 then self:SetAmmoPrimary(64) end
			if secAmmo > 2 then self:SetAmmoSecondary(2) end
			if secAmmo != self.OldAmmoSecondary and not self.Firing2 then
				self:AddBombs(1,secAmmo)
			end
		end
	elseif loadout == 6 then
		self:SetBodygroup(2,1)
		self:SetBodygroup(3,0)
		for i = 8,11 do
			self:SetBodygroup(i,0)
		end
		self:SetBodygroup(12,0)
		self:SetBodygroup(13,0)
		self:SetBodygroup(14,1)
		self:SetBodygroup(15,1)
		if loadout != self.OldLoadout then
			self:SetAmmoPrimary(800)
			self:SetAmmoSecondary(2)
			self:AddBombs(0,2)
		else
			if priAmmo > 800 then self:SetAmmoPrimary(800) end
			if secAmmo > 2 then self:SetAmmoSecondary(2) end
			if secAmmo != self.OldAmmoSecondary and not self.Firing2 then
				self:AddBombs(0,secAmmo)
			end
		end
	elseif loadout == 7 then
		self:SetBodygroup(2,1)
		self:SetBodygroup(3,0)
		for i = 8,11 do
			self:SetBodygroup(i,0)
		end
		self:SetBodygroup(12,0)
		self:SetBodygroup(13,0)
		self:SetBodygroup(14,1)
		self:SetBodygroup(15,1)
		if loadout != self.OldLoadout then
			self:SetAmmoPrimary(800)
			self:SetAmmoSecondary(2)
			self:AddBombs(1,2)
		else
			if priAmmo > 800 then self:SetAmmoPrimary(800) end
			if secAmmo > 2 then self:SetAmmoSecondary(2) end
			if secAmmo != self.OldAmmoSecondary and not self.Firing2 then
				self:AddBombs(1,secAmmo)
			end
		end
	elseif loadout == 8 then
		self:SetBodygroup(2,0)
		self:SetBodygroup(3,0)
		self:SetBodygroup(8,0)
		self:SetBodygroup(9,1)
		self:SetBodygroup(10,1)
		self:SetBodygroup(11,0)
		self:SetBodygroup(12,0)
		self:SetBodygroup(13,0)
		self:SetBodygroup(14,1)
		self:SetBodygroup(15,1)
		if loadout != self.OldLoadout then
			self:SetAmmoPrimary(800)
			self:SetAmmoSecondary(64)
			self:RemoveBombs()
		else
			if priAmmo > 800 then self:SetAmmoPrimary(800) end
			if secAmmo > 64 then self:SetAmmoSecondary(64) end
		end
	elseif loadout == 9 then
		self:SetBodygroup(2,0)
		self:SetBodygroup(3,0)
		for i = 8,11 do
			self:SetBodygroup(i,0)
		end
		self:SetBodygroup(12,1)
		self:SetBodygroup(13,1)
		self:SetBodygroup(14,1)
		self:SetBodygroup(15,1)
		self:SetAmmoSecondary(0)
		if loadout != self.OldLoadout then
			self:SetAmmoPrimary(1600)
			self:RemoveBombs()
		end
	end
	self.OldAmmoPrimary = priAmmo
	self.OldAmmoSecondary = secAmmo
	self.OldMissiles = missiles
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
			p:AddAngleVelocity(Vector(angvel.x > 150 and 0 or RPM*0.02,0,angvel.z > 300 and 0 or math.Clamp(RPM,0,2000)*0.04))
			local vel = p:GetVelocity()
			p:AddVelocity(Vector(0,0,vel.z < -600 and 0 or -RPM*0.005))
		end
	end
end

ENT.rotorHP = 300
ENT.TailRotorPos = Vector(-389,-12.6,162)

local baseclass = baseclass.Get("lunasflightschool_basescript_heli")
function ENT:OnTakeDamage(dmginfo)
	baseclass.OnTakeDamage(self,dmginfo)
	
	if self.TailEffectTime then return end
	
	local dist = self.TailRotorPos:Distance(self:WorldToLocal(dmginfo:GetDamagePosition()))
	if dist <= 90 then
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

function ENT:OnRemove()
	self:StopSound(self.CRASHSND)
	self:StopSound("AH1G_START")
end

function ENT:RemoveBombs()
	if self.Bombs then
		for k,v in pairs (self.Bombs) do
			if IsValid(v) then
				v:Remove()
			end
			v = nil
		end
		self.Bombs = nil
	end
end

function ENT:AddBombs(n,b)
	self:RemoveBombs()
	if istable(self.BOMBS) then
		self.Bombs = {}
		local s = 0
		if n == 0 then
			for k,v in pairs( self.BOMBS ) do
				if b != nil && isnumber(b) then
					if k <= b then
						local bomb = ents.Create("gb_bomb_fab250")
						bomb.IsOnPlane = true
						bomb:SetPos(self:LocalToWorld(v))
						bomb:SetAngles(self:GetAngles())
						bomb:Spawn()
						bomb:Activate()
						bomb:SetParent(self)
						bomb.phys=bomb:GetPhysicsObject()
						if !IsValid(bomb.phys) then return end
						bomb.phys:SetMass(1)
						bomb:SetCollisionGroup(20)
						self:dOwner(bomb)
						s = s + 1
						table.insert(self.Bombs,bomb)
					end
				else
					local bomb = ents.Create("gb_bomb_fab250")
					bomb.IsOnPlane = true
					bomb:SetPos(self:LocalToWorld(v))
					bomb:SetAngles( self:GetAngles() )
					bomb:Spawn()
					bomb:Activate()
					bomb:SetParent(self)
					bomb.phys=bomb:GetPhysicsObject()
					if !IsValid(bomb.phys) then return end
					bomb.phys:SetMass(1)
					bomb:SetCollisionGroup(20)
					self:dOwner(bomb)
					s = s + 1
					table.insert(self.Bombs,bomb)
				end
			end
		elseif n == 1 then
			for k,v in pairs( self.BOMBS ) do
				if b != nil && isnumber(b) then
					if k <= b then
						local bomb = ents.Create("gb_bomb_500gp") -- fab500
						bomb.IsOnPlane = true
						bomb:SetPos(self:LocalToWorld(v))
						bomb:SetAngles(self:GetAngles())
						bomb:Spawn()
						bomb:Activate()
						bomb:SetParent(self)
						bomb.phys=bomb:GetPhysicsObject()
						if !IsValid(bomb.phys) then return end
						bomb.phys:SetMass(1)
						bomb:SetCollisionGroup(20)
						self:dOwner(bomb)
						s = s + 1
						table.insert(self.Bombs,bomb)
					end
				else
					local bomb = ents.Create("gb_bomb_500gp") -- fab500
					bomb.IsOnPlane = true
					bomb:SetPos(self:LocalToWorld(v))
					bomb:SetAngles( self:GetAngles() )
					bomb:Spawn()
					bomb:Activate()
					bomb:SetParent(self)
					bomb.phys=bomb:GetPhysicsObject()
					if !IsValid(bomb.phys) then return end
					bomb.phys:SetMass(1)
					bomb:SetCollisionGroup(20)
					self:dOwner(bomb)
					s = s + 1
					table.insert(self.Bombs,bomb)
				end
			end
		end
		if not isnumber(b) then self:SetAmmoSecondary(s) end
	end
end

function ENT:RunOnSpawn()
	self.CRASHSND = "HELICOPTER_CRASHING_"..math.random(1,10)
	self.MUZZLEEFFECT = table.KeyFromValue(gred.Particles,"muzzleflash_bar_3p")
	self.TracerConvar = GetConVar("gred_sv_tracers")
	self:SetGunnerSeat(self:AddPassengerSeat(Vector(283.58,0,32.1139),Angle(0,-90,0)))
	self:AddPassengerSeat(Vector(87.3953,-11.0144,41.2806),Angle(0,180,0))
	self:AddPassengerSeat(Vector(87.3953,11.0144,41.2806),Angle(0,0,0))
	self:AddPassengerSeat(Vector(102.895,-11.0144,41.2806),Angle(0,180,0))
	self:AddPassengerSeat(Vector(102.895,11.0144,41.2806),Angle(0,0,0))
end

function ENT:SecondaryAttack(secAmmo,loadout)
	if not self:CanSecondaryAttack() then return end
	self:SetNextSecondary(0.1)
	if loadout == 4 or loadout == 5 or loadout == 6 or loadout == 7 then
		if istable( self.Bombs ) then
			local bomb = self.Bombs[ secAmmo ]
			table.remove(self.Bombs,secAmmo )
			if IsValid( bomb ) then
				bomb:EmitSound( "npc/waste_scanner/grenade_fire.wav" )
				bomb:SetParent(nil)
				bomb.ShouldExplodeOnImpact = true
				bomb:SetOwner(self:GetDriver())
				local p = self:GetPhysicsObject() if IsValid(p) then bomb.phys:AddVelocity(p:GetVelocity()) end
				timer.Simple(0.01,function() if IsValid(bomb.phys) then bomb.phys:SetMass(bomb.Mass)  end end)
				timer.Simple(1, function()
					if IsValid(bomb) and IsValid(bomb.phys) then
						bomb.dropping=true
						bomb.Armed=true
						bomb:SetCollisionGroup(0)
					end
				end)
				self:TakeSecondaryAmmo()
			end
		end
	elseif loadout == 8 then
		if r == nil or r > #self.ROCKETS or r == 0 then r = 1 end
		local mpos = self:LocalToWorld(self.ROCKETS[r])
		local Ang = self:WorldToLocal( mpos ).y > 0 and -1 or 1
		local ent = ents.Create(self.ROCKETENT)
		ent:SetPos(mpos)
		
		ent:SetAngles(self:GetAngles()-Angle(2.5))
		ent.IsOnPlane = true
		ent:SetOwner(self:GetDriver())
		ent:Spawn()
		ent:Activate()
		ent:Launch()
		constraint.NoCollide( ent, self, 0, 0 )
		r = r + 1
		if r > 2 then r = 0 end
		self:TakeSecondaryAmmo()
	end
end

function ENT:PrimaryAttack(loadout,ammo)
	if self:GetAI() then return end
	if not self:CanPrimaryAttack() then return end
	if loadout == 1 or loadout == 4 or loadout == 5 then
		self:SetNextPrimary( 0.15 )
		if p == nil or p > #self.ROCKETS or p == 0 then p = 1 end
		local mpos = self:LocalToWorld(self.ROCKETS[p])
		local Ang = self:WorldToLocal( mpos ).y > 0 and -1 or 1
		local ent = ents.Create(self.ROCKETENT)
		ent:SetPos(mpos)
		
		ent:SetAngles(self:GetAngles()-Angle(2.5))
		ent.IsOnPlane = true
		ent:SetOwner(self:GetDriver())
		ent:Spawn()
		ent:Activate()
		ent:Launch()
		constraint.NoCollide( ent, self, 0, 0 )
		p = p + 1
		if loadout == 1 and p > 2 then
			p = 0
		elseif loadout == 4 and p < 2 then p = 2 end
		self:TakePrimaryAmmo()
	elseif loadout == 2 or loadout == 3 then
		self:SetNextPrimary( 0.15 )
		if istable( self.Bombs ) then
			local bomb = self.Bombs[ ammo ]
			table.remove(self.Bombs,ammo )
			if IsValid( bomb ) then
				bomb:EmitSound( "npc/waste_scanner/grenade_fire.wav" )
				bomb:SetParent(nil)
				bomb.ShouldExplodeOnImpact = true
				bomb:SetOwner(self:GetDriver())
				local p = self:GetPhysicsObject() if IsValid(p) then bomb.phys:AddVelocity(p:GetVelocity()) end
				timer.Simple(0.01,function() if IsValid(bomb.phys) then bomb.phys:SetMass(bomb.Mass)  end end)
				timer.Simple(1, function()
					if IsValid(bomb) and IsValid(bomb.phys) then
						bomb.dropping=true
						bomb.Armed=true
						bomb:SetCollisionGroup(0)
					end
				end)
				self:TakePrimaryAmmo()
			end
		end
	elseif loadout >= 6 then
		self:SetNextPrimary(0.017)
		
		local Driver = self:GetDriver()
		local num = 0.7
		local tracer = self:UpdateTracers_1()
		for k,v in pairs (self.BulletPos) do
			if loadout != 9 && k > 4 then break end
			local pos2=self:LocalToWorld(v)
			-- local localang = Angle(-0.5,(self.BulletPos.y > 0 and -1 or 1),0)
			local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num))) --+ localang
			gred.CreateBullet(Driver,pos2,ang,"wac_base_20mm",{self},nil,false,tracer,40)
			self:TakePrimaryAmmo()
			local effectdata = EffectData()
			effectdata:SetOrigin(pos2)
			effectdata:SetAngles(ang)
			effectdata:SetEntity(self)
			util.Effect("gred_particle_aircraft_muzzle",effectdata)
		end
	end
end

function ENT:CreateAI()
end

function ENT:RemoveAI()
end

function ENT:OnEngineStarted()
end

function ENT:OnEngineStopped()
end

function ENT:HandleWeapons(Fire1, Fire2)
	local Driver = self:GetDriver()
	local priAmmo = self:GetAmmoPrimary()
	local secAmmo = self:GetAmmoSecondary()
	local Gunner = self:GetGunner()
	local HasGunner = IsValid( Gunner )
	local TurretSnd = false
	local missiles = self:GetMissileCount()
	local loadout = self:GetLoadout()
	
	if IsValid( Driver ) then
		FireTurret = Driver:lfsGetInput("FREELOOK")
		
		if self:GetAmmoPrimary() > 0 or FireTurret then
			Fire1 = Driver:KeyDown( IN_ATTACK )
		end
		self.Firing = Fire1
		if secAmmo > 0 or FireTurret then
			Fire2 = Driver:KeyDown( IN_ATTACK2 )
		end
		self.Firing2 = Fire2
	end
	if Fire1 then
		if FireTurret and not HasGunner then
			self:AltPrimaryAttack(Driver)
			TurretSnd = true
		else
			self:PrimaryAttack(loadout,priAmmo)
		end
	end
	if Fire2 then
		if FireTurret and not HasGunner then
			if missiles > 0 then
				-- self:AltSecondaryAttack(Driver)
			end
		else
			self:SecondaryAttack(secAmmo,loadout)
		end
	end
	
	if self.OldFire ~= Fire1 and not FireTurret then
		if loadout >= 6 then
			if Fire1 then
				self.wpn1 = CreateSound( self, "UPK23_SHOOT" )
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
						
					self:EmitSound( "UPK23_STOP" )
				end
			end
		end
		self.OldFire = Fire1
	end
	
	if HasGunner then
		if Gunner:KeyDown( IN_ATTACK ) then
			self:AltPrimaryAttack( Gunner, self:GetGunnerSeat() )
			TurretSnd = true
		end
		if Gunner:KeyDown(IN_ATTACK2) and missiles > 0 then
			-- self:AltSecondaryAttack( Gunner, self:GetGunnerSeat() )
		end
	end
	if self.NoTurretSound then
		if self.turret1 then
			self.turret1:Stop()
		end
	else
		if TurretSnd then
			self.turret1 = CreateSound(self,"A127_SHOOT")
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
				self:EmitSound("A127_STOP")
			end
		end
	end
	self.OldTurretSnd = TurretSnd
end

function ENT:OnEngineStartInitialized()
	self:EmitSound("AH1G_START")
end

function ENT:HandleLandingGear()
	local Driver = self:GetDriver()
	
	if IsValid( Driver ) then
		local KeyJump = Driver:KeyDown( IN_JUMP )
		
		if self.OldKeyJump ~= KeyJump then
			self.OldKeyJump = KeyJump
			if KeyJump then
				self:ToggleLandingGear()
				self:PhysWake()
			end
		end
	end
	
	local TValAuto = (self:GetStability() > 0.3) and 0 or 1
	local TValManual = self.LandingGearUp and 0 or 1
	
	local TVal = self.WheelAutoRetract and TValAuto or TValManual
	local Speed = FrameTime()
	local Speed2 = Speed * math.abs( math.cos( math.rad( self:GetLGear() * 180 ) ) )
	
	self:SetLGear( self:GetLGear() + math.Clamp(TVal - self:GetLGear(),-Speed,Speed) )
	self:SetRGear( self:GetRGear() + math.Clamp(TVal - self:GetRGear(),-Speed2,Speed2) )
	
	if IsValid( self.wheel_R ) then
		local RWpObj = self.wheel_R:GetPhysicsObject()
		if IsValid( RWpObj ) then
			RWpObj:SetMass( 1 + (self.WheelMass - 1) * self:GetRGear() ^ 5 )
		end
	end
	
	if IsValid( self.wheel_L ) then
		local LWpObj = self.wheel_L:GetPhysicsObject()
		if IsValid( LWpObj ) then
			LWpObj:SetMass( 1 + (self.WheelMass - 1) * self:GetLGear() ^ 5 )
		end
	end
	
	if IsValid( self.wheel_C ) then
		local CWpObj = self.wheel_C:GetPhysicsObject()
		if IsValid( CWpObj ) then
			CWpObj:SetMass( 1 + (self.WheelMass - 1) * self:GetRGear() )
		end
	end
end

function ENT:ToggleLandingGear()
	self.LandingGearUp = not self.LandingGearUp
	
	self:OnLandingGearToggled( self.LandingGearUp )
end

function ENT:RaiseLandingGear()
	if not self.LandingGearUp then
		self.LandingGearUp = true
		
		self:OnLandingGearToggled( self.LandingGearUp )
	end
end

function ENT:DeployLandingGear()
	if self.LandingGearUp then
		self.LandingGearUp = false
		
		self:OnLandingGearToggled( self.LandingGearUp )
	end
end

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
	print(Driver)
	if not IsValid( Pod ) then Pod = self:GetDriverSeat() end
	if not IsValid( Driver ) then Driver = Pod:GetDriver() end
	
	self:SetNextAltSecondary( 0.5 )
	if mi == nil or mi > #self.MISSILES or mi == 0 then mi = 1 end
	
	local pos = Driver:EyePos()
	local ang = Driver:EyeAngles()
	
	local tr = util.QuickTrace(pos,pos + ang:Forward()*10000,self)
	debugoverlay.Line(tr.StartPos,tr.HitPos,3,Color( 255, 0, 0 ),false )
	
	if tr.Hit and !tr.HitSky then
		self:SetTarget(tr.Entity)
		self:SetTargetOffset(tr.Entity:WorldToLocal(tr.HitPos))
	else
		return
	end
	
	
	local ent = ents.Create(self.MISSILEENT)
	ent:SetPos(self:LocalToWorld(self.MISSILES[mi]))
	ent:SetAngles(self:GetAngles()-Angle(2.5))
	ent.IsOnPlane = true
	ent:SetOwner(self:GetDriver())
	ent.JDAM = true
	ent.target = self:GetTarget()
	ent.targetOffset = self:GetTargetOffset()
	ent:Spawn()
	ent.PhysicsUpdate = function(self,ph)
        if self.WarHeadFailed then return end
		local pos = self:GetPos()
		local vel = self:WorldToLocal(pos+self:GetVelocity())
		vel.x = 0
		ph:AddAngleVelocity(
			ph:GetAngleVelocity()*-0.4
			+ Vector(math.Rand(-1,1), math.Rand(-1,1), math.Rand(-1,1))*5
			+ Vector(0, -vel.z, vel.y)
		)
		local target = self.target:LocalToWorld(self.targetOffset)
		local dist = self:GetPos():Distance(target)
		
		local v = self:WorldToLocal(target + Vector(
			0, 0, math.Clamp((self:GetPos()*Vector(1,1,0)):Distance(target*Vector(1,1,0))/5 - 50, 0, 1000)
		)):GetNormal()
		v.y = math.Clamp(v.y*10,-1,1)*100
		v.z = math.Clamp(v.z*10,-1,1)*100
		ph:AddAngleVelocity(Vector(0,-v.z,v.y))
		ph:AddVelocity(self:GetForward() - self:LocalToWorld(vel*Vector(0.1, 1, 1))+pos)
	end
	
	ent:Activate()
	if self.Bombs then
		for k,v in pairs(self.Bombs) do constraint.NoCollide(ent,v,0,0) end
	end
	constraint.NoCollide(ent,self,0,0)
	ent:Launch()
	mi = mi + 1
end

function ENT:AltPrimaryAttack( Driver, Pod )
	if not self:CanAltPrimaryAttack() then return end
	
	if not IsValid( Pod ) then Pod = self:GetDriverSeat() end
	if not IsValid( Driver ) then Driver = Pod:GetDriver() end
	
	if not IsValid( Pod ) then return end
	if not IsValid( Driver ) then return end
	local ang = self:GetAngles()
	local EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() ) - ang
	local EyeA = EyeAngles
	EyeA:Normalize()
	
	
	if (EyeA.y > 30 or EyeA.y < -30) or (EyeA.p < 0 or EyeA.p > 60) then self.NoTurretSound = true return else self.NoTurretSound = false end
	
	self:SetNextAltPrimary( 0.055 )
	
	local MuzzlePos = self:LocalToWorld(Vector(320.067,0,41.5814) + EyeAngles:Forward()*54)

	local pos2=MuzzlePos
	local num = 0.3
	local ang = (EyeAngles + ang + Angle(-0.8) + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
	gred.CreateBullet(Driver,pos2,ang,"wac_base_12mm",{self},nil,false,self:UpdateTracers_2())
	local effectdata = EffectData()
	effectdata:SetFlags(self.MUZZLEEFFECT)
	effectdata:SetOrigin(pos2)
	effectdata:SetAngles(ang)
	effectdata:SetSurfaceProp(0)
	util.Effect("gred_particle_simple",effectdata)
end
