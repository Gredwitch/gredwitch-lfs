
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")
local Tracer_MG17 = false
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
local Tracer_MG17_gunner = false
local tracer_mg17_gunner = 0
function ENT:UpdateTracers_MG17_gunner()
	tracer_mg17_gunner = tracer_mg17_gunner + 1
	if tracer_mg17_gunner >= self.TracerConvar:GetInt() then
		tracer_mg17_gunner = 0
		return "green"
	else
		return false
	end
end

function ENT:SpawnFunction( ply, tr, ClassName ) -- called by garry
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 100 )
	ent:Spawn()
	ent:Activate()
	ent:SetSkin(math.random(0,11))
	return ent
end

function ENT:HandleLandingGear()
	local Driver = self:GetDriver()
	
	if IsValid( Driver ) then
		local KeyJump = Driver:KeyDown( IN_JUMP )
		
		if self.OldKeyJump ~= KeyJump then
			self.OldKeyJump = KeyJump
			if KeyJump then
				self:ToggleLandingGear()
				self:PhysWake()
			end
		end
	end
	
	local TValAuto = (self:GetStability() > 0.3) and 0 or 1
	local TValManual = self.LandingGearUp and 0 or 1
	
	local TVal = self.WheelAutoRetract and TValAuto or TValManual
	local Speed = FrameTime()
	local Speed2 = Speed * math.abs( math.cos( math.rad( self:GetLGear() * 180 ) ) )
	
	self:SetLGear( self:GetLGear() + math.Clamp(TVal - self:GetLGear(),-Speed,Speed) )
	self:SetRGear( self:GetRGear() + math.Clamp(TVal - self:GetRGear(),-Speed2,Speed2) )
	
	if IsValid( self.wheel_R ) then
		local RWpObj = self.wheel_R:GetPhysicsObject()
		if IsValid( RWpObj ) then
			RWpObj:SetMass( 1 + (self.WheelMass - 1) * 1 ^ 5 )
		end
	end
	
	if IsValid( self.wheel_L ) then
		local LWpObj = self.wheel_L:GetPhysicsObject()
		if IsValid( LWpObj ) then
			LWpObj:SetMass( 1 + (self.WheelMass - 1) * 1 ^ 5 )
		end
	end
	
	if IsValid( self.wheel_C ) then
		local CWpObj = self.wheel_C:GetPhysicsObject()
		if IsValid( CWpObj ) then
			CWpObj:SetMass( 1 + (self.WheelMass - 1) * 1 )
		end
	end
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
	local ammo = self:GetAmmoSecondary()
	local loadout = self:GetLoadout()
	if ammo == 0 and self.Bombs then
		for k,v in pairs(self.Bombs) do
			if IsValid(v) then v:Remove() end
		end
		self.Bombs = nil
	end
	if not self.Firing then
		if loadout == 0 then -- 1xSC250
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,1)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			self:SetBodygroup(1,2)
			self:SetBodygroup(2,1)
			self:SetBodygroup(3,2)
			self:SetBodygroup(4,0)
			if ammo > 1 then
				self:SetAmmoSecondary(1)
			end
		elseif loadout == 1 then -- 1xSC250 + 4xSC100
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			if ammo > 5 then
				self:SetAmmoSecondary(5)
			end
			self:SetBodygroup(1,2)
			self:SetBodygroup(2,1)
			self:SetBodygroup(3,1)
			self:SetBodygroup(4,0)
		elseif loadout == 3 then -- 1xSC500
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,1)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			self:SetBodygroup(1,2)
			self:SetBodygroup(2,1)
			self:SetBodygroup(3,2)
			self:SetBodygroup(4,0)
			if ammo > 1 then
				self:SetAmmoSecondary(1)
			end
		elseif loadout == 2 then -- 3xSC250
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,3)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			if ammo > 3 then
				self:SetAmmoSecondary(3)
			end
			self:SetBodygroup(1,2)
			self:SetBodygroup(2,1)
			self:SetBodygroup(3,0)
			self:SetBodygroup(4,0)
		elseif loadout == 4 then -- 5xSC100 + 1xSC500
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,6)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			self:SetBodygroup(1,2)
			self:SetBodygroup(2,1)
			self:SetBodygroup(3,1)
			self:SetBodygroup(4,0)
			if ammo > 6 then
				self:SetAmmoSecondary(6)
			end
		elseif loadout == 5 then -- 2xSC250 + 1xSC500
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,3)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			if ammo > 3 then
				self:SetAmmoSecondary(3)
			end
			self:SetBodygroup(1,2)
			self:SetBodygroup(2,1)
			self:SetBodygroup(3,0)
			self:SetBodygroup(4,0)
		elseif loadout == 6 then -- 3xSC500
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,3)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			if ammo > 3 then
				self:SetAmmoSecondary(3)
			end
			self:SetBodygroup(1,2)
			self:SetBodygroup(2,1)
			self:SetBodygroup(3,0)
			self:SetBodygroup(4,0)
		elseif loadout == 7 then -- 1xSC1000
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,1)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			if ammo > 1 then
				self:SetAmmoSecondary(1)
			end
			self:SetBodygroup(1,2)
			self:SetBodygroup(2,1)
			self:SetBodygroup(3,0)
			self:SetBodygroup(4,0)
		elseif loadout == 8 then -- 1xSC1000 + 4xSC100
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,5)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			if ammo > 5 then
				self:SetAmmoSecondary(5)
			end
			self:SetBodygroup(1,2)
			self:SetBodygroup(2,1)
			self:SetBodygroup(3,1)
			self:SetBodygroup(4,0)
		elseif loadout == 9 then -- 1xSC1000 + 2xSC250
			if not (self.OldLoadout == loadout) then
				self:AddBombs(loadout,3)
			else
				if ammo != self.OldSecAmmo then
					self:AddBombs(loadout,ammo)
				end
			end
			if ammo > 3 then
				self:SetAmmoSecondary(3)
			end
			self:SetBodygroup(1,2)
			self:SetBodygroup(2,1)
			self:SetBodygroup(3,0)
			self:SetBodygroup(4,0)
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
		if n == 0 then
			local bomb = ents.Create("gb_bomb_sc250")
			bomb.IsOnPlane = true
			bomb:SetPos(self:LocalToWorld(self.BOMBS[5]))
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
		elseif n == 3 then
			local bomb = ents.Create("gb_bomb_sc500")
			bomb.IsOnPlane = true
			bomb:SetPos(self:LocalToWorld(self.BOMBS[5]))
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
		elseif n == 7 then
			local bomb = ents.Create("gb_bomb_sc1000")
			bomb.IsOnPlane = true
			bomb:SetPos(self:LocalToWorld(self.BOMBS[5]))
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
			for k,v in pairs( self.BOMBS ) do
				if b != nil then -- if there is no B
					if k <= b then -- k should never be > b
						if k != 5 then -- if its not the 250Kg bomb
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
						else
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
				else
					if k != 5 then -- if its not the 250Kg bomb
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
					else
						local bomb = ents.Create("gb_bomb_sc250")
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
		elseif n == 8 then
			for k,v in pairs( self.BOMBS ) do
				if b != nil then -- if there is no B
					if k <= b then -- k should never be > b
						if k != 5 then -- if its not the 250Kg bomb
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
						else
							local bomb = ents.Create("gb_bomb_sc1000")
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
				else
					if k != 5 then -- if its not the 250Kg bomb
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
					else
						local bomb = ents.Create("gb_bomb_sc1000")
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
		elseif n == 4 then
			for k,v in pairs( self.BOMBS ) do
				if b != nil then -- if there is no B
					if k <= b then -- k should never be > b
						if k != 5 then -- if its not the 250Kg bomb
							local bomb = ents.Create("gb_bomb_sc100")
							bomb.IsOnPlane = true
							if k == 6 then
								bomb:SetPos(self:LocalToWorld(self.BOMBS[5]))
							else
								bomb:SetPos(self:LocalToWorld(v))
							end
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
						else
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
				else
					if k != 5 then -- if its not the 250Kg bomb
						local bomb = ents.Create("gb_bomb_sc100")
						bomb.IsOnPlane = true
						if k == 6 then
							bomb:SetPos(self:LocalToWorld(self.BOMBS[5]))
						else
							bomb:SetPos(self:LocalToWorld(v))
						end
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
					else
						local bomb = ents.Create("gb_bomb_sc250")
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
		elseif n == 6 then
			for k,v in pairs( self.BOMBS ) do
				if b != nil then -- if there is no B
					if k == 5 or k == 6 or k == 7 then
						print(k)
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
			end
		elseif n == 2 then
			for k,v in pairs( self.BOMBS ) do
				if b != nil then -- if there is no B
					if k == 5 or k == 6 or k == 7 then
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
			end
		elseif n == 5 then
			for k,v in pairs( self.BOMBS ) do
				if b != nil then -- if there is no B
					if k == 5 or k == 6 or k == 7 then
						local bomb
						if k == 5 then
							bomb = ents.Create("gb_bomb_sc500")
						else
							bomb = ents.Create("gb_bomb_sc250")
						end
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
		elseif n == 9 then
			for k,v in pairs( self.BOMBS ) do
				if b != nil then -- if there is no B
					if k == 5 or k == 6 or k == 7 then
						local bomb
						if k == 5 then
							bomb = ents.Create("gb_bomb_sc1000")
						else
							bomb = ents.Create("gb_bomb_sc250")
						end
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
		self:SetAmmoSecondary(s)
	end
