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

function ENT:LFSHudPaint( X, Y, data ) -- driver only
	draw.SimpleText( "MISSILES", "LFS_FONT", 10, 135, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( self:GetMissileCount(), "LFS_FONT", 120, 135, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
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
	self.inited = true
	self.snd = {}
	gred.UpdateBoneTable(self)
end
local BaseClass = baseclass.Get("lunasflightschool_basescript_heli")
function ENT:Think()
	if not self.inited then self:Initialize() return end
	return BaseClass.Think(self)
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
	
	local roll = Angle(-self.smRoll*30)
	local pitch = Angle(self.smPitch*15)
	local yaw = Angle(self.smYaw*20)
	gred.ManipulateBoneAngles(self,"stick_pitch", pitch )
	gred.ManipulateBoneAngles(self,"stick_roll", roll )
	
	
	gred.ManipulateBoneAngles(self,"pedal_r", yaw)
	gred.ManipulateBoneAngles(self,"pedal_l", yaw)
	
	local Throttle = Angle(0,0,(math.max(
	math.Round( ((self:GetRPM() - self:GetIdleRPM()) / (self:GetMaxRPM() - self:GetIdleRPM())) * 100, 0)))/-8)
	gred.ManipulateBoneAngles(self,"collective1",Throttle)
	gred.ManipulateBoneAngles(self,"collective2",Throttle)
	------------------------------
	
	local Driver = self:GetDriver()
	local Gunner = self:GetGunner()
	local DriverValid = IsValid(Driver)
	local GunnerValid = IsValid(Gunner)
	local HasGunner = GunnerValid or (!GunnerValid and DriverValid && Driver:lfsGetInput("FREELOOK"))
	
	if not DriverValid and not GunnerValid and not HasGunner then
		gred.ManipulateBoneAngles(self,"gun_yaw", Angle(0))
		gred.ManipulateBoneAngles(self,"gun_pitch", Angle(0,0))
	elseif HasGunner then
		if GunnerValid then Driver = Gunner end
		local EyeAngles = self:WorldToLocalAngles( Driver:EyeAngles() )
		local e = EyeAngles
		EyeAngles:RotateAroundAxis( EyeAngles:Up(), 180 )
		e:RotateAroundAxis( EyeAngles:Right(), 180 )
		local Pitch = math.Clamp( -EyeAngles.p,-60,0 )
		local Yaw = -math.Clamp( e.y,-30,30 )
		gred.ManipulateBoneAngles(self,"gun_yaw", Angle(Yaw))
		gred.ManipulateBoneAngles(self,"gun_pitch", Angle(Pitch))
	else
		gred.ManipulateBoneAngles(self,"gun_yaw", Angle(0))
		gred.ManipulateBoneAngles(self,"gun_pitch", Angle(0,0))
	end
end

function ENT:AnimLandingGear()
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
		self:SetBodygroup(0,1)
		return
	end
	
	local RPM = math.min(self:GetRPM() * 5,self:GetMaxRPM())
	
	local PhysRot = RPM < 1800
	self.RPM = self.RPM and (self.RPM + RPM * FrameTime() * 0.5) or 0
	
	local Rot1 = Angle( -self.RPM,0,0)
	Rot1:Normalize() 
	
	local Rot2 = Angle(self.RPM)
	Rot2:Normalize() 
	
	gred.ManipulateBoneAngles(self,"toprotor", Rot1 )
	gred.ManipulateBoneAngles(self,"tailrotor", Rot2 )
end

function ENT:AnimCabin()
end

function ENT:AnimLandingGear()
end

function ENT:ExhaustFX()
end