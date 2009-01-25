/*---------------------------------------------------------
Asteroid Assault
By Levybreak
---------------------------------------------------------*/

include( 'shared.lua' )

function GM:Initialize()

	self.BaseClass:Initialize()
	surface.CreateFont("arvigo",30,700,true,false,"Avirgo30")
	
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

function BuyItemsMenu(activetab)

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

	local SheetDPanel = vgui.Create( "DPanelList" )
	SheetDPanel:SetAutoSize(true)
	SheetDPanel:SetSpacing( 5 ) 
	SheetDPanel:EnableHorizontal( true ) 
	SheetDPanel:EnableVerticalScrollbar( true ) 

		local SheetItemOne = vgui.Create("DCollapsibleCategory") 
		SheetItemOne:SetSize( 350, 75 )
		SheetItemOne:SetExpanded( 0 )
		SheetItemOne:SetLabel( "Gravity-Type" ) 
	SheetDPanel:AddItem( SheetItemOne ) 
  
			local CategoryList = vgui.Create( "DPanelList" ) 
			CategoryList:SetAutoSize(true)
			CategoryList:SetSpacing( 5 ) 
			CategoryList:EnableHorizontal( true ) 
			CategoryList:EnableVerticalScrollbar( true ) 
  
		SheetItemOne:SetContents( CategoryList )
  
			for k,v in pairs(RetrieveAllItemsInCategory("bomb")) do
				if v.Subcategory == "gravity" then
				local CategoryContentOne = vgui.Create( "DModelPanel" ) 
				CategoryContentOne:SetModel( v.Model ) 
				CategoryContentOne:SetFOV(40)
				CategoryContentOne:SetSize(75,75)
				CategoryContentOne:SetLookAt(Vector(0,0,0))
    			CategoryContentOne.DoClick = function()
					if LocalPlayer():GetNWInt("money") >= v.Cost then
						RunConsoleCommand("BuySomeShit", v.Name, GetPosForSpawning()) 
					else
						LocalPlayer():PrintMessage( HUD_PRINTTALK, "You don't have enough money for that "..v.Name.." you need $"..v.Cost-LocalPlayer():GetNWInt("money").." more!" )
					end
    			end 
				CategoryList:AddItem( CategoryContentOne ) 
				end
			end
			
	local ExplosiveType = vgui.Create("DCollapsibleCategory") 
		ExplosiveType:SetSize( 350, 75 )
		ExplosiveType:SetExpanded( 0 )
		ExplosiveType:SetLabel( "Explosive-Type" ) 
	SheetDPanel:AddItem( ExplosiveType ) 
	
		local CategoryList = vgui.Create( "DPanelList" ) 
			CategoryList:SetAutoSize(true)
			CategoryList:SetSpacing( 5 ) 
			CategoryList:EnableHorizontal( true ) 
			CategoryList:EnableVerticalScrollbar( true ) 
  
		ExplosiveType:SetContents( CategoryList )
		
			for k,v in pairs(RetrieveAllItemsInCategory("bomb")) do
				if v.Subcategory == "explosive" then
				local CategoryContentOne = vgui.Create( "DModelPanel" ) 
				CategoryContentOne:SetModel( v.Model ) 
				CategoryContentOne:SetFOV(40)
				CategoryContentOne:SetSize(75,75)
				CategoryContentOne:SetLookAt(Vector(0,0,0))
    			CategoryContentOne.DoClick = function()
					if LocalPlayer():GetNWInt("money") >= v.Cost then
						RunConsoleCommand("BuySomeShit", v.Name, GetPosForSpawning()) 
					else
						LocalPlayer():PrintMessage( HUD_PRINTTALK, "You don't have enough money for that "..v.Name.." you need $"..v.Cost-LocalPlayer():GetNWInt("money").." more!" )
					end
    			end 
				CategoryList:AddItem( CategoryContentOne ) 
				end
			end

