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
	
	local roll = Angle(self.smRoll*-30,self.smPitch*5)
	
	gred.ManipulateBoneAngles(self,"stick_Joint_R", roll )
	gred.ManipulateBoneAngles(self,"stick_Joint_L", roll )
	
	local yaw = Angle(self.smYaw*20)
	
	gred.ManipulateBoneAngles(self,"pedal1", yaw)
	gred.ManipulateBoneAngles(self,"pedal2", yaw)
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
	
	local Rot2 = Angle(0,self.RPM)
	Rot2:Normalize() 
	
	gred.ManipulateBoneAngles(self,"main_rotor", Rot1 )
	gred.ManipulateBoneAngles(self,"tail_rotor", Rot2 )
	self:SetBodygroup(0, PhysRot and 0 or 1 ) 
	-- self:SetBodygroup(1, PhysRot and 0 or 1 ) 
end

function ENT:AnimCabin()
end

function ENT:AnimLandingGear()
end

function ENT:ExhaustFX()
end