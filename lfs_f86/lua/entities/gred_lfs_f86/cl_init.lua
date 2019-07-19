
include("shared.lua")

-- ENT.DoNotEmit	= {}
ENT.EmitNow		= {}
ENT.SoundQueue	= {}
ENT.BumpSound	= nil

function ENT:LFSHUDPaintFilter()
	local partnum = {}
	local a = 1
	if self.Parts then
		for k,v in pairs(self.Parts) do
			partnum[a] = v
			a = a + 1
		end
	end
	partnum[a] = self
	return partnum
end

function ENT:CalcEngineSound( RPM, Pitch, Doppler )
	local Low = 500
	local High = self.MaxRPM
	local Mid = High/2
	
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

function ENT:LFSCalcViewThirdPerson(view, ply)
	view.origin = ply:EyePos()
	local Parent = ply:lfsGetPlane()
	local Pod = ply:GetVehicle()
	local radius = 550
	radius = radius + radius * Pod:GetCameraDistance()
	local TargetOrigin = view.origin - view.angles:Forward() * radius  + view.angles:Up() * radius * 0.2
	local WallOffset = 4
	local tr = util.TraceHull( {
		start = view.origin,
		endpos = TargetOrigin,
		filter = function( e )
			local c = e:GetClass()
			local collide = not c:StartWith( "prop_physics" ) and not c:StartWith( "prop_dynamic" ) and not c:StartWith( "prop_ragdoll" ) and not e:IsVehicle() and not c:StartWith( "gmod_" ) and not c:StartWith( "player" ) and not e.LFS and Parent:GetCalcViewFilter(e)
			
			return collide
		end,
		mins = Vector( -WallOffset, -WallOffset, -WallOffset ),
		maxs = Vector( WallOffset, WallOffset, WallOffset ),
	} )
	view.origin = tr.HitPos
	
	if tr.Hit and not tr.StartSolid then
		view.origin = view.origin + tr.HitNormal * WallOffset
	end
	
	return view
end

function ENT:LFSCalcViewFirstPerson( view, ply )
	return view
end

function ENT:EngineActiveChanged( bActive )
	if bActive then
		self.snd.RPM0 = CreateSound(self,"F86_RPM0")
		self.snd.RPM1 = CreateSound(self,"F86_RPM1")
		self.snd.RPM2 = CreateSound(self,"F86_RPM2")
		self.snd.RPM3 = CreateSound(self,"F86_RPM3")
		self.snd.DIST = CreateSound(self,"F86_DIST")
		
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
local BaseClass = baseclass.Get("lunasflightschool_basescript")

