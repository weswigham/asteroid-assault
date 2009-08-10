/*---------------------------------------------------------
Asteroid Assault
By Levybreak
---------------------------------------------------------*/

include( 'shared.lua' )
include( 'player_extensions.lua' )
include( 'perks.lua' )
include( 'cl_scoreboard.lua' )


function GM:Initialize()

	self.BaseClass:Initialize()
	surface.CreateFont("arvigo",30,700,true,false,"Avirgo30")
	--util.Effect("laser_sight",EffectData())
	
end


function PointOn2DBezierCurve(dis,pt1,pt2,pt3) --my poor attempt at a bezier curve algorthm. I think dis is distance along the curve, pt1 is start, pt2 is control, and pt3 is end.
	local out1 = ((1-dis)^2)*pt1.x+2*(1-dis)*dis*pt2.x+(dis^2)*pt3.x
	local out2 = ((1-dis)^2)*pt1.y+2*(1-dis)*dis*pt2.y+(dis^2)*pt3.y
	return out1,out2
end

function TableOfPointsOnCurve(col,w,h,itier,dist,pt1,pt2,pt3) --Color, width, height, iterations(smoothness), distance(is a part of iterations), start point, control point, end point
	local outtable = {}
	local start = 1/itier
	dist = math.Clamp(dist,1,itier)
	for i=1,dist do
		local x,y = PointOn2DBezierCurve(start,pt1,pt2,pt3)
		local tbl = {}
		tbl["x"] = x
		tbl["y"] = y
		tbl["w"] = w
		tbl["h"] = h
		tbl["color"] = col
		tbl["texture"] = draw.NoTexture()
		table.insert(outtable,tbl)
		start = start + 1/itier
	end
	return outtable
end

