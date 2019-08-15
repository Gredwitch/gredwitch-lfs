
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")
local tracer_cannon = 0
local tracer_mgff = 0
local tracer_mg13 = 0
local tracer_Mk103 = 0
local Tracer_Mk103 = false
local Tracer_mgff = false
local Tracer_mg13 = false
local Tracer_cannon = false
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
function ENT:UpdateTracers_Mk103()
	tracer_Mk103 = tracer_Mk103 + 1
	if tracer_Mk103 >= self.TracerConvar:GetInt() then
		tracer_Mk103 = 0
		return "white"
	else
		return false
	end
end
function ENT:UpdateTracers_MG13()
	tracer_mg13 = tracer_mg13 + 1
	if tracer_mg13 >= self.TracerConvar:GetInt() then
		tracer_mg13 = 0
		return "green"
	else
		return false
	end
end

function ENT:SpawnFunction( ply, tr, ClassName ) -- called by garry
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 90 ) -- spawn 20 units above ground
	ent:Spawn()
	ent:Activate()
	ent:SetSkin(table.Random(ent.CleanSkin))
	return ent
end

function ENT:GetMaxAmmoCannon()
	return self.AmmoCannon
end

function ENT:OnTick() -- use this instead of "think"
	local hp = self:GetHP()
	local skin = self:GetSkin()
	local ammo = self:GetAmmoSecondary()
	if hp <= 400 then
		if !table.HasValue(self.DamageSkin,skin) and table.HasValue(self.CleanSkin,skin) then
			self:SetSkin(skin + 1)
		end
	else
		if table.HasValue(self.DamageSkin,skin) then
			self:SetSkin(skin-1)
		end
	end
	local loadout = self:GetLoadout()
	if ammo == 0 and self.Bombs then
		for k,v in pairs(self.Bombs) do
			if IsValid(v) then v:Remove() end
		end
		self.Bombs = nil
	end
	
	if not self.Firing then
		if loadout == 0 then -- Clean
			if self.Bombs then
				for k,v in pairs(self.Bombs) do
					if IsValid(v) then v:Remove() end
				end
				self.Bombs = nil
			end
			self:SetAmmoSecondary(0)
			self:SetBodygroup(1,0) -- Bomb pylon
		elseif loadout == 8 then -- 4xSC100 + 1xSC1000
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			if ammo > 5 then
				self:AddBombs(loadout,8)
			end
			self:SetBodygroup(1,1) -- Bomb pylon
		elseif loadout == 7 then  -- 1xSC1000
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,1)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			if ammo > 1 then
				self:AddBombs(loadout,1)
			end
			self:SetBodygroup(1,1) -- Bomb pylon
		elseif loadout == 6 then -- 4xSC100
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			if ammo > 5 then
				self:AddBombs(loadout,5)
			end
			self:SetBodygroup(1,1) -- Bomb pylon
		elseif loadout == 5 then  -- 8xSC100
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,1)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			if ammo > 1 then
				self:AddBombs(loadout,1)
			end
			self:SetBodygroup(1,1) -- Bomb pylon
		elseif loadout == 4 then  -- 1xSC250
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,5)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			self:SetBodygroup(1,1) -- Bomb pylon
			if ammo > 5 then
				self:AddBombs(loadout,5)
			end
		elseif loadout == 3 then  -- 1xSC250 + 4xSC100
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,1)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			if ammo > 1 then
				self:AddBombs(loadout,1)
			end
			self:SetBodygroup(1,1) -- Bomb pylon
		elseif loadout == 2 then  -- 1xSC500
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,8)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			if ammo > 8 then
				self:AddBombs(loadout,8)
			end
			self:SetBodygroup(1,2) -- Bomb pylon
		elseif loadout == 1 then  -- 4xSC100
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,4)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			if ammo > 4 then
				self:AddBombs(loadout,4)
			end
			self:SetBodygroup(1,2) -- Bomb pylon
		elseif loadout == 9 then  -- Mk 109
			if self.Bombs then
				for k,v in pairs(self.Bombs) do
					if IsValid(v) then v:Remove() end
				end
				self.Bombs = nil
			end
			if not (self.OldLoadout == loadout) then
				self:SetAmmoSecondary(70)
			end
			self:SetBodygroup(1,0) -- Bomb pylon
		elseif loadout == 10 then  -- 14x Pb2
			if self.Bombs then
				for k,v in pairs(self.Bombs) do
					if IsValid(v) then v:Remove() end
				end
				self.Bombs = nil
			end
			if not (self.OldLoadout == loadout) then
				self:SetAmmoSecondary(14)
				ammo = 14
			end
			if ammo > 14 then
				self:SetAmmoSecondary(14)
				ammo = 14
			end
			self:SetBodygroup(1,0) -- Bomb pylon
		end
	end
	self.OldLoadout = loadout
	self.OldSecAmmo = ammo
	gred.HandleLandingGear(self,"gears")
	gred.PartThink(self,skin)
	--[[
	
		Bodygroup list
		SELF :
			1 : Undercarriage bomb pylons
				0 : blank
				1 : 1xbomb
				2 : 4xbombs
			2 : Nose guns
				0 : MG 17s
				1 : Nothing
				2 : Mk 108
				
		WINGS :
			1 : MG FF
				0 : MG FF
				1 : No MG FF
			2 : Under wings stuff
				0 : blank
				1 : 210mm rockets
				2 : 15mm MGs
				3 : 30mm cannons
				4 : R4M rockets
				5 : bomb pylons
	--]]
	self:SetBodygroup(2,2)
	local priAmmo = self:GetAmmoPrimary()
	local val
	if loadout == 2 or loadout == 4 or loadout == 6 or loadout == 8 then
		val = 5
	elseif loadout == 9 then
		val = 3
	elseif loadout == 10 then
		val = 4
	else
		val = 0
	end
	if self.Parts.wing_l then
		self.Parts.wing_l:SetBodygroup(1,1)
		self.Parts.wing_l:SetBodygroup(2,val)
	else
		if !self.WING_L_UPDATED then
			self.WING_L_UPDATED = true
			self.BulletPos[3] = nil
			self.Mk103[2] = nil
			self.MaxPrimaryAmmo = self.MaxPrimaryAmmo - 250
			self.MaxSecondaryAmmo = self.WING_R_UPDATED and 0 or self.MaxSecondaryAmmo / 2
			priAmmo = priAmmo - 250
			self:SetAmmoPrimary(priAmmo)
			self.BOMBS[6] = nil
			self.Rockets[2] = nil
			self.BOMBS[7] = nil
		end
	end
	if self.Parts.wing_r then
		self.Parts.wing_r:SetBodygroup(1,1)
		self.Parts.wing_r:SetBodygroup(2,val)
	else
		if !self.WING_R_UPDATED then
			self.WING_R_UPDATED = true
			self.Mk103[1] = nil
			self.BulletPos[2] = nil
			self.MaxPrimaryAmmo = self.MaxPrimaryAmmo - 250
			priAmmo = priAmmo - 250
			self.MaxSecondaryAmmo = self.WING_L_UPDATED and 0 or self.MaxSecondaryAmmo / 2
			self:SetAmmoPrimary(priAmmo)
			self.BOMBS[8] = nil
			self.Rockets[1] = nil
			self.BOMBS[9] = nil
		end
	end
	if priAmmo > self.MaxPrimaryAmmo then self:SetAmmoPrimary(self.MaxPrimaryAmmo) end
