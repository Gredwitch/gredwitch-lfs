if SERVER then AddCSLuaFile() end

sound.Add( 	{
	name = "LFS_M2_BROWNING_SHOOT",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/common/m2_shoot.wav"
} )
sound.Add( 	{
	name = "LFS_M2_BROWNING_STOP",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/common/m2_stop.wav"
} )
sound.Add( 	{
	name = "LFS_HS_MK2_SHOOT",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/common/hs_mk2_shoot.wav"
} )
sound.Add( 	{
	name = "LFS_HS_MK2_STOP",
	channel = CHAN_WEAPON,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/common/hs_mk2_stop.wav"
} )

---------------
sound.Add( 	{
	name = "P51A_RPM0",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/p51_lfs/mtg_rpm0.wav"
} )
sound.Add( 	{
	name = "P51A_RPM1",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/p51_lfs/mtg_rpm1.wav"
} )
sound.Add( 	{	
	name = "P51A_RPM2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/p51_lfs/mtg_rpm2.wav"
} )
sound.Add( 	{
	name = "P51A_RPM3",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/p51_lfs/mtg_rpm3.wav"
} )
------------------------------------
sound.Add( 	{
	name = "F4U_RPM0",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/f4u_lfs/f4u_rpm0.wav"
} )
sound.Add( 	{
	name = "F4U_RPM1",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/f4u_lfs/f4u_rpm1.wav"
} )
sound.Add( 	{	
	name = "F4U_RPM2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/f4u_lfs/f4u_rpm2.wav"
} )
sound.Add( 	{
	name = "F4U_RPM3",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/f4u_lfs/f4u_rpm3.wav"
} )
------------------------------------
sound.Add( 	{
	name = "P51D_RPM0",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/p51_lfs/mtg2_rpm0.wav"
} )
sound.Add( 	{
	name = "P51D_RPM1",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/p51_lfs/mtg2_rpm1.wav"
} )
sound.Add( 	{	
	name = "P51D_RPM2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/p51_lfs/mtg2_rpm2.wav"
} )
sound.Add( 	{
	name = "P51D_RPM3",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/p51_lfs/mtg2_rpm3.wav"
} )
------------------------------------
sound.Add( 	{
	name = "P51D_START",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/p51_lfs/mtg2_start.wav"
} )
sound.Add( 	{
	name = "P51D_STOP",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/p51_lfs/mtg2_stop.wav"
} )
sound.Add( 	{
	name = "P51A_START",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/p51_lfs/mtg_start.wav"
} )
sound.Add( 	{
	name = "P51A_STOP",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/p51_lfs/mtg_stop.wav"
} )
sound.Add( 	{
	name = "F4U_START",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/f4u_lfs/f4u_start.wav"
} )
sound.Add( 	{
	name = "F4U_STOP",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 90,
	sound = "gredwitch/f4u_lfs/f4u_stop.wav"
} )
sound.Add( 	{
	name = "P51_DIST",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/p51_lfs/p51_distant.wav"
} )
sound.Add( 	{
	name = "F4U_DIST",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 125,
	sound = "^gredwitch/f4u_lfs/f4u_distant.wav"
} )

timer.Simple(5,function()
	if CLIENT then
		GredwitchBase=steamworks.ShouldMountAddon(1131455085) and steamworks.IsSubscribed(1131455085)
		LFSBase=steamworks.ShouldMountAddon(1571918906) and steamworks.IsSubscribed(1571918906)
		-- AddonMats=steamworks.ShouldMountAddon(1602348103) and steamworks.IsSubscribed(1602348103)
		if !GredwitchBase then
			GredFrame=vgui.Create('DFrame')
			GredFrame:SetTitle("Grediwtch's Base is not installed / enabled")
			GredFrame:SetSize(ScrW()*0.95, ScrH()*0.95)
			GredFrame:SetPos((ScrW() - GredFrame:GetWide()) / 2, (ScrH() - GredFrame:GetTall()) / 2)
			GredFrame:MakePopup()
			
			local h=vgui.Create('DHTML')
			h:SetParent(GredFrame)
			h:SetPos(GredFrame:GetWide()*0.005, GredFrame:GetTall()*0.03)
			local x,y = GredFrame:GetSize()
			h:SetSize(x*0.99,y*0.96)
			h:SetAllowLua(true)
			h:OpenURL('https://steamcommunity.com/sharedfiles/filedetails/?id=1131455085.html')
		
		end
		if !LFSBase then
			GredEMPFrame=vgui.Create('DFrame')
			GredEMPFrame:SetTitle("LFS is not installed / enabled")
			GredEMPFrame:SetSize(ScrW()*0.95, ScrH()*0.95)
			GredEMPFrame:SetPos((ScrW() - GredEMPFrame:GetWide()) / 2, (ScrH() - GredEMPFrame:GetTall()) / 2)
			GredEMPFrame:MakePopup()
			
			local h=vgui.Create('DHTML')
			h:SetParent(GredEMPFrame)
			h:SetPos(GredEMPFrame:GetWide()*0.005, GredEMPFrame:GetTall()*0.03)
			local x,y = GredEMPFrame:GetSize()
			h:SetSize(x*0.99,y*0.96)
			h:SetAllowLua(true)
			h:OpenURL('https://steamcommunity.com/sharedfiles/filedetails/?id=1571918906.html')
		end
		-- if !AddonMats then
			-- GredMatsFrame=vgui.Create('DFrame')
			-- GredMatsFrame:SetTitle("LFS WW2 Luftwaffe Pack (materials) is not installed / enabled")
			-- GredMatsFrame:SetSize(ScrW()*0.95, ScrH()*0.95)
			-- GredMatsFrame:SetPos((ScrW() - GredMatsFrame:GetWide()) / 2, (ScrH() - GredMatsFrame:GetTall()) / 2)
			-- GredMatsFrame:MakePopup()
			
			-- local h=vgui.Create('DHTML')
			-- h:SetParent(GredMatsFrame)
			-- h:SetPos(GredMatsFrame:GetWide()*0.005, GredMatsFrame:GetTall()*0.03)
			-- local x,y = GredMatsFrame:GetSize()
			-- h:SetSize(x*0.99,y*0.96)
			-- h:SetAllowLua(true)
			-- h:OpenURL('https://steamcommunity.com/sharedfiles/filedetails/?id=1602348103.html')
		-- end
	end
end)