--DO NOT EDIT OR REUPLOAD THIS FILE
 
AddCSLuaFile("shared.lua") 
AddCSLuaFile("cl_init.lua")
include("shared.lua")

ENT.NextPointPosRequest = 0
ENT.NEXT_AI_HELLFIRE = 0
ENT.TailPos = Vector(-173.242,0,15.6829)
ENT.FoundEnts = {}
local TRACER_30MM = 0
local baseclass = baseclass.Get("lunasflightschool_basescript_heli")
local function GetAbsoluteVector(v)
	return Vector(math.abs(v.x),math.abs(v.y),math.abs(v.z))
end

local WEP = {
	[1] = "L1",
	[2] = "L2",
	[3] = "R1",
	[4] = "R2",
}

function ENT:SpawnFunction( ply, tr, ClassName )
	if not tr.Hit then return end

	local ent = ents.Create( ClassName )
	ent:SetPos( tr.HitPos + tr.HitNormal * 40 )
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:RunOnSpawn()
	self:SetGunnerSeat(self:AddPassengerSeat(Vector(115.948,0,11.0548),Angle(0,-90,0)))
	
	local pos = self:GetPos()
	local ang = self:GetAngles()
	
	local ent = ents.Create("prop_dynamic")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetModel("models/gredwitch/ah64_lfs/ah64_l1.mdl")
	ent:Spawn()
	ent:Activate()
	ent:SetParent(self)
	self.Weaponery.L1.Model = ent
	self.Weaponery.L1.Ammo = 0
	self:DeleteOnRemove(ent)
	
	
	local ent = ents.Create("prop_dynamic")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetModel("models/gredwitch/ah64_lfs/ah64_L2.mdl")
	ent:Spawn()
	ent:Activate()
	ent:SetParent(self)
	self.Weaponery.L2.Model = ent
	self.Weaponery.L2.Ammo = 0
	self:DeleteOnRemove(ent)
	
	
	local ent = ents.Create("prop_dynamic")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetModel("models/gredwitch/ah64_lfs/ah64_R1.mdl")
	ent:Spawn()
	ent:Activate()
	ent:SetParent(self)
	self.Weaponery.R1.Model = ent
	self.Weaponery.R1.Ammo = 0
	self:DeleteOnRemove(ent)
	
	
	local ent = ents.Create("prop_dynamic")
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetModel("models/gredwitch/ah64_lfs/ah64_R2.mdl")
	ent:Spawn()
	ent:Activate()
	ent:SetParent(self)
	self.Weaponery.R2.Model = ent
	self.Weaponery.R2.Ammo = 0
	self:DeleteOnRemove(ent)
	
	
	local ent = ents.Create("gred_prop_tail")
	ent.Model = "models/gredwitch/ah64_lfs/ah64_tail_rotorok.mdl"
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()
	ent:SetOwner(self)
	self.Tail = ent
	self:DeleteOnRemove(ent)
	
	local p = self.Tail:GetPhysicsObject( )
	if IsValid(p) then

		p:SetMass(50)
		p:EnableGravity(false)
		p:EnableDrag(false)
		p:EnableCollisions(true)
		p:Wake()

	end
	self.TailWeld = constraint.Weld(ent,self,0,0,0,true,true)
	
	self.MUZZLEEFFECT 		= table.KeyFromValue(gred.Particles,"muzzleflash_bar_3p")
	self.BACKBLAST_BIG	 	= table.KeyFromValue(gred.Particles,"ins_weapon_rpg_frontblast")
	self.BACKBLAST_SMALL 	= table.KeyFromValue(gred.Particles,"ins_weapon_at4_frontblast")
	self.TracerConvar		= GetConVar("gred_sv_tracers")
	timer.Simple(0.1,function() self:GetTail() end)
end

function ENT:OnTick()
	local ct = CurTime()
	self:HandleModels(ct)
	self:HandleStingers(ct)
	self:HandlePods()
	self:HandleCannon()
end

