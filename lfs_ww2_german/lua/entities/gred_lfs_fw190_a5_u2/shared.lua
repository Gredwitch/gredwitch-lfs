
ENT.Type           		= "anim"
DEFINE_BASECLASS( "lunasflightschool_basescript" )

ENT.PrintName 			= "[LFS]Fw 190A-5/U2"
ENT.Author 				= "Gredwitch"
ENT.Information 		= ""
ENT.Category 			= "Gredwitch's Stuff"

ENT.Spawnable			= true -- set to "true" to make it spawnable
ENT.AdminSpawnable		= false

ENT.MDL 				= "models/gredwitch/fw190_lfs/fw190.mdl" -- model forward direction must be facing to X+
--[[
ENT.GibModels = {
	"models/XQM/wingpiece2.mdl",
	"models/XQM/wingpiece2.mdl",
	"models/XQM/jetwing2medium.mdl",
	"models/XQM/jetwing2medium.mdl",
	"models/props_phx/misc/propeller3x_small.mdl",
	"models/props_c17/TrapPropeller_Engine.mdl",
	"models/props_junk/Shoe001a.mdl",
	"models/XQM/jetbody2fuselage.mdl",
	"models/XQM/jettailpiece1medium.mdl",
	"models/XQM/pistontype1huge.mdl",
}
]]
ENT.WheelMass 		= 	200 -- wheel mass is 1 when the landing gear is retracted
ENT.WheelRadius 	= 	15
ENT.WheelPos_L 		= 	Vector(79.93,-101.561,-87.2068)
ENT.WheelPos_R 		= 	Vector(79.93,101.561,-87.2068)
ENT.WheelPos_C 		= 	Vector(-198.527,0,-21.96124)

ENT.AITEAM 				= 1 -- 0 = FFA  1 = bad guys  2 = good guys

ENT.Mass 				= 2000 -- lower this value if you encounter spazz
ENT.Inertia 			= Vector(20000,20000,20000) -- you must increase this when you increase mass or it will spazz
ENT.Drag 				= -40 -- drag is a good air brake but it will make diving speed worse

--ENT.HideDriver 		= true -- hide the driver?
ENT.SeatPos 			= Vector(0,-1.62,3.67)
ENT.SeatAng 			= Angle(0,-90,0)

ENT.IdleRPM 			= 300 -- idle rpm. this can be used to tweak the minimum flight speed
ENT.MaxRPM 				= 2800 -- rpm at 100% throttle
ENT.LimitRPM 			= 3000 -- max rpm when holding throttle key

ENT.RotorPos 			= Vector(150,0,7.89529) -- make sure you set these correctly or your plane will act wierd
ENT.WingPos 			= Vector(43.2872,-2.60299,-8.27187) -- make sure you set these correctly or your plane will act wierd
ENT.ElevatorPos 		= Vector(-218.529,0,30.7348	) -- make sure you set these correctly or your plane will act wierd
ENT.RudderPos 			= Vector(-193.578,0,13.7062) -- make sure you set these correctly or your plane will act wierd

ENT.MaxVelocity 		= 1500 -- max theoretical velocity at 0 degree climb
ENT.MaxPerfVelocity 	= 1500 -- speed in which the plane will have its maximum turning potential

ENT.MaxThrust 			= 850 -- max power of rotor


ENT.MaxTurnPitch 		= 500
ENT.MaxTurnYaw 			= 400
ENT.MaxTurnRoll 		= 300

ENT.MaxHealth 			= 800
--ENT.MaxShield 		= 200  -- uncomment this if you want to use deflector shields. Dont use excessive amounts because it regenerates.

--ENT.Stability 		= 0.7   -- if you uncomment this the plane will always be able to turn at maximum performance. This causes MaxPerfVelocity to get ignored
ENT.MaxStability 		= 0.4 -- lower this value if you encounter spazz. You can increase this up to 1 to aid turning performance at MaxPerfVelocity-speeds but be careful

ENT.MaxSecondaryAmmo 	= 4 -- set to a positive number if you want to use weapons. set to -1 if you dont

ENT.BulletPos			= {}
ENT.BulletPos[1]		= Vector(97.1099,-42.0802,-15.886)
ENT.BulletPos[2]		= Vector(97.1099,42.0802,-15.886)
ENT.MaxPrimaryAmmo 		= 500

ENT.Loadouts			= 4 -- 4 loaoduts

ENT.MISSILEMDL 			= "models/gbombs/nebelwerfer_rocket.mdl"
ENT.MISSILES			= {
			[1]			= { Vector(45.6383,116.836,-23.1549), Vector(45.6383,-116.836,-23.1549) }
}
function ENT:GetCalcViewFilter(ent)
	return not ent.ClassName == "gred_prop_part"
