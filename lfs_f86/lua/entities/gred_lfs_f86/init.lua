
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName ) -- called by garry
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 100 ) -- spawn 20 units above ground
	ent:Spawn()
	ent:Activate()
	ent:SetSkin(math.random(0,15))
	return ent
end

function ENT:IsSmall(k)
	local startsWith = string.StartWith
	return startsWith(k,"gear") or startsWith(k,"wheel") or startsWith(k,"airbrake")
end

function ENT:RunOnSpawn() -- called when the vehicle is spawned
	Hidden = Color(255,255,255,0)
	Shown = Color(255,255,255,255)
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
	self.Attachements = {}
	self.Parts = {}
	local tostring = tostring
	local pairs = pairs
	local GetModel = GetModel
	
	for k,v in pairs (self:GetAttachments()) do
		self.Attachements[v.name] = self:LookupAttachment(tostring(v.name))
	end
	for k,v in pairs(self.Attachements) do
		if k != "blister" then
			local ent = ents.Create("gred_prop_part")
			ent:SetModel("models/gredwitch/f86_lfs/f86_"..k..".mdl")
			ent:SetPos(self:GetAttachment(self.Attachements[k]).Pos)
			ent:SetAngles(self:GetAngles())
			ent:SetParent(self,self.Attachements[k])
			if k == "tail" then
				ent.MaxHealth = 1100
			elseif k == "wing_r" or k == "wing_l" then
				ent.MaxHealth = 600
				ent.Mass = 500
			elseif self:IsSmall(k) then
				ent.MaxHealth = 100
			else
				ent.MaxHealth = 350
			end
			ent.CurHealth = ent.MaxHealth
			ent:Spawn()
			ent:Activate()
			self.Parts[k] = ent
		end
	end
	for k,v in pairs(self.Parts) do
		v.Parts = self.Parts
		v.Plane = self
		self.GibModels[k] = v:GetModel()
	end
	self.Parts.gear_c1.PartParent = self
	self.Parts.gear_c2.PartParent = self
	self.Parts.gear_c3.PartParent = self.Parts.gear_c2
	self.Parts.wheel_c.PartParent = self.Parts.gear_c3
	
	self.Parts.tail.PartParent = self.Parts.tail
	self.Parts.rudder.PartParent = self.Parts.tail
	self.Parts.elevator.PartParent = self.Parts.tail
	self.Parts.airbrake_l1.PartParent = self.Parts.tail
	self.Parts.airbrake_l2.PartParent = self.Parts.tail
	self.Parts.airbrake_l3.PartParent = self.Parts.tail
	self.Parts.airbrake_r1.PartParent = self.Parts.tail
	self.Parts.airbrake_r2.PartParent = self.Parts.tail
	self.Parts.airbrake_r3.PartParent = self.Parts.tail
	
	self.Parts.wing_l.PartParent = self.Parts.wing_l
	self.Parts.aileron_l.PartParent = self.Parts.wing_l
	self.Parts.flap_l.PartParent = self.Parts.wing_l
	self.Parts.gear_l2.PartParent = self.Parts.wing_l
	self.Parts.wheel_l.PartParent = self.Parts.gear_l2
	self.Parts.gear_l1.PartParent = self.Parts.wing_l
	self.Parts.gear_r1.PartParent = self.Parts.wing_r
	
	self.Parts.wing_r.PartParent = self.Parts.wing_r
	self.Parts.aileron_r.PartParent = self.Parts.wing_r
	self.Parts.flap_r.PartParent = self.Parts.wing_r
	self.Parts.gear_r2.PartParent = self.Parts.wing_r
	self.Parts.wheel_r.PartParent = self.Parts.gear_r2
	
	self.TracerConvar = GetConVar("gred_sv_tracers")
	self:CreateHVARs()
	
	self.LOADED = 1
end

