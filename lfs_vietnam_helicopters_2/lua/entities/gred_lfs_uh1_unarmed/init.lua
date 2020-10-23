--DO NOT EDIT OR REUPLOAD THIS FILE

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

ENT.rotorHP = 300
ENT.TailRotorPos = Vector(-281,3,110)

local BaseClass = baseclass.Get("lunasflightschool_basescript_heli")
function ENT:OnTakeDamage(dmginfo)
	BaseClass.OnTakeDamage(self,dmginfo)
	
	if self.TailEffectTime then return end
	
	local dist = self.TailRotorPos:Distance(self:WorldToLocal(dmginfo:GetDamagePosition()))
	if dist <= 45 then
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
	self:StopSound("UH1_START")
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
	local loadout = self:GetLoadout()
	local leftseat = self:GetLeftSeat()
	local rightseat = self:GetRightSeat()
	
	for i = 2, 6 do
		self:SetBodygroup(i,1)
	end
	self:SetBodygroup(9,3)
	self:SetBodygroup(10,12)
	self:SetBodygroup(13,3)
	self:SetBodygroup(14,3)
	self:SetBodygroup(8,1)
	
	if loadout != 1 and loadout != self.OldLoadout and self.Bench then
		for k,v in pairs(self.Bench) do
			self:RemoveSeat(v)
		end
		self.Bench = nil
	end
	if loadout != 2 and loadout != self.OldLoadout and self.Strether1 then
		for k,v in pairs(self.Strether1) do
			self:RemoveSeat(v)
		end
		self.Strether1 = nil
	end
	if loadout != 3 and loadout != self.OldLoadout and self.Strether2 then
		for k,v in pairs(self.Strether2) do
			self:RemoveSeat(v)
		end
		self.Strether2 = nil
	end
	if loadout != 4 and loadout != self.OldLoadout and self.Strether3 then
		for k,v in pairs(self.Strether3) do
			self:RemoveSeat(v)
		end
		self.Strether3 = nil
	end
	
	if rightseat then
		self:SetBodygroup(20,0)
		if self.OldRightSeat != rightseat then
			self:AddPassengerSeat( Vector(40.2794,-19.008,34.805), Angle(0,90,0) )
			self.RightSeat = self.pSeats[#self.pSeats]
		end
	else
		self:SetBodygroup(20,1)
		if self.OldRightSeat != rightseat then
			if self.RightSeat then
				self:RemoveSeat(self.RightSeat)
			end
		end
	end
	
	if leftseat then
		self:SetBodygroup(19,0)
		if self.OldLeftSeat != leftseat then
			self:AddPassengerSeat( Vector(40.2794,19.008,34.805), Angle(0,90,0) )
			self.LeftSeat = self.pSeats[#self.pSeats]
		end
	else
		self:SetBodygroup(19,1)
		if self.OldLeftSeat != leftseat then
			if self.LeftSeat then
				self:RemoveSeat(self.LeftSeat)
			end
		end
	end
	
	if loadout == 0 then
		self:SetBodygroup(15,1)
		self:SetBodygroup(16,1)
		self:SetBodygroup(17,2)
		self:SetBodygroup(18,0)
		-- self:SetBodygroup(22,1) CAUSES CRASHES
		if loadout != self.OldLoadout then
		
		end
	elseif loadout == 1 then
		self:SetBodygroup(15,1)
		self:SetBodygroup(16,1)
		self:SetBodygroup(17,2)
		self:SetBodygroup(18,1)
		self:SetBodygroup(7,0)
		if loadout != self.OldLoadout then
			self.Bench = {}
			self:AddPassengerSeat( Vector(-1.94208,-18.9253,34.907), Angle(0,-90,0) )
			self.Bench[1] = self.pSeats[#self.pSeats]
			self:AddPassengerSeat( Vector(-1.94208,0,34.907), Angle(0,-90,0) )
			self.Bench[2] = self.pSeats[#self.pSeats]
			self:AddPassengerSeat( Vector(-1.94208,18.2317,34.907), Angle(0,-90,0) )
			self.Bench[3] = self.pSeats[#self.pSeats]
		end
	elseif loadout == 2 then
		self:SetBodygroup(15,0)
		self:SetBodygroup(16,1)
		if self:GetBodygroup(17) == 0 then
			self:SetBodygroup(17,math.random(1,2))
		end
		self:SetBodygroup(18,0)
		self:SetBodygroup(7,1)
		if loadout != self.OldLoadout then
			self.Strether1 = {}
			self:AddPassengerSeat( Vector(8,20,35), Angle(0,0,90) )
			self.Strether1[1] = self.pSeats[#self.pSeats]
		end
	elseif loadout == 3 then
		self:SetBodygroup(15,0)
		self:SetBodygroup(16,0)
		if self:GetBodygroup(17) == 0 then
			self:SetBodygroup(17,math.random(1,2))
		end
		self:SetBodygroup(18,0)
		self:SetBodygroup(7,1)
		if loadout != self.OldLoadout then
			self.Strether2 = {}
			self:AddPassengerSeat( Vector(8,20,35), Angle(0,0,90) )
			self.Strether2[1] = self.pSeats[#self.pSeats]
			self:AddPassengerSeat( Vector(8,20,51), Angle(0,0,90) )
			self.Strether2[2] = self.pSeats[#self.pSeats]
		end
	elseif loadout == 4 then
		self:SetBodygroup(15,0)
		self:SetBodygroup(16,0)
		self:SetBodygroup(17,0)
		self:SetBodygroup(18,0)
		self:SetBodygroup(7,1)
		if loadout != self.OldLoadout then
			self.Strether3 = {}
			self:AddPassengerSeat( Vector(8,20,35), Angle(0,0,90) )
			self.Strether3[1] = self.pSeats[#self.pSeats]
			self:AddPassengerSeat( Vector(8,20,51), Angle(0,0,90) )
			self.Strether3[2] = self.pSeats[#self.pSeats]
			self:AddPassengerSeat( Vector(8,20,67), Angle(0,0,90) )
			self.Strether3[3] = self.pSeats[#self.pSeats]
		end
	end
	
	-- PrintTable(self.pSeats)
	
	self.OldLeftSeat = leftseat
	self.OldRightSeat = rightseat
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

function ENT:RemoveSeat(seat)
	self.pPodKeyIndex = self.pPodKeyIndex and self.pPodKeyIndex - 1 or 2
	seat:SetNWInt( "pPodIndex", self.pPodKeyIndex )
	
	table.RemoveByValue(self.pSeats,seat)
	seat:Remove()
	seat = nil
end

function ENT:RunOnSpawn()
	self.CRASHSND = "HELICOPTER_CRASHING_"..math.random(1,10)
	-- self:SetGunnerSeat(self:AddPassengerSeat(Vector(105,0,40),Angle(0,-90,0)))
	self:AddPassengerSeat( Vector(81.3078,19.2824,34.8398), Angle(0,-90,0) )
	self:AddPassengerSeat( Vector(37.0287,36.7331,21.9164), Angle(0,0,0) )
	self:AddPassengerSeat( Vector(37.0287,-36.7331,21.9164), Angle(0,180,0) )
	self:AddPassengerSeat( Vector(15,36.7331,21.9164), Angle(0,0,0) )
	self:AddPassengerSeat( Vector(15,-36.7331,21.9164), Angle(0,180,0) )
	-- self:AddPassengerSeat( Vector(,,), Angle(0,-90,0) )
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
	self:EmitSound("UH1_START")
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