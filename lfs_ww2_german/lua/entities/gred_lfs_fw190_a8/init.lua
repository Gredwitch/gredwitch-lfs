
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")
local tracer_cannon = 0
function ENT:UpdateTracers_Cannon()
	tracer_cannon = tracer_cannon + 1
	if tracer_cannon >= self.TracerConvar:GetInt() then
		tracer_cannon = 0
		return "yellow"
	else
		return false
	end
end
local tracer_mg13 = 0
function ENT:UpdateTracers_MG13()
	tracer_mg13 = tracer_mg13 + 1
	if tracer_mg13 >= self.TracerConvar:GetInt() then
		tracer_mg13 = 0
		return "green"
	else
		return false
	end
end
local Tracer_mg13 = false
local Tracer_cannon = false

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
		if !table.HasValue(self.DamageSkin,skin) and table.HasValue(self.CleanSkin,skin) then
			self:SetSkin(skin + 1)
		end
	else
		if table.HasValue(self.DamageSkin,skin) then
			self:SetSkin(skin-1)
		end
	end
	local loadout = self:GetLoadout()
	if loadout == 1 then
		if self.OldLoadout != loadout then
			self:SetAmmoSecondary(2)
		end
	else
		self:SetAmmoSecondary(0)
	end
	gred.HandleLandingGear(self,"gears")
	gred.PartThink(self,skin)
	self.OldLoadout = loadout
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
	
	local cannon = self:GetAmmoCannon()
	local secAmmo = self:GetAmmoSecondary()
	if self.Parts.wing_l then
		self.Parts.wing_l:SetBodygroup(1,0)
		self.Parts.wing_l:SetBodygroup(2,loadout == 1 and 1 or 0)
	else
		if !self.WING_L_UPDATED then
			self.WING_L_UPDATED = true
			self.CannonPos[2] = nil
			self.CannonPos[4] = nil
			self.AmmoCannon = self.WING_R_UPDATED and 0 or self.AmmoCannon / 2
			self.MaxSecondaryAmmo = self.WING_R_UPDATED and 0 or self.MaxSecondaryAmmo / 2
			cannon = self.WING_R_UPDATED and 0 or cannon / 2
			secAmmo = self.WING_R_UPDATED and 0 or secAmmo / 2
			self.MISSILES[1][2] = nil
			self:SetAmmoCannon(cannon)
		end
	end
	if self.Parts.wing_r then
		self.Parts.wing_r:SetBodygroup(1,0)
		self.Parts.wing_r:SetBodygroup(2,loadout == 1 and 1 or 0)
	else
		if !self.WING_R_UPDATED then
			self.WING_R_UPDATED = true
			self.CannonPos[1] = nil
			self.CannonPos[3] = nil
			self.AmmoCannon = self.WING_L_UPDATED and 0 or self.AmmoCannon / 2
			self.MaxSecondaryAmmo = self.WING_L_UPDATED and 0 or self.MaxSecondaryAmmo / 2
			cannon = self.WING_L_UPDATED and 0 or cannon / 2
			secAmmo = self.WING_L_UPDATED and 0 or secAmmo / 2
			self.MISSILES[1][1] = nil
			self:SetAmmoCannon(cannon)
		end
	end
	if cannon > self.AmmoCannon then self:SetAmmoCannon(self.AmmoCannon) end
	if secAmmo > self.MaxSecondaryAmmo then self:SetAmmoSecondary(self.MaxSecondaryAmmo) end
end

function ENT:CalcFlightOverride( Pitch, Yaw, Roll, Stability )
	return gred.PartCalcFlight(self,Pitch,Yaw,Roll,Stability,1,0.2)
end

function ENT:RunOnSpawn()
	self.TracerConvar = GetConVar("gred_sv_tracers")
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
	gred.InitAircraftParts(self,600)
end