end

function ENT:GetPartModelPath(k)
	return "models/gredwitch/fw190_lfs/fw190_"..k..".mdl"
end

ENT.PartParents = {
	
	gear_l2 	=	"gear_l3",
	gear_l3 	=	"wing_l",
	wheel_l 	=	"gear_l",
	gear_l 		=	"wing_l",
	gear_l4 	=	"wing_l",
	aileron_l 	=	"wing_l",
	flap_l 		=	"wing_l",
	gear_11 	=	false,
	
	gear_r2 	=	"gear_r3",
	gear_r3 	=	"wing_r",
	wheel_r 	=	"gear_r",
	gear_r 		=	"wing_r",
	gear_r4 	=	"wing_r",
	aileron_r 	=	"wing_r",
	flap_r 		=	"wing_r",
	gear_11 	=	false,
	
	wheel_c 	=	"gear_c",
	gear_c 		=	"tail",
	rudder 		=	"tail",
	elevator	=	"tail",
	
	tail 		=	false,
	wing_l 		=	false,
	wing_r 		=	false,
}


ENT.BOMBS = {
	[1] = Vector(42.9327,0,-40.8034),
	[2] = Vector(75.8759,4.748,-50.52),
	[3] = Vector(12.4919,4.748,-47.308),
	[4] = Vector(75.8759,-4.748,-50.52),
	[5] = Vector(12.4919,-4.748,-47.308),
}


function ENT:AddDataTables()
	self:NetworkVar( "Int",13, "Loadout", { KeyName = "loadout", Edit = { type = "Int", order = 4,min = 0, max = self.Loadouts, category = "Weapons"} } )
	
	if SERVER then
		self:SetLoadout(math.random(0,self.Loadouts))
	end
