
include("shared.lua")

-- function ENT:CalcEngineSound()
	-- local RPM = self:GetRPM()
	-- local Pitch = (RPM - self.IdleRPM) / (self.LimitRPM - self.IdleRPM)
	
	-- if self.ENG then
		-- self.ENG:ChangePitch(  math.Clamp( 60 + Pitch * 40,0,255) )
		-- self.ENG:ChangeVolume( math.Clamp( Pitch, 0.5,1) )
		-- self.ENG:SetSoundLevel(120)
	-- end
-- end

function ENT:Initialize()
	-- if !istable(self.RotorPos) then
		-- self.RotorPos = {self.RotorPos}
	-- end
	self.snd = {}
end

function ENT:CalcEngineSound( RPM, Pitch, Doppler )
	local Low = 1500
	local Mid = 5000
	
	if self.snd.RPM1 then
		self.snd.RPM1:ChangePitch( math.Clamp(100 + Pitch * 300 + Doppler,0,255) )
		self.snd.RPM1:ChangeVolume( RPM < Low and 1 or 0, 1.5 )
	end
	
	if self.snd.RPM2 then
		self.snd.RPM2:ChangePitch(  math.Clamp(20 + Pitch * 270 + Doppler,0,255) )
		self.snd.RPM2:ChangeVolume( (RPM >= Low and RPM < Mid) and 1 or 0, 1.5 )
	end
	
	if self.snd.RPM2_DIST then
		self.snd.RPM2_DIST:ChangePitch(  math.Clamp(math.Clamp(  50 + Pitch * 60, 50,255) + Doppler,0,255) )
		self.snd.RPM2_DIST:ChangeVolume( math.Clamp(Pitch * 6, 0,1))
	end
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.snd.RPM1 = CreateSound(self,"^gredwitch/a10_lfs/a10_idle.wav")
		-- self.snd.RPM1_DIST = CreateSound(self,"^gredwitch/a10_lfs/a10_idle_far.wav")
		self.snd.RPM2 = CreateSound(self,"^gredwitch/a10_lfs/a10_max.wav")
		self.snd.RPM2_DIST = CreateSound(self,"^gredwitch/a10_lfs/a10_max_far.wav")
		
		for k,v in pairs (self.snd) do
			v:PlayEx(0,0)
			v:SetSoundLevel(125)
		end
	else
		self:SoundStop()
	end
end

function ENT:SoundStop()
	for k,v in pairs(self.snd) do
		v:Stop()
	end
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