function GM:HUDPaint()

	surface.CreateFont("Arvigo",30,600,true,false,"Arvigo30")
	
	GAMEMODE:HUDDrawTargetID()
	GAMEMODE:HUDDrawPickupHistory()
	GAMEMODE:DrawDeathNotice( 0.85, 0.1 )
	
	local div = math.ceil(CurTime()/(255+150))
	surface.SetFont("Arvigo30")
	
	draw.WordBox( 10, 20, 20, "Money: "..LocalPlayer():GetNWInt("money"),"Arvigo30", Color(0,0,0,150), Color(CurTime()/div+150,100,100,250))
	local text = "Experience: "..LocalPlayer():GetNWInt("exp")
	draw.WordBox( 10, ScrW()-30-surface.GetTextSize(text), 20, text,"Arvigo30", Color(0,0,0,150), Color(80,80,200,250))
	
	if self.lastframemoney and self.lastframemoney != LocalPlayer():GetNWInt("money") then
		local length = surface.GetTextSize("Money: "..LocalPlayer():GetNWInt("money"))
		if LocalPlayer():GetNWInt("money")-self.lastframemoney > 0 then
			local value = LocalPlayer():GetNWInt("money")-self.lastframemoney
			hook.Add("HUDPaint","MoneyChange",function() draw.SimpleText("+$"..value,"Arvigo30",50+length,30,Color(CurTime()/div+150,250,100,250),TEXT_ALIGN_LEFT,TEXT_ALIGN_LEFT) end)
			timer.Simple(3,function() hook.Remove("HUDPaint","MoneyChange") end)
		else
			local value = math.abs(LocalPlayer():GetNWInt("money")-self.lastframemoney)
			hook.Add("HUDPaint","MoneyChange",function() draw.SimpleText("-$"..value,"Arvigo30",50+length,30,Color(250,CurTime()/div+150,100,250),TEXT_ALIGN_LEFT,TEXT_ALIGN_LEFT) end)
			timer.Simple(3,function() hook.Remove("HUDPaint","MoneyChange") end)
		end
	end
	self.lastframemoney = LocalPlayer():GetNWInt("money")
	
	
	local stufftodraw = TableOfPointsOnCurve(Color(0,0,0,200),1,20,500,500,{x=(ScrW()/2)-200,y=ScrH()},{x=(ScrW()/2),y=ScrH()-200},{x=(ScrW()/2)+200,y=ScrH()})
	for k,v in pairs(stufftodraw) do
		draw.TexturedQuad(v)
	end
	
	local dist = 0
	
	if GetGlobalInt("buildmode") > 0 then
		dist = (500/(3*60))*(GetGlobalInt("buildmode")/60)
		local str = ""
		local seconds = math.ceil(math.fmod(GetGlobalInt("buildmode")/60,60))
		if seconds < 10 then
			str = "Build Time Remaining- "..(math.floor((GetGlobalInt("buildmode")/60)/60))..":0"..seconds
		else
			str = "Build Time Remaining- "..(math.floor((GetGlobalInt("buildmode")/60)/60))..":"..seconds
		end
		draw.WordBox( 10, (ScrW()/2)-(surface.GetTextSize(str)/2)-5, ScrH()-45, str,"Arvigo30", Color(0,0,0,150), Color(CurTime()/div+150,100,100,250))
	elseif GetGlobalInt("armeggadon") > 0 then
		dist = (500/(12*60))*(GetGlobalInt("armeggadon")/60)
		local str = ""
		local seconds = math.ceil(math.fmod(GetGlobalInt("armeggadon")/60,60))
		if seconds < 10 then
			str = "Armageddon Time Remaining- "..(math.floor((GetGlobalInt("armeggadon")/60)/60))..":0"..seconds
		else
			str = "Armageddon Time Remaining- "..(math.floor((GetGlobalInt("armeggadon")/60)/60))..":"..seconds
		end
		draw.WordBox( 10, (ScrW()/2)-(surface.GetTextSize(str)/2)-5, ScrH()-45, str,"Arvigo30", Color(0,0,0,150), Color(CurTime()/div+150,100,100,250))
	end
	
	local stufftodraw2 = TableOfPointsOnCurve(Color(255-math.Clamp(500/(dist/8)*1.5,0,255),255-math.Clamp((500/(dist/8)*1.5)+10,0,255),255,255),1,10,500,dist,{x=(ScrW()/2)-200,y=ScrH()+5},{x=(ScrW()/2),y=ScrH()-195},{x=(ScrW()/2)+200,y=ScrH()+5})
	for k,v in pairs(stufftodraw2) do
		draw.TexturedQuad(v)
	end
	
end

--------------
--Perk Stuff--
--------------
local PerksToGive = {}

local function RecievePerkz(um) --Hurhur. local to prevent abuse by smart playaz
	local perk = um:ReadString()
	if LocalPlayer():IsValid() then
		GivePerk(LocalPlayer(),perk)
		LocalPlayer():PrintMessage( HUD_PRINTTALK,"You have recieved the perk "..(perk or "bugged usermessage").."!")
	else
		table.insert(PerksToGive,perk)
	end
end
usermessage.Hook("RecievePerks",RecievePerkz)

function GM:PlayerValid(ply)
	if PerksToGive and PerksToGive != {} then
		for k,perk in pairs(PerksToGive) do
			GivePerk(LocalPlayer(),perk)
		end
	end
end