local SheetItemTwo = vgui.Create( "DPanelList" )
	SheetItemTwo:SetAutoSize(true)
	SheetItemTwo:SetSpacing( 5 ) 
	SheetItemTwo:EnableHorizontal( true ) 
	SheetItemTwo:EnableVerticalScrollbar( true ) 

		local SheetItemOne = vgui.Create("DCollapsibleCategory") 
		SheetItemOne:SetSize( 350, 75 )
		SheetItemOne:SetExpanded( 0 )
		SheetItemOne:SetLabel( "Basic Bullets" ) 
	SheetItemTwo:AddItem( SheetItemOne ) 
  
			local CategoryList = vgui.Create( "DPanelList" ) 
			CategoryList:SetAutoSize(true)
			CategoryList:SetSpacing( 5 ) 
			CategoryList:EnableHorizontal( true ) 
			CategoryList:EnableVerticalScrollbar( true ) 
  
		SheetItemOne:SetContents( CategoryList )
  
			for k,v in pairs(RetrieveAllItemsInCategory("turret")) do
				if v.Subcategory == "basic" then
				local CategoryContentOne = vgui.Create( "DModelPanel" ) 
				CategoryContentOne:SetModel( v.Model ) 
				CategoryContentOne:SetFOV(40)
				CategoryContentOne:SetSize(75,75)
				CategoryContentOne:SetLookAt(Vector(0,0,0))
    			CategoryContentOne.DoClick = function()
        			if LocalPlayer():GetNWInt("money") >= v.Cost then
						RunConsoleCommand("BuySomeShit", v.Name, GetPosForSpawning()) 
					else
						LocalPlayer():PrintMessage( HUD_PRINTTALK, "You don't have enough money for that "..v.Name.." you need $"..v.Cost-LocalPlayer():GetNWInt("money").." more!" )
					end
    			end 
				CategoryList:AddItem( CategoryContentOne ) 
				end
			end

