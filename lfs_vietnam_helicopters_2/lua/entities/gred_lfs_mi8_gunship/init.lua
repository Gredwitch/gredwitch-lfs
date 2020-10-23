--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

ENT.rotorHP = 300
ENT.TailRotorPos = Vector(-492,25,148)

local BaseClass = baseclass.Get("lunasflightschool_basescript_heli")
function ENT:OnTakeDamage(dmginfo)
	BaseClass.OnTakeDamage(self,dmginfo)
	
	if self.TailEffectTime then return end
	
	local dist = self.TailRotorPos:Distance(self:WorldToLocal(dmginfo:GetDamagePosition()))
	if dist <= 70 then
		local dmg = dmginfo:GetDamage()
		self.rotorHP = self.rotorHP - dmg
		if self.rotorHP <= 100 then
			self.MaxYaw = 0
			self.TailEffectTime = CurTime()
			if !self.SoundPlayed and self:GetEngineActive() then
				self:EmitSound(self.CRASHSND)
				self.SoundPlayed = true
			end
		end
	end
end

function ENT:OnRemove()
	self:StopSound(self.CRASHSND)
	self:StopSound("MI8_START")
end

local tracer_1 = 0
function ENT:UpdateTracers_1()
	tracer_1 = tracer_1 + 1
	if tracer_1 >= self.TracerConvar:GetInt() then
		tracer_1 = 0
		return "green"
	else
		return false
	end
end

local tracer_2 = 0
function ENT:UpdateTracers_2()
	tracer_2 = tracer_2 + 1
	if tracer_2 >= self.TracerConvar:GetInt() then
		tracer_2 = 0
		return "green"
	else
		return false
	end
end

local tracer_3 = 0
function ENT:UpdateTracers_3()
	tracer_3 = tracer_2 + 1
	if tracer_3 >= self.TracerConvar:GetInt() then
		tracer_3 = 0
		return "green"
	else
		return false
	end
end

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 10 )
	ent:Spawn()
	ent:Activate()
	ent:SetSkin(math.random(0,3))
	return ent
end

function ENT:OnTick()
	for i = 1,5 do
		self:SetBodygroup(i,0)
	end
	
	local loadout = self:GetLoadout()
	if loadout == 0 then
		for i = 8,15 do
			self:SetBodygroup(i,0)
		end
		if loadout != self.OldLoadout then self:SetAmmoPrimary(self.MaxPrimaryAmmo) end
	elseif loadout == 1 then
		self:SetBodygroup(8,1)
		self:SetBodygroup(9,1)
		self:SetBodygroup(10,0)
		self:SetBodygroup(11,0)
		self:SetBodygroup(12,1)
		self:SetBodygroup(13,0)
		self:SetBodygroup(14,0)
		self:SetBodygroup(15,1)
		if loadout != self.OldLoadout then 
			self:SetAmmoPrimary(128)
		else
			if self:GetAmmoPrimary() > 128 then self:SetAmmoPrimary(128) end
		end
	elseif loadout == 2 then
		self:SetBodygroup(8,2)
		self:SetBodygroup(9,2)
		self:SetBodygroup(10,0)
		self:SetBodygroup(11,1)
		self:SetBodygroup(12,1)
		self:SetBodygroup(13,0)
		self:SetBodygroup(14,1)
		self:SetBodygroup(15,1)
		if loadout != self.OldLoadout then 
			self:SetAmmoPrimary(64)
		else
			if self:GetAmmoPrimary() > 64 then self:SetAmmoPrimary(64) end
		end
	
	end
	self.OldLoadout = loadout
	if self.TailEffectTime then
		if self:GetEngineActive() then
			local ct = CurTime()
			if self.TailEffectTime < ct then
				local effect = EffectData()
				effect:SetOrigin(self:LocalToWorld(self.TailRotorPos))
				effect:SetNormal(-self:GetRight())
				util.Effect("ManhackSparks",effect)
				self.TailEffectTime = ct + math.random(0.1,0.3)
			end
		end
		
		local RPM = self:GetRPM()
		local p = self:GetPhysicsObject()
		if IsValid(p) then
			local angvel = p:GetAngleVelocity()
			p:AddAngleVelocity(Vector(angvel.x > 100 and 0 or RPM*0.01,0,angvel.z > 200 and 0 or math.Clamp(RPM,0,2000)*0.04))
			local vel = p:GetVelocity()
			p:AddVelocity(Vector(0,0,vel.z < -600 and 0 or -RPM*0.005))
		end
	end
