
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
		self:SetBodygroup(1,0) -- Bomb pylons
		if self.OldLoadout != loadout then
			self:RemoveBombs()
		end
	elseif loadout == 1 then
		self:SetBodygroup(1,1) -- Nomn pylons
		if self.OldLoadout != loadout then
			self:SetAmmoSecondary(1)
			self:AddBombs(0)
		else
			if secAmmo != self.OldSecAmmo and not self.Firing then
				if secAmmo > 0 then
					self:AddBombs(0,secAmmo)
				else
					self:RemoveBombs()
				end
			end
		end
	elseif loadout == 2 then
		self:SetBodygroup(1,1) -- Nomn pylons
		if self.OldLoadout != loadout then
			self:SetAmmoSecondary(1)
			self:AddBombs(1)
		else
			if secAmmo != self.OldSecAmmo and not self.Firing then
				if secAmmo > 0 then
					self:AddBombs(1,secAmmo)
				else
					self:RemoveBombs()
				end
			end
		end
	end
	self.OldSecAmmo = secAmmo
	self.OldLoadout = loadout
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
	if istable(self.BOMBS) and (b and b > 0 or true) then
		self.Bombs = {}
		local s = 0
		local v = self.BOMBS[1]
		if n == 0 then
			local bomb = ents.Create("gb_bomb_500gp")
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
		elseif n == 1 then
			local pos = Vector(9,0,3.2)
			local bomb = ents.Create("gb_bomb_1000gp")
			bomb.IsOnPlane = true
			bomb:SetPos(self:LocalToWorld(v-pos))
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
		if not isnumber(b) then self:SetAmmoSecondary(s) end
	end
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
		self.Firing = Fire2
	end
	if Fire1 then
		self:PrimaryAttack()
	end
	if Fire2 then
		self:SecondaryAttack(loadout,secAmmo)
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
			self:SecondaryAttack(loadout,secAmmo)
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
		net.Start("gred_net_wac_mg_muzzle_fx")
			net.WriteVector(pos2)
			net.WriteAngle(ang)
		net.Broadcast()
	end
	tracer = tracer + 1
end

function ENT:SecondaryAttack(loadout,secAmmo)
	if not self:CanSecondaryAttack() then return end
	local Driver = self:GetDriver()

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
	self:TakeSecondaryAmmo()
	self:SetNextSecondary(0.3)
end

function ENT:CreateAI() -- called when the ai gets enabled
end

function ENT:RemoveAI() -- called when the ai gets disabled
end

function ENT:OnEngineStarted()
	self:EmitSound("F4U_START")
end

function ENT:OnEngineStopped()
	self:EmitSound("F4U_STOP")
end

function ENT:OnLandingGearToggled( bOn )
	self:EmitSound( "gredwitch/p51_lfs/p51_gear.wav" )
end