function ENT:CreateHVARs()
	if istable(self.ROCKETS) then
		self.HVARs = {}
		for k,v in pairs( self.ROCKETS ) do
			IsEven = math.Round(k / 2)*2 == k
			local Missile = ents.Create( "prop_dynamic" )
			Missile:SetModel( self.HVARMDL )
			Missile:SetPos( self:LocalToWorld(v-Vector(0,0,4.5)) )
			Missile:SetAngles( self:GetAngles() )
			Missile:SetMoveType( MOVETYPE_NONE )
			Missile:Spawn()
			Missile:Activate()
			Missile:SetNotSolid( true )
			Missile:DrawShadow( false )
			if IsEven then
				Missile:SetParent(self.Parts.wing_r)
			else
				Missile:SetParent(self.Parts.wing_l)
			end
			Missile.DoNotDuplicate = true
			Missile:SetRenderMode(RENDERGROUP_TRANSLUCENT)
			self:dOwner( Missile )
				
			table.insert( self.HVARs, Missile )
		end
	end
end

function ENT:HandleWeapons(Fire1, Fire2)
	local Driver = self:GetDriver()
	if IsValid( Driver ) then
		if self:GetAmmoPrimary() > 0 then
			Fire1 = Driver:KeyDown( IN_ATTACK )
		end
		if self:GetAmmoSecondary() > 0 then
			Fire2 = Driver:KeyDown( IN_ATTACK2 )
		end
		self.Firing = Fire2
	end
	
	if Fire1 then
		self:PrimaryAttack()
	end
	if Fire2 then
		self:SecondaryAttack()
	end
	
	if self.OldFire ~= Fire1 then
		
		if Fire1 then
			self.wpn1 = CreateSound( self, "LFS_M3_BROWNING_SHOOT" )
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
					
				self:EmitSound( "LFS_M3_BROWNING_STOP" )
			end
		end
		
		self.OldFire = Fire1
	end
end

