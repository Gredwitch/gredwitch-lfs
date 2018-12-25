
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName ) -- called by garry
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 100 )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:OnTick() -- use this instead of "think"
	local hp = self:GetHP()
	if hp <= 350 then self:SetSkin(1) else self:SetSkin(0) end
	local ammo = self:GetAmmoSecondary()
	local loadout = self:GetLoadout()
	if ammo == 0 and self.Bombs then
		for k,v in pairs(self.Bombs) do
			if IsValid(v) then v:Remove() end
		end
		self.Bombs = nil
	end
	if not self.Firing then
		if loadout == 3 then
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,4)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			if ammo > 4 then
				self:SetAmmoSecondary(4)
			end
			self:SetBodygroup(2,1)
			self:SetBodygroup(3,1)
			self:SetBodygroup(4,1)
			self:SetBodygroup(5,1)
		elseif loadout == 4 then
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,2)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			if ammo > 2 then
				self:SetAmmoSecondary(2)
			end
			self:SetBodygroup(2,0)
			self:SetBodygroup(3,1)
			self:SetBodygroup(4,1)
			self:SetBodygroup(5,0)
		elseif loadout == 2 then
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,30)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			if ammo > 30 then
				self:SetAmmoSecondary(30)
			end
			self:SetBodygroup(2,0)
			self:SetBodygroup(3,1)
			self:SetBodygroup(4,1)
			self:SetBodygroup(5,0)
		elseif loadout == 1 then
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,28)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			if ammo > 28 then
				self:SetAmmoSecondary(28)
			end
			self:SetBodygroup(2,0)
			self:SetBodygroup(3,0)
			self:SetBodygroup(4,0)
			self:SetBodygroup(5,0)
		elseif loadout == 0 then
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,10)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			if ammo > 10 then
				self:SetAmmoSecondary(10)
			end
			self:SetBodygroup(2,0)
			self:SetBodygroup(3,0)
			self:SetBodygroup(4,0)
			self:SetBodygroup(5,0)
		end
	end
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
		if n == 3 then
			for k,v in pairs(self.BOMBS) do
				if k < 5 and (b && k <= b) then
					local bomb = ents.Create("gb_bomb_sc250")
					bomb.IsOnPlane = true
					bomb:SetPos(self:LocalToWorld(v))
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
			end
		elseif n == 4 then
			for k,v in pairs(self.BOMBS) do
				if k < 3 and (b && k <= b) then
					local bomb = ents.Create("gb_bomb_sc500")
					bomb.IsOnPlane = true
					bomb:SetPos(self:LocalToWorld(v))
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
			end
		elseif n == 2 then
			for k,v in pairs(self.BOMBS) do
				if (b && k <= b) or true then
					if k < 3 then
						local bomb = ents.Create("gb_bomb_sc250")
						bomb.IsOnPlane = true
						bomb:SetPos(self:LocalToWorld(v))
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
					elseif k > 4 then
						local bomb = ents.Create("gb_bomb_sc100")
						bomb.IsOnPlane = true
						bomb:SetPos(self:LocalToWorld(v))
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
				end
			end
		elseif n == 1 then
			for k,v in pairs(self.BOMBS) do
				if (b && k <= b) or true then
					if k > 4 then
						local bomb = ents.Create("gb_bomb_sc100")
						bomb.IsOnPlane = true
						bomb:SetPos(self:LocalToWorld(v))
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
				end
			end
		elseif n == 0 then
			for k,v in pairs(self.BOMBS) do
				if (b && k <= b) or true then
					if k > 4 and k <= 14 then
						local bomb = ents.Create("gb_bomb_sc100")
						bomb.IsOnPlane = true
						bomb:SetPos(self:LocalToWorld(v))
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
				end
			end
		end
		if not b then self:SetAmmoSecondary(s) else self:SetAmmoSecondary(b) end
	end
end

function ENT:RunOnSpawn()
	self:SetGunnerSeat(self:AddPassengerSeat(Vector(173.908,11.1736,85.4852),Angle(0,90,0)))
	self:SetGunterSeat(self:AddPassengerSeat(Vector(200.354,-11.7944,69.0472),Angle(0,90,-130)))
	self:AddBombs(self:GetLoadout())
	-- self:AddPassengerSeat( Vector(-30,0,18), Angle(0,-90,0) )
