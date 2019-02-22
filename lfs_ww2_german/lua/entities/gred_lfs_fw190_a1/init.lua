
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
	
	self:SetBodygroup(1,1)
	self:SetBodygroup(2,0) -- MG FF
	self:SetBodygroup(3,0) -- 15mm R1
	self:SetBodygroup(4,0) -- Bomb pylon
	self:SetBodygroup(5,0) -- MG 17
	self:SetBodygroup(6,1) -- MG 151 / MG 17
end

function ENT:RunOnSpawn()
	--[[
	if istable(self.BOMBs) then
		self.Bombs = {}
		for k,v in pairs( self.BOMBS ) do
			for _,n in pairs( v ) do
				local f = "gb_bomb_sc100"
				if k == 3 then f = "gb_bomb_sc250" end
				local bomb = ents.Create(f)
				bomb.IsOnPlane = true
				bomb:SetPos( self:LocalToWorld( n ) )
				bomb:SetAngles( self:GetAngles() )
				bomb:Spawn()
				bomb:Activate()
				bomb:SetParent( self )
				bomb.phys=bomb:GetPhysicsObject()
				if !IsValid(bomb.phys) then return end
				bomb.phys:SetMass(1)
				bomb:SetCollisionGroup(20)
				self:dOwner(bomb)
				
				table.insert( self.Bombs, bomb )
			end
		end
	end
	]]
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
				self:dOwner( Missile )
				
				table.insert( self.MissileEnts, Missile )
			end
		end
	end
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
	
	if self.OldFire2 ~= Fire2 then
	
		if Fire2 then
			self.wpn2 = CreateSound( self, "BF109_FIRE2_LOOP" )
			self.wpn2:Play()
			self:CallOnRemove( "stopmesounds2", function( ent )
				if ent.wpn2 then
					ent.wpn2:Stop()
				end
			end)
		else
			if self.OldFire2 == true then
				if self.wpn2 then
					self.wpn2:Stop()
				end
				self.wpn2 = nil
					
				self:EmitSound( "BF109_FIRE2_LASTSHOT" )
			end
		end
		
		self.OldFire2 = Fire2
	end
end

function ENT:GetMaxAmmoMGFF()
	return self.AmmoMGFF
end

function ENT:GetMaxAmmoCannon()
	return self.AmmoCannon
end

function ENT:TakeMGFFAmmo(amount)
	amount = amount or 1
	self:SetAmmoMGFF(math.max(self:GetAmmoMGFF() - amount,0))
end

function ENT:TakeCannonAmmo(amount)
	amount = amount or 1
	self:SetAmmoCannon(math.max(self:GetAmmoCannon() - amount,0))
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
		b.Damage=10
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
			if k == 4 then
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

--[[function ENT:SecondaryAttack()
	if self:GetAI() then return end
	if not self:CanSecondaryAttack() then return end
	
	self:SetNextSecondary( 0.1 )

	self:TakeSecondaryAmmo()
	
	if istable( self.Bombs ) then
		local bomb = self.Bombs[ self:GetAmmoSecondary() + 1 ]
		bomb:EmitSound( "npc/waste_scanner/grenade_fire.wav" )
		if IsValid( bomb ) then
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
end]]

function ENT:SecondaryAttack()
	-- if self:GetAI() then return end
	if not self:CanSecondaryAttack() then return end
	
	self:SetNextSecondary( 0.11 )

	
	local ct = CurTime()
	for k,v in pairs (self.CannonPos) do
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
		b.Damage=40
		b.Radius=70
		b.sequential=true
		b.npod=1
		b.gunRPM=550
		b:Spawn()
		b:Activate()
		b.Filter = {self}
		b.Owner=Driver
		if !tracerC then tracerC = 0 end
		if tracerC >= GetConVarNumber("gred_sv_tracers") then
			b:SetSkin(0)
			b:SetModelScale(20)
			if k == 2 then
				tracer = 0
			end
		else b.noTracer = true end
		self:TakeSecondaryAmmo()
		tracerC = tracerC + 1
		-- if (k == 2) then self.NextCannon = ct + 0.11 self:TakeCannonAmmo(2) end

		local effectdata = EffectData()
		effectdata:SetOrigin(pos2)
		effectdata:SetAngles(ang)
		effectdata:SetEntity(self)
		util.Effect("gred_particle_aircraft_muzzle",effectdata)
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