end

function ENT:CalcFlightOverride( Pitch, Yaw, Roll, Stability )
	return gred.PartCalcFlight(self,Pitch,Yaw,Roll,Stability,1,0.2)
end

function ENT:RunOnSpawn()
	self.TracerConvar = GetConVar("gred_sv_tracers")
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
	
	local loadout = self:GetLoadout()
	if loadout == 2 then
		self:AddBombs(1)
	elseif loadout == 3 then
		self:AddBombs(2)
	elseif loadout == 4 then
		self:AddBombs(3)
	end
	gred.InitAircraftParts(self,600)
end

function ENT:AddBombs(n,b)
	if self.Bombs then
		for k,v in pairs (self.Bombs) do
			if IsValid(v) then
				v:Remove()
			end
			v = nil
		end
		self.Bombs = nil
	end
	if istable(self.BOMBS) then
		self.Bombs = {}
		local s = 0
		if n == 1 or n == 2 then
			for k,v in pairs( self.BOMBS ) do
				if k != 1 then
					if b != nil then
						if k-1 <= b then
							local bomb = ents.Create("gb_bomb_sc100")
							bomb.IsOnPlane = true
							bomb:SetPos( self:LocalToWorld( v ) )
							bomb:SetAngles( self:GetAngles() )
							bomb:Spawn()
							bomb:Activate()
							bomb:SetParent( self )
							bomb.phys=bomb:GetPhysicsObject()
							if !IsValid(bomb.phys) then return end
							bomb.phys:SetMass(1)
							bomb:SetCollisionGroup(20)
							self:dOwner(bomb)
							s = s + 1
							table.insert( self.Bombs, bomb )
						end
					else
						local bomb = ents.Create("gb_bomb_sc100")
						bomb.IsOnPlane = true
						bomb:SetPos( self:LocalToWorld( v ) )
						bomb:SetAngles( self:GetAngles() )
						bomb:Spawn()
						bomb:Activate()
						bomb:SetParent( self )
						bomb.phys=bomb:GetPhysicsObject()
						if !IsValid(bomb.phys) then return end
						bomb.phys:SetMass(1)
						bomb:SetCollisionGroup(20)
						self:dOwner(bomb)
						s = s + 1
						table.insert( self.Bombs, bomb )
					end
				end
			end
		elseif n == 3 then
			local bomb = ents.Create("gb_bomb_sc250")
			bomb.IsOnPlane = true
			bomb:SetPos( self:LocalToWorld( self.BOMBS[1] ) )
			bomb:SetAngles( self:GetAngles() )
			bomb:Spawn()
			bomb:Activate()
			bomb:SetParent( self )
			bomb.phys=bomb:GetPhysicsObject()
			if !IsValid(bomb.phys) then return end
			bomb.phys:SetMass(1)
			bomb:SetCollisionGroup(20)
			self:dOwner(bomb)
			s = s + 1
			table.insert( self.Bombs, bomb )
		elseif n == 4 then
			for k,v in pairs( self.BOMBS ) do
				if b != nil then -- if there is no B
					if s <= b then -- k should never be > b
						if k != 1 then -- if its not the 250Kg bomb
							if k > 5 then
								local bomb = ents.Create("gb_bomb_sc100")
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
								table.insert( self.Bombs, bomb )
							end
						else
							local bomb = ents.Create("gb_bomb_sc250")
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
							table.insert( self.Bombs, bomb )
						end
					end
				else
					if k != 1 then -- if its not the 250Kg bomb
						if k > 5 then
							local bomb = ents.Create("gb_bomb_sc100")
							bomb.IsOnPlane = true
							bomb:SetPos( self:LocalToWorld( v ) )
							bomb:SetAngles( self:GetAngles() )
							bomb:Spawn()
							bomb:Activate()
							bomb:SetParent( self )
							bomb.phys=bomb:GetPhysicsObject()
							if !IsValid(bomb.phys) then return end
							bomb.phys:SetMass(1)
							bomb:SetCollisionGroup(20)
							self:dOwner(bomb)
							s = s + 1
							table.insert( self.Bombs, bomb )
						end
					else
						local bomb = ents.Create("gb_bomb_sc250")
						bomb.IsOnPlane = true
						bomb:SetPos( self:LocalToWorld( v ) )
						bomb:SetAngles( self:GetAngles() )
						bomb:Spawn()
						bomb:Activate()
						bomb:SetParent( self )
						bomb.phys=bomb:GetPhysicsObject()
						if !IsValid(bomb.phys) then return end
						bomb.phys:SetMass(1)
						bomb:SetCollisionGroup(20)
						self:dOwner(bomb)
						s = s + 1
						table.insert( self.Bombs, bomb )
					end
				end
			end
		elseif n == 6 then
			for k,v in pairs( self.BOMBS ) do
				if b != nil then -- if there is no B
					if s < b then -- k should never be > b
						if k != 1 then -- if its not the 250Kg bomb
							if k > 5 then
								local bomb = ents.Create("gb_bomb_sc100")
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
								table.insert( self.Bombs, bomb )
							end
						else
							local bomb = ents.Create("gb_bomb_sc500")
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
							table.insert( self.Bombs, bomb )
						end
					end
				else
					if k != 1 then -- if its not the 250Kg bomb
						if k > 5 then
							local bomb = ents.Create("gb_bomb_sc100")
							bomb.IsOnPlane = true
							bomb:SetPos( self:LocalToWorld( v ) )
							bomb:SetAngles( self:GetAngles() )
							bomb:Spawn()
							bomb:Activate()
							bomb:SetParent( self )
							bomb.phys=bomb:GetPhysicsObject()
							if !IsValid(bomb.phys) then return end
							bomb.phys:SetMass(1)
							bomb:SetCollisionGroup(20)
							self:dOwner(bomb)
							s = s + 1
							table.insert( self.Bombs, bomb )
						end
					else
						local bomb = ents.Create("gb_bomb_sc500")
						bomb.IsOnPlane = true
						bomb:SetPos( self:LocalToWorld( v ) )
						bomb:SetAngles( self:GetAngles() )
						bomb:Spawn()
						bomb:Activate()
						bomb:SetParent( self )
						bomb.phys=bomb:GetPhysicsObject()
						if !IsValid(bomb.phys) then return end
						bomb.phys:SetMass(1)
						bomb:SetCollisionGroup(20)
						self:dOwner(bomb)
						s = s + 1
						table.insert( self.Bombs, bomb )
					end
				end
			end
		elseif n == 8 then
			for k,v in pairs( self.BOMBS ) do
				if b != nil then -- if there is no B
					if s <= b then -- k should never be > b
						if k != 1 then -- if its not the 250Kg bomb
							if k > 5 then
								local bomb = ents.Create("gb_bomb_sc100")
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
								table.insert( self.Bombs, bomb )
							end
						else
							local bomb = ents.Create("gb_bomb_sc1000")
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
							table.insert( self.Bombs, bomb )
						end
					end
				else
					if k != 1 then -- if its not the 250Kg bomb
						if k > 5 then
							local bomb = ents.Create("gb_bomb_sc100")
							bomb.IsOnPlane = true
							bomb:SetPos( self:LocalToWorld( v ) )
							bomb:SetAngles( self:GetAngles() )
							bomb:Spawn()
							bomb:Activate()
							bomb:SetParent( self )
							bomb.phys=bomb:GetPhysicsObject()
							if !IsValid(bomb.phys) then return end
							bomb.phys:SetMass(1)
							bomb:SetCollisionGroup(20)
							self:dOwner(bomb)
							s = s + 1
							table.insert( self.Bombs, bomb )
						end
					else
						local bomb = ents.Create("gb_bomb_sc1000")
						bomb.IsOnPlane = true
						bomb:SetPos( self:LocalToWorld( v ) )
						bomb:SetAngles( self:GetAngles() )
						bomb:Spawn()
						bomb:Activate()
						bomb:SetParent( self )
						bomb.phys=bomb:GetPhysicsObject()
						if !IsValid(bomb.phys) then return end
						bomb.phys:SetMass(1)
						bomb:SetCollisionGroup(20)
						self:dOwner(bomb)
						s = s + 1
						table.insert( self.Bombs, bomb )
					end
				end
			end
		elseif n == 5 then
			local bomb = ents.Create("gb_bomb_sc500")
			bomb.IsOnPlane = true
			bomb:SetPos( self:LocalToWorld( self.BOMBS[1] ) )
			bomb:SetAngles( self:GetAngles() )
			bomb:Spawn()
			bomb:Activate()
			bomb:SetParent( self )
			bomb.phys=bomb:GetPhysicsObject()
			if !IsValid(bomb.phys) then return end
			bomb.phys:SetMass(1)
			bomb:SetCollisionGroup(20)
			self:dOwner(bomb)
			s = s + 1
			table.insert( self.Bombs, bomb )
		elseif n == 7 then
			local bomb = ents.Create("gb_bomb_sc1000")
			bomb.IsOnPlane = true
			bomb:SetPos( self:LocalToWorld( self.BOMBS[1] ) )
			bomb:SetAngles( self:GetAngles() )
			bomb:Spawn()
			bomb:Activate()
			bomb:SetParent( self )
			bomb.phys=bomb:GetPhysicsObject()
			if !IsValid(bomb.phys) then return end
			bomb.phys:SetMass(1)
			bomb:SetCollisionGroup(20)
			self:dOwner(bomb)
			s = s + 1
			table.insert( self.Bombs, bomb )
		end
		-- print("s = ",s)
		if not b then self:SetAmmoSecondary(s) else  self:SetAmmoSecondary(b) end
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
	else
		FireCannons = false
	end
	
	if Fire1 then
		self:PrimaryAttack()
	end
	
	if Fire2 then
		self:SecondaryAttack()
	end
	
	if self.OldFire ~= Fire1 then
		
		if Fire1 then
			self.wpn1 = CreateSound( self, "FW190_FIRE_LOOP" )
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
					
				self:EmitSound( "FW190_FIRE_LASTSHOT" )
			end
		end
		
		self.OldFire = Fire1
	end
	
	if self.OldFire2 ~= Fire2 then
		if Fire2 then
			self:SecondaryAttack()
		end
		self.OldFire2 = Fire2
	end
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimary( 0.08 )
	
	local Driver = self:GetDriver()
	Tracer_cannon = self:UpdateTracers_Cannon()
	local num = 1
	for k,v in pairs (self.BulletPos) do
		local pos2=self:LocalToWorld(v)
		local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
		gred.CreateBullet(Driver,pos2,ang,"wac_base_20mm",self.FILTER,nil,false,Tracer_cannon,50)
		self:TakePrimaryAmmo()

		local effectdata = EffectData()
		effectdata:SetOrigin(pos2)
		effectdata:SetAngles(ang)
		effectdata:SetEntity(self)
		util.Effect("gred_particle_aircraft_muzzle",effectdata)
	end
end

function ENT:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end

	local loadout = self:GetLoadout()
	local ammo = self:GetAmmoSecondary()
	if loadout == 9 then
		self:SetNextSecondary( 0.158 )
		Tracer_Mk103 = self:UpdateTracers_Mk103()
		for k,v in pairs (self.Mk103) do
			local pos2=self:LocalToWorld(v)
			local num = 1
			local locaang = Angle(-0.5,(v.y > 0 and -1 or 1),0)
			local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num))) + 
			locaang
			gred.CreateBullet(Driver,pos2,ang,"wac_base_30mm",self.FILTER,nil,false,Tracer_Mk103,200)
			self:TakeSecondaryAmmo()

			local effectdata = EffectData()
			effectdata:SetOrigin(pos2)
			effectdata:SetAngles(ang)
			effectdata:SetEntity(self)
			util.Effect("gred_particle_aircraft_muzzle",effectdata)
		end
	else
		if self:GetAI() then return end
		self:SetNextSecondary( 0.4 )
		self:TakeSecondaryAmmo()
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
			end
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