end

function ENT:SetNextAltPrimary( delay )
	self.NextAltPrimary = CurTime() + delay
end

function ENT:SetNextAltPrimary1( delay )
	self.NextAltPrimary1 = CurTime() + delay
end

function ENT:CanAltPrimaryAttack()
	self.NextAltPrimary = self.NextAltPrimary or 0
	return self.NextAltPrimary < CurTime()
end
function ENT:CanAltPrimaryAttack1()
	self.NextAltPrimary1 = self.NextAltPrimary1 or 0
	return self.NextAltPrimary1 < CurTime()
end

function ENT:AltPrimaryAttack( Driver, Pod )
	if not self:CanAltPrimaryAttack() then return end
	
	if not IsValid( Pod ) then Pod = self:GetDriverSeat() end
	if not IsValid( Driver ) then Driver = Pod:GetDriver() end
	
	if not IsValid( Pod ) then return end
	if not IsValid( Driver ) then return end
	
	local EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() )
	local Forward = -self:GetForward()
	local Up = self:GetUp()
	
	local AimDirToForwardDir = math.deg( math.acos( math.Clamp( Forward:Dot( EyeAngles:Forward() ) ,-1,1) ) )
	local TooHigh = EyeAngles.p > 7
	if AimDirToForwardDir > 45 or TooHigh then self.NoTurretSound = true return else self.NoTurretSound = false end
	
	self:SetNextAltPrimary1( 0.057 )
	
	local MuzzlePos = self:LocalToWorld(Vector(147.039,0,123.762) + EyeAngles:Forward()*19)

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
	b.CustomDMG = true
	b.Damage=2
	b.Radius=70
	b.sequential=true
	b.npod=1
	b.gunRPM=1050
	b:Spawn()
	b:Activate()
	b.Filter = {self,self.Bombs,self.wheel_R,self.wheel_L,self.wheel_C}
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

function ENT:AltPrimaryAttack1( Driver, Pod )
	if not self:CanAltPrimaryAttack1() then return end
	
	if not IsValid( Pod ) then Pod = self:GetDriverSeat() end
	if not IsValid( Driver ) then Driver = Pod:GetDriver() end
	
	if not IsValid( Pod ) then return end
	if not IsValid( Driver ) then return end
	
	local EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() )
	local Forward = -self:GetForward()
	
	local AimDirToForwardDir = math.deg( math.acos( math.Clamp( Forward:Dot( EyeAngles:Forward() ) ,-1,1) ) )
	if AimDirToForwardDir > 50 then self.NoTurretSound1 = true return else self.NoTurretSound1 = false end
	
	self:SetNextAltPrimary1( 0.057 )
	
	local MuzzlePos = self:LocalToWorld(Vector(148.676,-11.2929,43.7199) + EyeAngles:Forward()*19)

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
	b.Filter = {self,self.Bombs,self.wheel_R,self.wheel_L,self.wheel_C}
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
	local Gunter = self:GetGunter()
	local HasGunter = IsValid( Gunter )
	local TurretSnd = false
	local TurretSnd1 = false
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
		if FireTurret then
			if not HasGunner then
				self:AltPrimaryAttack(Driver)
				TurretSnd = true
			end
			if not HasGunter then
				self:AltPrimaryAttack1(Driver)
				TurretSnd1 = true
			end
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
	if HasGunter then
		if Gunter:KeyDown( IN_ATTACK ) then
			self:AltPrimaryAttack1( Gunter, self:GetGunterSeat() )
			TurretSnd1 = true
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
	if self.NoTurretSound1 then
		if self.turret2 then
			self.turret2:Stop()
		end
	else
		if TurretSnd1 then
			self.turret2 = CreateSound(self,"JU87_MG15_LOOP")
			self.turret2:Play()
			self:CallOnRemove( "stop"..class.."sounds3", function( ent )
				if ent.turret2 then
					ent.turret2:Stop()
				end
			end)
		else
			if self.turret2 then
				self.turret2:Stop()
			end
			if self.OldTurret1Snd == true then
				self.turret2 = nil
				self:EmitSound("JU87_MG15_LASTSHOT")
			end
		end
	end
	self.OldTurretSnd = TurretSnd
	self.OldTurret1Snd = TurretSnd1
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
		local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
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
	self:EmitSound("JU88_START")