function ENT:AnimFins()
	local FT = FrameTime() * 10
	local Pitch = self:GetRotPitch()
	local Yaw = self:GetRotYaw()
	local Roll = -self:GetRotRoll()
	
	self.smPitch = self.smPitch and self.smPitch + (Pitch - self.smPitch) * FT or 0
	self.smYaw = self.smYaw and self.smYaw + (Yaw - self.smYaw) * FT or 0
	self.smRoll = self.smRoll and self.smRoll + (Roll - self.smRoll) * FT or 0
	self:ManipulateBoneAngles( 2, Angle( self.smRoll,0,0) )
	self:ManipulateBoneAngles( 5, Angle( self.smRoll,0,0) )
	
	self:ManipulateBoneAngles( 20, Angle( 0,0,self.smPitch) )
	self:ManipulateBoneAngles( 19, Angle( 0,0,self.smPitch) )
	
	self:ManipulateBoneAngles( 17, Angle( self.smYaw,0,0 ) )
	self:ManipulateBoneAngles( 18, Angle( self.smYaw,0,0 ) )
	
	local RPM = self:GetRPM()
	local RPMPercent = (RPM / self.LimitRPM)*90
	local RPMAng = Angle(-(RPMPercent*3.6)-0,0,0)
	local RPMAngAlt = Angle(-(RPMPercent*2.9)-0,0,0)
	self:ManipulateBoneAngles(50,RPMAng) -- FAN RPM %
	self:ManipulateBoneAngles(51,RPMAng) -- FAN RPM %
	RPM = Angle(-(RPM/1000)*36)
	self:ManipulateBoneAngles(52,RPMAngAlt) -- FAN RPM %
	self:ManipulateBoneAngles(53,RPM) -- FAN RPM
	self:ManipulateBoneAngles(77,RPMAngAlt) -- FAN RPM %
	self:ManipulateBoneAngles(78,RPM) -- FAN RPM %
	
	local VertANG = Angle(((-self:GetVelocity().z/24)-170),0,0)
	self:ManipulateBoneAngles(33,VertANG) -- Vertical speed
	
	local METER_IN_UNIT = 0.01905
	local FEET_IN_METER = 3.28084
	local METER_IN_FEET = 3.281
	local speed_meters = self:GetVelocity():Length()*METER_IN_UNIT -- Speed in m/s
	local speed_knots = speed_meters * 1.94384 -- Convert to knots
	self:ManipulateBoneAngles(31,Angle((-speed_knots*0.36)+15)) -- Speed in knots
	self:ManipulateBoneAngles(30,Angle((-speed_knots*0.72)+15)) -- Speed in knots
	self:ManipulateBoneAngles(32,Angle((-speed_knots*0.96)+85)) -- Speed in knots
	local ang = self:GetAngles()
	local Pitch = -ang.p
	if Pitch > 0 && Pitch > 90 then
		Pitch = 90 
	elseif
		Pitch < 0 && Pitch < -90 then Pitch = -90
	end
	Pitch = Angle(0,0,Pitch)
	local Roll = Angle(0,-ang.r)
	self:ManipulateBoneAngles(24,Roll+Pitch) -- Horizon 1
	self:ManipulateBoneAngles(25,Pitch+Roll) -- Horizon 2
	local Yaw = Angle(-ang.y)
	local Yaw1 = Angle(0,-ang.y)
	self:ManipulateBoneAngles(67,Yaw) -- compass 1
	self:ManipulateBoneAngles(76,Yaw) -- compass 2
	local G = Angle(-(speed_meters*speed_meters + 0.1)/360 + 225)
	local G2 = Angle(G*10 - Angle(225))
	self:ManipulateBoneAngles(74,G) -- compass 2
	self:ManipulateBoneAngles(75,G2) -- compass 2

	local trace = {
		start = self:GetPos(),
		endpos = self:GetPos()-Vector(0,0,10000/FEET_IN_METER/METER_IN_UNIT),
		mask = MASK_SOLID_BRUSHONLY+MASK_WATER
	}
	trace = util.TraceLine(trace)
	if trace.Hit then
		self.altitude = trace.Fraction*10000
	end
	local alt = Angle(-self.altitude)
	self:ManipulateBoneAngles(34,(alt/100)*METER_IN_FEET)
	local alt = Angle(0,0,self.altitude)
	self:ManipulateBoneAngles(35,(alt/1000)*METER_IN_FEET)
	self:ManipulateBoneAngles(36,(alt/100)*METER_IN_FEET)
	self:ManipulateBoneAngles(37,(alt/10)*METER_IN_FEET)
	
	self:ManipulateBoneAngles(38,(alt/100)*1.4)
	self:ManipulateBoneAngles(39,(alt/10)*1.4)
	self:ManipulateBoneAngles(40,(alt)*1.4)
	local h = Angle(os.date("%H")+((os.date("%M")*0.0166)))
	local m = Angle(os.date("%M"))
	self:ManipulateBoneAngles(27,-h*36)
	self:ManipulateBoneAngles(26,m*12)
	local Throttle = Angle(0,0,-(math.max( math.Round( ((self:GetRPM() - self:GetIdleRPM()) / (self:GetMaxRPM() - self:GetIdleRPM())) * 100, 0) ,0))+90)
	self:ManipulateBoneAngles(79,Throttle)
	self:ManipulateBoneAngles(80,Throttle)
	-- local 
	self:ManipulateBoneAngles(81,Angle(0,self.smRoll,self.smPitch/3))
	
end

function ENT:AnimRotor()
	local RPM = self:GetRPM()
	local PhysRot = RPM < 700
	self.RPM = self.RPM and (self.RPM + RPM * FrameTime() * (PhysRot and 3 or 1)) or 0
	
	local Rot = Angle(self.RPM,0,0)
	Rot:Normalize() 
	
	self:ManipulateBoneAngles( 13, Rot )
	self:ManipulateBoneAngles( 14, Rot )
end

function ENT:AnimCabin()
	local bOn = self:GetActive()
	
	local TVal = bOn and 0 or 1
	local Speed = FrameTime() * 4
	
	self.SMcOpen = self.SMcOpen and self.SMcOpen + math.Clamp(TVal - self.SMcOpen,-Speed,Speed) or 0
	self:ManipulateBoneAngles(1 , Angle(0,0,self.SMcOpen * 80) )
	
end

function ENT:AnimLandingGear()
	if !self.SMF then self.SMF = 0 end
	if !self.SMG then self.SMG = 0 end
	
	self.SMG = self.SMG and self.SMG + (-90 *  (1 - self:GetLGear()) - self.SMG) * FrameTime() * 8 or 0
	self.SMF = self.SMF and self.SMF + (-10 *  (1 - self:GetLGear()) - self.SMF) * FrameTime() * 8 or 0
	
	local flaps = Angle(0,0,-10 - self.SMF)
	self:ManipulateBoneAngles(15,flaps)
	self:ManipulateBoneAngles(16,flaps)
	
	local maingears = Angle(0,0,-90 - self.SMG)
	self:ManipulateBoneAngles(9,maingears)
	self:ManipulateBoneAngles(21,maingears)
	
	fgear_2 = Angle(0,0,-90 - self.SMG)
	fgear_3 = Angle(-90 - self.SMG,0,0)
	self:ManipulateBoneAngles(10,fgear_2)
	self:ManipulateBoneAngles(12,fgear_3)
end

function ENT:ExhaustFX()
	--[[ function gets called each frame by the base script. you can do whatever you want here ]]--
end
