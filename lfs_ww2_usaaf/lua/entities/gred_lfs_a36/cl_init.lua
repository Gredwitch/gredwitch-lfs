
include("shared.lua")

function ENT:LFSCalcViewFirstPerson( view ) -- modify first person camera view here
	--[[
	local ply = LocalPlayer()
	if ply == self:GetDriver() then
		-- driver view
	elseif ply == self:GetGunner() then
		-- gunner view
	else
		-- everyone elses view
	end
	]]--
	
	return view
end

function ENT:LFSCalcViewThirdPerson( view ) -- modify third person camera view here
	return view
end


function ENT:CalcEngineSound( RPM, Pitch, Doppler )
	local Low = 500
	local Mid = 1000
	local High = 2500
	
	if self.snd.RPM0 then
		self.snd.RPM0:ChangePitch( math.Clamp(100 + Pitch * 300 + Doppler,0,255) * 0.8 )
		self.snd.RPM0:ChangeVolume( RPM < Low and 1 or 0, 1.5 )
	end
	
	if self.snd.RPM1 then
		self.snd.RPM1:ChangePitch(  math.Clamp(50 + Pitch * 320 + Doppler,0,255) * 0.8 )
		self.snd.RPM1:ChangeVolume( (RPM >= Low and RPM < Mid) and 1 or 0, 1.5 )
	end
	
	if self.snd.RPM2 then
		self.snd.RPM2:ChangePitch(  math.Clamp(75 + Pitch * 110 + Doppler,0,255) * 0.8 )
		self.snd.RPM2:ChangeVolume( (RPM >= Mid) and 1 or 0, 1.5 )
	end
	
	if self.snd.RPM3 then
		self.snd.RPM3:ChangePitch(  math.Clamp(90 + Pitch * 50 + Doppler,0,255) * 0.8 )
		self.snd.RPM3:ChangeVolume( RPM >= High and 1 or 0, 1.5 )
	end
	
	if self.snd.DIST then
		self.snd.DIST:ChangePitch(  math.Clamp(math.Clamp( 50 + Pitch * 60, 50,255) + Doppler,0,255) )
		self.snd.DIST:ChangeVolume( math.Clamp( -1 + Pitch * 6, 0,1) )
	end
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.snd.RPM0 = CreateSound(self,"P51A_RPM0")
		self.snd.RPM1 = CreateSound(self,"P51A_RPM1")
		self.snd.RPM2 = CreateSound(self,"P51A_RPM2")
		self.snd.RPM3 = CreateSound(self,"P51A_RPM3")
		self.snd.DIST = CreateSound(self,"P51_DIST")
		
		for k,v in pairs (self.snd) do
			v:SetSoundLevel(125)
			v:PlayEx(0,0)
		end
	else
		self:SoundStop()
	end
end

function ENT:Initialize()
	self.snd = {}
	self:CreateBones()
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
	
	if IsValid( self.TheRotor ) then
		self.TheRotor:Remove()
	end
	
	if IsValid( self.TheLandingGear ) then
		self.TheLandingGear:Remove()
	end
end

function ENT:SoundStop()
	for k,v in pairs(self.snd) do
		v:Stop()
	end
end

function ENT:AnimFins()
	if not self.Bones then self:CreateBones() return end
	local FT = FrameTime() * 10
	local Pitch = self:GetRotPitch()
	local Yaw = self:GetRotYaw()
	local Roll = -self:GetRotRoll()
	
	---------------------------
	
	self.smPitch = self.smPitch and self.smPitch + (Pitch - self.smPitch) * FT or 0
	self.smYaw = self.smYaw and self.smYaw + (Yaw - self.smYaw) * FT or 0
	self.smRoll = self.smRoll and self.smRoll + (Roll - self.smRoll) * FT or 0
	self:ManipulateBoneAngles(self.Bones.stick_ailerons, Angle( 0,-self.smRoll/2,-self.smPitch/ 4) )
	self:ManipulateBoneAngles(self.Bones.aileron_l, Angle( self.smRoll,0,0) )
	self:ManipulateBoneAngles(self.Bones.aileron_r, Angle( -self.smRoll,0,0) )
	self:ManipulateBoneAngles( self.Bones.rudder, Angle( self.smYaw ) )
	self:ManipulateBoneAngles( self.Bones.pedals1, Angle( self.smYaw/3 ) )
	self:ManipulateBoneAngles( self.Bones.pedals2, Angle( -self.smYaw/3 ) )
	self:ManipulateBoneAngles( self.Bones.elevator, Angle( -self.smPitch) )
	
	---------------------------
	
	local s = Angle(0,os.date("%S"))
	local m = Angle(0,os.date("%M")+(s.y*0.0166))
	local h = Angle(0,os.date("%H")+(m.y*0.0166))
	self:ManipulateBoneAngles(self.Bones.clock_hour,h*9)
	self:ManipulateBoneAngles(self.Bones.clock_min,m*6)
	
	---------------------------
	
	local Throttle = (math.max( math.Round( ((self:GetRPM() - self:GetIdleRPM()) / (self:GetMaxRPM() - self:GetIdleRPM())) * 100, 0)))
	if Throttle < 0 then Throttle = 0 end
	self:ManipulateBonePosition(self.Bones.throttle,Vector(0,0,Throttle/10))
	self:ManipulateBonePosition(self.Bones.prop_pitch,Vector(0,0,Throttle/10))
	if Throttle > 100 then Throttle = Throttle * 1.5 end
	self:ManipulateBoneAngles(self.Bones.manifold_pressure,Angle(0,-Throttle*1.7))
	
	---------------------------
	
	local VertANG = (self:GetVelocity().z/24)
	self:ManipulateBoneAngles(self.Bones.climb,Angle(0,VertANG)) -- Vertical speed
	
	local METER_IN_UNIT = 0.01905
	local FEET_IN_METER = 3.28084
	local METER_IN_FEET = 3.281
	local ang = self:GetAngles()
	
	---------------------------
	
	speed_meters = (self:GetVelocity():Length()*METER_IN_UNIT/FEET_IN_METER)*-2 -- Speed in m/s
	self:ManipulateBoneAngles(self.Bones.speed,Angle(0,-speed_meters))
	
	---------------------------
	local r = ang.r
	self:ManipulateBonePosition(self.Bones.aviahorizon_pitch,Vector(0,-ang.p/50))
	self:ManipulateBoneAngles(self.Bones.aviahorizon_pitch,Angle(0,r))
	
	if r > 15 then r = 15 elseif r < -15 then r = -15 end
	self:ManipulateBoneAngles(self.Bones.bank,Angle(0,r))
	self:ManipulateBoneAngles(self.Bones.turn,Angle(0,r))
	self:ManipulateBoneAngles(self.Bones.compass,Angle(ang.y))
	self:ManipulateBoneAngles(self.Bones.compass1,Angle(0,ang.y))
	-- self:ManipulateBoneAngles(self.Bones.vario,Angle((self:GetVelocity().z/24)))
	
	---------------------------
	
	self:ManipulateBoneAngles(self.Bones.rpm,Angle(0,self:GetRPM()/10)) -- RPM
	
	---------------------------
	
	local trace = {
		start = self:GetPos(),
		endpos = self:GetPos()-Vector(0,0,10000/FEET_IN_METER/METER_IN_UNIT),
		mask = MASK_SOLID_BRUSHONLY+MASK_WATER
	}
	trace = util.TraceLine(trace)
	if trace.Hit then
		self.altitude = trace.Fraction*10000
	end
	
	local alt = Angle(0,self.altitude)
	-- local alt = Angle(0,0,self.altitude)
	self:ManipulateBoneAngles(self.Bones.altitude_10k,(alt/1000)*METER_IN_FEET)
	self:ManipulateBoneAngles(self.Bones.altitude_hour,(alt/100)*METER_IN_FEET)
	self:ManipulateBoneAngles(self.Bones.altitude_min,(alt/10)*METER_IN_FEET)
	
	
