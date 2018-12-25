
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
	local ammo = self:GetAmmoSecondary()
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
	local loadout = self:GetLoadout()
	if loadout == 1 then
		if self.Bombs then
			for k,v in pairs (self.Bombs) do
				if IsValid(v) then
					v:Remove()
				end
				v = nil
			end
		end
		if not (self.OldLoadout == loadout) then
			for k,v in pairs(self.MissileEnts) do
				if IsValid(v) then
					v:SetColor(Shown)
				end
			end
			self:SetAmmoSecondary(2)
		else
			if ammo > 0 then
				for m = 1, ammo do
					if IsValid(self.MissileEnts[m]) then
						self.MissileEnts[m]:SetColor(Shown)
					end
				end
			end
		end
		if ammo > 2 then
			self:SetAmmoSecondary(2)
		end
		self:SetBodygroup(1,0)
		self:SetBodygroup(4,0) -- Bomb pylon
	else
		if self.MissileEnts then
			for k,v in pairs(self.MissileEnts) do
				v:SetColor(Hidden)
			end
		end
		self:SetBodygroup(1,1)
		if ammo == 0 and self.Bombs then
			for k,v in pairs(self.Bombs) do
				if IsValid(v) then v:Remove() end
			end
			self.Bombs = nil
		end
		if loadout == 2 then
			if not (self.OldLoadout == loadout) then
				self:AddBombs(1)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(1,ammo)
				end
			end
			self:SetBodygroup(4,2) -- Bomb pylon
		elseif loadout == 3 then
			if not (self.OldLoadout == loadout) then
				self:AddBombs(2)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(2,ammo)
				end
			end
			if ammo > 1 then
				self:SetAmmoSecondary(1)
			end
			self:SetBodygroup(4,1) -- Bomb pylon
		elseif loadout == 4 then
			if not (self.OldLoadout == loadout) then
				self:AddBombs(3)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(3,ammo)
				end
			end
			if ammo > 1 then
				self:SetAmmoSecondary(1)
			end
			self:SetBodygroup(4,1) -- Bomb pylon
		else 
			self:SetBodygroup(4,0) -- Bomb pylon
			self:SetAmmoSecondary(0)
			if self.Bombs then
				for k,v in pairs (self.Bombs) do
					if IsValid(v) then
						v:Remove()
					end
					v = nil
				end
			end
		end
	end
	self.OldLoadout = loadout
	self.OldSecAmmo = ammo
	self:SetBodygroup(2,1) -- MG FF
	self:SetBodygroup(3,0) -- 15mm R1
	self:SetBodygroup(5,1) -- MG 17
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
	if istable(self.MISSILES) then
		self.MissileEnts = {}
		for k,v in pairs( self.MISSILES ) do
			for _,n in pairs( v ) do
				local Missile = ents.Create( "prop_dynamic" )
				Missile:SetModel( self.MISSILEMDL )
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
					
				table.insert( self.MissileEnts, Missile )
			end
		end
	end
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
		elseif n == 2 then
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
		elseif n == 3 then
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
		end
		if not b then self:SetAmmoSecondary(s) end
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
	self:SetNextPrimary( 0.08 ) -- MG17 RPM
	
	local Driver = self:GetDriver()
	for k,v in pairs (self.BulletPos) do
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
		b.Damage=35
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
		net.Start("gred_net_wac_mg_muzzle_fx")
			net.WriteVector(pos2)
			net.WriteAngle(ang)
		net.Broadcast()
	end
	tracer = tracer + 1
end

function ENT:SecondaryAttack()
	if self:GetAI() then return end
	if not self:CanSecondaryAttack() then return end
	
	self:SetNextSecondary( 0.4 )

	self:TakeSecondaryAmmo()
	local loadout = self:GetLoadout()
	local ammo = self:GetAmmoSecondary()
	if loadout == 1 then
		if istable( self.MissileEnts ) then
			local Missile = self.MissileEnts[ammo+1]
			-- Missile:EmitSound( "npc/waste_scanner/grenade_fire.wav" )
			if IsValid( Missile ) then
				local ent = ents.Create( "gb_rocket_nebel" )
				local mPos = Missile:GetPos()
				Missile:SetColor(Hidden)
				local Ang = self:WorldToLocal( mPos ).y > 0 and -1 or 1
				ent:SetPos( mPos )
				ent:SetAngles( self:LocalToWorldAngles( Angle(0,Ang,0) ) )
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
			end
		end
	elseif loadout != 1 and loadout != 0 then
		if istable( self.Bombs ) then
			local bomb = self.Bombs[ ammo + 1 ]
			table.remove(self.Bombs,ammo + 1)
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