local function MakeGetNewPerkWindow(um) 
	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( (ScrW()/2)-185,(ScrH()/2)-200 )
	DermaPanel:SetSize( 370, 400 )
	DermaPanel:SetTitle( "Chose a new perk!" )
	DermaPanel:SetVisible( true ) 
	DermaPanel:SetDraggable( true )
	DermaPanel:ShowCloseButton( false )
	DermaPanel:MakePopup()
	
	local SheetDPanel = vgui.Create( "DPanelList", DermaPanel)
	SheetDPanel:SetPos(5,30)
	SheetDPanel:SetSize(360,360)
	SheetDPanel:SetSpacing( 5 )
	SheetDPanel:EnableHorizontal( false )
	SheetDPanel:EnableVerticalScrollbar( true )
	
	for k,v in pairs(GetAllTypesOfPerks()) do
	
	local SheetItemOne = vgui.Create("DCollapsibleCategory") 
	SheetItemOne:SetSize( 350,350 )
	SheetItemOne:SetExpanded( 0 )
	SheetItemOne:SetLabel( v ) 
	SheetDPanel:AddItem( SheetItemOne ) 
	
	
	local CategoryList = vgui.Create( "DPanelList" ) 
	CategoryList:SetAutoSize(true)
	CategoryList:SetSpacing( 5 ) 
	CategoryList:EnableHorizontal( false ) 
	CategoryList:EnableVerticalScrollbar( true ) 
	SheetItemOne:SetContents( CategoryList )
	
	for kz,vz in pairs(GetAllPerksOfType(v)) do
		if vz.Level <= math.floor(LocalPlayer():GetNWInt("exp")/600) then
		local CategoryContentOne = vgui.Create( "DPanel" ) 
		CategoryContentOne:SetSize(340,75)
		
		local DaButton = vgui.Create( "DButton", CategoryContentOne)
		DaButton:SetPos(4,4)
		DaButton:SetSize(67,67)
		DaButton:SetText(vz.Name)
		DaButton.DoClick = function()
			RunConsoleCommand("IdLikeToBuyAVowelIMeanPerk",vz.Name)
			DermaPanel:Close()
		end
		if HasPerk(LocalPlayer(),vz.Name) or not (math.floor(LocalPlayer():GetNWInt("exp")/600) >= Perks[vz.Name].Level) then
			DaButton:SetDisabled(true)
		end
		
		local Decr = vgui.Create( "DLabel", CategoryContentOne)
		Decr:SetPos(80,4)
		Decr:SetText(vz.Desc.."\nLevel: "..vz.Level)
		Decr:SetSize(240,67)
		
		CategoryList:AddItem( CategoryContentOne ) 
		end
	end
	end
	if HasAllPerks(LocalPlayer()) == true then DermaPanel:Close() end
end
usermessage.Hook("ChoseNewPerk",MakeGetNewPerkWindow)

------------------
--End Perk Stuff--
------------------

function BuyItemsMenu(ply, cmd, activetab) --Automatically adds new subcategories now. :D

local DermaPanel = vgui.Create( "DFrame" )
DermaPanel:SetPos( (ScrW()/2)-185,(ScrH()/2)-200 )
DermaPanel:SetSize( 370, 400 )
DermaPanel:SetTitle( "General Use Menu" )
DermaPanel:SetVisible( true ) 
DermaPanel:SetDraggable( true )
DermaPanel:ShowCloseButton( true )
DermaPanel:MakePopup()


