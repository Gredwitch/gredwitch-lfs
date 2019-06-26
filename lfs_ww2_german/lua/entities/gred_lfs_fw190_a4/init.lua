
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
	self:SetBodygroup(1,1) -- Rocket tube
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
	self.TracerConvar = GetConVar("gred_sv_tracers")
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
	local Tracer_MG17 = self:UpdateTracers_MG17()
	for k,v in pairs (self.BulletPos) do
		local pos2=self:LocalToWorld(v)
		local num = 0.3
		local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
		gred.CreateBullet(Driver,pos2,ang,"wac_base_7mm",{self},nil,false,Tracer_MG17,20)
		self:TakePrimaryAmmo()

		local effectdata = EffectData()
		effectdata:SetOrigin(pos2)
		effectdata:SetAngles(ang)
		effectdata:SetEntity(self)
		util.Effect("gred_particle_aircraft_muzzle",effectdata)
	end
end
local tracer_mg17 = 0
function ENT:UpdateTracers_MG17()
	tracer_mg17 = tracer_mg17 + 1
	if tracer_mg17 >= self.TracerConvar:GetInt() then
		tracer_mg17 = 0
		return "green"
	else
		return false
	end
end
local Tracer_mgff = false
local Tracer_cannon = false

function ENT:SecondaryAttack()
	local ct = CurTime()
	local Driver = self:GetDriver()
	for k,v in pairs (self.CannonPos) do
		if ((k == 1 or k == 2) and self.NextCannon < ct and self:GetAmmoSecondary() > 0) or 
		   ((k == 3 or k == 4) and self.NextMGFF < ct and self:GetAmmoMGFF() > 0) then
			local pos2=self:LocalToWorld(v)
			local num = 1
			local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
			gred.CreateBullet(Driver,pos2,ang,"wac_base_20mm",{self},nil,false,k > 2 and Tracer_mgff or Tracer_cannon,k > 2 and 50 or 60)
			if (k == 2) then self.NextCannon = ct + 0.08 self:TakeSecondaryAmmo(2) Tracer_cannon = self:UpdateTracers_Cannon() end
			if (k == 4) then self.NextMGFF = ct + 0.11 self:TakeMGFFAmmo(2) Tracer_mgff = self:UpdateTracers_MGFF() end

			local effectdata = EffectData()
			effectdata:SetOrigin(pos2)
			effectdata:SetAngles(ang)
			effectdata:SetEntity(self)
			util.Effect("gred_particle_aircraft_muzzle",effectdata)
		end
	end
end


local tracer_cannon = 0
local tracer_mgff = 0
function ENT:UpdateTracers_MGFF()
	tracer_mgff = tracer_mgff + 1
	if tracer_mgff >= self.TracerConvar:GetInt() then
		tracer_mgff = 0
		return "white"
	else
		return false
	end
end
function ENT:UpdateTracers_Cannon()
	tracer_cannon = tracer_cannon + 1
	if tracer_cannon >= self.TracerConvar:GetInt() then
		tracer_cannon = 0
		return "yellow"
	else
		return false
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