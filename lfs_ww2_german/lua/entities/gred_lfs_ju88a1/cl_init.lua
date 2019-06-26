
include("shared.lua")

function ENT:LFSCalcViewThirdPerson( view ) -- modify third person camera view here

	local ply = LocalPlayer()
	if ply == self:GetDriver() then
		
	elseif ply == self:GetGunner() then
	elseif ply == self:GetGunter() then
	else
		-- everyone elses view
	end
	
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
	
	if self.snd.DIST then
		self.snd.DIST:ChangePitch(  math.Clamp(math.Clamp( 50 + Pitch * 60, 50,255) + Doppler,0,255) )
		self.snd.DIST:ChangeVolume( math.Clamp( -1 + Pitch * 6, 0,1) )
	end
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.snd.RPM0 = CreateSound(self,"JU88_RPM0")
		self.snd.RPM1 = CreateSound(self,"JU88_RPM1")
		self.snd.RPM2 = CreateSound(self,"JU88_RPM2")
		self.snd.DIST = CreateSound(self,"JU88_DIST")
		
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

function ENT:SoundStop(keepSiren)
	for k,v in pairs(self.snd) do
		if not (keepSiren and (v == self.snd.siren_loop or v == self.snd.siren_stop)) then
			v:Stop()
		end
	end
end

function ENT:AnimFins()
	if not self.Bones then self:CreateBones() return end
	local FT = FrameTime() * 10
	local Pitch = self:GetRotPitch()
	local Yaw = self:GetRotYaw()
	local Roll = -self:GetRotRoll()
	
	self.smPitch = self.smPitch and self.smPitch + (Pitch - self.smPitch) * FT or 0
	self.smYaw = self.smYaw and self.smYaw + (Yaw - self.smYaw) * FT or 0
	self.smRoll = self.smRoll and self.smRoll + (Roll - self.smRoll) * FT or 0
	
	-- self:ManipulateBoneAngles(self.Bones.stick_ailerons, Angle( 0,-self.smRoll/2,self.smPitch/-2) )
	self:ManipulateBoneAngles(self.Bones.aileron_l, Angle( -self.smRoll,0,0) )
	self:ManipulateBoneAngles(self.Bones.aileron_r, Angle( -self.smRoll,0,0) )
	self:ManipulateBoneAngles(self.Bones.rudder, Angle( -self.smYaw ) )
	-- self:ManipulateBoneAngles(self.Bones.pedals1, Angle( self.smYaw/2) )
	-- self:ManipulateBoneAngles(self.Bones.pedals2, Angle( self.smYaw/2) )
	self:ManipulateBoneAngles(self.Bones.elevator, Angle( -self.smPitch) )

	
	local METER_IN_UNIT = 0.01905
	local FEET_IN_METER = 3.28084
	local METER_IN_FEET = 3.281
	speed_meters = (self:GetVelocity():Length()*METER_IN_UNIT)*-2 -- Speed in m/s
	self:ManipulateBoneAngles(self.Bones.speed,Angle(0,speed_meters))
	
	local VertANG = Angle(0,0,((self:GetVelocity().z/24)))
	self:ManipulateBoneAngles(self.Bones.vario,VertANG)
	
	local ang = self:GetAngles()
	local Pitch = -ang.p
	if Pitch > 0 && Pitch > 90 then
		Pitch = 90 
	elseif
		Pitch < 0 && Pitch < -90 then Pitch = -90
	end
	Pitch = Angle(-Pitch)
	local Roll = Angle(0,-ang.r+90)
	self:ManipulateBoneAngles(self.Bones.aviahorizon_pitch,Roll+Pitch)
	self:ManipulateBoneAngles(self.Bones.compass,Angle(ang.y))

	local r = ang.r
	if r > 15 then r = 15 elseif r < -15 then r = -15 end
	self:ManipulateBoneAngles(self.Bones.bank,Angle(0,r))
	self:ManipulateBoneAngles(self.Bones.bank1,Angle(0,r))
	self:ManipulateBoneAngles(self.Bones.turn,Angle(0,r))
	
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
	self:ManipulateBoneAngles(self.Bones.altitude_min,alt)
	local RPM = self:GetRPM()
	local rpm = Angle(0,-RPM/10)
	self:ManipulateBoneAngles(self.Bones.rpm,rpm) -- RPM
	self:ManipulateBoneAngles(self.Bones.rpm1,rpm) -- RPM
	local Throttle = Angle(0,0,(math.max( math.Round( ((RPM - self:GetIdleRPM()) / (self:GetMaxRPM() - self:GetIdleRPM())) * 100, 0) ,0)))
	-- print(Throttle)
	self:ManipulateBoneAngles(self.Bones.manifold_pressure,Angle(0,-Throttle.r*1.5))
	self:ManipulateBoneAngles(self.Bones.manifold_pressure1,Angle(0,-Throttle.r*1.5))
	
	---------------------------------------------
	
	local Driver = self:GetDriver()
	local DriverValid = IsValid(Driver)
	local Gunner = self:GetGunner()
	local Gunter = self:GetGunter()
	local HasGunner = IsValid(Gunner)
	local HasGunter = IsValid(Gunter)
	
	
	
	if DriverValid or HasGunner then
		if HasGunner then Driver = Gunner end
		
		local EyeAngles = self:WorldToLocalAngles( Driver:EyeAngles() )
		EyeAngles:RotateAroundAxis( EyeAngles:Up(), 180 )
		
		local Yaw = math.Clamp( EyeAngles.y,-45,45)
		local Pitch = math.Clamp( EyeAngles.p,-5,45 )
		
		if not Driver:KeyDown( IN_WALK ) and not HasGunner then
			Yaw = 0
			Pitch = 0
		end
		
		self:ManipulateBoneAngles(self.Bones.mg_rear, Angle(Yaw,0,Pitch))
	end
	if DriverValid or HasGunter then
		if HasGunter then Driver = Gunter end
		
		local EyeAngles = self:WorldToLocalAngles( Driver:EyeAngles() )
		EyeAngles:RotateAroundAxis( EyeAngles:Up(), 180 )
		
		local Yaw = math.Clamp( EyeAngles.y,-45,45)
		local Pitch = math.Clamp( EyeAngles.p,-45,5 )
		if not Driver:KeyDown( IN_WALK ) and not HasGunter then
			Yaw = 0
			Pitch = 0
		end
		
		self:ManipulateBoneAngles(self.Bones.mg_gunter, Angle(Yaw,0,Pitch))
	end
	local TVal = self:GetIsBombing() and 90 or 0
	local Speed = FT*20
	self.AnimHatch = self.AnimHatch and self.AnimHatch + math.Clamp(TVal - self.AnimHatch,-Speed,Speed) or 0
	self:ManipulateBoneAngles(self.Bones.hatch1_fl,Angle(-self.AnimHatch))
	self:ManipulateBoneAngles(self.Bones.hatch1_fr,Angle(self.AnimHatch))
	self:ManipulateBoneAngles(self.Bones.hatch2_fl,Angle(self.AnimHatch))
	self:ManipulateBoneAngles(self.Bones.hatch2_fr,Angle(-self.AnimHatch))
	if self:GetLoadout() > 1 then
		self:ManipulateBoneAngles(self.Bones.hatch1_bl,Angle(-self.AnimHatch))
		self:ManipulateBoneAngles(self.Bones.hatch1_br,Angle(self.AnimHatch))
		self:ManipulateBoneAngles(self.Bones.hatch2_bl,Angle(self.AnimHatch))
		self:ManipulateBoneAngles(self.Bones.hatch2_br,Angle(-self.AnimHatch))
	end