local PropertySheet = vgui.Create( "DPropertySheet" )
PropertySheet:SetParent( DermaPanel )
PropertySheet:SetPos( 5, 30 )
PropertySheet:SetSize(360, 365)

	local SheetDPanel = vgui.Create( "DPanelList")
	SheetDPanel:SetPos(5,30)
	SheetDPanel:SetSize(360,360)
	SheetDPanel:SetSpacing( 5 )
	SheetDPanel:EnableHorizontal( false )
	SheetDPanel:EnableVerticalScrollbar( true )

	for kz,vz in pairs(RetrieveAllSubCategorys("bomb")) do
	local ExplosiveType = vgui.Create("DCollapsibleCategory") 
		ExplosiveType:SetSize( 350, 350 )
		ExplosiveType:SetExpanded( 0 )
		ExplosiveType:SetLabel( vz ) 
	SheetDPanel:AddItem( ExplosiveType ) 
	
		local CategoryList = vgui.Create( "DPanelList" ) 
			CategoryList:SetAutoSize(true)
			CategoryList:SetSpacing( 5 ) 
			CategoryList:EnableHorizontal( false ) 
			CategoryList:EnableVerticalScrollbar( true ) 
  
		ExplosiveType:SetContents( CategoryList )
		
			for k,v in pairs(RetrieveAllItemsInSubCategory("bomb",vz)) do
				local DPanelz = vgui.Create( "DPanel" ) 
				DPanelz:SetSize(340,75)
		
				local CategoryContentOne = vgui.Create( "DModelPanel",  DPanelz) 
				CategoryContentOne:SetModel( v.Model ) 
				CategoryContentOne:SetFOV(v.FOV or 40)
				CategoryContentOne:SetPos(4,4)
				CategoryContentOne:SetSize(67,67)
				CategoryContentOne:SetLookAt(Vector(0,0,0))
    			CategoryContentOne.DoClick = function()
					if LocalPlayer():GetNWInt("money") >= (v.Cost*((100-LocalPlayer():GetDiscount())/100)) then
						local pos = GetPosForSpawning()
						if pos == nil then
							LocalPlayer():PrintMessage( HUD_PRINTTALK, "That position is too far away to spawn something at." )
						else
							RunConsoleCommand("BuySomeShit", v.Name.." "..(pos or " "))
						end
					else
						LocalPlayer():PrintMessage( HUD_PRINTTALK, "You don't have enough money for that "..v.Name.." you need $"..v.Cost-LocalPlayer():GetNWInt("money").." more!" )
					end
    			end 
				
				local Decr = vgui.Create( "DLabel", DPanelz)
				Decr:SetPos(80,4)
				Decr:SetText((v.NiceName or v.Name)..": "..v.Desc.."\nCost: "..v.Cost.."\nWarnings: "..(v.Warning or "none"))
				Decr:SetSize(250,67)
		
				CategoryList:AddItem( DPanelz ) 
			end
		end
	
	local SheetItemTwo = vgui.Create( "DPanelList")
	SheetItemTwo:SetPos(5,30)
	SheetItemTwo:SetSize(360,360)
	SheetItemTwo:SetSpacing( 5 )
	SheetItemTwo:EnableHorizontal( false )
	SheetItemTwo:EnableVerticalScrollbar( true )

	for kz,vz in pairs(RetrieveAllSubCategorys("turret")) do
		local SheetItemOne = vgui.Create("DCollapsibleCategory") 
		SheetItemOne:SetSize( 350, 350 )
		SheetItemOne:SetExpanded( 0 )
		SheetItemOne:SetLabel( vz ) 
	SheetItemTwo:AddItem( SheetItemOne ) 
  
			local CategoryList = vgui.Create( "DPanelList" ) 
			CategoryList:SetAutoSize(true)
			CategoryList:SetSpacing( 5 ) 
			CategoryList:EnableHorizontal( false ) 
			CategoryList:EnableVerticalScrollbar( true ) 
  
		SheetItemOne:SetContents( CategoryList )
  
			for k,v in pairs(RetrieveAllItemsInSubCategory("turret",vz)) do
				local DPanelz = vgui.Create( "DPanel" ) 
				DPanelz:SetSize(340,75)
		
				local CategoryContentOne = vgui.Create( "DModelPanel",  DPanelz) 
				CategoryContentOne:SetModel( v.Model ) 
				CategoryContentOne:SetFOV(v.FOV or 40)
				CategoryContentOne:SetPos(4,4)
				CategoryContentOne:SetSize(67,67)
				CategoryContentOne:SetLookAt(Vector(0,0,0))
    			CategoryContentOne.DoClick = function()
					if LocalPlayer():GetNWInt("money") >= (v.Cost*((100-LocalPlayer():GetDiscount())/100)) then
						local pos = GetPosForSpawning()
						if pos == nil then
							LocalPlayer():PrintMessage( HUD_PRINTTALK, "That position is too far away to spawn something at." )
						else
							RunConsoleCommand("BuySomeShit", v.Name.." "..(pos or " "))
						end
					else
						LocalPlayer():PrintMessage( HUD_PRINTTALK, "You don't have enough money for that "..v.Name.." you need $"..v.Cost-LocalPlayer():GetNWInt("money").." more!" )
					end
    			end 
				
				local Decr = vgui.Create( "DLabel", DPanelz)
				Decr:SetPos(80,4)
				Decr:SetText((v.NiceName or v.Name)..": "..v.Desc.."\nCost: "..v.Cost.."\nWarnings: "..(v.Warning or "none"))
				Decr:SetSize(250,67)
		
				CategoryList:AddItem( DPanelz ) 
			end
		end

	local SheetItemThree = vgui.Create( "DPanelList")
	SheetItemThree:SetPos(5,30)
	SheetItemThree:SetSize(360,360)
	SheetItemThree:SetSpacing( 5 )
	SheetItemThree:EnableHorizontal( false )
	SheetItemThree:EnableVerticalScrollbar( true )

		for kz,vz in pairs(RetrieveAllSubCategorys("weapon"))	do
		local SheetItemOne = vgui.Create("DCollapsibleCategory") 
		SheetItemOne:SetSize( 350, 350 )
		SheetItemOne:SetExpanded( 0 )
		SheetItemOne:SetLabel( vz ) 
	SheetItemThree:AddItem( SheetItemOne ) 
  
			local CategoryList = vgui.Create( "DPanelList" ) 
			CategoryList:SetAutoSize(true)
			CategoryList:SetSpacing( 5 ) 
			CategoryList:EnableHorizontal( false ) 
			CategoryList:EnableVerticalScrollbar( true ) 
  
		SheetItemOne:SetContents( CategoryList )
  
			for k,v in pairs(RetrieveAllItemsInSubCategory("weapon",vz)) do
				local DPanelz = vgui.Create( "DPanel" ) 
				DPanelz:SetSize(340,75)
		
				local CategoryContentOne = vgui.Create( "DModelPanel",  DPanelz) 
				CategoryContentOne:SetModel( v.Model ) 
				CategoryContentOne:SetFOV(v.FOV or 40)
				CategoryContentOne:SetPos(4,4)
				CategoryContentOne:SetSize(67,67)
				CategoryContentOne:SetLookAt(Vector(0,0,0))
    			CategoryContentOne.DoClick = function()
					if LocalPlayer():GetNWInt("money") >= (v.Cost*((100-LocalPlayer():GetDiscount())/100)) then
						local pos = GetPosForSpawning()
						RunConsoleCommand("BuySomeShit", v.Name.." "..(pos or " "))
					else
						LocalPlayer():PrintMessage( HUD_PRINTTALK, "You don't have enough money for that "..v.Name.." you need $"..v.Cost-LocalPlayer():GetNWInt("money").." more!" )
					end
    			end 
				
				local Decr = vgui.Create( "DLabel", DPanelz)
				Decr:SetPos(80,4)
				Decr:SetText((v.NiceName or v.Name)..": "..v.Desc.."\nCost: "..v.Cost.."\nWarnings: "..(v.Warning or "none"))
				Decr:SetSize(250,67)
		
				CategoryList:AddItem( DPanelz ) 
			end
		end

	local SheetItemFour = vgui.Create( "DPanelList")
	SheetItemFour:SetPos(5,30)
	SheetItemFour:SetSize(360,360)
	SheetItemFour:SetSpacing( 5 )
	SheetItemFour:EnableHorizontal( false )
	SheetItemFour:EnableVerticalScrollbar( true )

		local SheetItemOne = vgui.Create("DCollapsibleCategory") 
		SheetItemOne:SetSize( 350, 350 )
		SheetItemOne:SetExpanded( 1 )
		SheetItemOne:SetLabel( "Junk" ) 
	SheetItemFour:AddItem( SheetItemOne ) 
  
			local CategoryList = vgui.Create( "DPanelList" ) 
			--CategoryList:SetAutoSize(true)
			CategoryList:SetSpacing( 5 ) 
			CategoryList:EnableHorizontal( true ) 
			CategoryList:EnableVerticalScrollbar( true ) 
			CategoryList:StretchToParent()
			local x,y = CategoryList:GetSize()
			CategoryList:SetSize(x,(75*4)-10)
  
		SheetItemOne:SetContents( CategoryList )
  
			for k,v in pairs(RetrieveAllItemsInCategory("prop")) do
				local CategoryContentOne = vgui.Create( "DModelPanel" ) 
				CategoryContentOne:SetModel( v.Model ) 
				CategoryContentOne:SetFOV(v.FOV or 80)
				CategoryContentOne:SetSize(75,75)
				CategoryContentOne:SetLookAt(Vector(0,0,0))
    			CategoryContentOne.DoClick = function()
					if LocalPlayer():GetNWInt("money") >= (v.Cost*((100-LocalPlayer():GetDiscount())/100)) then
						local pos = GetPosForSpawning()
						if pos == nil then
							LocalPlayer():PrintMessage( HUD_PRINTTALK, "That position is too far away to spawn something at." )
						else
							RunConsoleCommand("BuySomeShit", v.Name.." "..(pos or " "))
						end
					else
						LocalPlayer():PrintMessage( HUD_PRINTTALK, "You don't have enough money for that "..v.Name.." you need $"..v.Cost-LocalPlayer():GetNWInt("money").." more!" )
					end
    			end 
				CategoryList:AddItem( CategoryContentOne ) 
			end

