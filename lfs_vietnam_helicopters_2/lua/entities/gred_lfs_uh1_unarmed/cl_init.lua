--DO NOT EDIT OR REUPLOAD THIS FILE

include("shared.lua")

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
		self.ENG = CreateSound( self, "UH1_ENGINE" )
		self.ENG:Play()
		-- self.ENG:PlayEx(0,0)
	else
		self:SoundStop()
	end
end

function ENT:Initialize()
	self.snd = {}
	gred.UpdateBoneTable(self)
end


local METER_IN_UNIT = 0.01905
local FEET_IN_METER = 3.28084
ENT.roll = 0
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
	
	local roll = Angle(self.smPitch*5,self.smRoll*30)
	
	gred.ManipulateBoneAngles(self,"Stick_Joint_R", roll )
	gred.ManipulateBoneAngles(self,"Stick_Joint_L", roll )
	
	local yaw = Angle(self.smYaw*20)
	
	gred.ManipulateBoneAngles(self,"Pedal_R2_Joint", -yaw)
	gred.ManipulateBoneAngles(self,"Pedal_R1_Joint", yaw)
	gred.ManipulateBoneAngles(self,"Pedal_L1_Joint", -yaw)
	gred.ManipulateBoneAngles(self,"Pedal_L2_Joint", yaw)
	local RPM = self:GetRPM()
	local IdleRPM = self:GetIdleRPM()
	local Throttle = Angle(
	(math.max( math.Round( ((RPM - IdleRPM) / (self:GetMaxRPM() - IdleRPM)) * 100, 0)))/8)
	
	gred.ManipulateBoneAngles(self,"Collective_Joint_R", Throttle)
	gred.ManipulateBoneAngles(self,"Collective_Joint_L", Throttle)
	
	gred.ManipulateBoneAngles(self,"Dash_Needle12_Joint",Angle(0,-RPM/10))
	
	local vel = (self:GetVelocity():Length()*METER_IN_UNIT)*1.94384
	gred.ManipulateBoneAngles(self,"Dash_Needle1_Joint",Angle(0,0,vel))
	
	local ang = self:GetAngles()
	gred.ManipulateBoneAngles(self,"Dash_Gyro_Joint",Angle(ang.p,ang.r))
	
	local trace = {
		start = self:GetPos(),
		endpos = self:GetPos()-Vector(0,0,10000),
		mask = MASK_SOLID_BRUSHONLY+MASK_WATER
	}
	trace = util.TraceLine(trace)
	if trace.Hit then
		self.altitude = trace.Fraction*10000
	end
	
	local alt = (self.altitude/10)/2.8
	gred.ManipulateBoneAngles(self,"Dash_Needle20_Joint",Angle(0,-alt))
	gred.ManipulateBoneAngles(self,"Dash_Needle16_Joint",Angle(0,-alt))
	-- gred.ManipulateBoneAngles(self,"alt2,Angle(alt))
	-- gred.ManipulateBoneAngles(self,"altk1,Angle(alt/10))
	-- gred.ManipulateBoneAngles(self,"altk2,Angle(alt/10))
	
	-- gred.ManipulateBoneAngles(self,"bearing1,Angle(0,0,ang.y))
	-- gred.ManipulateBoneAngles(self,"bearing2,Angle(0,0,ang.y))
	
	local VertANG = (-self:GetVelocity().z/7)
	gred.ManipulateBoneAngles(self,"Dash_Needle3_Joint",Angle(0,VertANG-45))
	gred.ManipulateBoneAngles(self,"Dash_Needle18_Joint",Angle(0,VertANG))
	
	-- local s = Angle(0,os.date("%S"))
	-- local m = Angle(0,os.date("%M")+(s.y*0.0166))
	-- local h = Angle(0,os.date("%H")+(m.y*0.0166))
	
	-- gred.ManipulateBoneAngles(self,"clock_m,Angle(0,0,h*9))
	-- gred.ManipulateBoneAngles(self,"clock_h,Angle(0,0,m*6))
	
	------------------------------
	
	-- local Driver = self:GetDriver()
	-- local Gunner = self:GetGunner()
	-- local DriverValid = IsValid(Driver)
	-- local GunnerValid = IsValid(Gunner)
	-- local HasGunner = GunnerValid or (!GunnerValid and DriverValid && Driver:lfsGetInput("FREELOOK"))
	
	-- if not DriverValid and not GunnerValid and not HasGunner then
		-- gred.ManipulateBoneAngles(self,"turret, Angle(0))
		-- gred.ManipulateBoneAngles(self,"turret_pitch, Angle(0,0))
	-- elseif HasGunner then
		-- if GunnerValid then Driver = Gunner end
		-- local EyeAngles = self:WorldToLocalAngles( Driver:EyeAngles() )
		-- local e = EyeAngles
		-- EyeAngles:RotateAroundAxis( EyeAngles:Up(), 180 )
		-- e:RotateAroundAxis( EyeAngles:Right(), 180 )
		-- local Pitch = math.Clamp( -EyeAngles.p,-50,15 )
		-- local Yaw = math.Clamp( e.y,-40,40 )
		-- gred.ManipulateBoneAngles(self,"turret, Angle(Yaw))
		-- gred.ManipulateBoneAngles(self,"turret_pitch, Angle(0,Pitch))
	-- else
		-- gred.ManipulateBoneAngles(self,"turret, Angle(0))
		-- gred.ManipulateBoneAngles(self,"turret_pitch, Angle(0,0))
	-- end
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
	
	local PhysRot = RPM < 1800
	self.RPM = self.RPM and (self.RPM + RPM * FrameTime() * 0.5) or 0
	
	local Rot1 = Angle( 0,0,-self.RPM)
	Rot1:Normalize() 
	
	local Rot2 = Angle(0,0,self.RPM)
	Rot2:Normalize() 
	
	gred.ManipulateBoneAngles(self,"Mainrotor_Joint", Rot1 )
	gred.ManipulateBoneAngles(self,"Tailrotor_Joint", Rot2 )
	self:SetBodygroup(0, PhysRot and 0 or 1 ) 
	self:SetBodygroup(1, PhysRot and 0 or 1 ) 
end

function ENT:AnimCabin()
end

function ENT:AnimLandingGear()
end

function ENT:ExhaustFX()
end