function ENT:OnTick()
	if not self.LOADED then return end
	if self.LOADED == 1 then
		local NoCollide = constraint.NoCollide
		for k,v in pairs(self.Parts) do
			self:DeleteOnRemove(v)
			NoCollide(v,self,0,0)
			NoCollide(v,self.wheel_R,0,0)
			NoCollide(v,self.wheel_L,0,0)
			NoCollide(v,self.wheel_C,0,0)
			NoCollide(v,self.wheel_C_master,0,0)
			if k == "tail" or k == "wing_l" or k == "wing_r" then
				v:SetParent(nil)
				v:SetPos(self:GetAttachment(self.Attachements[k]).Pos)
				v.Weld = constraint.Weld(v,self,0,0,0,true,false)
			end
			for a,p in pairs(self.Parts) do
				NoCollide(v,p,0,0)
			end
			v.LOADED = true
			v.PartName = k
		end
		net.Start("gred_lfs_setparts")
			net.WriteEntity(self)
			net.WriteTable(self.Parts)
		net.Broadcast()
		self.LOADED = true
	end
	
	local hp = self:GetHP()
	local skin = self:GetSkin()
	if hp <= 250 then
		if table.HasValue(self.DamageSkin,skin) then return end
		if table.HasValue(self.CleanSkin,skin) then
			self:SetSkin(skin + 1)
		end
	else
		if table.HasValue(self.DamageSkin,skin) then
			self:SetSkin(skin-1)
		end
	end
	for k,v in pairs(self.Parts) do
		if not IsValid(v) then
			if k == "wheel_c" then
				self.wheel_C:Remove()
				self.wheel_C_master:Remove()
			end
			if k == "wheel_r" then
				self.wheel_R:Remove()
			end
			if k == "wheel_l" then
				self.wheel_L:Remove()
			end
			net.Start("gred_lfs_remparts")
				net.WriteEntity(self)
				net.WriteString(k)
			net.Broadcast()
			self.Parts[k] = nil
			self.GibModels[k] = nil
			k = nil
		return end
		local skin = self:GetSkin()
		if v.PartParent.Destroyed or !IsValid(v.PartParent) then
			v.CurHealth = 0
			v.DONOTEMIT = true
		end
		if v.CurHealth <= v.MaxHealth/2 then
			if not table.HasValue(self.DamageSkin,skin) then
				v:SetSkin(skin+1)
			end
			if v.CurHealth <=0 then
				if k == "wheel_c" then
					self.wheel_C:Remove()
					self.wheel_C_master:Remove()
				end
				if k == "wheel_r" then
					self.wheel_R:Remove()
				end
				if k == "wheel_l" then
					self.wheel_L:Remove()
				end
				constraint.RemoveAll(v)
				if not v.DONOTEMIT then
					v:EmitSound("LFS_PART_DESTROYED_0"..math.random(1,3))
				end
				v:SetParent(nil)
				v:SetVelocity(self:GetVelocity())
				v.Destroyed = true
				self.Parts[k] = nil
				self.GibModels[k] = nil
			end
			net.Start("gred_lfs_remparts")
				net.WriteEntity(self)
				net.WriteString(k)
			net.Broadcast()
		else
			if table.HasValue(self.DamageSkin,skin) then
				v:SetSkin(skin-1)
			else
				v:SetSkin(skin)
			end
		end
	end
	if not self.Parts.tail and not self.oof then
		self:TakeDamage(self.MaxHealth,self,self)
	end
	if not self.CurSeq then
	self.CurSeq = self:GetSequenceName(self:GetSequence())
	end
	if self.CurSeq != "gears" then
		self:ResetSequence("gears")
		self.CurSeq = self:GetSequenceName(self:GetSequence())
	end
	self.SMLG = self.SMLG and self.SMLG + ((0 + self:GetLGear()) - self.SMLG) * FrameTime() * 2 or 0
	self:SetCycle(self.SMLG)
	
	-------------------------------
	
	local loadout = self:GetLoadout()
	local secAmmo = self:GetAmmoSecondary()
	if loadout == 0 then
		self:SetAmmoSecondary(0)
		if self.Parts.wing_l then self.Parts.wing_l:SetBodygroup(1,0) end
		if self.Parts.wing_r then self.Parts.wing_r:SetBodygroup(1,0) end
		if self.OldLoadout != loadout then
			self:SetHVARsColor(self.HVARs,Hidden)
			self:RemoveBombs()
		end
	elseif loadout == 1 then
		if self.Parts.wing_l then self.Parts.wing_l:SetBodygroup(1,2) end
		if self.Parts.wing_r then self.Parts.wing_r:SetBodygroup(1,2) end
		if self.OldLoadout != loadout then
			self:RemoveBombs()
			self:SetHVARsColor(self.HVARs,Shown)
			self:SetAmmoSecondary(16)
		else
			if not self.Firing then
				for m = 1, secAmmo do
					if IsValid(self.HVARs[m]) then
						self.HVARs[m]:SetColor(Shown)
					end
				end
				for m = secAmmo+1, 8 do
					if IsValid(self.HVARs[m]) then
						self.HVARs[m]:SetColor(Hidden)
					end
				end
			end
		end
	elseif loadout == 2 then
		if self.Parts.wing_l then self.Parts.wing_l:SetBodygroup(1,1) end
		if self.Parts.wing_r then self.Parts.wing_r:SetBodygroup(1,1) end
		if self.OldLoadout != loadout then
			self:SetAmmoSecondary(2)
			self:SetHVARsColor(self.HVARs,Hidden)
			self:AddBombs(0)
		else
			local a = 2
			if (self.Parts.wing_l and not self.Parts.wing_r) or (self.Parts.wing_r and not self.Parts.wing_l) then a = 1
			elseif not self.Parts.wing_l and not self.Parts.wing_r then a = 0 end
			if secAmmo > a then self:SetAmmoSecondary(a) secAmmo = a end
			if secAmmo != self.OldSecAmmo and not self.Firing then
				self:AddBombs(0,secAmmo)
			end
		end
	elseif loadout == 3 then
		if self.Parts.wing_l then self.Parts.wing_l:SetBodygroup(1,1) end
		if self.Parts.wing_r then self.Parts.wing_r:SetBodygroup(1,1) end
		if self.OldLoadout != loadout then
			self:SetAmmoSecondary(2)
			self:SetHVARsColor(self.HVARs,Hidden)
			self:AddBombs(1)
		else
			local a = 2
			if (self.Parts.wing_l and not self.Parts.wing_r) or (self.Parts.wing_r and not self.Parts.wing_l) then a = 1
			elseif not self.Parts.wing_l and not self.Parts.wing_r then a = 0 end
			if secAmmo > a then self:SetAmmoSecondary(a) secAmmo = a end
			if secAmmo != self.OldSecAmmo and not self.Firing then
				self:AddBombs(1,secAmmo)
			end
		end
	end
	self.OldSecAmmo = secAmmo
	self.OldLoadout = loadout
	
	-------------------------------
	--[[local vel
	local Mass
	local Stability
	local PhysObj
	local PhysObjValid
	local addRoll
	local addYaw
	
	if not self.Parts.wing_l then
		vel = self:GetVelocity():Length()
		addRoll = 0.2*vel
		addYaw = vel*1.5
	end
	if not self.Parts.wing_r then
		vel = vel or self:GetVelocity():Length()
		addRoll = addRoll and addRoll*2 or 0.2*vel
		addYaw = addYaw and addYaw + vel*1.5 or vel*1.5
	end
	
	
	if addYaw then 
		PhysObj = self:GetPhysicsObject()
		PhysObjValid = IsValid(PhysObj)
		local MaxYaw = self:GetMaxTurnSpeed().y
		local RudderVel = self:GetRudderVelocity()
		if PhysObjValid then
			Stability = self:GetStability()
			Mass = PhysObj:GetMass()
			PhysObj:ApplyForceOffset( -self:GetRudderUp() * (math.Clamp(RudderVel,-MaxYaw,MaxYaw) + -200 * Stability) *  Mass * Stability +Vector(0,addYaw), self:GetRudderPos() )
		end
	end
	
	if addRoll then
		PhysObj = PhysObj or self:GetPhysicsObject()
		PhysObjValid = PhysObjValid or IsValid(PhysObj)
		if PhysObjValid then
			Stability = Stability or self:GetStability()
			Mass = Mass or PhysObj:GetMass()
			self:ApplyAngForce( Angle(0,0,-self:GetAngVel().r * Stability + addRoll) *  Mass * 500 * Stability )
		end
	end
	
	if not self.Parts.aileron_l then
		if not self.LeftAileronGone then
			self.MaxTurnRoll = self.MaxTurnRoll / 2
			self.LeftAileronGone = true
		end
		if self.RightAileronGone and self.LeftAileronGone then 
			self.MaxTurnRoll = 0
		end
		Pitch = -500
	end
	
	if not self.Parts.aileron_r then
		if not self.RightAileronGone then
			self.MaxTurnRoll = self.MaxTurnRoll / 2
			self.RightAileronGone = true
		end
		if self.RightAileronGone and self.LeftAileronGone then 
			self.MaxTurnRoll = 0
		end
	end
	
	if not self.Parts.elevator then
		self.MaxTurnPitch = 0
	end
	if not self.Parts.rudder then
		self.MaxTurnPitch = 0
	end--]]