end

function ENT:RunOnSpawn()
	
	self.MUZZLEEFFECT = table.KeyFromValue(gred.Particles,"muzzleflash_bar_3p")
	self.TracerConvar = GetConVar("gred_sv_tracers")
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
	Tracer_MG17_gunner = self:UpdateTracers_MG17_gunner()
	for k,v in pairs(self.TurretMuzzle) do
		local MuzzlePos = self:LocalToWorld(v + EyeAngles:Forward()*20)
		
		local pos2=MuzzlePos
		local num = 0.3
		local ang = (EyeAngles + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
		gred.CreateBullet(Driver,pos2,ang,"wac_base_7mm",{self},nil,false,Tracer_MG17_gunner,15)
		local effectdata = EffectData()
		effectdata:SetFlags(self.MUZZLEEFFECT)
		effectdata:SetOrigin(pos2)
		effectdata:SetAngles(ang)
		effectdata:SetSurfaceProp(0)
		util.Effect("gred_particle_simple",effectdata)
	end
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
			self.turret1 = CreateSound(self,"JU87_MG81Z_LOOP")
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
	self:SetNextPrimary( 0.052 )
	
	local Driver = self:GetDriver()
	Tracer_mg17 = self:UpdateTracers_MG17()
	for k,v in pairs (self.BulletPos) do
		local pos2=self:LocalToWorld(v)
		local num = 0.3
		local locaang = Angle(-0.5,(v.y > 0 and -1 or 1),0)
		local ang = (self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num))) + 
		locaang
		gred.CreateBullet(Driver,pos2,ang,"wac_base_7mm",{self},nil,false,Tracer_mg17,20)
		self:TakePrimaryAmmo()

		local effectdata = EffectData()
		effectdata:SetOrigin(pos2)
		effectdata:SetAngles(ang)
		effectdata:SetEntity(self)
		util.Effect("gred_particle_aircraft_muzzle",effectdata)
	end
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