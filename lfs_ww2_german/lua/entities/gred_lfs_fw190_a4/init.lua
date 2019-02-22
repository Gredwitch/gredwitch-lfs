
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName ) -- called by garry
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 90 ) -- spawn 20 units above ground
	ent:Spawn()
	ent:Activate()
	ent:SetSkin(table.Random(ent.CleanSkin))
	return ent
end

function ENT:OnTick() -- use this instead of "think"
	local hp = self:GetHP()
	local skin = self:GetSkin()
	if hp <= 350 then
		if table.HasValue(self.DamageSkin,skin) then return end
		if table.HasValue(self.CleanSkin,skin) then
			self:SetSkin(skin + 1)
		end
	else
		if table.HasValue(self.DamageSkin,skin) then
			self:SetSkin(skin-1)
		end
	end
	self.OldLoadout = loadout
	self:SetBodygroup(2,0) -- MG FF
	self:SetBodygroup(3,0) -- 15mm R1
	self:SetBodygroup(4,0) -- Bomb pylon
	self:SetBodygroup(6,0) -- MG 17
	-- self:SetBodygroup(7,0) -- MG 151 / MG 17
end

function ENT:RunOnSpawn()
	self.DamageSkin = {}
	self.CleanSkin  = {}
	for i = 0, self:SkinCount() do
		num = i / 2
		IsEven = math.Round(num)*2 == i
		if IsEven then
			table.insert(self.CleanSkin,i)
		else
			table.insert(self.DamageSkin,i)
		end
	end
end