end

function ENT:AnimRotor()
	if not self.Bones then self:CreateBones() return end
	local RPM = self:GetRPM()
	local PhysRot = RPM < 700
	self.RPM = self.RPM and (self.RPM + RPM * FrameTime() * (PhysRot and 3 or 1)) or 0
	
	local Rot = Angle(self.RPM)
	Rot:Normalize() 
	self:ManipulateBoneAngles(self.Bones.propeller, Rot )
	self:SetBodygroup(0, PhysRot and 0 or 1 ) 
end

function ENT:AnimCabin()
	if not self.Bones then self:CreateBones() return end
	local bOn = self:GetActive()
	
	local TVal = bOn and 0 or 1
	local Speed = FrameTime() * 4
	self.SMcOpen = self.SMcOpen and self.SMcOpen + math.Clamp(TVal - self.SMcOpen,-Speed,Speed) or 0
	self:ManipulateBoneAngles(self.Bones.blister1, Angle(-self.SMcOpen * 150))
	self:ManipulateBoneAngles(self.Bones.blister2, Angle(self.SMcOpen * 90))
	
end

function ENT:AnimLandingGear()

	if not self.CurSeq then
		self.CurSeq = self:GetSequenceName(self:GetSequence())
	end
	if self.CurSeq != "gears" then
		self:ResetSequence("gears")
		self.CurSeq = self:GetSequenceName(self:GetSequence())
	end
	self.SMLG = self.SMLG and self.SMLG + ((0 + self:GetLGear()) - self.SMLG) * FrameTime() * 2 or 0
	self.SMRG = self.SMRG and self.SMRG + ((0 + self:GetRGear()) - self.SMRG) * FrameTime() * 2 or 0
	self:SetCycle(self.SMRG)
	if self.SMRG >= 0.95 then
		self:SetBodygroup(3,0)
	elseif self.SMRG <= 0.05 then
		self:SetBodygroup(3,1)
	else
		self:SetBodygroup(3,2)
	end
end

function ENT:ExhaustFX()
	if not self:GetEngineActive() then return end
	
	self.nextEFX = self.nextEFX or 0
	
	local THR = (self:GetRPM() - self.IdleRPM) / (self.LimitRPM - self.IdleRPM)
	
	if self.nextEFX < CurTime() then
		self.nextEFX = CurTime() + 0.05 + (1 - THR) / 10
		
		local Pos = {
			Vector(113.645,20.7457,30.6247),
			Vector(121.734,20.8472,30.3137),
			Vector(129.185,20.278,30.7942),
			Vector(136.671,20.4173,30.6247),
			Vector(144.459,20.7352,30.6247),
			Vector(152.302,20.3109,30.6247),
		}
		
		for _, v in pairs(Pos) do 
			if math.random(0,1) == 1 then
				local effectdata = EffectData()
					effectdata:SetOrigin( v )
					effectdata:SetAngles( Angle(-90,20,0) )
					effectdata:SetMagnitude( math.Clamp(THR,0.2,1) ) 
					effectdata:SetEntity( self )
				util.Effect( "lfs_exhaust", effectdata )
			end
			
			if math.random(0,1) == 1 then
				local vr = v
				vr.y = -v.y
				
				local effectdata = EffectData()
					effectdata:SetOrigin( vr )
					effectdata:SetAngles( Angle(-90,-20,0) )
					effectdata:SetMagnitude( math.Clamp(THR,0.2,1) ) 
					effectdata:SetEntity( self )
				util.Effect( "lfs_exhaust", effectdata )
			end
		end
	end
end
