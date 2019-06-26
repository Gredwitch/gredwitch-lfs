
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
	local loadout = self:GetLoadout()
	local secAmmo = self:GetAmmoSecondary()
	local slct = self:GetCurSecondary()
	
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
	
	if loadout == 0 then
		self:SetAmmoSecondary(0)
		self:SetBodygroup(1,0) -- Rocket pylons
		self:SetBodygroup(2,0) -- Bomb pylons
		self:SetBodygroup(3,0) -- M10 pylons
		if self.OldLoadout != loadout then
			self:RemoveBombs()
			self:SetMissilesColor(self.HVARs,Hidden)
			self:SetMissilesColor(self.M8s,Hidden)
		end
		self:SetCurSecondary(999)
	elseif loadout == 1 then
		self:SetBodygroup(1,1) -- Rocket pylons
		self:SetBodygroup(2,0) -- Bomb pylons
		self:SetBodygroup(3,0) -- M10 pylons
		self:SetCurSecondary(0)
		if self.OldLoadout != loadout then
			self:RemoveBombs()
			self:SetMissilesColor(self.HVARs,Shown,{7,8,9,10})
			self:SetMissilesColor(self.M8s,Hidden)
			self:SetAmmoSecondary(6)
		else
			if secAmmo > 6 then self:SetAmmoSecondary(6) secAmmo = 6 end
			if secAmmo > 0 and not slct != self.OldSecondary and slct == 0 then
				for m = 1, secAmmo-1 do
					if IsValid(self.HVARs[m]) then
						self.HVARs[m]:SetColor(Shown)
					end
				end
				for i = 7,10 do
					if IsValid(self.HVARs[i]) then
						self.HVARs[i]:SetColor(Hidden)
					end
				end
			end
		end
	elseif loadout == 3 then
		self:SetBodygroup(1,0) -- Rocket pylons
		self:SetBodygroup(2,0) -- Bomb pylons
		self:SetBodygroup(3,2) -- M10 pylons
		self:SetCurSecondary(0)
		if self.OldLoadout != loadout then
			self:RemoveBombs()
			self:SetMissilesColor(self.HVARs,Hidden)
			self:SetMissilesColor(self.M8s,Shown)
			self:SetAmmoSecondary(6)
		else
			if secAmmo > 6 then self:SetAmmoSecondary(6) secAmmo = 6 end
			if secAmmo > 0 and not slct != self.OldSecondary and slct == 0 then
				for m = 1, secAmmo-1 do
					if IsValid(self.M8s[m]) then
						self.M8s[m]:SetColor(Shown)
					end
				end
			end
		end
	elseif loadout == 2 then
		self:SetBodygroup(1,0) -- Rocket pylons
		self:SetBodygroup(2,2) -- Bomb pylons
		self:SetBodygroup(3,0) -- M10 pylons
		if self.OldLoadout != loadout then
			self:SetMissilesColor(self.HVARs,Hidden)
			self:SetMissilesColor(self.M8s,Hidden)
			self:SetAmmoSecondary(2)
			self:AddBombs(2)
		else
			if secAmmo > 2 then self:SetAmmoSecondary(2) secAmmo = 2 end
			if secAmmo != self.OldSecAmmo and not self.Firing then
				self:AddBombs(2,secAmmo)
			end
		end
		self:SetCurSecondary(1)
	end
	self.OldSecondary = slct
	self.OldSecAmmo = secAmmo
	self.OldLoadout = loadout
end

function ENT:GetRocketCount(loadout)
	if not self.RKTCOUNT then
		self:SetRocketCount(loadout)
	end
	return self.RKTCOUNT
end

function ENT:SetRocketCount(loadout)
	local count = 0
	if loadout == 1 or loadout == 7 then
		if istable(self.HVARs) then
			for i = 7,10 do
				if IsValid(self.HVARs[i]) then
					self.HVARs[i]:SetColor(Hidden)
				end
			end
			for m = 1, 10 do
				if IsValid(self.HVARs[m]) then
					if self.HVARs[m]:GetColor().a == Shown.a then count = count + 1 end
				end
			end
		end
	elseif loadout == 2 then
		if istable(self.M8s) then
			for k,v in pairs(self.M8s) do
				if v:GetColor() == Shown then count = count + 1 end
			end
		end
	end
	self.RKTCOUNT = count
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
	
	self:CreateMissiles()
