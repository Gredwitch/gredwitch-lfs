
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
	local priAmmo = self:GetAmmoPrimary()
	local secAmmo = self:GetAmmoSecondary()
	if self.Parts.wing_l then
		self.Parts.wing_l:SetBodygroup(1,0)
		self.Parts.wing_l:SetBodygroup(2,0)
	else
		if !self.WING_L_UPDATED then
			self.WING_L_UPDATED = true
			self.BulletPos[4] = nil
			self.CannonPos[2] = nil
			self.MaxSecondaryAmmo = self.WING_R_UPDATED and 0 or self.MaxSecondaryAmmo / 2
			self.MaxPrimaryAmmo = self.MaxPrimaryAmmo - 950
			priAmmo = priAmmo - 950
			self:SetAmmoPrimary(priAmmo)
			secAmmo = self.WING_R_UPDATED and 0 or secAmmo / 2
			self:SetAmmoSecondary(secAmmo)
		end
	end
	if self.Parts.wing_r then
		self.Parts.wing_r:SetBodygroup(1,0)
		self.Parts.wing_r:SetBodygroup(2,0)
	else
		if !self.WING_R_UPDATED then
			self.WING_R_UPDATED = true
			self.BulletPos[3] = nil
			self.CannonPos[1] = nil
			self.MaxPrimaryAmmo = self.MaxPrimaryAmmo - 950
			priAmmo = priAmmo - 950
			self:SetAmmoPrimary(priAmmo)
			self.MaxSecondaryAmmo = self.WING_L_UPDATED and 0 or self.MaxSecondaryAmmo / 2
			secAmmo = self.WING_L_UPDATED and 0 or secAmmo / 2
			self:SetAmmoSecondary(secAmmo)
		end
	end
	if priAmmo > self.MaxPrimaryAmmo then self:SetAmmoPrimary(self.MaxPrimaryAmmo) end
	if secAmmo > self.MaxSecondaryAmmo then self:SetAmmoSecondary(self.MaxSecondaryAmmo) end
	self:SetBodygroup(1,0)
	self:SetBodygroup(2,0)
end

function ENT:RunOnSpawn()
	self.TracerConvar = GetConVar("gred_sv_tracers")
	
	if istable(self.BOMBS) then
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

function ENT:CalcFlightOverride( Pitch, Yaw, Roll, Stability )
	return gred.PartCalcFlight(self,Pitch,Yaw,Roll,Stability,1,0.2)
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
	local Tracer_MG17 = self:UpdateTracers_MG17()
	for k,v in pairs (self.BulletPos) do
		local pos2=self:LocalToWorld(v)
		local num = 0.3
		local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
		gred.CreateBullet(Driver,pos2,ang,"wac_base_7mm",self.FILTER,nil,false,Tracer_MG17,12)
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

function ENT:SecondaryAttack()
	-- if self:GetAI() then return end
	if not self:CanSecondaryAttack() then return end
	
	self:SetNextSecondary( 0.11 )
	
	local Driver = self:GetDriver()
	local ct = CurTime()
	local Tracer_MGFF = self:UpdateTracers_MGFF()
	for k,v in pairs (self.CannonPos) do
		local pos2=self:LocalToWorld(v)
		local num = 1
		local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
		gred.CreateBullet(Driver,pos2,ang,"wac_base_20mm",self.FILTER,nil,false,Tracer_MGFF)
		self:TakeSecondaryAmmo()
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