function ENT:HandleWeapons(Fire1, Fire2)
	local Driver = self:GetDriver()
	
	if IsValid( Driver ) then
			Fire1 = Driver:KeyDown( IN_ATTACK )
			FireCannons = Driver:KeyDown( IN_ATTACK )
		
		if self:GetAmmoSecondary() > 0 then
			Fire2 = Driver:KeyDown( IN_ATTACK2 )
		end
	end
	local pri = self:GetAmmoPrimary()
	local cannon = self:GetAmmoCannon()
	if Fire1 then
		if pri > 0 then
			self:PrimaryAttack()
			stoppri = false
			PRISnd = true
		else
			PRISnd = false
		end
		self:FireCannons()
		if cannon > 0 then
			stopcannon = false
			CannonSnd = true
		else
			CannonSnd = false
		end
	end
	
	if self.OldFire ~= Fire1 then
		if Fire1 then
			if PRISnd then
				if pri > 0 then
					self.wpn1 = CreateSound( self, "BF109_FIRE_LOOP" )
					self.wpn1:Play()
				else
					if self.wpn1 then
						self.wpn1:Stop()
					end
					self.wpn1 = nil
					self:EmitSound( "BF109_FIRE_LASTSHOT" )
				end
				self:CallOnRemove( "stopmesounds1", function( ent )
					if ent.wpn1 then
						ent.wpn1:Stop()
					end
				end)
			end
			if CannonSnd then
				if cannon > 0 then
					self.wpn3 = CreateSound( self, "FW190_FIRE_LOOP" )
					self.wpn3:Play()
				else
					if self.wpn3 then
						self.wpn3:Stop()
					end
					self.wpn3 = nil
					self:EmitSound( "FW190_FIRE_LASTSHOT" )
				end
				self:CallOnRemove( "stopmesounds3", function( ent )
					if ent.wpn3 then
						ent.wpn3:Stop()
					end
				end)
			end
		else
			if self.OldFire == true then
				if self.wpn1 then
					self.wpn1:Stop()
				end
				if self.wpn2 then
					self.wpn2:Stop()
				end
				if self.wpn3 then
					self.wpn3:Stop()
				end
				
				self.wpn1 = nil
				self.wpn2 = nil
				self.wpn3 = nil
				if PRISnd then
					self:EmitSound( "BF109_FIRE_LASTSHOT" )
				end
				if CannonSnd then
					self:EmitSound( "FW190_FIRE_LASTSHOT" )
				end
			end
		end
		self.OldFire = Fire1
	end
	
	if !(pri > 0) then
		if self.wpn1 then
			self.wpn1:Stop()
		end
		self.wpn1 = nil
		if !stoppri then
			self:EmitSound( "BF109_FIRE_LASTSHOT" )
			stoppri = true
		end
	end
	if !(cannon > 0) then
		if self.wpn3 then
			self.wpn3:Stop()
		end
		self.wpn3 = nil
		if !stopcannon then
			self:EmitSound("FW190_FIRE_LASTSHOT")
			stopcannon = true
		end
	end
	if istable( self.MissileEnts ) then
		for k, v in pairs( self.MissileEnts ) do
			if IsValid( v ) then
				if k > self:GetAmmoSecondary() then
					v:SetNoDraw( true )
				else
					v:SetNoDraw( false )
				end
			end
		end
	end
	
	if self.OldFire2 ~= Fire2 then
		if Fire2 then
			self:SecondaryAttack()
		end
		self.OldFire2 = Fire2
	end
end

function ENT:GetMaxAmmoCannon()
	return self.AmmoCannon
end

function ENT:FireCannons()
	local ct = CurTime()
	if self.NextCannon > ct then return end
	local Driver = self:GetDriver()
	for k,v in pairs (self.CannonPos) do
		if self:GetAmmoCannon() > 0 then
			local pos2=self:LocalToWorld(v)
			local num = 1
			local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
			gred.CreateBullet(Driver,pos2,ang,"wac_base_20mm",self.FILTER,nil,false,self:UpdateTracers_Cannon(),50)
			local effectdata = EffectData()
			effectdata:SetOrigin(pos2)
			effectdata:SetAngles(ang)
			effectdata:SetEntity(self)
			util.Effect("gred_particle_aircraft_muzzle",effectdata)
		end
	end
	self.NextCannon = ct + 0.08 
	self:TakeCannonAmmo(#self.CannonPos)
end

function ENT:TakeCannonAmmo(amount)
	amount = amount or 1
	self:SetAmmoCannon(math.max(self:GetAmmoCannon() - amount,0))
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimary( 0.067 ) -- MG13 RPM
	
	local Driver = self:GetDriver()
	local Tracer_MG13 = self:UpdateTracers_MG13()
	for k,v in pairs (self.BulletPos) do
		local pos2=self:LocalToWorld(v)
		local num = 0.3
		local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
		gred.CreateBullet(Driver,pos2,ang,"wac_base_12mm",self.FILTER,nil,false,Tracer_MG13,40)
		self:TakePrimaryAmmo()

		local effectdata = EffectData()
		effectdata:SetOrigin(pos2)
		effectdata:SetAngles(ang)
		effectdata:SetEntity(self)
		util.Effect("gred_particle_aircraft_muzzle",effectdata)
	end
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
	if self:GetAI() then return end
	if not self:CanSecondaryAttack() then return end
	
	self:SetNextSecondary( 0.1 )

	self:TakeSecondaryAmmo()
	
	if istable( self.MissileEnts ) then
		local Missile = self.MissileEnts[ self:GetAmmoSecondary() + 1 ]
		-- Missile:EmitSound( "npc/waste_scanner/grenade_fire.wav" )
		if IsValid( Missile ) then
			local ent = ents.Create( "gb_rocket_nebel" )
			local mPos = Missile:GetPos()
			local Ang = self:WorldToLocal( mPos ).y > 0 and -1 or 1
			ent:SetPos( mPos )
			ent.IsOnPlane = true
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