end

function ENT:CalcFlightOverride( Pitch, Yaw, Roll, Stability )

	local addRoll = 0
	local addYaw = 0
	local vel = self:GetVelocity():Length()
	if not self.Parts.wing_l then
		addRoll = 0.3*vel
		addYaw = vel*0.02
	end
	if not self.Parts.wing_r then
		addRoll = !self.Parts.wing_l and addRoll or -0.3*vel
		addYaw = !self.Parts.wing_l and addYaw - vel*0.09 or addYaw - vel*0.02
	end
	if not self.Parts.aileron_l then
		if Roll < 0 then Roll = Roll/2 end
	end
	if not self.Parts.aileron_r then
		if Roll > 0 then Roll = Roll/2 end
	end
	if not self.Parts.elevator then
		Pitch = 0
	end
	if not self.Parts.rudder then
		Yaw = 0
	end
	Roll = Roll + addRoll
	Yaw = Yaw + addYaw
	return Pitch,Yaw,Roll,Stability,Stability,Stability
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

function ENT:SetHVARsColor(HVARs,color,x)
	if istable(HVARs) and istable(color) then
		for k,v in pairs(HVARs) do
			if istable(x) then
				local bump = false
				for a,b in pairs(x) do
					if k == b then bump = true break end
				end
				if not bump then
					v:SetColor(color)
				end
			else
				v:SetColor(color)
			end
		end
	end
