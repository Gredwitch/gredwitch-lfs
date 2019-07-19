
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
function ENT:LFSHudPaint( X, Y, data ) -- driver only
	draw.SimpleText( "MG151/20", "LFS_FONT", 10, 135, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( self:GetAmmoCannon(), "LFS_FONT", 120, 135, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	-- draw.SimpleText( "MG151/20", "LFS_FONT", 10, 160, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	-- draw.SimpleText( self:GetAmmoCannon(), "LFS_FONT", 120, 160, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
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
	
	if self.snd.DIST then
		self.snd.DIST:ChangePitch(  math.Clamp(math.Clamp( 50 + Pitch * 60, 50,255) + Doppler,0,255) )
		self.snd.DIST:ChangeVolume( math.Clamp( -1 + Pitch * 6, 0,1) )
	end
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.snd.RPM0 = CreateSound(self,"FW190_RPM0")
		self.snd.RPM1 = CreateSound(self,"FW190_RPM1")
		self.snd.RPM2 = CreateSound(self,"FW190_RPM2")
		self.snd.DIST = CreateSound(self,"FW190_DIST")
		
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
	gred.UpdateBoneTable(self)
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
	if not self.Bones then gred.UpdateBoneTable(self) return end
	local FT = FrameTime() * 10
	local Pitch = self:GetRotPitch()
	local Yaw = self:GetRotYaw()
	local Roll = -self:GetRotRoll()
	
	---------------------------
	
	self.smPitch = self.smPitch and self.smPitch + (Pitch - self.smPitch) * FT or 0
	self.smYaw = self.smYaw and self.smYaw + (Yaw - self.smYaw) * FT or 0
	self.smRoll = self.smRoll and self.smRoll + (Roll - self.smRoll) * FT or 0
	gred.ManipulateBoneAngles(self,"sticka_ailerons",Angle( 0,-self.smRoll,-self.smPitch/ 4) )
	gred.ManipulateBoneAngles(self,"aileron_l",Angle( self.smRoll,0,0) )
	gred.ManipulateBoneAngles(self,"aileron_r",Angle( self.smRoll,0,0) )
	gred.ManipulateBoneAngles(self,"rudder",Angle( -self.smYaw ) )
	gred.ManipulateBoneAngles(self,"pedal1",Angle( 0,0,-self.smYaw/3 ) )
	gred.ManipulateBoneAngles(self,"pedal2",Angle( 0,0,self.smYaw/3 ) )
	gred.ManipulateBoneAngles(self,"elevator",Angle( 0,0,self.smPitch) )
	
	---------------------------
	
	local s = Angle(0,os.date("%S"))
	local m = Angle(0,os.date("%M")+(s.y*0.0166))
	local h = Angle(0,os.date("%H")+(m.y*0.0166))
	gred.ManipulateBoneAngles(self,"clock_hour",h*9)
	gred.ManipulateBoneAngles(self,"clock_min",m*6)
	gred.ManipulateBoneAngles(self,"clock_sec",s*6)
	
	---------------------------
	
	local Throttle = (math.max( math.Round( ((self:GetRPM() - self:GetIdleRPM()) / (self:GetMaxRPM() - self:GetIdleRPM())) * 100, 0)))
	if Throttle < 0 then Throttle = 0 end
	gred.ManipulateBonePosition(self,"throttle",Vector(0,0,Throttle/10))
	if Throttle > 100 then Throttle = Throttle * 1.2 end
	gred.ManipulateBoneAngles(self,"manifold_pressure",Angle(Throttle*1.5))
	
	---------------------------
	
	local METER_IN_UNIT = 0.01905
	local FEET_IN_METER = 3.28084
	local METER_IN_FEET = 3.281
	local ang = self:GetAngles()
	
	---------------------------
	
	speed_meters = (self:GetVelocity():Length()*METER_IN_UNIT)*-2 -- Speed in m/s
	gred.ManipulateBoneAngles(self,"speed",Angle(0,speed_meters))
	
	---------------------------
	gred.ManipulateBoneAngles(self,"aviahorizon_pitch",Angle(0,ang.r,ang.p))
	local r = ang.r
	if r > 15 then r = 15 elseif r < -15 then r = -15 end
	gred.ManipulateBoneAngles(self,"bank",Angle(0,r))
	gred.ManipulateBoneAngles(self,"turn",Angle(0,r))
	gred.ManipulateBoneAngles(self,"vario",Angle((self:GetVelocity().z/24)))
	
	---------------------------
	
	gred.ManipulateBoneAngles(self,"rpm",Angle(0,-self:GetRPM()/10)) -- RPM
	
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
	
	local alt = Angle(0,-self.altitude/7) -- Altitude in M
	gred.ManipulateBoneAngles(self,"altitude_hour",Angle(-alt.y/100))
	gred.ManipulateBoneAngles(self,"altitude_min",alt)
	
	
end

function ENT:AnimRotor()
	if not self.Bones then gred.UpdateBoneTable(self) return end
	local RPM = self:GetRPM()
	local PhysRot = RPM < 700
	self.RPM = self.RPM and (self.RPM + RPM * FrameTime() * (PhysRot and 3 or 1)) or 0
	
	local Rot = Angle(0,self.RPM)
	Rot:Normalize() 
	gred.ManipulateBoneAngles(self,"propeller", Rot )
	self:SetBodygroup(0, PhysRot and 0 or 1 ) 
end

function ENT:AnimCabin()
	if not self.Bones then gred.UpdateBoneTable(self) return end
	local bOn = self:GetActive()
	
	local TVal = bOn and 0 or 1
	local Speed = FrameTime() * 4
	self.SMcOpen = self.SMcOpen and self.SMcOpen + math.Clamp(TVal - self.SMcOpen,-Speed,Speed) or 0
	self:ManipulateBonePosition(10,Vector(0,0,-self.SMcOpen * 28))
	if self.SMcOpen == 0 then
		self:ManipulateBoneScale(7,Vector(1,self.SMcOpen/1.25,1))
	else
		self:ManipulateBoneScale(7,Vector(1,self.SMcOpen,1))
	end
	self:ManipulateBoneAngles(7,Angle(0,0,self.SMcOpen*1.5))
	
end

function ENT:AnimLandingGear()
	if not self.Bones then gred.UpdateBoneTable(self) return end
	self.SMLG = self.SMLG and self.SMLG + ((1 - self:GetLGear()) - self.SMLG) * FrameTime() * 8 or 0
	self.SMRG = self.SMRG and self.SMRG + ((1 - self:GetRGear()) - self.SMRG) * FrameTime() * 8 or 0
	
	local gExp = self.SMRG ^ 40
	gred.ManipulateBoneAngles(self,"gear_r_1",Angle(0,0,-90 + 90 * self.SMRG) )
	gred.ManipulateBoneAngles(self,"gear_l_1",Angle(0,0,-90 + 90 * self.SMLG) )
	
	gred.ManipulateBoneAngles(self,"flap_l",Angle(30 + -30 * self.SMLG) )
	gred.ManipulateBoneAngles(self,"flap_r",Angle(-30 + 30 * self.SMLG) )
	
	gred.ManipulateBoneAngles(self,"gear_r_2",Angle(0,0,-90 + 90 * self.SMRG) )
	gred.ManipulateBoneAngles(self,"gear_l_2",Angle(0,0,-98 + 98 * self.SMLG) )
	
	gred.ManipulateBoneAngles(self,"gear_r_3",Angle(0,0,-110 + 110 * self.SMRG) )
	gred.ManipulateBoneAngles(self,"gear_l_3",Angle(0,0,-110 + 110 * self.SMLG) )
	
	
	gred.ManipulateBonePosition(self,"gear_b_1",Vector(0,-20 + 20 * self.SMLG) )
	
	gred.ManipulateBoneAngles(self,"gear_l_4",Angle(55 + -55 * gExp) )
	gred.ManipulateBoneAngles(self,"gear_r_4",Angle(-55 + 55 * gExp) )
end

function ENT:ExhaustFX()
	if not self:GetEngineActive() then return end
	
	self.nextEFX = self.nextEFX or 0
	
	local THR = (self:GetRPM() - self.IdleRPM) / (self.LimitRPM - self.IdleRPM)
	
	if self.nextEFX < CurTime() then
		self.nextEFX = CurTime() + 0.05 + (1 - THR) / 10
		
		local Pos = {
			Vector(85.6699,21.384,14.036),
			Vector(85.6699,-21.384,14.036),
			
			Vector(85.7139,22.33,10.692),
			Vector(85.7139,-22.33,10.692),
			
			Vector(85.7579,23.276,7.34801),
			Vector(85.7579,-23.276,7.34801),
			
			Vector(85.7359,24.354,3.58601),
			Vector(85.7359,-24.354,3.58601),
			
			Vector(85.7139,25.432,0),
			Vector(85.7139,-25.432,0),
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
