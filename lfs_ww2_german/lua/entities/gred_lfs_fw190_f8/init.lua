
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

function ENT:GetMaxAmmoCannon()
	return self.AmmoCannon
end

function ENT:OnTick() -- use this instead of "think"
	local hp = self:GetHP()
	local skin = self:GetSkin()
	local ammo = self:GetAmmoSecondary()
	if hp <= 400 then
		if table.HasValue(self.DamageSkin,skin) then return end
		if table.HasValue(self.CleanSkin,skin) then
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
	
	self:SetBodygroup(1,1)
	if not self.Firing then
		if loadout == 0 then -- Clean
			if self.Bombs then
				for k,v in pairs(self.Bombs) do
					if IsValid(v) then v:Remove() end
				end
				self.Bombs = nil
			end
			self:SetAmmoSecondary(0)
			self:SetBodygroup(4,0) -- Bomb pylon
			self:SetBodygroup(3,0) -- Wing stuff
		elseif loadout == 1 then -- 4xSC100
			if not (self.OldLoadout == loadout) then
				self:AddBombs(1)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(1,ammo)
				end
			end
			if ammo > 4 then
				self:AddBombs(1,4)
			end
			self:SetBodygroup(3,0) -- Wing stuff
			self:SetBodygroup(4,2) -- Bomb pylon
		elseif loadout == 2 then  -- 8xSC100
			if not (self.OldLoadout == loadout) then
				self:AddBombs(1,8)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(1,ammo)
				end
			end
			if ammo > 8 then
				self:AddBombs(1,8)
			end
			self:SetBodygroup(3,4) -- Wing stuff
			self:SetBodygroup(4,2) -- Bomb pylon
		elseif loadout == 3 then  -- 1xSC250
			if not (self.OldLoadout == loadout) then
				self:AddBombs(3)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(3,ammo)
				end
			end
			if ammo > 1 then
				self:AddBombs(3,1)
			end
			self:SetBodygroup(3,0) -- Wing stuff
			self:SetBodygroup(4,1) -- Bomb pylon
		elseif loadout == 4 then  -- 1xSC250 + 4xSC100
			if not (self.OldLoadout == loadout) then
				self:AddBombs(4,5)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(4,ammo)
				end
			end
			if ammo > 5 then
				self:AddBombs(4,5)
			end
			self:SetBodygroup(3,4) -- Wing stuff
			self:SetBodygroup(4,1) -- Bomb pylon
		elseif loadout == 5 then  -- 1xSC500
			if not (self.OldLoadout == loadout) then
				self:AddBombs(5)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(5,ammo)
				end
			end
			if ammo > 1 then
				self:AddBombs(5,1)
			end
			self:SetBodygroup(3,0) -- Wing stuff
			self:SetBodygroup(4,1) -- Bomb pylon
		elseif loadout == 6 then  -- 1xSC500 + 4xSC100
			if not (self.OldLoadout == loadout) then
				self:AddBombs(6,5)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(6,ammo)
				end
			end
			if ammo > 5 then
				self:AddBombs(6,5)
			end
			self:SetBodygroup(3,4) -- Wing stuff
			self:SetBodygroup(4,1) -- Bomb pylon
		elseif loadout == 7 then  -- 1xSC1000
			if not (self.OldLoadout == loadout) then
				self:AddBombs(7)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(7,ammo)
				end
			end
			if ammo > 1 then
				self:AddBombs(7,1)
			end
			self:SetBodygroup(3,0) -- Wing stuff
			self:SetBodygroup(4,1) -- Bomb pylon
		elseif loadout == 8 then  -- 1xSC1000 + 4xSC100
			if not (self.OldLoadout == loadout) then
				self:AddBombs(8,5)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(8,ammo)
				end
			end
			if ammo > 5 then
				self:AddBombs(8,5)
			end
			self:SetBodygroup(3,4) -- Wing stuff
			self:SetBodygroup(4,1) -- Bomb pylon
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
			self:SetBodygroup(4,0) -- Bomb pylon
			self:SetBodygroup(3,2) -- Wing stuff
		end
	end
	self.OldLoadout = loadout
	self.OldSecAmmo = ammo
	
	self:SetBodygroup(2,1) -- MG FF
	self:SetBodygroup(5,0) -- MG 17
	self:SetBodygroup(6,0) -- MG 151 / MG 17
end

function ENT:RunOnSpawn()
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
		if n == 1 then
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

function ENT:TakeCannonAmmo(amount)
	amount = amount or 1
	self:SetAmmoCannon(math.max(self:GetAmmoCannon() - amount,0))
end