function ENT:HandleWeapons(Fire1, Fire2)
	local Driver = self:GetDriver()
	local class = self:GetClass()
	if IsValid( Driver ) then
		if self:GetAmmoPrimary() > 0 then
			Fire1 = Driver:KeyDown( IN_ATTACK )
		end
		if self:GetAmmoSecondary() > 0 then self.SecNoStop = false end
		if self:GetAmmoMGFF() > 0 then self.MGFFNoStop = false end
 		Fire2 = Driver:KeyDown( IN_ATTACK2 )
	end
	
	if Fire1 then
		self:PrimaryAttack()
	end
	if Fire2 then
		self:SecondaryAttack()
	end
	if self.OldFire ~= Fire1 then
		
		if Fire1 then
			self.wpn1 = CreateSound( self, "BF109_FIRE_LOOP" )
			self.wpn1:Play()
			self:CallOnRemove( "stop"..class.."sounds1", function( ent )
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
					
				self:EmitSound( "BF109_FIRE_LASTSHOT" )
			end
		end
		
		self.OldFire = Fire1
	end
	
	if self:GetAmmoSecondary() > 0 then
		if self.OldFire2 ~= Fire2 then
			if Fire2 then
				self.wpn2 = CreateSound( self, "FW190_FIRE_LOOP")
				self.wpn2:Play()
				self:CallOnRemove( "stop"..class.."sounds2", function( ent )
					if ent.wpn2 then
						ent.wpn2:Stop()
					end
				end)
			else
				if self.OldFire2 == true then
					if self.wpn2 then
						self.wpn2:Stop()
						self.wpn2 = nil
					end
					if !self.SecNoStop then
						self:EmitSound( "FW190_FIRE_LASTSHOT" )
					end
					if self:GetAmmoSecondary() <= 0 then
						self.SecNoStop = true
					end
				end
			end
		end
	else
		if self.OldFire2 == true then
			if self.wpn2 then
				self.wpn2:Stop()
				self.wpn2 = nil
			end
			if !self.SecNoStop then
				self:EmitSound( "FW190_FIRE_LASTSHOT" )
			end
			if self:GetAmmoSecondary() <= 0 then
				self.SecNoStop = true
			end
		end
	end
	if self:GetAmmoMGFF() > 0 then
		if self.OldFire2 ~= Fire2 then
			if Fire2 then
				self.wpn3 = CreateSound( self, "BF109_FIRE2_LOOP")
				self.wpn3:Play()
				self:CallOnRemove( "stop"..class.."sounds3", function( ent )
					if ent.wpn3 then
						ent.wpn3:Stop()
					end
				end)
			else
				if self.OldFire2 == true then
					if self.wpn3 then
						self.wpn3:Stop()
						self.wpn3 = nil
					end
					if !self.MGFFNoStop then
						self:EmitSound( "BF109_FIRE2_LASTSHOT" )
					end
					if self:GetAmmoMGFF() <= 0 then
						self.MGFFNoStop = true
					end
				end
			end
		end
	else
		if self.OldFire2 == true then
			if self.wpn3 then
				self.wpn3:Stop()
				self.wpn3 = nil
			end
			if !self.MGFFNoStop then
				self:EmitSound( "BF109_FIRE2_LASTSHOT" )
			end
			if self:GetAmmoMGFF() <= 0 then
				self.MGFFNoStop = true
			end
		end
	end
	if self.OldFire2 ~= Fire2 then
		self.OldFire2 = Fire2
	end
end

function ENT:GetMaxAmmoMGFF()
	return self.AmmoMGFF
end

function ENT:TakeMGFFAmmo(amount)
	amount = amount or 1
	self:SetAmmoMGFF(math.max(self:GetAmmoMGFF() - amount,0))
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimary( 0.052 ) -- MG17 RPM
	
	local Driver = self:GetDriver()
	for k,v in pairs (self.BulletPos) do
		local pos2=self:LocalToWorld(v)
		local num = 0.3
		local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
		local b=ents.Create("gred_base_bullet")
		b:SetPos(pos2)
		b:SetAngles(ang)
		b.col = "Yellow"
		b.Speed=1000
		b.Caliber = "wac_base_7mm"
		b.Size=0
		b.Width=0
		b.CustomDMG = true
		b.Damage=5
		b.Radius=70
		b.sequential=true
		b.npod=1
		b.gunRPM=750
		b:Spawn()
		b:Activate()
		b.Filter = {self}
		b.Owner=Driver
		if !tracer then tracer = 0 end
		if tracer >= GetConVarNumber("gred_sv_tracers") then
			b:SetSkin(0)
			b:SetModelScale(20)
			if k == 2 then
				tracer = 0
			end
		else b.noTracer = true end
		self:TakePrimaryAmmo()

		local effectdata = EffectData()
		effectdata:SetOrigin(pos2)
		effectdata:SetAngles(ang)
		effectdata:SetEntity(self)
		util.Effect("gred_particle_aircraft_muzzle",effectdata)
	end
	tracer = tracer + 1
end

function ENT:SecondaryAttack()
	local ct = CurTime()
	for k,v in pairs (self.CannonPos) do
		if ((k == 1 or k == 2) and self.NextCannon < ct and self:GetAmmoSecondary() > 0) or 
		   ((k == 3 or k == 4) and self.NextMGFF < ct and self:GetAmmoMGFF() > 0) then
			local pos2=self:LocalToWorld(v)
			local num = 1
			local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
			local b=ents.Create("gred_base_bullet")
			b:SetPos(pos2)
			b:SetAngles(ang)
			b.col = "Yellow"
			b.Speed=1000
			b.Caliber = "wac_base_20mm"
			b.Size=0
			b.Width=0
			b.CustomDMG = true
			if k >= 2 then
				b.Damage=20
			else
				b.Damage=10
			end
			b.Radius=70
			b.sequential=true
			b.npod=1
			b.gunRPM=750
			b:Spawn()
			b:Activate()
			b.Filter = {self}
			b.Owner=Driver
			if !tracerC then tracerC = 0 end
			if tracerC >= GetConVarNumber("gred_sv_tracers") then
				b:SetSkin(0)
				b:SetModelScale(20)
				if k == 4 then
					tracer = 0
				end
			else b.noTracer = true end
			tracerC = tracerC + 1
			if (k == 2) then self.NextCannon = ct + 0.08 self:TakeSecondaryAmmo(2) end
			if (k == 4) then self.NextMGFF = ct + 0.11 self:TakeMGFFAmmo(2) end

			local effectdata = EffectData()
			effectdata:SetOrigin(pos2)
			effectdata:SetAngles(ang)
			effectdata:SetEntity(self)
			util.Effect("gred_particle_aircraft_muzzle",effectdata)
		end
	end
end

function ENT:CreateAI() -- called when the ai gets enabled
end

function ENT:RemoveAI() -- called when the ai gets disabled
end

function ENT:OnEngineStarted()
	self:EmitSound("FW190_START")
end

function ENT:OnEngineStopped()
	self:EmitSound("FW190_STOP")
end

function ENT:OnLandingGearToggled( bOn )
	self:EmitSound( "lfs/bf109/gear.wav" )
end