end

function ENT:SetMissilesColor(missiles,color,x)
	if istable(missiles) and istable(color) then
		for k,v in pairs(missiles) do
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

function ENT:CreateMissiles()
	if istable(self.HVAR) then
		self.HVARs = {}
		for k,v in pairs( self.HVAR ) do
			for _,n in pairs( v ) do
				local Missile = ents.Create( "prop_dynamic" )
				Missile:SetModel( self.HVARMDL )
				Missile:SetPos( self:LocalToWorld( n ) )
				Missile:SetAngles( self:GetAngles() )
				Missile:SetMoveType( MOVETYPE_NONE )
				Missile:Spawn()
				Missile:Activate()
				Missile:SetNotSolid( true )
				Missile:DrawShadow( false )
				Missile:SetParent( self )
				Missile.DoNotDuplicate = true
				Missile:SetRenderMode(RENDERGROUP_TRANSLUCENT)
				self:dOwner( Missile )
					
				table.insert( self.HVARs, Missile )
			end
		end
	end
	if istable(self.M8) then
		self.M8s = {}
		for k,v in pairs( self.M8 ) do
			for _,n in pairs( v ) do
				local Missile = ents.Create( "prop_dynamic" )
				Missile:SetModel( self.M8MDL )
				Missile:SetPos( self:LocalToWorld( n ) )
				Missile:SetAngles( self:GetAngles() )
				Missile:SetMoveType( MOVETYPE_NONE )
				Missile:Spawn()
				Missile:Activate()
				Missile:SetNotSolid( true )
				Missile:DrawShadow( false )
				Missile:SetParent( self )
				Missile.DoNotDuplicate = true
				Missile:SetRenderMode(RENDERGROUP_TRANSLUCENT)
				self:dOwner( Missile )
					
				table.insert( self.M8s, Missile )
			end
		end
	end
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
			local pos = Vector(0,0,3)
			for k,v in pairs( self.BOMBS ) do
				if b != nil && isnumber(b) then
					if k <= b then
						local bomb = ents.Create("gb_bomb_250gp")
						bomb.IsOnPlane = true
						bomb:SetPos(self:LocalToWorld(v+pos))
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
					local bomb = ents.Create("gb_bomb_250gp")
					bomb.IsOnPlane = true
					bomb:SetPos(self:LocalToWorld(v+pos))
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
			local pos = Vector(0,0,3)
			for k,v in pairs( self.BOMBS ) do
				if b != nil && isnumber(b) then
					if k <= b then
						local bomb = ents.Create("gb_bomb_500gp")
						bomb.IsOnPlane = true
						bomb:SetPos(self:LocalToWorld(v+pos+Vector(0,0,3)))
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
					local bomb = ents.Create("gb_bomb_500gp")
					bomb.IsOnPlane = true
					bomb:SetPos(self:LocalToWorld(v+pos+Vector(0,0,3)))
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
		elseif n == 2 then
			local pos = Vector(0,0,3)
			for k,v in pairs( self.BOMBS ) do
				if b != nil && isnumber(b) then
					if k <= b then
						local bomb = ents.Create("gb_bomb_1000gp")
						bomb.IsOnPlane = true
						bomb:SetPos(self:LocalToWorld(v+pos+Vector(0,0,1)))
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
					local bomb = ents.Create("gb_bomb_1000gp")
					bomb.IsOnPlane = true
					bomb:SetPos(self:LocalToWorld(v+pos+Vector(0,0,1)))
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

function ENT:GetLastChangeSecondary()
	return self.LastChangeSecondary
end

function ENT:SetLastChangeSecondary(ct)
	self.LastChangeSecondary = ct + 0.3
end

function ENT:ChangeSecondary()
	local ct = CurTime()
	if self:GetLastChangeSecondary() >= ct then return end
	local cursec = self:GetCurSecondary()
	if cursec == 0 then
		self:SetCurSecondary(1)
	else
		self:SetCurSecondary(0)
	end
	self:SetLastChangeSecondary(ct)