function ENT:HandleWeapons(Fire1, Fire2)
	local Driver = self:GetDriver()
	local ca=self:GetAmmoCannon()
	if IsValid( Driver ) then
		if self:GetAmmoPrimary() > 0 then
			Fire1 = Driver:KeyDown( IN_ATTACK )
		end
		if ca > 0 then
			FireCannons = Driver:KeyDown( IN_ATTACK )
		end
		if self:GetAmmoSecondary() > 0 then
			Fire2 = Driver:KeyDown( IN_ATTACK2 )
		end
		self.Firing = Fire2
	end
	
	if Fire1 then
		self:PrimaryAttack()
	end
	
	if FireCannons then
		self:FireCannons()
	end
	
	if Fire2 then
		self:SecondaryAttack()
	end
	
	if self.OldFire ~= Fire1 then
		
		if Fire1 then
			self.wpn1 = CreateSound( self, "BF109_FIRE_LOOP" )
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
					
				self:EmitSound( "BF109_FIRE_LASTSHOT" )
			end
		end
		
		self.OldFire = Fire1
	end
	
	if self.OldCannon ~= FireCannons then
		
		if FireCannons then
			self.wpn3 = CreateSound( self, "FW190_FIRE_LOOP" )
			self.wpn3:Play()
			self:CallOnRemove( "stopmesounds3", function( ent )
				if ent.wpn3 then
					ent.wpn3:Stop()
				end
			end)
		else
			if self.OldCannon == true then
				if self.wpn3 then
					self.wpn3:Stop()
				end
				self.wpn3 = nil
					
				self:EmitSound( "FW190_FIRE_LASTSHOT" )
			end
		end
		
		self.OldCannon = FireCannons
	else
		if ca <= 0 then
			if self.wpn3 then
				self.wpn3:Stop()
				self:EmitSound( "FW190_FIRE_LASTSHOT" )
				self.wpn3 = nil
			end
		end
	end
	
	if self.OldFire2 ~= Fire2 then
		local l = self:GetLoadout()
		if Fire2 then
			self:SecondaryAttack()
			if l == 9 then
				self.wpn2 = CreateSound( self, "FW190_MK103_LOOP" )
				self.wpn2:Play()
				self:CallOnRemove( "stopmesounds2", function( ent )
					if ent.wpn2 then
						ent.wpn2:Stop()
					end
				end)
			end
		else
			if l == 9 then
				if self.OldFire2 == true then
					if self.wpn2 then
						self.wpn2:Stop()
					end
					self.wpn2 = nil
						
					-- self:EmitSound( "BF109_FIRE_LASTSHOT" )
				end
			end
		end
		self.OldFire2 = Fire2
	end
end

function ENT:FireCannons()
	local ct = CurTime()
	for k,v in pairs (self.CannonPos) do
		if ((k == 1 or k == 2) and self.NextCannon < ct and self:GetAmmoCannon() > 0) then 
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
			b.CustomDMG=true
			b.Damage=15
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
				if k == 2 then
					tracerC = 0
				end
			else b.noTracer = true end
			tracerC = tracerC + 1
			if (k == 2) then self.NextCannon = ct + 0.08 self:TakeCannonAmmo(2) end

			local effectdata = EffectData()
			effectdata:SetOrigin(pos2)
			effectdata:SetAngles(ang)
			effectdata:SetEntity(self)
			util.Effect("gred_particle_aircraft_muzzle",effectdata)
		end
	end
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimary( 0.067 )
	
	local Driver = self:GetDriver()
	for k,v in pairs (self.BulletPos) do
		local pos2=self:LocalToWorld(v)
		local num = 0.7
		local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
		local b=ents.Create("gred_base_bullet")
		b:SetPos(pos2)
		b:SetAngles(ang)
		b.col = "Green"
		b.Speed=1000
		b.Caliber = "wac_base_12mm"
		b.Size=0
		b.Width=0
		b.CustomDMG=true
		b.Damage=7
		b.Radius=70
		b.sequential=true
		b.npod=1
		b.gunRPM=900
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
	if not self:CanSecondaryAttack() then return end

	local loadout = self:GetLoadout()
	local ammo = self:GetAmmoSecondary()
	if loadout == 9 then
		self:SetNextSecondary( 0.158 )
		for k,v in pairs (self.Mk103) do
			local pos2=self:LocalToWorld(v)
			local num = 1
			local locaang = Angle(-0.5,(v.y > 0 and -1 or 1),0)
			local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num))) + 
			locaang
			local b=ents.Create("gred_base_bullet")
			b:SetPos(pos2)
			b:SetAngles(ang)
			b.col = "Yellow"
			b.Speed=1000
			b.Caliber = "wac_base_30mm"
			b.Size=0
			b.Width=0
			b.Damage=40
			b.Radius=70
			b.sequential=true
			b.npod=1
			b.gunRPM=380
			b:Spawn()
			b:Activate()
			b.Filter = {self}
			b.Owner=Driver
			if !tracerC then tracerC = 0 end
			if tracerC >= GetConVarNumber("gred_sv_tracers") then
				b:SetSkin(0)
				b:SetModelScale(20)
				-- if k == 2 then
					-- tracerC = 0
				-- end
			else b.noTracer = true end
			self:TakeSecondaryAmmo()
			tracerC = tracerC + 1

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