end

function ENT:AddBombs(n,b)
	self:RemoveBombs()
	if istable(self.BOMBS) and (b and b > 0 or true) then
		self.Bombs = {}
		local s = 0
		if n == 0 then
			for k,v in pairs(self.BOMBS) do
				IsEven = math.Round(k / 2)*2 == k
				if b != nil && isnumber(b) then
					if k <= b then
						local bomb = ents.Create("gb_bomb_500gp")
						bomb.IsOnPlane = true
						bomb:SetPos(self:LocalToWorld(v))
						bomb:SetAngles( self:GetAngles() )
						bomb:Spawn()
						bomb:Activate()
						if IsEven then
							bomb:SetParent(self.Parts.wing_r)
						else
							bomb:SetParent(self.Parts.wing_l)
						end
						bomb.phys=bomb:GetPhysicsObject()
						if !IsValid(bomb.phys) then return end
						bomb.phys:SetMass(1)
						bomb:SetCollisionGroup(20)
						self:dOwner(bomb)
						s = s + 1
						table.insert(self.Bombs,bomb)
					end
				else
					local bomb = ents.Create("gb_bomb_500gp")
					bomb.IsOnPlane = true
					bomb:SetPos(self:LocalToWorld(v))
					bomb:SetAngles( self:GetAngles() )
					bomb:Spawn()
					bomb:Activate()
					if IsEven then
						bomb:SetParent(self.Parts.wing_r)
					else
						bomb:SetParent(self.Parts.wing_l)
					end
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
			for k,v in pairs(self.BOMBS) do
				IsEven = math.Round(k / 2)*2 == k
				if b != nil && isnumber(b) then
					if k <= b then
						local bomb = ents.Create("gb_bomb_1000gp")
						bomb.IsOnPlane = true
						bomb:SetPos(self:LocalToWorld(v-Vector(0,0,3)))
						bomb:SetAngles( self:GetAngles() )
						bomb:Spawn()
						bomb:Activate()
						if IsEven then
							bomb:SetParent(self.Parts.wing_r)
						else
							bomb:SetParent(self.Parts.wing_l)
						end
						bomb.phys=bomb:GetPhysicsObject()
						if !IsValid(bomb.phys) then return end
						bomb.phys:SetMass(1)
						bomb:SetCollisionGroup(20)
						self:dOwner(bomb)
						s = s + 1
						table.insert(self.Bombs,bomb)
					end
				else
					local bomb = ents.Create("gb_bomb_1000gp")
					bomb.IsOnPlane = true
					bomb:SetPos(self:LocalToWorld(v-Vector(0,0,3)))
					bomb:SetAngles( self:GetAngles() )
					bomb:Spawn()
					bomb:Activate()
					if IsEven then
						bomb:SetParent(self.Parts.wing_r)
					else
						bomb:SetParent(self.Parts.wing_l)
					end
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
local tracer = 0
function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimary( 0.05 )
	
	local Driver = self:GetDriver()
	local Tracer = self:UpdateTracers()
	local filter = {self}
	for k,v in pairs(self.Parts) do table.insert(filter,v) end
	for k,v in pairs(self.BulletPos) do
		local pos2=self:LocalToWorld(v)
		local num = 0.7
		local ang = self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num))
		gred.CreateBullet(Driver,pos2,ang,"wac_base_12mm",filter,nil,false,Tracer)
		self:TakePrimaryAmmo()
		local effectdata = EffectData()
		effectdata:SetOrigin(pos2)
		effectdata:SetAngles(ang)
		effectdata:SetEntity(self)
		util.Effect("gred_particle_aircraft_muzzle",effectdata)
	end