end
--[[
local isvector = isvector
local IsValid = IsValid
local isnumber = isnumber
local tostring = tostring
local istable = istable
local OldMotion
local RWpObj
local phy
local pos

local abs = math.abs
local new_table

local function Scale(OriginalTabe,new_table,ent,args)
	for k,v in pairs(OriginalTabe) do
		if isvector(v) then
			new_table[k] = Vector(v.x*args[1],v.y*args[1],v.z*args[1])
			ent[k] = new_table[k]
		elseif isnumber(v) then
			new_table[k] = k == "MaxTurnRoll" and v/args[1] or (k == "MaxTurnPitch" or k == "MaxTurnYaw") and v or v*args[1]
			ent[k] = new_table[k]
		elseif istable(v) then
			local tab = {}
			Scale(v,tab,ent,args)
			new_table[k] = tab
			ent[k] = new_table[k]
		end
	end
end
		
concommand.Add("tiny", function(ply,cmd,args)
	if !args[1] then print("No scale specified") return end -- args[1] can be remplaced by any float
	if args[1] == 0 then print("lol are you serious") return end
	
	local ent = ply:GetEyeTrace().Entity
	
	if IsValid(ent) and ent.LFS then
		args[1] = abs(args[1]) -- do you really want negative scales?
		-- if ent:GetModelScale() == args[1] then return end -- commented because i need to floor the value and stuff
		phy = ent:GetPhysicsObject()
		if !IsValid(phy) then
			print("WARNING : the physics object of the LFS aircraft "..tostring(ent).." scaled by "..ply:GetName().." ("..ply:SteamID()..") is not valid!")
			return
		end
		OldMotion = phy:IsMotionEnabled()
		phy:EnableMotion(false)
		
		ent.OLD_VALUES = ent.OLD_VALUES or {
			Inertia 		= ent.Inertia,
			Mass			= ent.Mass,
			-- Drag 			= ent.Drag,
			SeatPos 		= ent.SeatPos,
			HideDriver		= ent.HideDriver,
			
			Data			= ent.Data,
			
			WheelPos_L 		= ent.WheelPos_L,
			WheelPos_R 		= ent.WheelPos_R,
			WheelPos_C 		= ent.WheelPos_C,
			WheelRadius 	= ent.WheelRadius,
				
			RotorPos 		= ent.RotorPos,
			WingPos 		= ent.WingPos,
			ElevatorPos 	= ent.ElevatorPos,
			RudderPos 		= ent.RudderPos,
			
			MaxVelocity 	= ent.MaxVelocity,
			MaxPerfVelocity = ent.MaxPerfVelocity,
			
			MaxThrust		= ent.MaxThrust,
			
			MaxStability	= ent.MaxStability,
			Stability		= ent.Stability,
			
			MaxTurnPitch	= ent.MaxTurnPitch,
			MaxTurnYaw		= ent.MaxTurnYaw,
			MaxTurnRoll		= ent.MaxTurnRoll,
			pSeats			= ent.pSeats,
		}
		new_table = {}
		
		-- print("Values")
		Scale(ent.OLD_VALUES,new_table,ent,args)
		-- phy:SetDragCoefficient(ent.Drag)
		phy:SetInertia(ent.Inertia)
		ent:SetAITEAM(2)
		-- phy:SetMass(new_table.Mass)
		ent:GetDriverSeat():Remove()
		ent.HideDriver = (args[1] == 1 and ent.OLD_VALUES.HideDriver) or args[1] != 1 -- auto hide the driver
		ent:SetDriverSeat(1)
		ent:InitPod()
		
		-- print("Seats")
		if ent.pSeats then
			new_table.pSeats = {}
			for k,v in pairs(ent.pSeats) do
				ent.OLD_VALUES.pSeats[k] = ent.OLD_VALUES.pSeats[k] or ent:WorldToLocal(v:GetPos())
				new_table.pSeats[k] = Vector(ent.OLD_VALUES.pSeats[k].x*args[1],ent.OLD_VALUES.pSeats[k].y*args[1],ent.OLD_VALUES.pSeats[k].z*args[1])
				v:SetPos(ent:LocalToWorld(new_table.pSeats[k]))
			end
		end
		
		-- print("Wheels")
		if ent.wheel_L then
			constraint.RemoveConstraints(ent.wheel_L,"Axis")
			pos = ent:LocalToWorld(new_table.WheelPos_L)
			ent.wheel_L:SetPos(pos)
			ent.wheel_L:SetCollisionBounds(Vector(-new_table.WheelRadius,-new_table.WheelRadius,-new_table.WheelRadius), Vector(new_table.WheelRadius,new_table.WheelRadius,new_table.WheelRadius) )
			RWpObj = ent.wheel_L:GetPhysicsObject()
			timer.Simple(0,function()
				if IsValid(RWpObj) then
					ent:dOwner( constraint.Axis( ent.wheel_L, ent, 0, 0, RWpObj:GetMassCenter(), pos, 0, 0, 50, 0, Vector(1,0,0) , false ) )
				else
					print("WARNING : the physics object of the left wheel of LFS aircraft "..tostring(ent).." scaled by "..ply:GetName().." ("..ply:SteamID()..") is not valid!")
				end
			end)
		end
		if ent.wheel_R then
			constraint.RemoveConstraints(ent.wheel_R,"Axis")
			pos = ent:LocalToWorld(new_table.WheelPos_R)
			ent.wheel_R:SetPos(pos)
			ent.wheel_R:SetCollisionBounds(Vector(-new_table.WheelRadius,-new_table.WheelRadius,-new_table.WheelRadius), Vector(new_table.WheelRadius,new_table.WheelRadius,new_table.WheelRadius) )
			RWpObj = ent.wheel_R:GetPhysicsObject()
			timer.Simple(0,function()
				if IsValid(RWpObj) then
					ent:dOwner( constraint.Axis( ent.wheel_R, ent, 0, 0, RWpObj:GetMassCenter(), pos, 0, 0, 50, 0, Vector(1,0,0) , false ) )
				else
					print("WARNING : the physics object of the right wheel of LFS aircraft "..tostring(ent).." scaled by "..ply:GetName().." ("..ply:SteamID()..") is not valid!")
				end
			end)
		end
		if ent.wheel_C then
			constraint.RemoveConstraints(ent.wheel_C,"Axis")
			pos = ent:LocalToWorld(new_table.WheelPos_C)
			ent.wheel_C:SetPos(pos)
			ent.wheel_C:SetCollisionBounds(Vector(-new_table.WheelRadius,-new_table.WheelRadius,-new_table.WheelRadius), Vector(new_table.WheelRadius,new_table.WheelRadius,new_table.WheelRadius) )
			RWpObj = ent.wheel_C:GetPhysicsObject()
			timer.Simple(0,function()
				if IsValid(RWpObj) then
					ent:dOwner( constraint.Axis( ent.wheel_C, ent, 0, 0, RWpObj:GetMassCenter(), pos, 0, 0, 50, 0, Vector(1,0,0) , false ) )
				else
					print("WARNING : the physics object of the c wheel of LFS aircraft "..tostring(ent).." scaled by "..ply:GetName().." ("..ply:SteamID()..") is not valid!")
				end
			end)
		end
		-- PrintTable(new_table)
		-- PrintTable(ent.OLD_VALUES)
		ent:SetModelScale(args[1])
		ent:Activate()
		phy = ent:GetPhysicsObject()
		if !IsValid(phy) then
			print("WARNING : the physics object of the LFS aircraft "..tostring(ent).." scaled by "..ply:GetName().." ("..ply:SteamID()..") is not valid!")
			return
		end
		phy:EnableMotion(OldMotion)
	end
end)]]