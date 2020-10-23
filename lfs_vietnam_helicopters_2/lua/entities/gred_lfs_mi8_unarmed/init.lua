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
	for i = 3,5 do
		self:SetBodygroup(i,1)
	end
	
	for i = 10,15 do
		self:SetBodygroup(i,1)
	end
	
	self:SetBodygroup(8,3)
	self:SetBodygroup(9,3)
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
	self:AddPassengerSeat( Vector(Vector(150,23.792,50)), Angle(0,-90,0) )
	
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

function ENT:CreateAI()
end

function ENT:RemoveAI()
end

function ENT:OnEngineStarted()
end

function ENT:OnEngineStopped()
end


function ENT:OnEngineStartInitialized()
	self:EmitSound( "wac/ah1g/start.wav")
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
