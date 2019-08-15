
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
local Tracer_cannon = false
local Tracer_MG15 = false
local Tracer_MG17 = false
local tracer_mg17 = 0
local tracer_mg15 = 0
function ENT:UpdateTracers_MG15()
	tracer_mg15 = tracer_mg15 + 1
	if tracer_mg15 >= self.TracerConvar:GetInt() then
		tracer_mg15 = 0
		return "white"
	else
		return false
	end
end
function ENT:UpdateTracers_MG17()
	tracer_mg17 = tracer_mg17 + 1
	if tracer_mg17 >= self.TracerConvar:GetInt() then
		tracer_mg17 = 0
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
	gred.HandleLandingGear(self,"gears")
	gred.PartThink(self,skin)
	local loadout = self:GetLoadout()
	if loadout == 1 then
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
		self:SetBodygroup(3,0) -- 15mm R1
		self:SetBodygroup(1,0)
	elseif loadout == 0 then
		if self.MissileEnts then
			for k,v in pairs(self.MissileEnts) do
				v:SetColor(Hidden)
			end
		end
		if not (self.OldLoadout == loadout) then
			self:SetAmmoSecondary(500)
		end
		-- if ammo != self.OldSecAmmo then
			-- self:SetAmmoSecondary(ammo)
		-- end
		self:SetBodygroup(1,1)
		self:SetBodygroup(3,1) -- 15mm R1
	end
	self.OldLoadout = loadout
	self.OldSecAmmo = ammo
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
	local secammo = self:GetAmmoSecondary()
	if self.Parts.wing_l then
		self.Parts.wing_l:SetBodygroup(1,1)
		self.Parts.wing_l:SetBodygroup(2,loadout == 0 and 2 or 1)
	else
		if !self.WING_L_UPDATED then
			self.WING_L_UPDATED = true
			self.CannonPos[2] = nil
			self.R1Pos[2] = nil
			self.R1Pos[3] = nil
			self.AmmoCannon = self.WING_R_UPDATED and 0 or self.AmmoCannon / 2
			self.MaxSecondaryAmmo = self.WING_R_UPDATED and 0 or self.MaxSecondaryAmmo / 2
			secammo = self.WING_R_UPDATED and 0 or secammo / 2
			cannon = self.WING_R_UPDATED and 0 or cannon / 2
			self.MISSILES[1][2] = nil
			self:SetAmmoCannon(cannon)
			self:SetAmmoSecondary(secammo)
		end
	end
	if self.Parts.wing_r then
		self.Parts.wing_r:SetBodygroup(1,1)
		self.Parts.wing_r:SetBodygroup(2,loadout == 0 and 2 or 1)
	else
		if !self.WING_R_UPDATED then
			self.WING_R_UPDATED = true
			self.CannonPos[1] = nil
			self.R1Pos[1] = nil
			self.R1Pos[4] = nil
			self.AmmoCannon = self.WING_L_UPDATED and 0 or self.AmmoCannon / 2
			self.MaxSecondaryAmmo = self.WING_L_UPDATED and 0 or self.MaxSecondaryAmmo / 2
			cannon = self.WING_L_UPDATED and 0 or cannon / 2
			secammo = self.WING_L_UPDATED and 0 or secammo / 2
			self.MISSILES[1][1] = nil
			self:SetAmmoCannon(cannon)
			self:SetAmmoSecondary(secammo)
		end
	end
	
	if cannon > self.AmmoCannon then self:SetAmmoPrimary(self.AmmoCannon) end
	if secammo > self.MaxSecondaryAmmo then self:SetAmmoSecondary(self.MaxSecondaryAmmo) end
	if loadout == 1 then
		if ((self.WING_L_UPDATED or self.WING_R_UPDATED) and secammo > 1) then self:SetAmmoSecondary(1) end
	end
end

function ENT:CalcFlightOverride( Pitch, Yaw, Roll, Stability )
	return gred.PartCalcFlight(self,Pitch,Yaw,Roll,Stability,1,0.2)
end

