if SERVER then AddCSLuaFile() end

timer.Simple(5,function()
		GredwitchBase=steamworks.ShouldMountAddon(1131455085) and steamworks.IsSubscribed(1131455085)
		LFSBase=steamworks.ShouldMountAddon(1571918906) and steamworks.IsSubscribed(1571918906)
	end
	if !GredwitchBase then
		if CLIENT then
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
	end
	if !LFSBase then
		if CLIENT then
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
	end
end)