end

function ENT:RunOnSpawn()
	self.CRASHSND = "HELICOPTER_CRASHING_"..math.random(1,10)
	self.MUZZLEEFFECT = table.KeyFromValue(gred.Particles,"muzzleflash_bar_3p")
	self.TracerConvar = GetConVar("gred_sv_tracers")
	self:AddPassengerSeat( Vector(150,23.792,50),Angle(0,-90,0) )
	
	self:SetGunnerSeat(self:AddPassengerSeat( Vector(101.892,-22.6402,40), Angle(0,180,0) ))
	self:SetGunner2Seat(self:AddPassengerSeat( Vector(101.892,22.6402,40), Angle(0,0,0) ))
	self:SetGunner3Seat(self:AddPassengerSeat( Vector(-80,0,45), Angle(0,90,-60) ))
	
	self:AddPassengerSeat( Vector(59.7755,31.7511,47.5918), Angle(0,180,0) )
	self:AddPassengerSeat( Vector(59.7755,-31.7511,47.5918), Angle(0,0,0) )
	self:AddPassengerSeat( Vector(34.5218,31.7511,47.5918), Angle(0,180,0) )
	self:AddPassengerSeat( Vector(34.5218,-31.7511,47.5918), Angle(0,0,0) )
	self:AddPassengerSeat( Vector(0,31.7511,47.5918), Angle(0,180,0) )
	self:AddPassengerSeat( Vector(0,-31.7511,47.5918), Angle(0,0,0) )
	self:AddPassengerSeat( Vector(-20,31.7511,47.5918), Angle(0,180,0) )
	self:AddPassengerSeat( Vector(-20,-31.7511,47.5918), Angle(0,0,0) )
	self:AddPassengerSeat( Vector(-45,31.7511,47.5918), Angle(0,180,0) )
	self:AddPassengerSeat( Vector(-45,-31.7511,47.5918), Angle(0,0,0) )
	self:AddPassengerSeat( Vector(-72,31.7511,47.5918), Angle(0,180,0) )
	self:AddPassengerSeat( Vector(-72,-31.7511,47.5918), Angle(0,0,0) )
	-- self:AddPassengerSeat( Vector(,,), Angle(0,0,0) )
	
	self.wheel_C:Remove()
	self.wheel_C_master:Remove()
	if isvector( self.WheelPos_C ) then
		local SteerMaster = ents.Create( "prop_physics" )
		
		if IsValid( SteerMaster ) then
			SteerMaster:SetModel( "models/hunter/plates/plate025x025.mdl" )
			SteerMaster:SetPos( self:GetPos() )
			SteerMaster:SetAngles( Angle(0,90,0) )
			SteerMaster:Spawn()
			SteerMaster:Activate()
			
			local smPObj = SteerMaster:GetPhysicsObject()
			if IsValid( smPObj ) then
				smPObj:EnableMotion( false )
			end
			
			SteerMaster:SetOwner( self )
			SteerMaster:DrawShadow( false )
			SteerMaster:SetNotSolid( true )
			SteerMaster:SetNoDraw( true )
			SteerMaster.DoNotDuplicate = true
			self:DeleteOnRemove( SteerMaster )
			self:dOwner( SteerMaster )
			
			self.wheel_C_master = SteerMaster
			
			local wheel_C = ents.Create( "prop_physics" )
			
			if IsValid( wheel_C ) then
				wheel_C:SetPos( self:LocalToWorld( self.WheelPos_C ) )
				wheel_C:SetAngles( Angle(0,0,0) )
				
				wheel_C:SetModel( "models/props_vehicles/tire001c_car.mdl" )
				wheel_C:Spawn()
				wheel_C:Activate()
				
				wheel_C:SetNoDraw( true )
				wheel_C:DrawShadow( false )
				wheel_C.DoNotDuplicate = true
				
				local radius = 11
				
				wheel_C:PhysicsInitSphere( radius, "jeeptire" )
				wheel_C:SetCollisionBounds( Vector(-radius,-radius,-radius), Vector(radius,radius,radius) )
				
				local CWpObj = wheel_C:GetPhysicsObject()
				if not IsValid( CWpObj ) then
					self:Remove()
					
					print("LFS: Failed to initialize landing gear phys model. Plane terminated.")
					return
				end
			
				CWpObj:EnableMotion(false)
				CWpObj:SetMass(400)
				
				self.wheel_C = wheel_C
				self:DeleteOnRemove( wheel_C )
				self:dOwner( wheel_C )
				
				self:dOwner( constraint.AdvBallsocket(wheel_C, SteerMaster,0,0,Vector(0,0,0),Vector(0,0,0),0,0, -180, -0.01, -0.01, 180, 0.01, 0.01, 0, 0, 0, 1, 0) )
				self:dOwner( constraint.AdvBallsocket(wheel_C,self,0,0,Vector(0,0,0),Vector(0,0,0),0,0, -180, -180, -180, 180, 180, 180, 0, 0, 0, 0, 0) )
				self:dOwner( constraint.NoCollide( wheel_C, self, 0, 0 ) )
				
				CWpObj:EnableMotion( true )
				CWpObj:EnableDrag( false ) 
			end
		end
	end