local SheetItemThree = vgui.Create( "DPanelList" )
	SheetItemThree:SetAutoSize(true)
	SheetItemThree:SetSpacing( 5 ) 
	SheetItemThree:EnableHorizontal( true ) 
	SheetItemThree:EnableVerticalScrollbar( true ) 

		local SheetItemOne = vgui.Create("DCollapsibleCategory") 
		SheetItemOne:SetSize( 350, 75 )
		SheetItemOne:SetExpanded( 0 )
		SheetItemOne:SetLabel( "SMGs" ) 
	SheetItemThree:AddItem( SheetItemOne ) 
  
			local CategoryList = vgui.Create( "DPanelList" ) 
			CategoryList:SetAutoSize(true)
			CategoryList:SetSpacing( 5 ) 
			CategoryList:EnableHorizontal( true ) 
			CategoryList:EnableVerticalScrollbar( true ) 
  
		SheetItemOne:SetContents( CategoryList )
  
			for k,v in pairs(RetrieveAllItemsInCategory("weapon")) do
				if v.Subcategory == "smg" then
				local CategoryContentOne = vgui.Create( "DModelPanel" ) 
				CategoryContentOne:SetModel( v.Model ) 
				CategoryContentOne:SetFOV(40)
				CategoryContentOne:SetSize(75,75)
				CategoryContentOne:SetLookAt(Vector(0,0,0))
    			CategoryContentOne.DoClick = function()
					if LocalPlayer():GetNWInt("money") >= v.Cost then
						RunConsoleCommand("BuySomeShit", v.Name, GetPosForSpawning()) 
					else
						LocalPlayer():PrintMessage( HUD_PRINTTALK, "You don't have enough money for that "..v.Name.." you need $"..v.Cost-LocalPlayer():GetNWInt("money").." more!" )
					end
    			end 
				CategoryList:AddItem( CategoryContentOne ) 
				end
			end
			
		local SheetItemOne = vgui.Create("DCollapsibleCategory") 
		SheetItemOne:SetSize( 350, 75 )
		SheetItemOne:SetExpanded( 0 )
		SheetItemOne:SetLabel( "Other" ) 
	SheetItemThree:AddItem( SheetItemOne ) 
  
			local CategoryList = vgui.Create( "DPanelList" ) 
			CategoryList:SetAutoSize(true)
			CategoryList:SetSpacing( 5 ) 
			CategoryList:EnableHorizontal( true ) 
			CategoryList:EnableVerticalScrollbar( true ) 
  
		SheetItemOne:SetContents( CategoryList )
  
			for k,v in pairs(RetrieveAllItemsInCategory("weapon")) do
				if v.Subcategory == "other" then
				local CategoryContentOne = vgui.Create( "DModelPanel" ) 
				CategoryContentOne:SetModel( v.Model ) 
				CategoryContentOne:SetFOV(40)
				CategoryContentOne:SetSize(75,75)
				CategoryContentOne:SetLookAt(Vector(0,0,0))
    			CategoryContentOne.DoClick = function()
					if LocalPlayer():GetNWInt("money") >= v.Cost then
						RunConsoleCommand("BuySomeShit", v.Name, GetPosForSpawning()) 
					else
						LocalPlayer():PrintMessage( HUD_PRINTTALK, "You don't have enough money for that "..v.Name.." you need $"..v.Cost-LocalPlayer():GetNWInt("money").." more!" )
					end
    			end 
				CategoryList:AddItem( CategoryContentOne ) 
				end
			end

	local SheetItemFour = vgui.Create( "DPanelList" )
	SheetItemFour:SetAutoSize(true)
	SheetItemFour:SetSpacing( 5 ) 
	SheetItemFour:EnableHorizontal( true ) 
	SheetItemFour:EnableVerticalScrollbar( true ) 

		local SheetItemOne = vgui.Create("DCollapsibleCategory") 
		SheetItemOne:SetSize( 350, 75 )
		SheetItemOne:SetExpanded( 0 )
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
				if v.Subcategory == "junk" then
				local CategoryContentOne = vgui.Create( "DModelPanel" ) 
				CategoryContentOne:SetModel( v.Model ) 
				CategoryContentOne:SetFOV(80)
				CategoryContentOne:SetSize(75,75)
				CategoryContentOne:SetLookAt(Vector(0,0,0))
    			CategoryContentOne.DoClick = function()
					if LocalPlayer():GetNWInt("money") >= v.Cost then
						RunConsoleCommand("BuySomeShit", v.Name.." "..GetPosForSpawning()) 
					else
						LocalPlayer():PrintMessage( HUD_PRINTTALK, "You don't have enough money for that "..v.Name.." you need $"..v.Cost-LocalPlayer():GetNWInt("money").." more!" )
					end
    			end 
				CategoryList:AddItem( CategoryContentOne ) 
				end
			end

local HelpDPanel = vgui.Create( "DLabel" )
HelpDPanel:SetPos(5,5)
HelpDPanel:SetText([[Real help will be coming soon! For now,
All you need to know is that you need to stay alive.
You can do that by blowing up the asteroids before they hit you.
There is also a build phase between waves of aseroids.
That is when you can buy props to build a small shelter if/when you
need a break during the apocalypse.

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
	BuyItemsMenu("Props")
end 

function OpenTheBuyWindowFromContextKey()
	if GetGlobalInt("buildmode") > 0 then
		BuyItemsMenu("Props")
	else
		BuyItemsMenu("Weapons")
	end
end 

hook.Add("OnSpawnMenuOpen","UponOpeningTehMenuz",OpenTheBuyWindowFromSpawnKey)
hook.Add("OnContextMenuOpen","UponOpeningTehContextMenuz",OpenTheBuyWindowFromContextKey)

function GetPosForSpawning()
	local trace = LocalPlayer():GetEyeTrace()
	if trace.HitPos:Distance(LocalPlayer():GetPos()) <= 2510 then
		return tostring(trace.HitPos)
	else
		return LocalPlayer():GetPos()
	end
end