function ENT:Think()
	local Ply = LocalPlayer()
	local ply = Ply:GetViewEntity()
	local hp = self:GetHP()
	local ct = CurTime()
	self.BumpSound = self.BumpSound or ct
	ply.NGPLAY = ply.NGPLAY or 0
	
	ply.lfsGetPlane = ply.lfsGetPlane or function() return nil end
	if ply:lfsGetPlane() != self and (ply.NGPLAY < ct) and self:GetEngineActive() then
		local vel = self:GetVelocity():Length()
		if vel >= 2600 then
			local plypos = ply:GetPos()
			local pos = self:GetPos()
			local dist = pos:Distance(plypos)
			if dist < 12000 then
				ply.NGPLAY = ct + 6
				ply:EmitSound("LFS_JET_PASSBY_CLOSE_0"..math.random(1,3))
			end
		end
	end
	
	if self.BumpSound < ct then
		for k,v in pairs(self.SoundQueue) do
			ply:EmitSound(v)
			
			table.RemoveByValue(self.SoundQueue,v)
			self.BumpSound = ct + 4
			break
		end
	end
	
	if self.IsDead then
		local Driver = self:GetDriver()
		if self.CheckDriver and Driver != self.OldDriver and !IsValid(Driver) then
			for k,v in pairs(player.GetAll()) do
				if v:lfsGetAITeam() == self.OldDriver:lfsGetAITeam() and (IsValid(v:lfsGetPlane()) or v == self.OldDriver) then
					v:EmitSound("GRED_VO_BAILOUT_0"..math.random(1,3))
				end
			end
		end
		self.CheckDriver = true
		self.OldDriver = Driver
	end
	if ply:lfsGetPlane() == self then
		if self.EmitNow.wing_r and self.EmitNow.wing_r != "CEASE" then
			self.EmitNow.wing_r = "CEASE"
			table.insert(self.SoundQueue,"GRED_VO_HOLE_RIGHT_WING_0"..math.random(1,3))
		end
		if self.EmitNow.wing_l and self.EmitNow.wing_l != "CEASE" then
			self.EmitNow.wing_l = "CEASE"
			table.insert(self.SoundQueue,"GRED_VO_HOLE_LEFT_WING_0"..math.random(1,3))
		end
		if hp == 0 then
			self.IsDead = true
		end
	end
	-- self.OldHP = hp
	BaseClass.Think(self)
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
	-- self.smRoll = Angle(self.smRoll*0.9)
	gred.ManipulateBoneAngles(self,"aileron_l",Angle(self.smRoll*0.8))
	gred.ManipulateBoneAngles(self,"aileron_r",Angle(-self.smRoll*0.8))
	gred.ManipulateBoneAngles(self,"rudder", Angle( -self.smYaw ) )
	gred.ManipulateBoneAngles(self,"elevator", Angle( -self.smPitch) )
	gred.ManipulateBoneAngles(self,"stick_ailerons", Angle( 0,-self.smRoll/1.5,-self.smPitch/ 4) )
	local pedal = Angle(self.smYaw/3 )
	gred.ManipulateBoneAngles(self,"pedal_l",pedal)
	gred.ManipulateBoneAngles(self,"pedal_r",pedal)
	
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
	gred.ManipulateBonePosition(self,throttle,Vector(0,0,Throttle/10))
	
	-------------------------
	
	
	local METER_IN_UNIT = 0.01905
	local FEET_IN_METER = 3.28084
	local METER_IN_FEET = 3.281
	local ang = self:GetAngles()
	
	-------------------------
	
	local speed_meters = (self:GetVelocity():Length()*METER_IN_UNIT/FEET_IN_METER)*-2 -- Speed in knots/h
	gred.ManipulateBoneAngles(self,"speed",Angle(0,-speed_meters))
	
	-------------------------
	local r = ang.r
	gred.ManipulateBonePosition(self,"aviahorizon_pitch",Vector(0,-ang.p/50))
	gred.ManipulateBoneAngles(self,"aviahorizon_pitch",Angle(0,r))
	if r > 15 then r = 15 elseif r < -15 then r = -15 end
	gred.ManipulateBoneAngles(self,"bank",Angle(0,r))
	gred.ManipulateBoneAngles(self,"turn",Angle(0,r))
	gred.ManipulateBoneAngles(self,"compass",Angle(0,ang.y))
	gred.ManipulateBoneAngles(self,"vario",Angle(0,0,(self:GetVelocity().z/24)))
	
	---------------------------
	local rpm = self:GetRPM()
	gred.ManipulateBoneAngles(self,"rpm",Angle(0,0,(rpm/self.MaxRPM))*180) -- RPM
	gred.ManipulateBoneAngles(self,"rpm1",Angle(0,-rpm/18,rpm/180)) -- RPM
	
	-------------------------
	
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
	gred.ManipulateBoneAngles(self,"altitude_10k",(alt/1000)*METER_IN_FEET)
	gred.ManipulateBoneAngles(self,"altitude_hour",(alt/100)*METER_IN_FEET)
	gred.ManipulateBoneAngles(self,"altitude_min",(alt/10)*METER_IN_FEET)
	gred.ManipulateBoneAngles(self,"altitude1_hour",(alt/100)*METER_IN_FEET)
	gred.ManipulateBoneAngles(self,"altitude1_min",(alt/10)*METER_IN_FEET)
	
	