end

function ENT:PrimaryAttack(loadout)
	if self:GetAI() then return end
	if not self:CanPrimaryAttack() then return end
	
	self:SetNextPrimary( 0.1 )
	self:TakePrimaryAmmo()
	
	if p == nil or p >  table.Count(self.MISSILES) or p == 0 then p = 1 end
	if loadout == 1 then
		if p >= 5 then p = 1 end
	elseif loadout == 2 then
		if p >= 3 then p = 1 end
	end
	local mpos = self:LocalToWorld(self.MISSILES[p])
	local Ang = self:WorldToLocal( mpos ).y > 0 and -1 or 1
	local ent = ents.Create(self.MISSILEENT)
	ent:SetPos(mpos)
	
	ent:SetAngles(self:GetAngles()-Angle(2.5))
	ent.IsOnPlane = true
	ent:SetOwner(self:GetDriver())
	ent:Spawn()
	ent:Activate()
	ent:Launch()
	constraint.NoCollide( ent, self, 0, 0 )
	constraint.NoCollide( ent, self.wheel_R, 0, 0 )
	constraint.NoCollide( ent, self.wheel_L, 0, 0 )
	constraint.NoCollide( ent, self.wheel_C, 0, 0 )
	
	p = p + 1
end

function ENT:SetNextRightPKT( delay )
	self.NextRightPKT = CurTime() + delay
end

function ENT:CanRightPKTAttack()
	self.NextRightPKT = self.NextRightPKT or 0
	return self.NextRightPKT < CurTime()
end