end

function ENT:OnEngineStopped()
	self:EmitSound("JU88_STOP")
end

function ENT:OnLandingGearToggled( bOn )
	-- self:EmitSound( "vehicles/tank_readyfire1.wav" )
	
	-- if bOn then
		-- [[ set bodygroup of landing gear down? ]]--
	-- else
		-- [[ set bodygroup of landing gear up? ]]--
	-- end
end

function ENT:HandleActive()
	local gPod = self:GetGunnerSeat()
	local gtPod = self:GetGunterSeat()
	
	if IsValid( gPod ) then
		local Gunner = gPod:GetDriver()
		
		if Gunner ~= self:GetGunner() then
			self:SetGunner( Gunner )
			
			if IsValid( Gunner ) then
				Gunner:CrosshairEnable() 
			end
		end
	end
	if IsValid( gtPod ) then
		local Gunter = gtPod:GetDriver()
		
		if Gunter ~= self:GetGunner() then
			self:SetGunter( Gunter )
			
			if IsValid( Gunter ) then
				Gunter:CrosshairEnable() 
			end
		else
			self:SetGunter(nil)
		end
	end
	local Pod = self:GetDriverSeat()
	
	if not IsValid( Pod ) then
		self:SetActive( false )
		return
	end
	
	local Driver = Pod:GetDriver()
	local Active = self:GetActive()
	
	if Driver ~= self:GetDriver() then
		if self.HideDriver then
			if IsValid( self:GetDriver() ) then
				self:GetDriver():SetNoDraw( false )
			end
			if IsValid( Driver ) then
				Driver:SetNoDraw( true )
			end
		end
		
		self:SetDriver( Driver )
		self:SetActive( IsValid( Driver ) )
		
		if Active then
			self:EmitSound( "vehicles/atv_ammo_close.wav" )
		else
			self:EmitSound( "vehicles/atv_ammo_open.wav" )
		end
	end
	
	local Time = CurTime()
	
	self.NextSetInertia = self.NextSetInertia or 0
	
	if self.NextSetInertia < Time then
		local inea = Active or self:GetEngineActive() or (self:GetStability() > 0.1) or not self:HitGround()
		local TargetInertia = inea and self.Inertia or self.LFSInertiaDefault
		
		self.NextSetInertia = Time + 1 -- !!!hack!!! reset every second. There are so many factors that could possibly break this like touching the planes with the physgun which sometimes causes ent:GetInertia() to return a wrong value?!?!
		
		local PObj = self:GetPhysicsObject()
		if IsValid( PObj ) then
			PObj:SetMass( self.Mass ) -- !!!hack!!!
			PObj:SetInertia( TargetInertia ) -- !!!hack!!!
		end
	end
end

function ENT:Explode()
	if self.ExplodedAlready then return end
	
	self.ExplodedAlready = true
	
	local Driver = self:GetDriver()
	local Gunner = self:GetGunner()
	local Gunter = self:GetGunter()
	
	if IsValid( Driver ) then
		Driver:TakeDamage( 200, self.FinalAttacker or Entity(0), self.FinalInflictor or Entity(0) )
	end
	
	if IsValid( Gunner ) then
		Gunner:TakeDamage( 200, self.FinalAttacker or Entity(0), self.FinalInflictor or Entity(0) )
	end
	
	if IsValid( Gunter ) then
		Gunter:TakeDamage( 200, self.FinalAttacker or Entity(0), self.FinalInflictor or Entity(0) )
	end
	
	if istable( self.pSeats ) then
		for _, pSeat in pairs( self.pSeats ) do
			if IsValid( pSeat ) then
				local psgr = pSeat:GetDriver()
				if IsValid( psgr ) then
					psgr:TakeDamage( 200, self.FinalAttacker or Entity(0), self.FinalInflictor or Entity(0) )
				end
			end
		end
	end
	
	local ent = ents.Create( "lunasflightschool_destruction" )
	if IsValid( ent ) then
		ent:SetPos( self:GetPos() + Vector(0,0,100) )
		ent.GibModels = self.GibModels
		
		ent:Spawn()
		ent:Activate()
	end
	
	self:Remove()
end

