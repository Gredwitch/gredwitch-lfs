--DO NOT EDIT OR REUPLOAD THIS FILE

include("shared.lua")

function ENT:GetCalcViewFilter(ent)
	return ent != self.Tail
end

function ENT:LFSCalcViewFirstPerson( view, ply )
	return view
end

function ENT:LFSCalcViewThirdPerson( view, ply )
	return view
end

function ENT:CalcEngineSound( RPM, Pitch, Doppler )
	local THR = RPM / self:GetLimitRPM()
	
	if self.ENG then
		self.ENG:ChangePitch( math.Clamp( math.min(RPM / self:GetIdleRPM(),1) * 100+ Doppler + THR * 20,0,255) )
		self.ENG:ChangeVolume( math.Clamp(THR,0.8,1) )
	end
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.ENG = CreateSound( self, "AH1G_ENGINE" )
		self.ENG:Play()
		-- self.ENG:PlayEx(0,0)
	else
		self:SoundStop()
	end
end

function ENT:Initialize()
	self.snd = {}
	self.snd["BEEP_CRASH"] = CreateSound(self,"BEEP_CRASH")
	gred.UpdateBoneTable(self)
end


local METER_IN_UNIT = 0.01905
local FEET_IN_METER = 3.28084
ENT.roll = 0
function ENT:AnimFins()
	if not self.Bones then gred.UpdateBoneTable(self) return end
	
	if self.TailDestroyed then
		self.snd.BEEP_CRASH:Play()
	end
	
	local FT = FrameTime() * 10
	local Pitch = self:GetRotPitch()
	local Yaw = self:GetRotYaw()
	local Roll = -self:GetRotRoll()
	
	---------------------------
	
	self.smPitch = self.smPitch and self.smPitch + (Pitch - self.smPitch) * FT or 0
	self.smYaw = self.smYaw and self.smYaw + (Yaw - self.smYaw) * FT or 0
	self.smRoll = self.smRoll and self.smRoll + (Roll - self.smRoll) * FT or 0
	gred.ManipulateBoneAngles(self,"joy_roll", Angle(0,-self.smPitch*10,-self.smRoll*20) )
	gred.ManipulateBoneAngles(self,"yawr1", Angle(self.smYaw*-50))
	gred.ManipulateBoneAngles(self,"yawr2", Angle(self.smYaw*-50))
	gred.ManipulateBoneAngles(self,"yawl1", Angle(self.smYaw*50))
	gred.ManipulateBoneAngles(self,"yawl2", Angle(self.smYaw*50))
	
	local Throttle = (math.max( math.Round( ((self:GetRPM() - self:GetIdleRPM()) / (self:GetMaxRPM() - self:GetIdleRPM())) * 100, 0)))
	gred.ManipulateBoneAngles(self,"collective", Angle(-Throttle/8))
	
	gred.ManipulateBoneAngles(self,"rpm1_main",Angle(0,0,self:GetRPM()/10))
	gred.ManipulateBoneAngles(self,"rpm2_main",Angle(0,0,self:GetRPM()/10))
	local vel = (self:GetVelocity():Length()*METER_IN_UNIT)*1.94384
	gred.ManipulateBoneAngles(self,"speed1",Angle(0,0,vel))
	gred.ManipulateBoneAngles(self,"speed2",Angle(0,0,vel))
	
	local ang = self:GetAngles()
	gred.ManipulateBoneAngles(self,"roll1",Angle(0,0,ang.r))
	gred.ManipulateBoneAngles(self,"roll2",Angle(0,0,ang.r))
	gred.ManipulateBoneAngles(self,"pitch1",Angle(ang.p))
	gred.ManipulateBoneAngles(self,"pitch2",Angle(ang.p))
	
	local trace = {
		start = self:GetPos(),
		endpos = self:GetPos()-Vector(0,0,10000/FEET_IN_METER/METER_IN_UNIT),
		mask = MASK_SOLID_BRUSHONLY+MASK_WATER
	}
	trace = util.TraceLine(trace)
	if trace.Hit then
		self.altitude = trace.Fraction*10000
	end
	
	local alt = Angle(0,0,self.altitude/1.9)
	gred.ManipulateBoneAngles(self,"alt1",Angle(alt))
	gred.ManipulateBoneAngles(self,"alt2",Angle(alt))
	gred.ManipulateBoneAngles(self,"altk1",Angle(alt/10))
	gred.ManipulateBoneAngles(self,"altk2",Angle(alt/10))
	
	gred.ManipulateBoneAngles(self,"bearing1",Angle(0,0,ang.y))
	gred.ManipulateBoneAngles(self,"bearing2",Angle(0,0,ang.y))
	local VertANG = (self:GetVelocity().z/7)
	gred.ManipulateBoneAngles(self,"vert1",Angle(0,0,VertANG+180))
	
	local s = Angle(0,os.date("%S"))
	local m = Angle(0,os.date("%M")+(s.y*0.0166))
	local h = Angle(0,os.date("%H")+(m.y*0.0166))
	
	gred.ManipulateBoneAngles(self,"clock_m",Angle(0,0,h*9))
	gred.ManipulateBoneAngles(self,"clock_h",Angle(0,0,m*6))
	
	------------------------------
	
	local Driver = self:GetDriver()
	local Gunner = self:GetGunner()
	local DriverValid = IsValid(Driver)
	local GunnerValid = IsValid(Gunner)
	local HasGunner = GunnerValid or (!GunnerValid and DriverValid && Driver:lfsGetInput("FREELOOK"))
	
	if not DriverValid and not GunnerValid and not HasGunner then
		gred.ManipulateBoneAngles(self,"turret", Angle(0))
		gred.ManipulateBoneAngles(self,"turret_pitch", Angle(0,0))
	elseif HasGunner then
		if GunnerValid then Driver = Gunner end
		local EyeAngles = self:WorldToLocalAngles( Driver:EyeAngles() )
		local e = EyeAngles
		EyeAngles:RotateAroundAxis( EyeAngles:Up(), 180 )
		e:RotateAroundAxis( EyeAngles:Right(), 180 )
		local Pitch = math.Clamp( -EyeAngles.p,-50,15 )
		local Yaw = math.Clamp( e.y,-40,40 )
		gred.ManipulateBoneAngles(self,"turret", Angle(Yaw))
		gred.ManipulateBoneAngles(self,"turret_pitch", Angle(0,Pitch))
	else
		gred.ManipulateBoneAngles(self,"turret", Angle(0))
		gred.ManipulateBoneAngles(self,"turret_pitch", Angle(0,0))
	end