end

function ENT:AnimRotor()
	if not self.Bones then self:CreateBones() return end
	
	local RPM = self:GetRPM()
	local PhysRot = RPM < 700
	self.RPM = self.RPM and (self.RPM + RPM * FrameTime() * (PhysRot and 3 or 1)) or 0
	
	local Rot = Angle(0,self.RPM)
	Rot:Normalize() 
	
	self:ManipulateBoneAngles( self.Bones.prop_l, Rot )
	self:ManipulateBoneAngles( self.Bones.prop_r, Rot )
	self:SetBodygroup(0, PhysRot and 0 or 1 ) 
	self:SetBodygroup(1, PhysRot and 0 or 1 ) 
end

function ENT:AnimLandingGear()
	
end

function ENT:ExhaustFX()
	if not self:GetEngineActive() then return end
	
	self.nextEFX = self.nextEFX or 0
	
	local THR = (self:GetRPM() - self.IdleRPM) / (self.LimitRPM - self.IdleRPM)
	
	if self.nextEFX < CurTime() then
		self.nextEFX = CurTime() + 0.05 + (1 - THR) / 10
		-- -91.1258
		local Pos = { -- +8.304
			Vector(162.787,151.849,69.2026),
			Vector(182.122,150.115,69.1029),
			Vector(190.426,150.115,69.1029),
			Vector(198.73,150.115,69.1029),
			Vector(207.034,150.115,69.1029),
			Vector(215.338,150.115,69.1029),
			Vector(223.642,150.115,69.1029),
			
			Vector(162.787,88.951,69.2026),
			Vector(182.122,91.1258,69.1029),
			Vector(190.426,91.1258,69.1029),
			Vector(198.73,91.1258,69.1029),
			Vector(207.034,91.1258,69.1029),
			Vector(215.338,91.1258,69.1029),
			Vector(223.642,91.1258,69.1029),
		}
		
		for _, v in pairs(Pos) do 
			if math.random(0,1) == 1 then
				local effectdata = EffectData()
					effectdata:SetOrigin( v )
					effectdata:SetAngles( Angle(-90,-20,0) )
					effectdata:SetMagnitude( math.Clamp(THR,0.2,1) ) 
					effectdata:SetEntity( self )
				util.Effect( "lfs_exhaust", effectdata )
			end
			
			if math.random(0,1) == 1 then
				local vr = v
				vr.y = -v.y
				
				local effectdata = EffectData()
					effectdata:SetOrigin( vr )
					effectdata:SetAngles( Angle(-90,20,0) )
					effectdata:SetMagnitude( math.Clamp(THR,0.2,1) ) 
					effectdata:SetEntity( self )
				util.Effect( "lfs_exhaust", effectdata )
			end
		end
	end
end