end

function ENT:UpdateTracers()
	tracer = tracer + 1
	if tracer >= self.TracerConvar:GetInt() then
		tracer = 0
		return "red"
	else
		return false
	end
end

function ENT:SecondaryAttack()
	if self:GetAI() then return end
	if not self:CanSecondaryAttack() then return end
	local Driver = self:GetDriver()
	local loadout = self:GetLoadout()
	local secAmmo = self:GetAmmoSecondary()
	if loadout == 1 then
		if istable( self.HVARs ) then
			local Missile = self.HVARs[secAmmo]
			if IsValid( Missile ) then
				b = nil
				local ent = ents.Create( "gb_rocket_hvar" )
				local mPos = Missile:GetPos()
				Missile:SetColor(Hidden)
				local Ang = self:WorldToLocal( mPos ).y > 0 and -1 or 1
				ent:SetPos( mPos )
				ent:SetAngles( self:LocalToWorldAngles( Angle(-3,Ang,0) ) )
				ent.IsOnPlane = true
				ent:Spawn()
				ent:Activate()
				ent:SetOwner(self:GetDriver())
				ent.phys = ent:GetPhysicsObject()
				local p = self:GetPhysicsObject() 
				if IsValid(p) and IsValid(ent.phys) then ent.phys:AddVelocity(p:GetVelocity()) end
				ent:Launch()
				for k,v in pairs(self.Parts) do constraint.NoCollide(ent,v,0,0)  end
				
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
			end
		end
		self:TakeSecondaryAmmo()
	elseif loadout >= 2 then
		if istable( self.Bombs ) then
			local bomb = self.Bombs[ secAmmo ]
			table.remove(self.Bombs,secAmmo )
			if IsValid( bomb ) then
				bomb:EmitSound( "npc/waste_scanner/grenade_fire.wav" )
				bomb:SetParent(nil)
				bomb.ShouldExplodeOnImpact = true
				bomb:SetOwner(self:GetDriver())
				for k,v in pairs(self.Parts) do constraint.NoCollide(bomb,v,0,0)  end
				local p = self:GetPhysicsObject() if IsValid(p) then bomb.phys:AddVelocity(p:GetVelocity()) end
				timer.Simple(0.01,function() if IsValid(bomb.phys) then bomb.phys:SetMass(bomb.Mass)  end end)
				timer.Simple(1, function()
					if IsValid(bomb) and IsValid(bomb.phys) then
						bomb.dropping=true
						bomb.Armed=true
						bomb:SetCollisionGroup(0)
					end
				end)
			end
		end
		self:TakeSecondaryAmmo()
	end
	self:SetNextSecondary(0.3)
end

function ENT:CreateAI() -- called when the ai gets enabled
end

function ENT:RemoveAI() -- called when the ai gets disabled
end

function ENT:OnEngineStarted()
	-- [[ play engine start sound? ]]--
	self:EmitSound("F86_START")
end

function ENT:OnEngineStopped()
	--[[ play engine stop sound? ]]--
	self:EmitSound("F86_STOP")
end

function ENT:OnLandingGearToggled( bOn )
	
	if bOn then
		--[[ set bodygroup of landing gear down? ]]--
	else
		--[[ set bodygroup of landing gear up? ]]--
	end
end
 