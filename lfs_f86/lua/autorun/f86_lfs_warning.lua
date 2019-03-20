AddCSLuaFile()

sound.Add( 	{
	name = "LFS_M3_BROWNING_STOP",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/common/m2_stop.wav"
} )
sound.Add( 	{
	name = "LFS_M3_BROWNING_SHOOT",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/common/m3_shoot.wav"
} )

---------------------------------------------------------------

sound.Add( 	{
	name = "LFS_PART_DESTROYED_01",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 130,
	sound = "gredwitch/common/plane_explosion_1.wav"
} )
sound.Add( 	{
	name = "LFS_PART_DESTROYED_02",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 130,
	sound = "gredwitch/common/plane_explosion_2.wav"
} )
sound.Add( 	{
	name = "LFS_PART_DESTROYED_03",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 130,
	sound = "gredwitch/common/plane_explosion_3.wav"
} )

---------------------------------------------------------------

sound.Add( 	{
	name = "LFS_JET_PASSBY_CLOSE_01",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 0,
	sound = "gredwitch/common/passby_jet_close-001.wav"
} )
sound.Add( 	{
	name = "LFS_JET_PASSBY_CLOSE_02",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 0,
	sound = "gredwitch/common/passby_jet_close-002.wav"
} )
sound.Add( 	{
	name = "LFS_JET_PASSBY_CLOSE_03",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 0,
	sound = "gredwitch/common/passby_jet_close-003.wav"
} )
sound.Add( 	{
	name = "LFS_JET_PASSBY_DISTANT_01",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 0,
	sound = "gredwitch/common/passby_jet_distant-001.wav"
} )
sound.Add( 	{
	name = "LFS_JET_PASSBY_DISTANT_02",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 0,
	sound = "gredwitch/common/passby_jet_distant-002.wav"
} )
sound.Add( 	{
	name = "LFS_JET_PASSBY_DISTANT_03",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 0,
	sound = "gredwitch/common/passby_jet_distant-003.wav"
} )

---------------------------------------------------------------

sound.Add( 	{
	name = "F86_RPM0",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/f86_lfs/f86_rpm0.wav"
} )
sound.Add( 	{
	name = "F86_RPM1",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/f86_lfs/f86_rpm1.wav"
} )
sound.Add( 	{
	name = "F86_RPM2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/f86_lfs/f86_rpm2.wav"
} )
sound.Add( 	{
	name = "F86_RPM3",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/f86_lfs/f86_rpm3.wav"
} )
sound.Add( 	{
	name = "F86_START",
	channel = CHAN_STATIC,
	volume = 0.1,
	level = 125,
	sound = "gredwitch/f86_lfs/f86_start.wav"
} )
sound.Add( 	{
	name = "F86_STOP",
	channel = CHAN_STATIC,
	volume = 0.1,
	level = 125,
	sound = "gredwitch/f86_lfs/f86_stop.wav"
} )

---------------------------------------------------------------
for i = 1,3 do
sound.Add( 	{
	name = "GRED_VO_HOLE_LEFT_WING_0"..i,
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "gredwitch/voice/eng_left_wing_v1_r"..i.."_t1_mood_high.wav"
} )
sound.Add( 	{
	name = "GRED_VO_HOLE_RIGHT_WING_0"..i,
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "gredwitch/voice/eng_right_wing_v1_r"..i.."_t1_mood_high.wav"
} )
sound.Add( 	{
	name = "GRED_VO_BAILOUT_0"..i,
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/voice/eng_bailout_v1_r"..i.."_t1_mood_high.wav"
} )
end

gred = gred or {}
local tableinsert = table.insert
gred.AddonList = gred.AddonList or {}
tableinsert(gred.AddonList,1131455085) -- Base
tableinsert(gred.AddonList,1571918906) -- LFS Base
tableinsert(gred.AddonList,971538203) -- Content

