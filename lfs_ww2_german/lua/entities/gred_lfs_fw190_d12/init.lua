
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
	local loadout = self:GetLoadout()
	if loadout == 1 then
		if self.OldLoadout == loadout then
			
		else
			self:SetAmmoSecondary(2)
		end
		self:SetBodygroup(1,0)
	else
		self:SetAmmoSecondary(0)
		self:SetBodygroup(1,1)
	end
	self.OldLoadout = loadout
	self:SetBodygroup(2,0) -- MG FF
	self:SetBodygroup(3,0) -- 15mm R1
	self:SetBodygroup(4,0) -- Bomb pylon
	self:SetBodygroup(5,0) -- MG 17
	self:SetBodygroup(6,0) -- MG 151 / MG 17
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
			Fire1 = Driver:KeyDown( IN_ATTACK )
			FireCannons = Driver:KeyDown( IN_ATTACK )
		
		if self:GetAmmoSecondary() > 0 then
			Fire2 = Driver:KeyDown( IN_ATTACK2 )
		end
	end
	local pri = self:GetAmmoPrimary()
	local mgff = self:GetAmmoMGFF()
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
		if mgff > 0 then
			stopmgff = false
			MGFFSnd = true
		else
			MGFFSnd = false
		end
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
			if MGFFSnd then
				if mgff > 0 then
					self.wpn2 = CreateSound( self, "FW190_FIRE_LOOP" )
					self.wpn2:Play()
				else
					if self.wpn2 then
						self.wpn2:Stop()
					end
					self.wpn2 = nil
					self:EmitSound( "FW190_FIRE_LASTSHOT" )
				end
				self:CallOnRemove( "stopmesounds2", function( ent )
					if ent.wpn2 then
						ent.wpn2:Stop()
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
				if MGFFSnd then
					self:EmitSound( "FW190_FIRE_LASTSHOT" )
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
	if !(mgff > 0) then
		if self.wpn2 then
			self.wpn2:Stop()
		end
		self.wpn2 = nil
		if !stopmgff then
			self:EmitSound( "FW190_FIRE_LASTSHOT" )
			stopmgff = true
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

function ENT:GetMaxAmmoMGFF()
	return self.AmmoMGFF
end

function ENT:GetMaxAmmoCannon()
	return self.AmmoCannon
end

function ENT:FireCannons()
	local ct = CurTime()
	for k,v in pairs (self.CannonPos) do
		if ((k == 1 or k == 2) and self.NextCannon < ct and self:GetAmmoCannon() > 0) or 
		   ((k == 3 or k == 4) and self.NextMGFF < ct and self:GetAmmoMGFF() > 0) then
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
				if k == 4 then
					tracer = 0
				end
			else b.noTracer = true end
			tracerC = tracerC + 1
			if (k == 4) then self.NextMGFF = ct + 0.08 self:TakeMGFFAmmo(2) end
			if (k == 2) then self.NextCannon = ct + 0.08 self:TakeCannonAmmo(2) end
			net.Start("gred_net_wac_mg_muzzle_fx")
				net.WriteVector(pos2)
				net.WriteAngle(ang)
			net.Broadcast()
		end
	end
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
	self:SetNextPrimary( 0.067 ) -- MG17 RPM
	
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
		b.Caliber = "wac_base_12mm"
		b.Size=0
		b.Width=0
		b.Damage=40
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
		net.Start("gred_net_wac_mg_muzzle_fx")
			net.WriteVector(pos2)
			net.WriteAngle(ang)
		net.Broadcast()
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

function ENT:InitWheels() -- Add front wheels
	if not IsValid( self.wheel_L ) then
		local wheel_L = ents.Create( "prop_physics" )
		
		if IsValid( wheel_L ) then
			wheel_L:SetPos( self:LocalToWorld( self.WheelPos_L ) )
			wheel_L:SetAngles( self:LocalToWorldAngles( Angle(0,90,0) ) )
			
			wheel_L:SetModel( "models/props_vehicles/tire001c_car.mdl" )
			wheel_L:Spawn()
			wheel_L:Activate()
			
			wheel_L:SetNoDraw( true )
			wheel_L:DrawShadow( false )
			wheel_L.DoNotDuplicate = true
			
			local radius = self.WheelRadius
			
			wheel_L:PhysicsInitSphere( radius, "jeeptire" )
			wheel_L:SetCollisionBounds( Vector(-radius,-radius,-radius), Vector(radius,radius,radius) )
			
			local LWpObj = wheel_L:GetPhysicsObject()
			if not IsValid( LWpObj ) then
				self:Remove()
				
				print("LFS: Failed to initialize landing gear phys model. Plane terminated.")
				return
			end
		
			LWpObj:EnableMotion(false)
			LWpObj:SetMass( self.WheelMass )
			
			self.wheel_L = wheel_L
			self:DeleteOnRemove( wheel_L )
			self:dOwner( wheel_L )
			
			constraint.Axis( wheel_L, self, 0, 0, LWpObj:GetMassCenter(), wheel_L:GetPos(), 0, 0, 50, 0, Vector(1,0,0) , false )
			constraint.NoCollide( wheel_L, self, 0, 0 ) 
			
			LWpObj:EnableMotion( true )
			--LWpObj:EnableDrag( false ) 
			
		else
			self:Remove()
		
			print("LFS: Failed to initialize landing gear. Plane terminated.")
		end
	end
	
	if not IsValid( self.wheel_R ) then
		local wheel_R = ents.Create( "prop_physics" )
		
		if IsValid( wheel_R ) then
			wheel_R:SetPos( self:LocalToWorld(  self.WheelPos_R ) )
			wheel_R:SetAngles( self:LocalToWorldAngles( Angle(0,90,0) ) )
			
			wheel_R:SetModel( "models/props_vehicles/tire001c_car.mdl" )
			wheel_R:Spawn()
			wheel_R:Activate()
			
			wheel_R:SetNoDraw( true )
			wheel_R:DrawShadow( false )
			wheel_R.DoNotDuplicate = true
			
			local radius = self.WheelRadius
			
			wheel_R:PhysicsInitSphere( radius, "jeeptire" )
			wheel_R:SetCollisionBounds( Vector(-radius,-radius,-radius), Vector(radius,radius,radius) )
			
			local RWpObj = wheel_R:GetPhysicsObject()
			if not IsValid( RWpObj ) then
				self:Remove()
				
				print("LFS: Failed to initialize landing gear phys model. Plane terminated.")
				return
			end
		
			RWpObj:EnableMotion(false)
			RWpObj:SetMass( self.WheelMass )
			
			self.wheel_R = wheel_R
			self:DeleteOnRemove( wheel_R )
			self:dOwner( wheel_R )
			
			constraint.Axis( wheel_R, self, 0, 0, RWpObj:GetMassCenter(), wheel_R:GetPos(), 0, 0, 50, 0, Vector(1,0,0) , false )
			constraint.NoCollide( wheel_R, self, 0, 0 ) 
			
			RWpObj:EnableMotion( true )
			--RWpObj:EnableDrag( false ) 
		else
			self:Remove()
		
			print("LFS: Failed to initialize landing gear. Plane terminated.")
		end
	end
	
	if not IsValid( self.wheel_F ) then
		local wheel_F = ents.Create( "prop_physics" )
		
		if IsValid( wheel_F ) then
			wheel_F:SetPos( self:LocalToWorld(  self.WheelPos_F ) )
			wheel_F:SetAngles( self:LocalToWorldAngles( Angle(0,90,0) ) )
			
			wheel_F:SetModel( "models/props_vehicles/tire001c_car.mdl" )
			wheel_F:Spawn()
			wheel_F:Activate()
			
			wheel_F:SetNoDraw( true )
			wheel_F:DrawShadow( false )
			wheel_F.DoNotDuplicate = true
			
			local radius = self.WheelRadius / 2
			
			wheel_F:PhysicsInitSphere( radius, "jeeptire" )
			wheel_F:SetCollisionBounds( Vector(-radius,-radius,-radius), Vector(radius,radius,radius) )
			
			local RWpObj = wheel_F:GetPhysicsObject()
			if not IsValid( RWpObj ) then
				self:Remove()
				
				print("LFS: Failed to initialize landing gear phys model. Plane terminated.")
				return
			end
		
			RWpObj:EnableMotion(false)
			RWpObj:SetMass( self.WheelMass + 300  )
			
			self.wheel_F = wheel_F
			self:DeleteOnRemove( wheel_F )
			self:dOwner( wheel_F )
			
			constraint.Axis( wheel_F, self, 0, 0, RWpObj:GetMassCenter(), wheel_F:GetPos(), 0, 0, 50, 0, Vector(1,0,0) , false )
			constraint.NoCollide( wheel_F, self, 0, 0 ) 
			
			RWpObj:EnableMotion( true )
			--RWpObj:EnableDrag( false ) 
		else
			self:Remove()
		
			print("LFS: Failed to initialize landing gear. Plane terminated.")
		end
	end
	
	local PObj = self:GetPhysicsObject()
	
	if IsValid( PObj ) then 
		PObj:EnableMotion( true )
	end
end

function ENT:OnLandingGearToggled( bOn )
	self:EmitSound( "lfs/bf109/gear.wav" )
end