local HelpDPanel = vgui.Create( "DLabel" )
HelpDPanel:SetPos(5,5)
HelpDPanel:SetText([[Welcome to Asteroid Assault!
Your goal is to survive as long as possible through earning
money and perks! You earn money by shooting down asteroids!
You earn perks by leveling up! You get a level every 600 experience
and you gain 1 exerience for every 1 second you are alive!
You can try and survive longer by building a base in build mode,
and you can try and make more money by buying better weapons in
battle mode!

~This has been an automated Aperture Science Help Message.]])
HelpDPanel:SizeToContents()
HelpDPanel:SetColor(Color(255,255,255,240))

--[[
PropertySheet:AddSheet("Help", HelpDPanel, "gui/silkicons/group", false, false, "Help Menu")
PropertySheet:AddSheet("Bombs", SheetDPanel, "gui/silkicons/group", false, false, "Buy Bombs Here")
PropertySheet:AddSheet("Turrets", SheetItemTwo, "gui/silkicons/group", false, false, "Buy Turrets Here")
PropertySheet:AddSheet("Weapons", SheetItemThree, "gui/silkicons/group", false, false, "Buy Weapons Here")
PropertySheet:AddSheet("Props", SheetItemFour, "gui/silkicons/group", false, false, "Buy Props Here")]]

	if activetab != nil then
		if activetab == "Props" then
			PropertySheet:AddSheet("Props", SheetItemFour, "gui/silkicons/group", false, false, "Buy Props Here")
			PropertySheet:AddSheet("Weapons", SheetItemThree, "gui/silkicons/group", false, false, "Buy Weapons Here")
			PropertySheet:AddSheet("Turrets", SheetItemTwo, "gui/silkicons/group", false, false, "Buy Turrets Here")
			PropertySheet:AddSheet("Bombs", SheetDPanel, "gui/silkicons/group", false, false, "Buy Bombs Here")
			PropertySheet:AddSheet("Help", HelpDPanel, "gui/silkicons/group", false, false, "Help Menu")
		elseif activetab == "Weapons" then
			PropertySheet:AddSheet("Weapons", SheetItemThree, "gui/silkicons/group", false, false, "Buy Weapons Here")
			PropertySheet:AddSheet("Turrets", SheetItemTwo, "gui/silkicons/group", false, false, "Buy Turrets Here")
			PropertySheet:AddSheet("Bombs", SheetDPanel, "gui/silkicons/group", false, false, "Buy Bombs Here")
			PropertySheet:AddSheet("Props", SheetItemFour, "gui/silkicons/group", false, false, "Buy Props Here")
			PropertySheet:AddSheet("Help", HelpDPanel, "gui/silkicons/group", false, false, "Help Menu")
		elseif activetab == "Turrets" then 
			PropertySheet:AddSheet("Turrets", SheetItemTwo, "gui/silkicons/group", false, false, "Buy Turrets Here")
			PropertySheet:AddSheet("Bombs", SheetDPanel, "gui/silkicons/group", false, false, "Buy Bombs Here")
			PropertySheet:AddSheet("Weapons", SheetItemThree, "gui/silkicons/group", false, false, "Buy Weapons Here")
			PropertySheet:AddSheet("Props", SheetItemFour, "gui/silkicons/group", false, false, "Buy Props Here")
			PropertySheet:AddSheet("Help", HelpDPanel, "gui/silkicons/group", false, false, "Help Menu")
		elseif activetab == "Bombs" then 
			PropertySheet:AddSheet("Bombs", SheetDPanel, "gui/silkicons/group", false, false, "Buy Bombs Here")
			PropertySheet:AddSheet("Turrets", SheetItemTwo, "gui/silkicons/group", false, false, "Buy Turrets Here")
			PropertySheet:AddSheet("Weapons", SheetItemThree, "gui/silkicons/group", false, false, "Buy Weapons Here")
			PropertySheet:AddSheet("Props", SheetItemFour, "gui/silkicons/group", false, false, "Buy Props Here")
			PropertySheet:AddSheet("Help", HelpDPanel, "gui/silkicons/group", false, false, "Help Menu")
		elseif activetab == "Help" then
			PropertySheet:AddSheet("Help", HelpDPanel, "gui/silkicons/group", false, false, "Help Menu")
			PropertySheet:AddSheet("Bombs", SheetDPanel, "gui/silkicons/group", false, false, "Buy Bombs Here")
			PropertySheet:AddSheet("Turrets", SheetItemTwo, "gui/silkicons/group", false, false, "Buy Turrets Here")
			PropertySheet:AddSheet("Weapons", SheetItemThree, "gui/silkicons/group", false, false, "Buy Weapons Here")
			PropertySheet:AddSheet("Props", SheetItemFour, "gui/silkicons/group", false, false, "Buy Props Here")
		else
			PropertySheet:AddSheet("Help", HelpDPanel, "gui/silkicons/group", false, false, "Help Menu")
			PropertySheet:AddSheet("Bombs", SheetDPanel, "gui/silkicons/group", false, false, "Buy Bombs Here")
			PropertySheet:AddSheet("Turrets", SheetItemTwo, "gui/silkicons/group", false, false, "Buy Turrets Here")
			PropertySheet:AddSheet("Weapons", SheetItemThree, "gui/silkicons/group", false, false, "Buy Weapons Here")
			PropertySheet:AddSheet("Props", SheetItemFour, "gui/silkicons/group", false, false, "Buy Props Here")
		end
	end

end 
concommand.Add("OpenBuyWindow", BuyItemsMenu)

function OpenTheBuyWindowFromSpawnKey()
	BuyItemsMenu(nil,nil,"Props")
end 

function OpenTheBuyWindowFromContextKey()
	if GetGlobalInt("buildmode") > 0 then
		BuyItemsMenu(nil,nil,"Props")
	else
		BuyItemsMenu(nil,nil,"Weapons")
	end
end 

function OpenBuyMenuFromServer(um)
	BuyItemsMenu(nil,nil,um:ReadString())
end
usermessage.Hook("OpenBuyMenuFromServer",OpenBuyMenuFromServer)

hook.Add("OnSpawnMenuOpen","UponOpeningTehMenuz",OpenTheBuyWindowFromSpawnKey)
hook.Add("OnContextMenuOpen","UponOpeningTehContextMenuz",OpenTheBuyWindowFromContextKey)

function GetPosForSpawning()
	local trace = LocalPlayer():GetEyeTrace()
	if trace.HitPos:Distance(LocalPlayer():GetPos()) <= 2510 then
		return tostring(trace.HitPos)
	else
		return nil
	end
end
