
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName ) -- called by garry
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 10 ) -- spawn 20 units above ground
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:OnTick() -- use this instead of "think"
	local hp = self:GetHP()
	if hp <= 350 then self:SetSkin(3) else self:SetSkin(2) end
	local ammo = self:GetAmmoSecondary()
	local loadout = self:GetLoadout()
	if ammo == 0 and self.Bombs then
		for k,v in pairs(self.Bombs) do
			if IsValid(v) then v:Remove() end
		end
		self.Bombs = nil
	end
	if not self.Firing then
		if loadout == 0 then
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,5)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
		elseif loadout == 1 then
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,1)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
		elseif loadout == 2 then
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,1)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
		end
	end
	self:SetBodygroup(3,1)
	self.OldLoadout = loadout
	self.OldSecAmmo = ammo
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
		if n == 0 then
			local bomb = ents.Create("gb_bomb_sc250")
			bomb.IsOnPlane = true
			bomb:SetPos(self:LocalToWorld(self.BOMBS[1]))
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
		elseif n == 1 then
			local bomb = ents.Create("gb_bomb_sc500")
			bomb.IsOnPlane = true
			bomb:SetPos(self:LocalToWorld(self.BOMBS[1]))
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
		elseif n == 2 then
			local bomb = ents.Create("gb_bomb_sc1000")
			bomb.IsOnPlane = true
			bomb:SetPos(self:LocalToWorld(self.BOMBS[1]))
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
		self:SetAmmoSecondary(s)
	end
end

function ENT:RunOnSpawn()
	self:SetGunnerSeat(self:AddPassengerSeat(Vector(-43.7618,0,101.572),Angle(0,0,0)))
	self:AddBombs(self:GetLoadout())
	-- self:AddPassengerSeat( Vector(-30,0,18), Angle(0,-90,0) )
end

function ENT:SetNextAltPrimary( delay )
	self.NextAltPrimary = CurTime() + delay
end

function ENT:CanAltPrimaryAttack()
	self.NextAltPrimary = self.NextAltPrimary or 0
	return self.NextAltPrimary < CurTime()
end

function ENT:AltPrimaryAttack( Driver, Pod )
	if not self:CanAltPrimaryAttack() then return end
	
	if not IsValid( Pod ) then Pod = self:GetDriverSeat() end
	if not IsValid( Driver ) then Driver = Pod:GetDriver() end
	
	if not IsValid( Pod ) then return end
	if not IsValid( Driver ) then return end
	
	local EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() )
	local Forward = -self:GetForward()
	
	local AimDirToForwardDir = math.deg( math.acos( math.Clamp( Forward:Dot( EyeAngles:Forward() ) ,-1,1) ) )
	if AimDirToForwardDir > 25 then self.NoTurretSound = true return else self.NoTurretSound = false end
	
	self:SetNextAltPrimary( 0.057 )
	
	local MuzzlePos = self:LocalToWorld(Vector(-78.584,0,136) + EyeAngles:Right()*24)

	local pos2=MuzzlePos
	local num = 0.3
	local ang = (EyeAngles + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
	local b=ents.Create("gred_base_bullet")
	b:SetPos(pos2)
	b:SetAngles(ang)
	b.Speed=1000
	b.Caliber = "wac_base_7mm"
	b.Size=0
	b.Width=0
	b.Damage=40
	b.Radius=70
	b.sequential=true
	b.npod=1
	b.gunRPM=1050
	b:Spawn()
	b:Activate()
	b.Filter = {self,self.Bombs}
	b.Owner=Driver
	if !tracer then tracer = 0 end
	if tracer >= GetConVarNumber("gred_sv_tracers") then
		b:SetSkin(3)
		b:SetModelScale(20)
		tracer = 0
	else b.noTracer = true end
	net.Start("gred_net_explosion_fx")
		net.WriteString("muzzleflash_bar_3p")
		net.WriteVector(pos2)
		net.WriteAngle(ang)
		net.WriteBool(false)
	net.Broadcast()
	tracer = tracer + 1
end

function ENT:HandleWeapons(Fire1, Fire2)
	local Driver = self:GetDriver()
	local Gunner = self:GetGunner()
	local HasGunner = IsValid( Gunner )
	local TurretSnd = false
	local FireTurret = false
	local class = self:GetClass()
	
	if IsValid( Driver ) then
		if self:GetAmmoPrimary() > 0 then
			Fire1 = Driver:KeyDown( IN_ATTACK )
		end
		
		FireTurret = Driver:KeyDown( IN_WALK )
		
		if self:GetAmmoSecondary() > 0 then
			Fire2 = Driver:KeyDown( IN_ATTACK2 )
		end
		self.Firing = Fire2
	end
	
	if Fire1 then
		if FireTurret and not HasGunner then
			self:AltPrimaryAttack(Driver)
			TurretSnd = true
		else
			self:PrimaryAttack()
		end
	end
	
	if self.OldFire ~= Fire1 and not FireTurret then
		
		if Fire1 then
			self.wpn1 = CreateSound( self, "BF109_FIRE_LOOP" )
			self.wpn1:Play()
			self:CallOnRemove( "stop"..class.."sounds1", function( ent )
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
	
	if HasGunner then
		if Gunner:KeyDown( IN_ATTACK ) then
			self:AltPrimaryAttack( Gunner, self:GetGunnerSeat() )
			TurretSnd = true
		end
	end
	if self.NoTurretSound then
		if self.turret1 then
			self.turret1:Stop()
		end
	else
		if TurretSnd then
			self.turret1 = CreateSound(self,"JU87_MG15_LOOP")
			self.turret1:Play()
			self:CallOnRemove( "stop"..class.."sounds2", function( ent )
				if ent.turret1 then
					ent.turret1:Stop()
				end
			end)
		else
			if self.turret1 then
				self.turret1:Stop()
			end
			if self.OldTurretSnd == true then
				self.turret1 = nil
				self:EmitSound("JU87_MG15_LASTSHOT")
			end
		end
	end
	self.OldTurretSnd = TurretSnd
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

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimary( 0.052 )
	
	local Driver = self:GetDriver()
	for k,v in pairs (self.BulletPos) do
		local pos2=self:LocalToWorld(v)
		local num = 0.3
		local locaang = Angle(-0.5,(v.y > 0 and -1 or 1),0)
		local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num))) + 
		locaang
		local b=ents.Create("gred_base_bullet")
		b:SetPos(pos2)
		b:SetAngles(ang)
		b.Speed=1000
		b.Caliber = "wac_base_7mm"
		b.Size=0
		b.Width=0
		b.Damage=40
		b.Radius=70
		b.sequential=true
		b.npod=1
		b.gunRPM=1150
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
	
	self:SetNextSecondary( 0.1 )

	self:TakeSecondaryAmmo()
	local ammo = self:GetAmmoSecondary()
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

function ENT:CreateAI() -- called when the ai gets enabled
end

function ENT:RemoveAI() -- called when the ai gets disabled
end

function ENT:OnEngineStarted()
	self:EmitSound("JU87_START")
end

function ENT:OnEngineStopped()
	self:EmitSound("JU87_STOP")
end

function ENT:OnLandingGearToggled( bOn )
	-- self:EmitSound( "vehicles/tank_readyfire1.wav" )
	
	-- if bOn then
		-- [[ set bodygroup of landing gear down? ]]--
	-- else
		-- [[ set bodygroup of landing gear up? ]]--
	-- end
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