end

function ENT:AnimRotor()
	-- if not self.Bones then gred.UpdateBoneTable(self) return end
	-- local RPM = self:GetRPM()
	-- local PhysRot = RPM < 700
	-- self.RPM = self.RPM and (self.RPM + RPM * FrameTime() * (PhysRot and 3 or 1)) or 0
	
	-- local Rot = Angle(self.RPM)
	-- Rot:Normalize() 
	-- gred.ManipulateBoneAngles(self,"prop, Rot )
	-- self:SetBodygroup(0, PhysRot and 0 or 1 ) 
end

function ENT:AnimCabin()
	if not self.Bones then gred.UpdateBoneTable(self) return end
	local bOn = self:GetActive()
	
	local TVal = bOn and 0 or 1
	local Speed = FrameTime() * 4
	self.SMcOpen = self.SMcOpen and self.SMcOpen + math.Clamp(TVal - self.SMcOpen,-Speed,Speed) or 0
	gred.ManipulateBonePosition(self,"blister", Vector(0,0,-self.SMcOpen * 50))
	
end

function ENT:AnimLandingGear()

	-- if not self.CurSeq then
		-- self.CurSeq = self:GetSequenceName(self:GetSequence())
	-- end
	-- if self.CurSeq != "gears" then
		-- self:ResetSequence("gears")
		-- self.CurSeq = self:GetSequenceName(self:GetSequence())
	-- end
	-- self.SMLG = self.SMLG and self.SMLG + ((0 + self:GetLGear()) - self.SMLG) * FrameTime() * 2 or 0
	-- self.SMRG = self.SMRG and self.SMRG + ((0 + self:GetRGear()) - self.SMRG) * FrameTime() * 2 or 0
	-- self:SetCycle(self.SMRG)
	-- if self.SMRG >= 0.95 then
		-- self:SetBodygroup(4,0)
	-- elseif self.SMRG <= 0.05 then
		-- self:SetBodygroup(4,1)
	-- else
		-- self:SetBodygroup(4,2)
	-- end
end

function ENT:ExhaustFX()
	-- if not self:GetEngineActive() then return end
	
	-- self.nextEFX = self.nextEFX or 0
	
	-- local THR = (self:GetRPM() - self.IdleRPM) / (self.LimitRPM - self.IdleRPM)
	
	-- if self.nextEFX < CurTime() then
		-- self.nextEFX = CurTime() + 0.05 + (1 - THR) / 10
		
		-- local Pos = {
			-- Vector(67.3839,20.9509,17.2637),
			-- Vector(74.3938,21.164,17.3147),
			-- Vector(81.5075,21.3686,17.2891),
			-- Vector(88.4159,21.428,17.368),
			-- Vector(95.4258,21.384,17.4722),
			-- Vector(102.452,21.296,17.4722),
		-- }
		
		-- for _, v in pairs(Pos) do 
			-- if math.random(0,1) == 1 then
				-- local effectdata = EffectData()
					-- effectdata:SetOrigin( v )
					-- effectdata:SetAngles( Angle(-90,20,0) )
					-- effectdata:SetMagnitude( math.Clamp(THR,0.2,1) ) 
					-- effectdata:SetEntity( self )
				-- util.Effect( "lfs_exhaust", effectdata )
			-- end
			
			-- if math.random(0,1) == 1 then
				-- local vr = v
				-- vr.y = -v.y
				
				-- local effectdata = EffectData()
					-- effectdata:SetOrigin( vr )
					-- effectdata:SetAngles( Angle(-90,20,0) )
					-- effectdata:SetMagnitude( math.Clamp(THR,0.2,1) ) 
					-- effectdata:SetEntity( self )
				-- util.Effect( "lfs_exhaust", effectdata )
			-- end
		-- end
	-- end
end