function ENT:HandleStingers(ct)
	-- if self:GetEnableStingers() then
		-- self:SetBodygroup(3,0)
		-- if self.NextScan < ct then
			-- self.FoundEnts = {}
			
			-- for k,v in pairs(simfphys.LFS:PlanesGetAll()) do
				-- table.insert(self.FoundEnts,v)
			-- end
			-- for k,v in pairs(ents.FindByClass("wac_hc*")) do
				-- table.insert(self.FoundEnts,v)
			-- end
			
			-- for k,v in pairs(ents.FindByClass("wac_pl*")) do
				-- table.insert(self.FoundEnts,v)
			-- end
			-- local pos = self:GetPos()
			-- for k,v in pairs(ents.FindInCone(pos,self:GetForward(),10000,0.707)) do
				-- if table.HasValue(self.FoundEnts) then
					-- debugoverlay.Box(v:GetPos(),Vector(-50,-50,-50),Vector(50,50,50),0.1,color_white)
				-- end
			-- end
			-- for k,v in pairs(ents.FindInCone(pos,-self:GetForward(),10000,0.707)) do
				-- debugoverlay.Box(v:GetPos(),Vector(-50,-50,-50),Vector(50,50,50),0.1,color_black)
				-- if table.HasValue(self.FoundEnts) then
					-- table.RemoveByValue(v)
				-- end
			-- end
			-- for k,v in pairs(
			-- self.NextScan = ct + 2
		-- end
	-- else
		self:SetBodygroup(3,1)
	-- end
end

function ENT:HandleModels(ct)
	local TailValid = IsValid(self.Tail)
	local skin = self:GetSkin()
	
	if !TailValid and !self.TailDestroyed then
		if !self.InfoSent then
			net.Start("gred_apache_tail_destroyed")
				net.WriteEntity(self)
				net.WriteEntity(nil)
			net.Broadcast()
			
			if IsValid(self.wheel_C) then
				self.wheel_C:Remove()
			end
			if IsValid(self.wheel_C_master) then
				self.wheel_C_master:Remove()
			end
			if self:GetEngineActive() then
				if self.CRASHSND then self:StopSound(self.CRASHSND) end
				self.CRASHSND = "HELICOPTER_CRASHING_"..math.random(1,10)
				self:EmitSound(self.CRASHSND)
			end
			self.TailRotorDownLevel = 2
			self.MaxTurnYawHeli = 0
			self.TailDestroyed = true
			self.Tail = nil
			self.InfoSent = true
			
			local effect = EffectData()
			effect:SetOrigin(self:LocalToWorld(self.TailPos))
			effect:SetNormal(-self:GetForward())
			util.Effect("ManhackSparks",effect)
		end
	elseif TailValid then
		self.Tail:SetSkin(skin)
	elseif self.TailDestroyed then
		local RPM = self:GetRPM()
		local p = self:GetPhysicsObject()
		if IsValid(p) then
			-- p:ApplyForceCenter(Vector(RPM * 30))
			self.MaxPitch = 0
			self.MaxYaw = 0
			self.MaxRoll = 0
			p:AddAngleVelocity(Vector(0,RPM*0.01))
			-- p:AddVelocity(Vector(0,0,)
		end
	end
	for k,v in pairs(self.Weaponery) do
		if IsValid(v.Model) then
			v.Model:SetSkin(skin)
		end
	end
	if self.TailRotorDownLevel == 1 then
		local RPM = self:GetRPM()
		local p = self:GetPhysicsObject()
		if IsValid(p) then
			local angvel = p:GetAngleVelocity()
			p:AddAngleVelocity(Vector(angvel.x > 50 and 0 or RPM*0.01,0,angvel.z > 200 and 0 or math.Clamp(RPM,0,2000)*0.04))
			local vel = p:GetVelocity()
			p:AddVelocity(Vector(0,0,vel.z < -600 and 0 or -RPM*0.005))
		end
	end
	
end

function ENT:HandleCannon()
	if self:GetAI() then
		local Target = self:AIGetTarget()
		if Target != self.OldTarget then
			net.Start("gred_apache_aitarget")
				net.WriteEntity(self)
				net.WriteEntity(Target)
			net.Broadcast()
		end
		self.OldTarget = Target
	end
	
	if self.FIRING_30MM != self.OLD_FIRING_30MM then
		-- self:SetFIRING_30MM(self.FIRING_30MM)
	end
	
	self.OLD_FIRING_30MM = self.FIRING_30MM
end

function ENT:HandlePods()
	local L1 = self:GetLeft1Pod()
	local L2 = self:GetLeft2Pod()
	local R1 = self:GetRight1Pod()
	local R2 = self:GetRight2Pod()
	
	local Hydras = self:GetHydras()
	local Hellfires = self:GetHellfires()
	
	
	
	if L1 == 0 then
		
		for i = 0,25 do
			self.Weaponery.L1.Model:SetBodygroup(i,1)
		end
		if L1 != self.OldL1 then
			self.SomethingChanged = true
		end
		self.Weaponery.L1.Hydra = false
		self.Weaponery.L1.WP = false
		self.Weaponery.L1.Hellfire = false
		self.Weaponery.L1.Ammo = 0
		
	elseif L1 == 1 or L1 == 2 then
		
		for i = 0,4 do
			self.Weaponery.L1.Model:SetBodygroup(i,1)
		end
		self.Weaponery.L1.Model:SetBodygroup(5,0)
		self.Weaponery.L1.Hydra = true
		self.Weaponery.L1.Hellfire = false
		if L1 == 1 then
			self.Weaponery.L1.WP = false
		else
			self.Weaponery.L1.WP = true
		end
		if L1 != self.OldL1 then
			self.SomethingChanged = true
			self.Weaponery.L1.Ammo = 19
		end
		
		for i = 25-self.Weaponery.L1.Ammo,25 do
			self.Weaponery.L1.Model:SetBodygroup(i,0)
		end
		for i = 6,6 + (18 - self.Weaponery.L1.Ammo)do
			self.Weaponery.L1.Model:SetBodygroup(i,1)
		end
		
	elseif L1 == 3 then
		
		for i = 5,25 do
			self.Weaponery.L1.Model:SetBodygroup(i,1)
		end
		
		if L1 != self.OldL1 then
			self.SomethingChanged = true
			self.Weaponery.L1.Ammo = 4
		end
		
		for i = 1-self.Weaponery.L1.Ammo,4 do
			self.Weaponery.L1.Model:SetBodygroup(i,0)
		end
		for i = 1,4-(self.Weaponery.L1.Ammo) do
			self.Weaponery.L1.Model:SetBodygroup(i,1)
		end
		
		self.Weaponery.L1.Model:SetBodygroup(0,0)
		self.Weaponery.L1.Hydra = false
		self.Weaponery.L1.WP = false
		self.Weaponery.L1.Hellfire = true
	end
	
	if L2 == 0 then
		
		for i = 0,25 do
			self.Weaponery.L2.Model:SetBodygroup(i,1)
		end
		if L2 != self.OldL2 then
			self.SomethingChanged = true
		end
		self.Weaponery.L2.Hydra = false
		self.Weaponery.L2.WP = false
		self.Weaponery.L2.Hellfire = false
		self.Weaponery.L2.Ammo = 0
		
	elseif L2 == 1 or L2 == 2 then
		
		for i = 0,4 do
			self.Weaponery.L2.Model:SetBodygroup(i,1)
		end
		self.Weaponery.L2.Model:SetBodygroup(5,0)
		self.Weaponery.L2.Hydra = true
		self.Weaponery.L2.Hellfire = false
		if L2 == 1 then
			self.Weaponery.L2.WP = false
		else
			self.Weaponery.L2.WP = true
		end
		if L2 != self.OldL2 then
			self.SomethingChanged = true
			self.Weaponery.L2.Ammo = 19
		end
		
		for i = 25-self.Weaponery.L2.Ammo,25 do
			self.Weaponery.L2.Model:SetBodygroup(i,0)
		end
		for i = 6,6 + (18 - self.Weaponery.L2.Ammo)do
			self.Weaponery.L2.Model:SetBodygroup(i,1)
		end
		
	elseif L2 == 3 then
		
		for i = 5,25 do
			self.Weaponery.L2.Model:SetBodygroup(i,1)
		end
		
		if L2 != self.OldL2 then
			self.SomethingChanged = true
			self.Weaponery.L2.Ammo = 4
		end
		
		for i = 1-self.Weaponery.L2.Ammo,4 do
			self.Weaponery.L2.Model:SetBodygroup(i,0)
		end
		for i = 1,4-(self.Weaponery.L2.Ammo) do
			self.Weaponery.L2.Model:SetBodygroup(i,1)
		end
		
		self.Weaponery.L2.Model:SetBodygroup(0,0)
		self.Weaponery.L2.Hydra = false
		self.Weaponery.L2.WP = false
		self.Weaponery.L2.Hellfire = true
	end
	
	if R1 == 0 then
		
		for i = 0,25 do
			self.Weaponery.R1.Model:SetBodygroup(i,1)
		end
		if R1 != self.OldR1 then
			self.SomethingChanged = true
		end
		self.Weaponery.R1.Hydra = false
		self.Weaponery.R1.WP = false
		self.Weaponery.R1.Hellfire = false
		self.Weaponery.R1.Ammo = 0
		
	elseif R1 == 1 or R1 == 2 then
		
		for i = 0,4 do
			self.Weaponery.R1.Model:SetBodygroup(i,1)
		end
		self.Weaponery.R1.Model:SetBodygroup(5,0)
		self.Weaponery.R1.Hydra = true
		self.Weaponery.R1.Hellfire = false
		if R1 == 1 then
			self.Weaponery.R1.WP = false
		else
			self.Weaponery.R1.WP = true
		end
		if R1 != self.OldR1 then
			self.SomethingChanged = true
			self.Weaponery.R1.Ammo = 19
		end
		
		for i = 25-self.Weaponery.R1.Ammo,25 do
			self.Weaponery.R1.Model:SetBodygroup(i,0)
		end
		for i = 6,6 + (18 - self.Weaponery.R1.Ammo)do
			self.Weaponery.R1.Model:SetBodygroup(i,1)
		end
		
	elseif R1 == 3 then
		
		for i = 5,25 do
			self.Weaponery.R1.Model:SetBodygroup(i,1)
		end
		
		if R1 != self.OldR1 then
			self.SomethingChanged = true
			self.Weaponery.R1.Ammo = 4
		end
		
		for i = 1-self.Weaponery.R1.Ammo,4 do
			self.Weaponery.R1.Model:SetBodygroup(i,0)
		end
		for i = 1,4-(self.Weaponery.R1.Ammo) do
			self.Weaponery.R1.Model:SetBodygroup(i,1)
		end
		
		self.Weaponery.R1.Model:SetBodygroup(0,0)
		self.Weaponery.R1.Hydra = false
		self.Weaponery.R1.WP = false
		self.Weaponery.R1.Hellfire = true
	end
	
	if R2 == 0 then
		
		for i = 0,25 do
			self.Weaponery.R2.Model:SetBodygroup(i,1)
		end
		if R2 != self.OldR2 then
			self.SomethingChanged = true
		end
		self.Weaponery.R2.Hydra = false
		self.Weaponery.R2.WP = false
		self.Weaponery.R2.Hellfire = false
		self.Weaponery.R2.Ammo = 0
		
	elseif R2 == 1 or R2 == 2 then
		
		for i = 0,4 do
			self.Weaponery.R2.Model:SetBodygroup(i,1)
		end
		self.Weaponery.R2.Model:SetBodygroup(5,0)
		self.Weaponery.R2.Hydra = true
		self.Weaponery.R2.Hellfire = false
		if R2 == 1 then
			self.Weaponery.R2.WP = false
		else
			self.Weaponery.R2.WP = true
		end
		if R2 != self.OldR2 then
			self.SomethingChanged = true
			self.Weaponery.R2.Ammo = 19
		end
		
		for i = 25-self.Weaponery.R2.Ammo,25 do
			self.Weaponery.R2.Model:SetBodygroup(i,0)
		end
		for i = 6,6 + (18 - self.Weaponery.R2.Ammo)do
			self.Weaponery.R2.Model:SetBodygroup(i,1)
		end
		
	elseif R2 == 3 then
		
		for i = 5,25 do
			self.Weaponery.R2.Model:SetBodygroup(i,1)
		end
		
		if R2 != self.OldR2 then
			self.SomethingChanged = true
			self.Weaponery.R2.Ammo = 4
		end
		
		for i = 1-self.Weaponery.R2.Ammo,4 do
			self.Weaponery.R2.Model:SetBodygroup(i,0)
		end
		for i = 1,4-(self.Weaponery.R2.Ammo) do
			self.Weaponery.R2.Model:SetBodygroup(i,1)
		end
		
		self.Weaponery.R2.Model:SetBodygroup(0,0)
		self.Weaponery.R2.Hydra = false
		self.Weaponery.R2.WP = false
		self.Weaponery.R2.Hellfire = true
	end
	
	
	if self.SomethingChanged then
		local a_hydra = 0
		local a_hellfire = 0
		for k,v in pairs(self.Weaponery) do
			if v.Hydra then
				a_hydra = a_hydra + v.Ammo
			else
				a_hellfire = a_hellfire + v.Ammo
			end
		end
		Hydras = a_hydra
		Hellfires = a_hellfire
		self:SetHydras(a_hydra)
		self:SetHellfires(a_hellfire)
		self.SomethingChanged = false
	else
		if self.OldHydras != Hydras and not self.FIRING_HYDRAS then
			local a = 0
			local b = 1
			local tab
			for k,v in pairs(self.Weaponery) do
				if v.Hydra then
					v.Ammo = 0
					a = a + 1
				end
			end 
			local A = a * 19
			Hydras = Hydras > A and A or Hydras
			for i = 1,Hydras do
				b = b < 1 or b > 4 and 1 or b
				v = self.Weaponery[WEP[b]]
				while !v or !v.Hydra or v.Ammo >= 19 do
					b = b < 1 or b > 4 and 1 or b + 1
					tab = v
					v = self.Weaponery[WEP[b]]
					if v == tab then break end
				end
				if v.Hydra and v.Ammo < 19 then
					v.Ammo = v.Ammo + 1
					b = b + 1
				end
			end
			self:SetHydras(Hydras)
		end
		if self.OldHellfires != Hellfires and not self.FIRING_HELLFIRES then
			local a = 0
			local b = 1
			local tab
			for k,v in pairs(self.Weaponery) do
				if v.Hellfire then
					v.Ammo = 0
					a = a + 1
				end
			end 
			local A = a * 4
			Hellfires = Hellfires > A and A or Hellfires
			for i = 1,Hellfires do
				b = b < 1 or b > 4 and 1 or b
				v = self.Weaponery[WEP[b]]
				while !v or !v.Hellfire or v.Ammo >= 4 do
					b = b < 1 or b > 4 and 1 or b + 1
					tab = v
					v = self.Weaponery[WEP[b]]
					if v == tab then break end
				end
				if v.Hellfire and v.Ammo < 4 then
					v.Ammo = v.Ammo + 1
					b = b + 1
				end
			end
			self:SetHellfires(Hellfires)
		end
	end
	
	self.OldL1 = L1
	self.OldL2 = L2
	self.OldR1 = R1
	self.OldR2 = R2
	
	self.OldHydras = Hydras
	self.OldHellfires = Hellfires
	
	return a_hydra,a_hellfire
end

------------------------------------------------------------

function ENT:FIRE_HYDRAS(ct,ply,count)
	if self:GetAI() then return end
	if not self:CAN_FIRE_HYDRAS(ct,count) then return end
	if !self:UPDATE_AMMO_HYDRA() then return end
	if !HYDRA_ID or HYDRA_ID > 4 or HYDRA_ID == 0 then HYDRA_ID = 1 end
	
	local tab = self.Weaponery[WEP[HYDRA_ID]]
	local oldtab = tab
	while tab.Ammo < 1 or !tab.Hydra do
		HYDRA_ID = HYDRA_ID+1 > 4 and 1 or HYDRA_ID + 1
		tab = self.Weaponery[WEP[HYDRA_ID]]
		if tab == oldtab then break end
	end
	
	local pos = tab.HydraPos[20-tab.Ammo]
	if not pos then return end
	pos = self:LocalToWorld(pos)
	local ang = self:GetAngles()
	local ent = ents.Create(tab.WP and self.HYDRAWP_ENT or self.HYDRA_ENT)
	ent:SetPos(pos)
	ent.Model = self.HYDRA_MODEL
	ent:SetAngles(ang+Angle(-2.5))
	ent.IsOnPlane = true
	ent:SetOwner(ply)
	ent:Spawn()
	ent:Activate()
	local p = ent:GetPhysicsObject()
	if IsValid(p) then 
		p:EnableCollisions(false)
	end
	timer.Simple(0.3,function() if IsValid(p) then p:EnableCollisions(true) end end)
	ent:Launch()
	
	ang.y = ang.y + 180
	local effectdata = EffectData()
	effectdata:SetFlags(self.BACKBLAST_SMALL)
	effectdata:SetOrigin(pos)
	effectdata:SetAngles(ang)
	effectdata:SetSurfaceProp(0)
	util.Effect("gred_particle_simple",effectdata)
	
	tab.Ammo = tab.Ammo - 1
	
	HYDRA_ID = HYDRA_ID + 1
	self:UPDATE_AMMO_HYDRA()
	self.NextHydra = ct + 0.15
end

function ENT:FIRE_HELLFIRES(ct,ply,count,pod,AI,Target)
	if not self:CAN_FIRE_HELLFIRES(ct,count) then return end
	if not self:UPDATE_AMMO_HELLFIRE() then return end
	
	if not IsValid(pod) then pod = self:GetDriverSeat() end
	if not IsValid(ply) then ply = pod:GetDriver() end
	
	if not IsValid(pod) then return end
	if not IsValid(ply) then return end
	if !HELLFIRE_ID or HELLFIRE_ID > 4 or HELLFIRE_ID == 0 then HELLFIRE_ID = 1 end
	local veh
	local tab = self.Weaponery[WEP[HELLFIRE_ID]]
	local oldtab = tab
	while tab.Ammo <= 0 or !tab.Hellfire do
		HELLFIRE_ID = HELLFIRE_ID+1 > 4 and 1 or HELLFIRE_ID + 1
		tab = self.Weaponery[WEP[HELLFIRE_ID]]
		if tab == oldtab then break end
	end
	
	local ang = self:GetAngles()
	local EyeAngles
	
	if self.PointPos then
		EyeAngles = (self.PointPos-self:GetRotorPos()):Angle() - ang
	else
		if AI and ply == self then
			local Target = self:AIGetTarget()
			if IsValid(Target) then
				EyeAngles = (Target:GetPos() - self:GetRotorPos()):Angle() - ang
				veh = Target:GetVehicle()
			else
				return
			end
		else
			EyeAngles = pod:WorldToLocalAngles(ply:EyeAngles() ) - ang
		end
	end
	local EyeA = EyeAngles
	EyeA:Normalize()
	
	if (EyeA.y > 110 or EyeA.y < -110) or (EyeA.p > 60 or EyeA.p < -11) then return end
	local pos = tab.HellfirePos[5-tab.Ammo]
	
	if not pos then return end
	EyeA = EyeA + ang
	local tr = self.PointPos and util.QuickTrace(self.PointPos,self.PointPos,self) or util.QuickTrace(self:GetRotorPos(),EyeA:Forward()*9999 - EyeA:Up()*450 + GetAbsoluteVector(EyeA:Right()*80),self)
	if tr.HitSky then return end
	pos = self:LocalToWorld(pos)
	local ent = ents.Create(self.HELLFIRE_ENT)
	ent:SetPos(pos)
	ent:SetAngles(ang+Angle(-2.5))
	ent:SetModel(self.HELLFIRE_MODEL)
	ent.Owner = ply
	ent.Damage = 500
	ent.Radius = 400
	ent.Speed = 60
	ent.Drag = Vector(0,1,1)
	ent.TrailLength = 200
	ent.Scale = 15
	ent.SmokeDens = 1
	ent.Launcher = self
	ent.target = (AI and ply == self) and veh or tr.Entity
	ent.targetOffset = (AI and ply == self) and veh:GetPos() or tr.HitPos
	ent.calcTarget = function(r)
		r.hellfire = true
		return r.targetOffset
	end
	
	ent:Spawn()
	ent:Activate()
	self:NoCollide(ent)
	ent:StartRocket()
	local ph = ent:GetPhysicsObject()
	if ph:IsValid() then
		ph:SetVelocity(self:GetVelocity())
		ph:AddAngleVelocity(Vector(30,0,0))
	end
	ang.y = ang.y + 180
	local effectdata = EffectData()
	effectdata:SetFlags(self.BACKBLAST_BIG)
	effectdata:SetOrigin(pos)
	effectdata:SetAngles(ang)
	effectdata:SetSurfaceProp(0)
	util.Effect("gred_particle_simple",effectdata)
	
	tab.Ammo = tab.Ammo - 1
	
	self:EmitSound("FIRE_HELLFIRE")
	
	HELLFIRE_ID = HELLFIRE_ID + 1
	self:UPDATE_AMMO_HELLFIRE()
	self.NextHellfire = ct + 1
	self.NEXT_AI_HELLFIRE = ct + 10
end

function ENT:FIRE_STINGERS(ct,ply,count,pod)
end

function ENT:FIRE_30MM(ct,ply,count,pod,ang,EyeAngles,AI,Target)
	self.FIRING_30MM = true
	if not self:CAN_FIRE_30MM(ct,count) then return end
	if not IsValid(pod) then pod = self:GetDriverSeat() end
	if not IsValid(ply) then ply = pod:GetDriver() end
	
	if not IsValid(pod) then self.FIRING_30MM = false return end
	if not IsValid(ply) then self.FIRING_30MM = false return end
	if not EyeAngles then self.FIRING_30MM = false return end
	
	ang = ang or self:GetAngles()
	local EyeA = EyeAngles
	EyeA:Normalize()
	
	if (EyeA.y > 110 or EyeA.y < -110) or (EyeA.p > 60 or EyeA.p < -11) then self.FIRING_30MM = false return end
	
	local pos2	= self:LocalToWorld(Vector(88.9067,0,-26.0772) + EyeAngles:Forward()*62)
	local num 	= 1.7
	local ang 	= (EyeAngles + ang + Angle(-0.8) + Angle(math.Rand(-num,num), math.Rand(-num,num), math.Rand(-num,num)))
	gred.CreateBullet(ply,pos2,ang,"wac_base_30mm",{self},nil,false,self:UpdateTracers())
	
	local effectdata = EffectData()
	effectdata:SetFlags(self.MUZZLEEFFECT)
	effectdata:SetOrigin(pos2)
	effectdata:SetAngles(ang)
	effectdata:SetSurfaceProp(0)
	util.Effect("gred_particle_simple",effectdata)
	
	self.NextCannon = ct + 0.096
	self:Set30mm(count-1)
end

function ENT:UpdateTracers()
	TRACER_30MM = TRACER_30MM + 1
	if TRACER_30MM >= self.TracerConvar:GetInt() then
		TRACER_30MM = 0
		return "red"
	else
		return false
	end
end
function ENT:HandleWeapons(Fire1, Fire2)
	local ct = CurTime()
	local FireTurret
	local Target
	local TargetValid
	local TargetInVehicle
	local TargetInPlane
	local AI = self:GetAI()
	if AI then
		Target = self:AIGetTarget()
		TargetValid = IsValid(Target) -- and self:AITargetInfront(Target,65)
		if TargetValid then
			TargetInPlane = (Target:IsPlayer() and IsValid(Target:lfsGetPlane())) or Target.LFS
			if !TargetInPlane then
				TargetInVehicle = IsValid(Target:GetVehicle())
			end
		end
	end
	local Driver = AI and self or self:GetDriver()
	local HasDriver = IsValid(Driver)
	local Gunner = self:GetGunner()
	local HasGunner = IsValid(Gunner)
	
	local Hellfires = self:GetHellfires()
	local Hydras = self:GetHydras()
	local Cannon = self:Get30mm()
	local Stingers = 0 -- self:GetStingers()
	
	local ang
	local EyeAngles
	
	self.FIRING_30MM = false
	self.FIRING_HYDRAS = false
	self.FIRING_HELLFIRES = false
	-- self.FIRING_STINGERS = false
	
	if HasDriver then
		FireTurret = ((AI and TargetValid) or (!AI and Driver:lfsGetInput("FREELOOK"))) and not HasGunner
		if (Hydras > 0 and (not FireTurret or Cannon < 1)) or (FireTurret and Cannon > 0) then
			Fire1 = AI and TargetValid or (!AI and Driver:KeyDown(IN_ATTACK) and not Driver:KeyDown(IN_ZOOM))
		end
		
		if (Stingers > 0 and (not FireTurret or Hellfires < 1)) or (FireTurret and Hellfires > 0) then
			Fire2 = (AI and (!FireTurret and TargetInPlane) or (FireTurret and TargetInVehicle and self.NEXT_AI_HELLFIRE < ct)) or (!AI and Driver:KeyDown(IN_ATTACK2))
		end
	end
	
	if FireTurret or HasGunner then
		
		if !self.PointPos and self.NextPointPosRequest < ct then
			self.NextPointPosRequest = ct + 0.1
			net.Start("gred_apache_request_pointpos")
				net.WriteEntity(self)
			net.Broadcast()
		end
		
		ang = self:GetAngles()
		if !AI or HasGunner then
			if self.PointPos then
				EyeAngles = (self.PointPos-self:GetRotorPos()):Angle() - ang
				EyeAngles:Normalize()
			else
				EyeAngles = HasGunner and self:GetGunnerSeat():WorldToLocalAngles(Gunner:EyeAngles()) - ang or self:GetDriverSeat():WorldToLocalAngles(Driver:EyeAngles()) - ang
			end
		else
			if IsValid(Target) then
				EyeAngles = (self:GetRotorPos() - Target:GetPos()):Angle() - ang
				EyeAngles:RotateAroundAxis(EyeAngles:Up(),180)
			end
		end
		if EyeAngles then
			self:SetPoseParameter("camera_yaw",-EyeAngles.y)
			self:SetPoseParameter("camera_pitch",-EyeAngles.p)
		end
	else
		-- if !self.ControlInput.LockCamera then
			-- self.PointPos = nil
		-- end
	end
	if Fire1 then
		if FireTurret and Cannon > 0 then
			self:FIRE_30MM(ct,Driver,Cannon,nil,ang,EyeAngles,AI,Target)
		else
			self.FIRING_HYDRAS = true
			self:FIRE_HYDRAS(ct,Driver,Hydras)
		end
	end
	if Fire2 then
		if FireTurret and Hellfires > 0 then
			if (AI and TargetInVehicle) or !AI then
				self.FIRING_HELLFIRES = true
				self:FIRE_HELLFIRES(ct,Driver,Hellfires,nil,AI,Target)
			end
		else
			self.FIRING_STINGERS = true
			self:FIRE_STINGERS(ct,Driver,Stingers)
		end
	end
	
	if HasGunner then
		local GunnerSeat
		if Gunner:KeyDown(IN_ATTACK) and !Gunner:KeyDown(IN_ZOOM) then
			GunnerSeat = self:GetGunnerSeat()
			self:FIRE_30MM(ct,Gunner,Cannon,GunnerSeat,ang,EyeAngles)
		end
		if Gunner:KeyDown(IN_ATTACK2) then
			GunnerSeat = GunnerSeat or self:GetGunnerSeat()
			self.FIRING_HELLFIRES = true
			self:FIRE_HELLFIRES(ct,Gunner,Hellfires,GunnerSeat)
		end
	end
	
	self:SetFIRING_30MM(self.FIRING_30MM)
end

------------------------------------------------------------

function ENT:CAN_FIRE_HYDRAS(ct,count)
	self.NextHydra = self.NextHydra or 0
	return self.NextHydra < ct and count > 0
end

function ENT:CAN_FIRE_HELLFIRES(ct,count)
	self.NextHellfire = self.NextHellfire or 0
	return self.NextHellfire < ct and count > 0
end

function ENT:CAN_FIRE_30MM(ct,count)
	self.NextCannon = self.NextCannon or 0
	return self.NextCannon < ct and count > 0
end

function ENT:CAN_FIRE_STINGER(ct,count)
	self.NextStinger = self.NextStinger or 0
	return self.NextStinger < ct and count > 0
end

function ENT:UPDATE_AMMO_HYDRA()
	local a = 0
	for k,v in pairs(self.Weaponery) do
		if v.Hydra then
			a = a + v.Ammo
		end
	end
	self:SetHydras(a)
	return a > 0
end

function ENT:UPDATE_AMMO_HELLFIRE()
	local a = 0
	for k,v in pairs(self.Weaponery) do
		if !v.Hydra and v.Hellfire then
			a = a + v.Ammo
		end
	end
	self:SetHellfires(a)
	return a > 0
end

------------------------------------------------------------

function ENT:PhysicsCollide(data,col)
	timer.Simple(0,function() if !IsValid(self) then return end
		if self.TailDestroyed or (self.TailRotorDownLevel and self.TailRotorDownLevel > 0) then
			if data.Speed > 1000 and (!data.HitEntity:IsPlayer() and !data.HitEntity:IsNPC() and !string.StartWith(data.HitEntity:GetClass(),"vfire")) then
				self:Explode()
			end
		end
		baseclass.PhysicsCollide(self,data,col)
	end)
end

function ENT:OnRemove()
	if self.CRASHSND then
		self:StopSound(self.CRASHSND)
	end
end

function ENT:NoCollide(ent)
	constraint.NoCollide( ent, self, 0, 0 )
	if IsValid(self.wheel_C) then
		constraint.NoCollide( ent, self.wheel_C, 0, 0 )
	end
	if IsValid(self.wheel_L) then
		constraint.NoCollide( ent, self.wheel_L, 0, 0 )
	end
	if IsValid(self.wheel_R) then
		constraint.NoCollide( ent, self.wheel_R, 0, 0 )
	end
	if IsValid(self.wheel_C_master) then
		constraint.NoCollide( ent, self.wheel_C_master, 0, 0 )
	end
	local driver = self:GetDriver()
	if IsValid(driver) then
		constraint.NoCollide( ent,driver, 0, 0 )
	end
	local gunner = self:GetGunner()
	if IsValid(gunner) then
		constraint.NoCollide( ent, gunner, 0, 0 )
	end
end

function ENT:OnEngineStartInitialized()
	self:EmitSound("AHAG_START")
end

function ENT:CreateAI()
end

function ENT:RemoveAI()
end

function ENT:OnEngineStarted()
end

function ENT:OnEngineStopped()
end