if SERVER then
	util.AddNetworkString("gred_lfs_setparts")
	util.AddNetworkString("gred_lfs_remparts")
end
if CLIENT then
	net.Receive("gred_lfs_setparts",function()
		local self = net.ReadEntity()
		if not self then print("[F-86] ERROR! ENTITY NOT INITALIZED CLIENT SIDE! PLEASE, RE-SPAWN!") return end
		self.Parts = {}
		for k,v in pairs(net.ReadTable()) do
			self.Parts[k] = v
		end
	end)
	net.Receive("gred_lfs_remparts",function()
		local self = net.ReadEntity()
		local k = net.ReadString()
		
		self.EmitNow = self.EmitNow or {}
		if (k == "wing_l" or k == "wing_r") and self.EmitNow[k] != "CEASE" then
			self.EmitNow[k] = true
		end
		if self.Parts then
			self.Parts[k] = nil
		end
	end)
end


--DO NOT EDIT OR REUPLOAD THIS FILE
if CLIENT then
	timer.Simple(1,function()
		local LFS_TIME_NOTIFY = 0
		net.Receive( "lfs_failstartnotify", function( len )
			surface.PlaySound( "common/wpn_hudon.ogg" )
			LFS_TIME_NOTIFY = CurTime() + 2
		end )
		
		local function DrawCircle( X, Y, radius )
			local segmentdist = 360 / ( 2 * math.pi * radius / 2 )
			
			for a = 0, 360, segmentdist do
				surface.DrawLine( X + math.cos( math.rad( a ) ) * radius, Y - math.sin( math.rad( a ) ) * radius, X + math.cos( math.rad( a + segmentdist ) ) * radius, Y - math.sin( math.rad( a + segmentdist ) ) * radius )
				
				surface.DrawLine( X + math.cos( math.rad( a ) ) * radius, Y - math.sin( math.rad( a ) ) * radius, X + math.cos( math.rad( a + segmentdist ) ) * radius, Y - math.sin( math.rad( a + segmentdist ) ) * radius )
			end
		end
		
		local MinZ = 0
		local function PaintPlaneHud( ent, X, Y )

			if not IsValid( ent ) then return end
			
			local vel = ent:GetVelocity():Length()
			
			local Throttle = ent:GetThrottlePercent()
			local Col = Throttle <= 100 and Color(255,255,255,255) or Color(255,0,0,255)
			draw.SimpleText( "THR", "LFS_FONT", 10, 10, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			draw.SimpleText( Throttle.."%" , "LFS_FONT", 120, 10, Col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			
			local speed = math.Round(vel * 0.09144,0)
			draw.SimpleText( "IAS", "LFS_FONT", 10, 35, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			draw.SimpleText( speed.."km/h" , "LFS_FONT", 120, 35, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			
			local ZPos = math.Round( ent:GetPos().z,0)
			if (ZPos + MinZ)< 0 then MinZ = math.abs(ZPos) end
			
			local alt = math.Round( (ent:GetPos().z + MinZ) * 0.0254,0)
			
			draw.SimpleText( "ALT", "LFS_FONT", 10, 60, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			draw.SimpleText( alt.."m" , "LFS_FONT", 120, 60, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			
			local AmmoPrimary = ent:GetAmmoPrimary()
			local AmmoSecondary = ent:GetAmmoSecondary()
			
			if ent:GetMaxAmmoPrimary() > -1 then
				draw.SimpleText( "PRI", "LFS_FONT", 10, 85, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
				draw.SimpleText( ent:GetAmmoPrimary(), "LFS_FONT", 120, 85, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			end
			
			if ent:GetMaxAmmoSecondary() > -1 then
				draw.SimpleText( "SEC", "LFS_FONT", 10, 110, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
				draw.SimpleText( ent:GetAmmoSecondary(), "LFS_FONT", 120, 110, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			end
			
			ent:LFSHudPaint( X, Y, {speed = speed, altitude = alt, PrimaryAmmo = AmmoPrimary, SecondaryAmmo = AmmoSecondary, Throttle = Throttle}, ply )
		end
	
		local smHider = 0
		local function PaintSeatSwitcher( ent, X, Y )
			local me = LocalPlayer()
			 
			if not IsValid( ent ) then return end
			
			local pSeats = ent:GetPassengerSeats()
			local SeatCount = table.Count( pSeats ) 
			
			if SeatCount <= 0 then return end
			
			pSeats[0] = ent:GetDriverSeat()
			
			draw.NoTexture() 
			
			local MySeat = me:GetVehicle():GetNWInt( "pPodIndex", -1 )
			
			local Passengers = {}
			for _, ply in pairs( player.GetAll() ) do
				if ply:lfsGetPlane() == ent then
					local Pod = ply:GetVehicle()
					Passengers[ Pod:GetNWInt( "pPodIndex", -1 ) ] = ply:GetName()
				end
			end
			if ent:GetAI() then
				Passengers[1] = "[AI] "..ent.PrintName
			end
			
			me.SwitcherTime = me.SwitcherTime or 0
			me.oldPassengers = me.oldPassengers or {}
			
			local Time = CurTime()
			for k, v in pairs( Passengers ) do
				if me.oldPassengers[k] ~= v then
					me.oldPassengers[k] = v
					me.SwitcherTime = Time + 2
				end
			end
			for k, v in pairs( me.oldPassengers ) do
				if not Passengers[k] then
					me.oldPassengers[k] = nil
					me.SwitcherTime = Time + 2
				end
			end
			
			for _, v in pairs( simfphys.LFS.pSwitchKeysInv ) do
				if input.IsKeyDown(v) then
					me.SwitcherTime = Time + 2
				end
			end
			
			local Hide = me.SwitcherTime > Time
			smHider = smHider + ((Hide and 1 or 0) - smHider) * FrameTime() * 15
			local Alpha1 = 135 + 110 * smHider 
			local HiderOffset = 300 * smHider
			local Offset = -50
			local yPos = Y - (SeatCount + 1) * 30 - 10
			
			for _, Pod in pairs( pSeats ) do
				local I = Pod:GetNWInt( "pPodIndex", -1 )
				if I >= 0 then
					if I == MySeat then
						draw.RoundedBox(5, X + Offset - HiderOffset, yPos + I * 30, 35 + HiderOffset, 25, Color(127,0,0,100 + 50 * smHider) )
					else
						draw.RoundedBox(5, X + Offset - HiderOffset, yPos + I * 30, 35 + HiderOffset, 25, Color(0,0,0,100 + 50 * smHider) )
					end
					if Hide then
						if Passengers[I] then
							draw.DrawText( Passengers[I], "LFS_FONT_SWITCHER", X + 40 + Offset - HiderOffset, yPos + I * 30 + 2.5, Color( 255, 255, 255,  Alpha1 ), TEXT_ALIGN_LEFT )
						else
							draw.DrawText( "-", "LFS_FONT_SWITCHER", X + 40 + Offset - HiderOffset, yPos + I * 30 + 2.5, Color( 255, 255, 255,  Alpha1 ), TEXT_ALIGN_LEFT )
						end
						
						draw.DrawText( "["..I.."]", "LFS_FONT_SWITCHER", X + 17 + Offset - HiderOffset, yPos + I * 30 + 2.5, Color( 255, 255, 255, Alpha1 ), TEXT_ALIGN_CENTER )
					else
						if Passengers[I] then
							draw.DrawText( "[^"..I.."]", "LFS_FONT_SWITCHER", X + 17 + Offset - HiderOffset, yPos + I * 30 + 2.5, Color( 255, 255, 255, Alpha1 ), TEXT_ALIGN_CENTER )
						else
							draw.DrawText( "["..I.."]", "LFS_FONT_SWITCHER", X + 17 + Offset - HiderOffset, yPos + I * 30 + 2.5, Color( 255, 255, 255, Alpha1 ), TEXT_ALIGN_CENTER )
						end
					end
				end
			end
		end
		
		local NextFind = 0
		local AllPlanes = {}
		local function PaintPlaneIdentifier( ent )
			if not ShowPlaneIdent then return end
			
			if NextFind < CurTime() then
				NextFind = CurTime() + 3
				AllPlanes = simfphys.LFS:PlanesGetAll()
			end
			
			local MyPos = ent:GetPos()
			local MyTeam = ent:GetAITEAM()
			
			for _, v in pairs( AllPlanes ) do
				if IsValid( v ) then
					if v ~= ent then
						if isvector( v.SeatPos ) then
							local rPos = v:LocalToWorld( v.SeatPos )
							local Pos = rPos:ToScreen()
							local Size = 60
							local Dist = (MyPos - rPos):Length()
							
							if Dist < 13000 then
								local Alpha = math.max(255 - Dist * 0.015,0)
								local Team = v:GetAITEAM()
								
								if Team == 0 then
									surface.SetDrawColor( 255, 150, 0, Alpha )
								else
									if Team ~= MyTeam then
										surface.SetDrawColor( 255, 0, 0, Alpha )
									else
										surface.SetDrawColor( 0, 127, 255, Alpha )
									end
								end
								
								surface.DrawLine( Pos.x - Size, Pos.y + Size, Pos.x + Size, Pos.y + Size )
								surface.DrawLine( Pos.x - Size, Pos.y - Size, Pos.x - Size, Pos.y + Size )
								surface.DrawLine( Pos.x + Size, Pos.y - Size, Pos.x + Size, Pos.y + Size )
								surface.DrawLine( Pos.x - Size, Pos.y - Size, Pos.x + Size, Pos.y - Size )
							end
						end
					end
				end
			end
		end
		
		
		
		hook.Add( "HUDPaint", "!!!!LFS_hud", function()
			local ply = LocalPlayer()
			
			if ply:GetViewEntity() ~= ply then return end
			
			local Pod = ply:GetVehicle()
			local Parent = ply:lfsGetPlane()
			
			if not IsValid( Pod ) or not IsValid( Parent ) then 
				ply.oldPassengers = {}
				
				return
			end
			
			local X = ScrW()
			local Y = ScrH()
			
			PaintSeatSwitcher( Parent, X, Y )
			
			if Parent:GetDriverSeat() ~= Pod then 
				Parent:LFSHudPaintPassenger( X, Y, ply )
				
				return
			end
			
			if HintPlayerAboutHisFuckingIncompetence then
				if not Parent.ERRORSOUND then
					surface.PlaySound( "error.wav" )
					Parent.ERRORSOUND = true
				end
				
				local HintCol = Color(255,0,0, 255 )
				
				surface.SetDrawColor( 0, 0, 0, 255 )
				surface.DrawRect( 0, 0, X, Y ) 
				surface.SetDrawColor( 255, 255, 255, 255 )
				
				draw.SimpleText( "OOPS! SOMETHING WENT WRONG :( ", "LFS_FONT", X * 0.5, Y * 0.5 - 40, HintCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( "ONE OF YOUR ADDONS IS BREAKING THE CALCVIEW HOOK. PLANES WILL NOT BE USEABLE", "LFS_FONT", X * 0.5, Y * 0.5 - 20, HintCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( "HOW TO FIX?", "LFS_FONT", X * 0.5, Y * 0.5 + 20, HintCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( "DISABLE ALL ADDONS THAT COULD POSSIBLY MESS WITH THE CAMERA-VIEW", "LFS_FONT", X * 0.5, Y * 0.5 + 40, HintCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( "(THIRDPERSON ADDONS OR SIMILAR)", "LFS_FONT", X * 0.5, Y * 0.5 + 60, HintCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				
				draw.SimpleText( ">>PRESS YOUR USE-KEY TO LEAVE THE VEHICLE & HIDE THIS MESSAGE<<", "LFS_FONT", X * 0.5, Y * 0.5 + 120, Color(255,0,0, math.abs( math.cos( CurTime() ) * 255) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				
				return
			end
			
			PaintPlaneHud( Parent, X, Y )
			PaintPlaneIdentifier( Parent )
			
			local startpos =  Parent:GetRotorPos()
			local partnum = {}
			local a = 1
			if Parent.Parts then
				for k,v in pairs(Parent.Parts) do
					partnum[a] = v
					a = a + 1
				end
			end
			partnum[a] = Parent
			local TracePlane = util.TraceLine( {
				start = startpos,
				endpos = (startpos + Parent:GetForward() * 50000),
				filter = partnum
			} )
			
			local TracePilot = util.TraceLine( {
				start = startpos,
				endpos = (startpos + ply:EyeAngles():Forward() * 50000),
				filter = partnum
			} )
			local HitPlane = TracePlane.HitPos:ToScreen()
			local HitPilot = TracePilot.HitPos:ToScreen()

			local Sub = Vector(HitPilot.x,HitPilot.y,0) - Vector(HitPlane.x,HitPlane.y,0)
			local Len = Sub:Length()
			local Dir = Sub:GetNormalized()
			surface.SetDrawColor( 255, 255, 255, 100 )
			if Len > 34 then
				local FailStart = LFS_TIME_NOTIFY > CurTime()
				if FailStart then
					surface.SetDrawColor( 255, 0, 0, math.abs( math.cos( CurTime() * 10 ) ) * 255 )
				end
				
				if not ply:KeyDown( IN_WALK ) or FailStart then
					surface.DrawLine( HitPlane.x + Dir.x * 10, HitPlane.y + Dir.y * 10, HitPilot.x - Dir.x * 34, HitPilot.y- Dir.y * 34 )
					
					-- shadow
					surface.SetDrawColor( 0, 0, 0, 50 )
					surface.DrawLine( HitPlane.x + Dir.x * 10 + 1, HitPlane.y + Dir.y * 10 + 1, HitPilot.x - Dir.x * 34+ 1, HitPilot.y- Dir.y * 34 + 1 )
				end
			end
			
			surface.SetDrawColor( 255, 255, 255, 255 )
			DrawCircle( HitPlane.x, HitPlane.y, 10 )
			surface.DrawLine( HitPlane.x + 10, HitPlane.y, HitPlane.x + 20, HitPlane.y ) 
			surface.DrawLine( HitPlane.x - 10, HitPlane.y, HitPlane.x - 20, HitPlane.y ) 
			surface.DrawLine( HitPlane.x, HitPlane.y + 10, HitPlane.x, HitPlane.y + 20 ) 
			surface.DrawLine( HitPlane.x, HitPlane.y - 10, HitPlane.x, HitPlane.y - 20 ) 
			DrawCircle( HitPilot.x, HitPilot.y, 34 )
			
			-- shadow
			surface.SetDrawColor( 0, 0, 0, 80 )
			DrawCircle( HitPlane.x + 1, HitPlane.y + 1, 10 )
			surface.DrawLine( HitPlane.x + 11, HitPlane.y + 1, HitPlane.x + 21, HitPlane.y + 1 ) 
			surface.DrawLine( HitPlane.x - 9, HitPlane.y + 1, HitPlane.x - 16, HitPlane.y + 1 ) 
			surface.DrawLine( HitPlane.x + 1, HitPlane.y + 11, HitPlane.x + 1, HitPlane.y + 21 ) 
			surface.DrawLine( HitPlane.x + 1, HitPlane.y - 19, HitPlane.x + 1, HitPlane.y - 16 ) 
			DrawCircle( HitPilot.x + 1, HitPilot.y + 1, 34 )
		end )

		------------------------------------------------------
		
	end)
end