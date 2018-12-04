
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:SpawnFunction( ply, tr, ClassName ) -- called by garry
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 80 ) -- spawn 20 units above ground
	ent:Spawn()
	ent:Activate()
	ent:SetSkin(math.random(0,3))
	return ent
end

function ENT:RunOnSpawn() -- called when the vehicle is spawned
	self.sounds_a10 = {}
	self.sounds_a10["close_shoot"] = CreateSound(self,"^gredwitch/a10_lfs/a10_gun_close_shoot.wav")
	self.sounds_a10["far_shoot"] = CreateSound(self,"^gredwitch/a10_lfs/a10_gun_far_shoot.wav")
	self.sounds_a10["close_stop"] = CreateSound(self,"^gredwitch/a10_lfs/a10_gun_close_stop.wav")
	self.sounds_a10["far_stop"] = CreateSound(self,"^gredwitch/a10_lfs/a10_gun_far_stop.wav")
	
	self.sounds_a10.close_shoot:SetSoundLevel(80)
	self.sounds_a10.close_stop:SetSoundLevel(80)
	self.sounds_a10.far_shoot:SetSoundLevel(120)
	self.sounds_a10.far_stop:SetSoundLevel(120)
	
	-- self.RotorPos 		=	{}  -- these wheels are invisible spherical entities
	-- self.RotorPos[1] 	=	Vector(-103,57,41)
	-- self.RotorPos[2] 	=	Vector(-103,-57,41)
end

function ENT:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimary( 0.015 )
	self.Firing = true
	self.ShouldPlayStopSound = false
	
	-- self:EmitSound("gred_a10_far_shoot")
	-- self:EmitSound("gred_a10_close_shoot")
	self.sounds_a10.close_stop:Stop()
	self.sounds_a10.far_stop:Stop()
	self.sounds_a10.close_shoot:PlayEx(1,100)
	self.sounds_a10.far_shoot:PlayEx(1,100)
	
	local Driver = self:GetDriver()
	
	local pos2=self:LocalToWorld(self.BulletPos)
	local num = 2.5
	local ang = self:GetAngles() + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num))
	local b=ents.Create("gred_base_bullet")
	b:SetPos(pos2)
	b:SetAngles(ang)
	-- b.col = tracercolor
	b.Speed=1000
	b.Caliber = "wac_base_30mm"
	b.Size=0
	b.Width=0
	b.Damage=40
	b.Radius=70
	b.sequential=true
	b.npod=1
	b.gunRPM=3900
	b:Spawn()
	b:Activate()
	b.Filter = {self}
	b.Owner=Driver
	if !tracer then tracer = 0 end
	if tracer >= GetConVarNumber("gred_sv_tracers") then
		b:SetSkin(1)
		b:SetModelScale(20)
		tracer = 0
	else b.noTracer = true end
	tracer = tracer + 1
	self:TakePrimaryAmmo()
	net.Start("gred_net_wac_mg_muzzle_fx")
		net.WriteVector(pos2)
		net.WriteAngle(ang)
	net.Broadcast()
end

function ENT:OnTick()
	if self:CanPrimaryAttack() and self.Firing then 
		self.Firing = false
		self.ShouldPlayStopSound = true
	end
	if !self.Firing and self.ShouldPlayStopSound and self.sounds_a10 then
		self.sounds_a10.close_shoot:Stop()
		self.sounds_a10.far_shoot:Stop()
		self.sounds_a10.close_stop:PlayEx(1,100)
		self.sounds_a10.far_stop:PlayEx(1,100)
		
		for k,v in pairs(player.GetHumans()) do
		local d = self:GetDriver()
		
		if IsValid(d) && v == d:GetViewEntity() then return end
			timer.Simple(2,function()
				net.Start("gred_net_sound_lowsh")
					net.WriteString("gunsounds/brrt_0"..math.random(1,4)..".wav")
				net.Send(v)
			end)
		end
		
		self.ShouldPlayStopSound = false
	end
end
function ENT:OnRemove()
	for k,v in pairs(self.sounds_a10) do v:Stop() v = nil end
end


function ENT:SecondaryAttack()
	if self:GetAI() then return end
	if not self:CanSecondaryAttack() then return end
	self:SetNextSecondary( 0.2 )
	self:TakeSecondaryAmmo()
	
	if m == nil or m >  table.Count(self.MISSILES) or m == 0 then m = 1 end
	local mpos = self:LocalToWorld(self.MISSILES[m])
	local Ang = self:WorldToLocal( mpos ).y > 0 and -1 or 1
	local ent = ents.Create(self.MISSILEENT)
	ent:SetPos(mpos)
	print(mpos)
	ent:SetAngles( self:LocalToWorldAngles( Angle(-2,Ang,0) ) )
	ent.IsOnPlane = true
	ent:SetOwner(self:GetDriver())
	ent:Spawn()
	ent:Activate()
	ent:Launch()
	constraint.NoCollide( ent, self, 0, 0 ) 
	if IsValid( self.wheel_R ) then
		constraint.NoCollide( ent, self.wheel_R, 0, 0 ) 
	end
	if IsValid( self.wheel_L ) then
		constraint.NoCollide( ent, self.wheel_L, 0, 0 ) 
	end
	if IsValid( self.wheel_F ) then
		constraint.NoCollide( ent, self.wheel_F, 0, 0 ) 
	end
	m = m + 1
end

function ENT:CreateAI() -- called when the ai gets enabled
end

function ENT:RemoveAI() -- called when the ai gets disabled
end

function ENT:OnEngineStarted()
	--[[ play engine start sound? ]]--
	-- self:EmitSound( "vehicles/airboat/fan_motor_start1.wav" )
end

function ENT:OnEngineStopped()
	--[[ play engine stop sound? ]]--
	-- self:EmitSound( "vehicles/airboat/fan_motor_shut_off1.wav" )
end

function ENT:OnLandingGearToggled( bOn )
	self:EmitSound( "vehicles/tank_readyfire1.wav" )
	
	if bOn then
		--[[ set bodygroup of landing gear down? ]]--
	else
		--[[ set bodygroup of landing gear up? ]]--
	end
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
			
			local radius = self.WheelRadius
			
			wheel_F:PhysicsInitSphere( radius, "jeeptire" )
			wheel_F:SetCollisionBounds( Vector(-radius,-radius,-radius), Vector(radius,radius,radius) )
			
			local RWpObj = wheel_F:GetPhysicsObject()
			if not IsValid( RWpObj ) then
				self:Remove()
				
				print("LFS: Failed to initialize landing gear phys model. Plane terminated.")
				return
			end
		
			RWpObj:EnableMotion(false)
			RWpObj:SetMass( self.WheelMass )
			
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
