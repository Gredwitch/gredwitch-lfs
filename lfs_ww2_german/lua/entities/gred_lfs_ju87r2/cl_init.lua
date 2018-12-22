
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
		self.snd.RPM2:ChangeVolume( (RPM >= Mid and RPM < High) and 1 or 0, 1.5 )
	end
	
	if self.snd.RPM3 then
		self.snd.RPM3:ChangePitch(  math.Clamp(90 + Pitch * 50 + Doppler,0,255) * 0.8 )
		self.snd.RPM3:ChangeVolume( RPM >= High and 1 or 0, 1.5 )
	end
	
	if self.snd.DIST then
		self.snd.DIST:ChangePitch(  math.Clamp(math.Clamp( 50 + Pitch * 60, 50,255) + Doppler,0,255) )
		self.snd.DIST:ChangeVolume( math.Clamp( -1 + Pitch * 6, 0,1) )
	end
	
	local speed = self:GetVelocity():Length()*0.09144 -- Speed in km/h
	if self.snd.siren_loop then
		self.snd.siren_loop:ChangePitch(  math.Clamp( 60 + Pitch * speed/3.5 + Doppler/4,0,255) )
		self.snd.siren_loop:ChangeVolume( speed > 130 and 1 or 0, 1.5 )
		if speed > 130 then self.noSiren = false end
	end
	if self.snd.siren_stop then
		if self.noSiren then return end
		self.snd.siren_stop:ChangePitch(  math.Clamp( 60 + Pitch * speed/3.5 + Doppler/4,0,255) )
		self.snd.siren_stop:ChangeVolume( speed < 90 and 1 or 0, 1.5 )
		if speed < 130 then self.noSiren = true end
	end
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.snd.RPM0 = CreateSound(self,"JU87_RPM0")
		self.snd.RPM1 = CreateSound(self,"JU87_RPM1")
		self.snd.RPM2 = CreateSound(self,"JU87_RPM2")
		self.snd.RPM3 = CreateSound(self,"JU87_RPM3")
		self.snd.DIST = CreateSound(self,"JU87_DIST")
		
		self.snd.siren_loop = CreateSound(self,"JU87_SIREN_START")
		self.snd.siren_stop = CreateSound(self,"JU87_SIREN_STOP")
		for k,v in pairs (self.snd) do
			v:PlayEx(0,0)
		end
	else
		self:SoundStop(true)
	end
end