function ENT:RunOnSpawn()
	Hidden = Color(255,255,255,0)
	Shown = Color(255,255,255,255)
	self.TracerConvar = GetConVar("gred_sv_tracers")
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
	local sec = self:GetAmmoSecondary()
	local loadout = self:GetLoadout()
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
	if Fire2 and loadout == 0 then
		if sec > 0 then
			self:SecondaryAttack()
			stopsec = false
			SECSnd = true
		else
			SECSnd = false
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
				if self.wpn3 then
					self.wpn3:Stop()
				end
				
				self.wpn1 = nil
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
	if !(sec > 0) and loadout == 0 then
		if self.wpn4 then
			self.wpn4:Stop()
		end
		self.wpn4 = nil
		if !stopsec then
			self:EmitSound( "FW190_FIRE_LASTSHOT" )
			stopsec = true
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
			if loadout == 0 then
				if SECSnd then
					if sec > 0 then
						self.wpn4 = CreateSound( self, "FW190_FIRE_LOOP" )
						self.wpn4:Play()
					else
						if self.wpn4 then
							self.wpn4:Stop()
						end
						self.wpn4 = nil
						self:EmitSound( "FW190_FIRE_LASTSHOT" )
					end
					self:CallOnRemove( "stopmesounds4", function( ent )
						if ent.wpn4 then
							ent.wpn4:Stop()
						end
					end)
				end
			else
				self:SecondaryAttack()
			end
		else
			if loadout == 0 then
				if self.OldFire2 == true then
					if self.wpn4 then
						self.wpn4:Stop()
					end
					
					if SECSnd then
						self:EmitSound( "FW190_FIRE_LASTSHOT" )
					end
				end
			end
		end
		self.OldFire2 = Fire2
	end
end

function ENT:GetMaxAmmoCannon()
	return self.AmmoCannon
end

function ENT:FireCannons()
	local ct = CurTime()
	if self.NextCannon < ct and self:GetAmmoCannon() > 0 then
		local Driver = self:GetDriver() 
		Tracer_cannon = self:UpdateTracers_Cannon()
		local num = 1
		for k,v in pairs (self.CannonPos) do
			local pos2 = self:LocalToWorld(v)
			local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
			gred.CreateBullet(Driver,pos2,ang,"wac_base_20mm",self.FILTER,nil,false,Tracer_cannon)
			if (k == 2) then self.NextCannon = ct + 0.08 self:TakeCannonAmmo(2) end

			local effectdata = EffectData()
			effectdata:SetOrigin(pos2)
			effectdata:SetAngles(ang)
			effectdata:SetEntity(self)
			util.Effect("gred_particle_aircraft_muzzle",effectdata)
		end
	end
end

function ENT:TakeCannonAmmo(amount)
	amount = amount or 1
	self:SetAmmoCannon(math.max(self:GetAmmoCannon() - amount,0))
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimary( 0.052 ) -- MG17 RPM
	
	local Driver = self:GetDriver()
	local Tracer_MG17 = self:UpdateTracers_MG17()
	local num = 0.3
	for k,v in pairs (self.BulletPos) do
		local pos2=self:LocalToWorld(v)
		local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
		gred.CreateBullet(Driver,pos2,ang,"wac_base_7mm",self.FILTER,nil,false,Tracer_MG17,20)
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
	
	local driver = self:GetDriver()
	if self:GetLoadout() == 1 then
		if self:GetAI() then return end
		if istable( self.MissileEnts ) then
			self:TakeSecondaryAmmo()
			self:SetNextSecondary( 0.4 )
			local Missile = self.MissileEnts[ self:GetAmmoSecondary() + 1 ]
			-- Missile:EmitSound( "npc/waste_scanner/grenade_fire.wav" )
			if IsValid( Missile ) then
				local ent = ents.Create( "gb_rocket_nebel" )
				local mPos = Missile:GetPos()
				local Ang = self:WorldToLocal( mPos ).y > 0 and -1 or 1
				ent:SetPos( mPos )
				ent:SetAngles( self:LocalToWorldAngles( Angle(0,Ang,0) ) )
				ent.IsOnPlane = true
				ent:Spawn()
				ent:Activate()
				ent:SetOwner(driver)
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
	else
		self:SetNextSecondary( 0.08 )
		local Tracer_MG15 = self:UpdateTracers_MG15()
		for k,v in pairs (self.R1Pos) do
			local pos2=self:LocalToWorld(v)
			local num = 0.5
			local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
			gred.CreateBullet(driver,pos2,ang,"wac_base_12mm",self.FILTER,nil,false,Tracer_MG15,25)

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