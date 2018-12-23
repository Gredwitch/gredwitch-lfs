
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName ) -- called by garry
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 100 )
	ent:Spawn()
	ent:Activate()
	ent:SetSkin(math.random(0,11))
	return ent
end

function ENT:OnTick() -- use this instead of "think"
	local hp = self:GetHP()
	local skin = self:GetSkin()
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
	self:SetBodygroup(1,2)
	self:SetBodygroup(2,2)
	self:SetBodygroup(3,2)
	self:SetBodygroup(4,2)
end

function ENT:RunOnSpawn()
	
	self:SetGunnerSeat(self:AddPassengerSeat(Vector(-69.0436,0,6),Angle(0,90,0)))
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
	if AimDirToForwardDir > 45 then self.NoTurretSound = true return else self.NoTurretSound = false end
	
	self:SetNextAltPrimary( 0.057 )
	for k,v in pairs(self.TurretMuzzle) do
		local MuzzlePos = self:LocalToWorld(v + EyeAngles:Forward()*20)
		
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
			if k == 2 then
				tracer = 0
			end
		else b.noTracer = true end
		net.Start("gred_net_explosion_fx")
			net.WriteString("muzzleflash_bar_3p")
			net.WriteVector(pos2)
			net.WriteAngle(ang)
			net.WriteBool(false)
		net.Broadcast()
	end
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
			self.turret1 = CreateSound(self,"JU87_MG81Z_LOOP")
			self.turret1:Play()
			self:CallOnRemove( "stop_"..class.."_sounds2", function( ent )
				if ent.turret1 then
					ent.turret1:Stop()
				end
			end)
		else
			if self.turret1 then
				self.turret1:Stop()
			end
			self.turret1 = nil
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
	self:SetNextPrimary( 0.375	)
	self:EmitSound("JU87_BK37")
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
		b.Caliber = "wac_base_40mm"
		b.Size=0
		b.Width=0
		b.CustomDMG = true
		b.Damage=307
		b.Radius=50
		b.sequential=true
		b.npod=1
		b.gunRPM=160
		b:Spawn()
		b:Activate()
		b.Filter = {self}
		b.Owner=Driver
		b:SetSkin(0)
		b:SetModelScale(20)
		self:TakePrimaryAmmo()
		net.Start("gred_net_explosion_fx")
			net.WriteString("gred_arti_muzzle_blast")
			net.WriteVector(pos2)
			net.WriteAngle(ang)
			net.WriteBool(false)
		net.Broadcast()
	end
end

function ENT:SecondaryAttack()
	if self:GetAI() then return end
	if not self:CanSecondaryAttack() then return end
	
	self:SetNextSecondary( 0.1 )

	-- self:TakeSecondaryAmmo()
	-- local ammo = self:GetAmmoSecondary()
	-- if istable( self.Bombs ) then
		-- local bomb = self.Bombs[ ammo + 1 ]
		-- table.remove(self.Bombs,ammo + 1)
		-- if IsValid( bomb ) then
			-- bomb:EmitSound( "npc/waste_scanner/grenade_fire.wav" )
			-- bomb:SetParent(nil)
			-- bomb.ShouldExplodeOnImpact = true
			-- bomb:SetOwner(self:GetDriver())
			-- local p = self:GetPhysicsObject() if IsValid(p) then bomb.phys:AddVelocity(p:GetVelocity()) end
			-- timer.Simple(0.01,function() if IsValid(bomb.phys) then bomb.phys:SetMass(bomb.Mass)  end end)
			-- timer.Simple(1, function()
				-- if IsValid(bomb) and IsValid(bomb.phys) then
					-- bomb.dropping=true
					-- bomb.Armed=true
					-- bomb:SetCollisionGroup(0)
				-- end
			-- end)
		-- end
	-- end
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