function ENT:RightPKTAttack( Driver, Pod )
	if not self:CanRightPKTAttack() then return end
	
	if not IsValid( Pod ) then Pod = self:GetDriverSeat() end
	if not IsValid( Driver ) then Driver = Pod:GetDriver() end
	
	if not IsValid( Pod ) then return end
	if not IsValid( Driver ) then return end
	local ang = self:GetAngles()
	local EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() ) - ang
	local EyeA = EyeAngles
	EyeA:Normalize()
	
	if EyeA.y > 0 or (EyeA.p > 90 or EyeA.p < -90) then self.NoTurretSound = true return else self.NoTurretSound = false end
	self:SetNextRightPKT( 0.075 )
	
	local MuzzlePos = self:LocalToWorld(Vector(97.6815,-43.0575,60.4058) + EyeAngles:Forward()*30)

	local pos2=MuzzlePos
	local num = 0.3
	local ang = (EyeAngles + ang + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
	gred.CreateBullet(Driver,pos2,ang,"wac_base_7mm",{self},nil,false,self:UpdateTracers_1())
	local effectdata = EffectData()
	effectdata:SetFlags(self.MUZZLEEFFECT)
	effectdata:SetOrigin(pos2)
	effectdata:SetAngles(ang)
	effectdata:SetSurfaceProp(0)
	util.Effect("gred_particle_simple",effectdata)
end

function ENT:SetNextLeftPKT( delay )
	self.NextLeftPKT = CurTime() + delay
end

function ENT:CanLeftPKTAttack()
	self.NextLeftPKT = self.NextLeftPKT or 0
	return self.NextLeftPKT < CurTime()
end

function ENT:LeftPKTAttack( Driver, Pod )
	if not self:CanLeftPKTAttack() then return end
	
	if not IsValid( Pod ) then Pod = self:GetDriverSeat() end
	if not IsValid( Driver ) then Driver = Pod:GetDriver() end
	
	if not IsValid( Pod ) then return end
	if not IsValid( Driver ) then return end
	local ang = self:GetAngles()
	local EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() ) - ang
	local EyeA = EyeAngles
	EyeA:Normalize()
	
	
	if EyeA.y < 0 or (EyeA.p > 90 or EyeA.p < -90) then self.NoTurretSound2 = true return else self.NoTurretSound2 = false end
	self:SetNextLeftPKT( 0.075 )
	
	local MuzzlePos = self:LocalToWorld(Vector(97.6815,43.0575,60.4058) + EyeAngles:Forward()*30)

	local pos2=MuzzlePos
	local num = 0.3
	local ang = (EyeAngles + ang + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
	gred.CreateBullet(Driver,pos2,ang,"wac_base_7mm",{self},nil,false,self:UpdateTracers_1())
	local effectdata = EffectData()
	effectdata:SetFlags(self.MUZZLEEFFECT)
	effectdata:SetOrigin(pos2)
	effectdata:SetAngles(ang)
	effectdata:SetSurfaceProp(0)
	util.Effect("gred_particle_simple",effectdata)
end

function ENT:SetNextRearPKT( delay )
	self.NextRearPKT = CurTime() + delay
end

function ENT:CanRearPKTAttack()
	self.NextRearPKT = self.NextRearPKT or 0
	return self.NextRearPKT < CurTime()
end

function ENT:RearPKTAttack( Driver, Pod )
	if not self:CanRearPKTAttack() then return end
	
	if not IsValid( Pod ) then Pod = self:GetDriverSeat() end
	if not IsValid( Driver ) then Driver = Pod:GetDriver() end
	
	if not IsValid( Pod ) then return end
	if not IsValid( Driver ) then return end
	local ang = self:GetAngles()
	local EyeAngles = Pod:WorldToLocalAngles( Driver:EyeAngles() ) - ang
	local EyeA = EyeAngles
	
	EyeA:Normalize()
	local b
	if EyeA.y < 0 then EyeA.y = -EyeA.y
		b = true 
	end
	if EyeA.y < 130 or (EyeA.p > 90 or EyeA.p < -10) then self.NoTurretSound3 = true return else self.NoTurretSound3 = false end
	self:SetNextRearPKT( 0.075 )
	if b then EyeA.y = -EyeA.y end
	local MuzzlePos = self:LocalToWorld(Vector(-121.669,0,55.1036) + EyeAngles:Forward()*24)
	
	local pos2=MuzzlePos
	local num = 0.3
	local ang = (EyeAngles + ang + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
	gred.CreateBullet(Driver,pos2,ang,"wac_base_7mm",{self},nil,false,self:UpdateTracers_1())
	local effectdata = EffectData()
	effectdata:SetFlags(self.MUZZLEEFFECT)
	effectdata:SetOrigin(pos2)
	effectdata:SetAngles(ang)
	effectdata:SetSurfaceProp(0)
	util.Effect("gred_particle_simple",effectdata)
end

function ENT:HandleWeapons(Fire1, Fire2)
	local Driver = self:GetDriver()
	local loadout = self:GetLoadout()
	local Gunner = self:GetGunner()
	local Gunner2 = self:GetGunner2()
	local Gunner3 = self:GetGunner3()
	local HasGunner = IsValid( Gunner )
	local HasGunner2 = IsValid(Gunner2)
	local HasGunner3 = IsValid(Gunner3)
	local TurretSnd = false
	local TurretSnd2 = false
	local TurretSnd3 = false
	
	if IsValid( Driver ) then
		FireTurret = Driver:lfsGetInput("FREELOOK")
		
		if self:GetAmmoPrimary() > 0 or FireTurret then
			Fire1 = Driver:KeyDown( IN_ATTACK )
		end
	end
	if Fire1 then
		if FireTurret then
			if not HasGunner then
				self:LeftPKTAttack(Driver)
				TurretSnd = true
			end
			if not HasGunner2 then
				self:RightPKTAttack(Driver)
				TurretSnd2 = true
			end
			if not HasGunner3 then
				self:RearPKTAttack(Driver)
				TurretSnd3 = true
			end
		else
			self:PrimaryAttack(loadout)
		end
	end
	
	if self.OldFire ~= Fire1 and not FireTurret then
		
		self.OldFire = Fire1
	end
	
	if HasGunner then
		if Gunner:KeyDown( IN_ATTACK ) then
			self:RightPKTAttack( Gunner, self:GetGunnerSeat() )
			TurretSnd = true
		end
	end
	if HasGunner2 then
		if Gunner2:KeyDown( IN_ATTACK ) then
			self:LeftPKTAttack( Gunner2, self:GetGunner2Seat() )
			TurretSnd2 = true
		end
	end
	if HasGunner3 then
		if Gunner3:KeyDown( IN_ATTACK ) then
			self:RearPKTAttack( Gunner3, self:GetGunner3Seat() )
			TurretSnd3 = true
		end
	end
	
	if self.NoTurretSound then
		if self.turret1 then
			self.turret1:Stop()
		end
	else
		if TurretSnd then
			self.turret1 = CreateSound(self,"PKT_SHOOT")
			self.turret1:Play()
			self:CallOnRemove( "stopmesounds2", function( ent )
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
				self:EmitSound("PKT_STOP")
			end
		end
	end
	
	if self.NoTurretSound2 then
		if self.turret2 then
			self.turret2:Stop()
		end
	else
		if TurretSnd2 then
			self.turret2 = CreateSound(self,"PKT_SHOOT")
			self.turret2:Play()
			self:CallOnRemove( "stopmesounds3", function( ent )
				if ent.turret2 then
					ent.turret2:Stop()
				end
			end)
		else
			if self.turret2 then
				self.turret2:Stop()
			end
			if self.OldTurretSnd2 == true then
				self.turret2 = nil
				self:EmitSound("PKT_STOP")
			end
		end
	end
	
	if self.NoTurretSound3 then
		if self.turret3 then
			self.turret3:Stop()
		end
	else
		if TurretSnd3 then
			self.turret3 = CreateSound(self,"PKT_SHOOT")
			self.turret3:Play()
			self:CallOnRemove( "stopmesounds3", function( ent )
				if ent.turret3 then
					ent.turret3:Stop()
				end
			end)
		else
			if self.turret3 then
				self.turret3:Stop()
			end
			if self.OldTurretSnd3 == true then
				self.turret3 = nil
				self:EmitSound("PKT_STOP")
			end
		end
	end
	self.OldTurretSnd = TurretSnd
	self.OldTurretSnd2 = TurretSnd2
	self.OldTurretSnd3 = TurretSnd3
end

function ENT:HandleActive()
	local gtPod = self:GetGunner2Seat()
	if IsValid( gtPod ) then
		local Gunner2 = gtPod:GetDriver()
		
		if Gunner2 ~= self:GetGunner() then
			self:SetGunner2( Gunner2 )
			
			if IsValid( Gunner2 ) then
				Gunner2:CrosshairEnable() 
			end
		else
			self:SetGunner2(nil)
		end
	end
	local g3Pod = self:GetGunner3Seat()
	if IsValid( g3Pod ) then
		local Gunner3 = g3Pod:GetDriver()
		
		if Gunner3 ~= self:GetGunner() then
			self:SetGunner3( Gunner3 )
			
			if IsValid( Gunner3 ) then
				Gunner3:CrosshairEnable() 
			end
		else
			self:SetGunner3(nil)
		end
	end
	
	return BaseClass.HandleActive(self)
end

function ENT:CreateAI()
end

function ENT:RemoveAI()
end

function ENT:OnEngineStarted()
end

function ENT:OnEngineStopped()
end

function ENT:OnEngineStartInitialized()
	self:EmitSound("MI8_START")
end

--[[
function ENT:OnEngineStopInitialized()
end

function ENT:OnRotorDestroyed()
	self:EmitSound( "physics/metal/metal_box_break2.wav" )
	
	self:SetHP(1)
	
	timer.Simple(2, function()
		if not IsValid( self ) then return end
		self:Destroy()
	end)
end

function ENT:OnRotorCollide( Pos, Dir )
	local effectdata = EffectData()
		effectdata:SetOrigin( Pos )
		effectdata:SetNormal( Dir )
	util.Effect( "manhacksparks", effectdata, true, true )

	self:EmitSound( "ambient/materials/roust_crash"..math.random(1,2)..".wav" )
end
]]