function ENT:Initialize()
	self.snd = {}
	self.Bones = {}
	timer.Simple(0,function()
		for i=0, self:GetBoneCount()-1 do
			self.Bones[self:GetBoneName(i)] = i
		end
		self.Inited = true
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
	if !self.Inited then return end
	
	local FT = FrameTime() * 10
	local Pitch = self:GetRotPitch()
	local Yaw = self:GetRotYaw()
	local Roll = -self:GetRotRoll()
	
	self.smPitch = self.smPitch and self.smPitch + (Pitch - self.smPitch) * FT or 0
	self.smYaw = self.smYaw and self.smYaw + (Yaw - self.smYaw) * FT or 0
	self.smRoll = self.smRoll and self.smRoll + (Roll - self.smRoll) * FT or 0
	
	self:ManipulateBoneAngles(self.Bones.stick_ailerons, Angle( 0,-self.smRoll/2,self.smPitch/-2) )
	self:ManipulateBoneAngles(self.Bones.aileron_l, Angle( self.smRoll,0,0) )
	self:ManipulateBoneAngles(self.Bones.aileron_r, Angle( self.smRoll,0,0) )
	self:ManipulateBoneAngles(self.Bones.rudder, Angle( self.smYaw ) )
	self:ManipulateBoneAngles(self.Bones.pedals1, Angle( self.smYaw/2) )
	self:ManipulateBoneAngles(self.Bones.pedals2, Angle( self.smYaw/2) )
	self:ManipulateBoneAngles(self.Bones.elevator, Angle( 0,0,self.smPitch) )

	
	local METER_IN_UNIT = 0.01905
	local FEET_IN_METER = 3.28084
	local METER_IN_FEET = 3.281
	speed_meters = (self:GetVelocity():Length()*METER_IN_UNIT)*-2 -- Speed in m/s
	self:ManipulateBoneAngles(self.Bones.speed,Angle(0,speed_meters))
	
	local VertANG = Angle(((self:GetVelocity().z/24)),0,0)
	self:ManipulateBoneAngles(self.Bones.vario,VertANG)
	
	local ang = self:GetAngles()
	local Pitch = -ang.p
	if Pitch > 0 && Pitch > 90 then
		Pitch = 90 
	elseif
		Pitch < 0 && Pitch < -90 then Pitch = -90
	end
	Pitch = Angle(0,0,-Pitch)
	local Roll = Angle(0,-ang.r)
	self:ManipulateBoneAngles(self.Bones.aviahorizon_roll,Roll+Pitch)
	self:ManipulateBoneAngles(self.Bones.compass,Angle(0,ang.y))
	self:ManipulateBoneAngles(self.Bones.compass1,Angle(ang.y))

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
	-- self:ManipulateBoneAngles(self.Bones.,alt)
	
	local s = Angle(0,os.date("%S"))
	local m = Angle(0,os.date("%M")+(s.y*0.0166))
	local h = Angle(0,os.date("%H")+(m.y*0.0166))
	self:ManipulateBoneAngles(self.Bones.clock_hour,h*9)
	self:ManipulateBoneAngles(self.Bones.clock_min,m*6)
	self:ManipulateBoneAngles(self.Bones.clock_sec,s*6)
	local Throttle = Angle(0,0,(math.max( math.Round( ((self:GetRPM() - self:GetIdleRPM()) / (self:GetMaxRPM() - self:GetIdleRPM())) * 100, 0) ,0)))
	-- print(Throttle)
	self:ManipulateBoneAngles(self.Bones.throttle,Throttle)
	self:ManipulateBoneAngles(self.Bones.prop_pitch,Throttle)
	self:ManipulateBoneAngles(self.Bones.manifold_pressure,Angle(0,-Throttle.r*1.5))
	
	---------------------------------------------
	
	local Driver = self:GetDriver()
	local Gunner = self:GetGunner()
	
	local HasGunner = IsValid( Gunner )
	
	if not IsValid( Driver ) and not HasGunner then return end
	
	if HasGunner then Driver = Gunner end
	
	local EyeAngles = self:WorldToLocalAngles( Driver:EyeAngles() )
	EyeAngles:RotateAroundAxis( EyeAngles:Up(), 180 )
	
	local Yaw = math.Clamp( EyeAngles.y,-25,25)
	local Pitch = math.Clamp( EyeAngles.p,-15,30 )
	
	if not Driver:KeyDown( IN_WALK ) and not HasGunner then
		Yaw = 0
		Pitch = 0
	end
	
	self:ManipulateBoneAngles(self.Bones.mg15, Angle(-25+Yaw,0,Pitch))
	
end

function ENT:AnimRotor()
	if !self.Inited then return end
	
	local RPM = self:GetRPM()
	local PhysRot = RPM < 700
	self.RPM = self.RPM and (self.RPM + RPM * FrameTime() * (PhysRot and 3 or 1)) or 0
	
	local Rot = Angle(0,self.RPM)
	local Rot1 = Angle(self.RPM)
	Rot:Normalize() 
	
	self:ManipulateBoneAngles( self.Bones.propeller_main, Rot )
	self:ManipulateBoneAngles( self.Bones.propeller_siren_left, Rot1 )
	self:ManipulateBoneAngles( self.Bones.propeller_siren_right, Rot1 )
	self:SetBodygroup(0, PhysRot and 0 or 1 ) 
	self:SetBodygroup(1, PhysRot and 0 or 1 ) 
	self:SetBodygroup(2, PhysRot and 0 or 1 ) 
end

function ENT:AnimCabin()
	if !self.Inited then return end
	
	local bOn = self:GetActive()
	
	local TVal = bOn and 0 or 1
	local Speed = FrameTime() * 4
	
	self.SMcOpen = self.SMcOpen and self.SMcOpen + math.Clamp(TVal - self.SMcOpen,-Speed,Speed) or 0
	self:ManipulateBonePosition(self.Bones.blister, Vector(0,0,-self.SMcOpen * 28))
	
end

function ENT:AnimLandingGear()
	if !self.Inited then return end
	
	--[[ function gets called each frame by the base script. you can do whatever you want here ]]--
end

function ENT:ExhaustFX()
	if not self:GetEngineActive() then return end
	
	self.nextEFX = self.nextEFX or 0
	
	local THR = (self:GetRPM() - self.IdleRPM) / (self.LimitRPM - self.IdleRPM)
	
	if self.nextEFX < CurTime() then
		self.nextEFX = CurTime() + 0.05 + (1 - THR) / 10
		
		local Pos = {
			Vector(89.72,27.2,95.8),
			Vector(97,27.2,95.8),
			Vector(104.38,27.2,95.8),
			Vector(111.7,27.2,95.8),
			Vector(119,27.2,95.8),
			Vector(126.34,27.2,95.8),
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