end

function ENT:CreateBones()
	self.Bones = nil
	timer.Simple(0,function()
		if not self && IsValid(self) then return end
		self.Bones = {}
		local name
		for i=0, self:GetBoneCount()-1 do
			name = self:GetBoneName(i)
			if name == "__INVALIDBONE__" then
				self.Bones = nil
				break
			end
			self.Bones[name] = i
		end
	end)
end

function ENT:OnRemove()
	self:SoundStop()
end

function ENT:SoundStop()
	if self.ENG then
		self.ENG:Stop()
	end
end

function ENT:RequestTail()
	if self.TailDestroyed then return end
	local ct = CurTime()
	self.NextTailRequest = self.NextTailRequest or 0
	if self.NextTailRequest < ct then
		net.Start("gred_apache_request_tail")
			net.WriteEntity(self)
		net.SendToServer()
		self.NextTailRequest = ct + 0.3
	end
end

function ENT:DamageFX()
	local HP = self:GetHP()
	
	self.nextDFX = self.nextDFX or 0
	
	if self.nextDFX < CurTime() then
		self.nextDFX = CurTime() + 0.05
		if HP != 0 and HP < self:GetMaxHP() * 0.5 then
			local effectdata = EffectData()
				effectdata:SetOrigin(self:GetRotorPos() - self:GetForward() * 50)
			util.Effect("lfs_blacksmoke",effectdata)
		end
		if self.TailDestroyed then
			local effectdata = EffectData()
				effectdata:SetOrigin(self:LocalToWorld(self.TailPos))
			util.Effect("lfs_blacksmoke",effectdata)
		end
		
	end
end

function ENT:AnimRotor()
	if not self.Bones then gred.UpdateBoneTable(self) return end
	local RotorBlown = self:GetRotorDestroyed()

	if RotorBlown ~= self.wasRotorBlown then
		self.wasRotorBlown = RotorBlown
		
		if RotorBlown then
			self:DrawShadow( false ) 
		end
	end
	
	if RotorBlown then
		self:SetBodygroup(0,2)
		return
	end
	
	local RPM = math.min(self:GetRPM() * 5,self:GetMaxRPM())
	
	local PhysRot = RPM > 1800
	self:SetBodygroup(0,PhysRot and 1 or 0)
	self.RPM = self.RPM and (self.RPM + RPM * FrameTime() * 0.5) or 0
	
	local Rot1 = Angle( -self.RPM,0,0)
	Rot1:Normalize() 
	 
	gred.ManipulateBoneAngles(self,"toprotor", Rot1 )
	self.Tail = IsValid(self.Tail) and self.Tail or self:GetNWEntity("Tail")
	if IsValid(self.Tail) then
		if self.Tail.TailRotorDestroyed then
			self.Tail:SetBodygroup(0,3)
		else
			local Rot2 = Angle(0,self.RPM)
			Rot2:Normalize()
			self.Tail:ManipulateBoneAngles(1,Rot2)
			if RPM < 1800 then
				self.Tail:SetBodygroup(0,0)
			elseif RPM >= 1800 and RPM < 3000 then
				self.Tail:SetBodygroup(0,1)
			elseif RPM >= 3000 then
				self.Tail:SetBodygroup(0,2)
			end
		end
	else
		self:RequestTail()
	end
end

function ENT:AnimCabin()
end

function ENT:AnimLandingGear()
end

function ENT:ExhaustFX()
end