end

function ENT:HandleWeapons(Fire1, Fire2)
	local Driver = self:GetDriver()
	local loadout = self:GetLoadout()
	local secAmmo = self:GetAmmoSecondary()
	if IsValid( Driver ) then
		if self:GetAmmoPrimary() > 0 then
			Fire1 = Driver:KeyDown( IN_ATTACK )
		end
		if secAmmo > 0 then
			Fire2 = Driver:KeyDown( IN_ATTACK2 )
		end
		Change = Driver:KeyDown( IN_WALK )
		self.Firing = Fire2
	end
	if Change and loadout >= 5 then
		self:ChangeSecondary()
	end
	local slct = self:GetCurSecondary()
	if Fire1 then
		self:PrimaryAttack()
	end
	if Fire2 then
		self:SecondaryAttack(loadout,secAmmo,slct)
	end
	if self.OldFire ~= Fire1 then
		
		if Fire1 then
			self.wpn1 = CreateSound( self, "LFS_M2_BROWNING_SHOOT" )
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
					
				self:EmitSound( "LFS_M2_BROWNING_STOP" )
			end
		end
		
		self.OldFire = Fire1
	end
	
	if self.OldFire2 ~= Fire2 then
		if Fire2 then
			self:SecondaryAttack(loadout,secAmmo,slct)
		end
		self.OldFire2 = Fire2
	end
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimary( 0.08 )
	
	local Driver = self:GetDriver()
	for k,v in pairs (self.BulletPos) do
		local pos2=self:LocalToWorld(v)
		local num = 0.5
		local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
		local b=ents.Create("gred_base_bullet")
		b:SetPos(pos2)
		b:SetAngles(ang)
		b.col = "Red"
		b.Speed=1000
		b.Caliber = "wac_base_12mm"
		b.Size=0
		b.Width=0
		b.CustomDMG=true
		b.Damage=2
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
			b:SetSkin(1)
			b:SetModelScale(20)
			if k == 6 then
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

function ENT:SecondaryAttack(loadout,secAmmo,slct)
	if not self:CanSecondaryAttack() then return end
	local Driver = self:GetDriver()
	if slct == 0 then
		if istable( self.HVARs ) then
			if loadout == 1 or (loadout >= 6) then
				local Missile = self.HVARs[secAmmo]
				local b = 1
				while Missile:GetColor() == Hidden do
					Missile = self.HVARs[secAmmo+b]
					b = b + 1
				end
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
			else
				local Missile = self.M8s[secAmmo]
				local b = 1
				while Missile:GetColor() == Hidden do
					Missile = self.M8s[secAmmo+b]
					b = b + 1
				end
				if IsValid( Missile ) then
					local ent = ents.Create( "gb_rocket_rp3" )
					local mPos = Missile:GetPos()
					Missile:SetColor(Hidden)
					local Ang = self:WorldToLocal( mPos ).y > 0 and -1 or 1
					ent:SetPos( mPos )
					ent:SetAngles( self:LocalToWorldAngles( Angle(-5,Ang,0) ) )
					ent:Spawn()
					ent:Activate()
					ent:SetModel(self.M8MDL) -- REMOVE ME
					ent:SetOwner(self:GetDriver())
					ent.phys = ent:GetPhysicsObject()
					local p = self:GetPhysicsObject() 
					if IsValid(p) and IsValid(ent.phys) then ent.phys:AddVelocity(p:GetVelocity()) end
					ent:Launch()
					
					constraint.NoCollide( ent, self, 0, 0 ) 
					if IsValid( self.wheel_R ) then
						constraint.NoCollide( ent, self.wheel_R, 0, 0 ) 
					end
					if IsValid( self.wheel_L ) then
						constraint.NoCollide( ent, self.wheel_L, 0, 0 ) 
					end
				end
			end
		end
	else
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
			end
		end
	end
	self:TakeSecondaryAmmo()
	self:SetNextSecondary(0.3)
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
	self:EmitSound( "gredwitch/p51_lfs/p51_gear.wav" )
end