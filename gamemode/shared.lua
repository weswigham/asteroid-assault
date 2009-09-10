/*---------------------------------------------------------
Asteroid Assault
By Levybreak
---------------------------------------------------------*/

GM.Name 	= "Asteroid Assault"
GM.Author 	= "Levybreak"
GM.Email 	= "-snip-"
GM.Website 	= "N/A"
GM.BuildTime = 5
GM.ATime = 10

function PointOn3DBezierCurve(dis,pt1,pt2,pt3) --my poor attempt at a bezier curve algorthm. I think dis is distance along the curve, pt1 is start, pt2 is control, and pt3 is end.
	local out1 = ((1-dis)^2)*pt1.x+2*(1-dis)*dis*pt2.x+(dis^2)*pt3.x
	local out2 = ((1-dis)^2)*pt1.y+2*(1-dis)*dis*pt2.y+(dis^2)*pt3.y
	local out3 = ((1-dis)^2)*pt1.z+2*(1-dis)*dis*pt2.z+(dis^2)*pt3.z
	return Vector(out1,out2,out3)
end

/*---------------------------------------------------------
  Item system
---------------------------------------------------------*/
Items = {}

function RegisterItem(cmd,tbl)
         Items[cmd] = tbl
		-- print("ITEMs Registered!")
end

--Checks to see if Item even exists
function ItemExists(item)
	if Items[item] != nil then
		return true
	else
		return false
	end
end

function RetrieveAllSubCategorys(cata)
	local tbl = {}
	for k,v in pairs(RetrieveAllItemsInCategory(cata)) do
		if not table.HasValue(tbl,v.Subcategory) then
			table.insert(tbl,v.Subcategory)
		end
	end
	return tbl
end

function RetrieveAllItemsInSubCategory(cata,sub)
	local tbl = {}
	for k,v in pairs(RetrieveAllItemsInCategory(cata)) do
		if v.Subcategory == sub then
			table.insert(tbl,v)
		end
	end
	return tbl
end

function RetrieveAllItemsInCategory(cata)
	local tbl = {}
	for k,v in pairs(Items) do
		if v.Category == cata then
		table.insert(tbl,v)
		end
	end
	return tbl
end

function AddPropToList(model,cost,name,fov) --fov is optional
	local ITEM = {}

	ITEM.Name = string.gsub(name," ","-")
	ITEM.NiceName = name
	ITEM.Desc = "Prop"
	ITEM.Class = "prop_physics"
	ITEM.Cost = cost
	ITEM.Category = "prop"
	ITEM.Subcategory = "junk"
	ITEM.Model = model
	ITEM.FOV = fov
	RegisterItem(ITEM.Name,ITEM)
end 

/*---------------------------------------------------------
"Bombs"
---------------------------------------------------------*/
local ITEM = {}

ITEM.Name = "SmallStasisBomb"--nospaces in name! Concommand nessessitates such!
ITEM.NiceName = "Small Stasis Bomb"
ITEM.Desc = "Stops asteroids within range."
ITEM.Class = "base_bomb"
ITEM.Cost = 1200
ITEM.Category = "bomb"
ITEM.Subcategory = "Stasis"
ITEM.Warning = "Range = 750; Press Use to activate!"
ITEM.Model = "models/Roller.mdl"
ITEM.KeyValues = {Type="1",
				Strength="750",
				Time="9"}
RegisterItem(ITEM.Name,ITEM)

local ITEM = {}

ITEM.Name = "MedStasisBomb"--nospaces in name! Concommand nessessitates such!
ITEM.NiceName = "Medium Stasis Bomb"
ITEM.Desc = "Stops asteroids within range."
ITEM.Class = "base_bomb"
ITEM.Cost = 2600
ITEM.Category = "bomb"
ITEM.Subcategory = "Stasis"
ITEM.Warning = "Range = 1250; Will only be on for 12 seconds!"
ITEM.Model = "models/Roller.mdl"
ITEM.KeyValues = {Type="1",
				Strength="1250",
				Time="12"}
RegisterItem(ITEM.Name,ITEM)

local ITEM = {}

ITEM.Name = "LarStasisBomb"--nospaces in name! Concommand nessessitates such!
ITEM.NiceName = "Huge Stasis Bomb"
ITEM.Desc = "Stops asteroids within range."
ITEM.Class = "base_bomb"
ITEM.Cost = 5250
ITEM.Category = "bomb"
ITEM.Subcategory = "Stasis"
ITEM.Warning = "Range = 2000; Will only be on for 15 seconds!"
ITEM.Model = "models/Roller.mdl"
ITEM.KeyValues = {Type="1",
				Strength="2000",
				Time="15"}
RegisterItem(ITEM.Name,ITEM)

local ITEM = {}

ITEM.Name = "SmallRepelBomb"--nospaces in name! Concommand nessessitates such!
ITEM.NiceName = "Small Repulsion Bomb"
ITEM.Desc = "Repels asteroids within range."
ITEM.Class = "base_bomb"
ITEM.Cost = 600
ITEM.Category = "bomb"
ITEM.Subcategory = "Repulsion"
ITEM.Warning = "Range = 500; Will only be on for 5 seconds!"
ITEM.Model = "models/Roller.mdl"
ITEM.KeyValues = {Type="2",
				Strength="500",
				Time="5"}
RegisterItem(ITEM.Name,ITEM)

local ITEM = {}

ITEM.Name = "MedRepelBomb"--nospaces in name! Concommand nessessitates such!
ITEM.NiceName = "Medium Repulsion Bomb"
ITEM.Desc = "Repels asteroids within range."
ITEM.Class = "base_bomb"
ITEM.Cost = 1200
ITEM.Category = "bomb"
ITEM.Subcategory = "Repulsion"
ITEM.Warning = "Range = 750; Will only be on for 8 seconds!"
ITEM.Model = "models/Roller.mdl"
ITEM.KeyValues = {Type="2",
				Strength="750",
				Time="8"}
RegisterItem(ITEM.Name,ITEM)

local ITEM = {}

ITEM.Name = "LargeRepelBomb"--nospaces in name! Concommand nessessitates such!
ITEM.NiceName = "Large Repulsion Bomb"
ITEM.Desc = "Repels asteroids within range."
ITEM.Class = "base_bomb"
ITEM.Cost = 2000
ITEM.Category = "bomb"
ITEM.Subcategory = "Repulsion"
ITEM.Warning = "Range = 1250; Will only be on for 10 seconds!"
ITEM.Model = "models/Roller.mdl"
ITEM.KeyValues = {Type="2",
				Strength="1250",
				Time="10"}
RegisterItem(ITEM.Name,ITEM)

local ITEM = {}

ITEM.Name = "SmallAttractionBomb"--nospaces in name! Concommand nessessitates such!
ITEM.NiceName = "Small Attraction Bomb"
ITEM.Desc = "Attracts asteroids within range."
ITEM.Class = "base_bomb"
ITEM.Cost = 1000
ITEM.Category = "bomb"
ITEM.Subcategory = "Attraction"
ITEM.Warning = "Range = 500; Will only be on for 5 seconds!"
ITEM.Model = "models/Roller.mdl"
ITEM.KeyValues = {Type="3",
				Strength="500",
				Time="5",
				Health="10"}--So this dies really, really fast.
RegisterItem(ITEM.Name,ITEM)

local ITEM = {}

ITEM.Name = "MedAttractionBomb"--nospaces in name! Concommand nessessitates such!
ITEM.NiceName = "Medium Attraction Bomb"
ITEM.Desc = "Attracts asteroids within range."
ITEM.Class = "base_bomb"
ITEM.Cost = 1500
ITEM.Category = "bomb"
ITEM.Subcategory = "Attraction"
ITEM.Warning = "Range = 1000; Will only be on for 5 seconds!"
ITEM.Model = "models/Roller.mdl"
ITEM.KeyValues = {Type="3",
				Strength="1000",
				Time="5",
				Health="10"}--So this dies really, really fast.
RegisterItem(ITEM.Name,ITEM)

local ITEM = {}

ITEM.Name = "LargeAttractionBomb"--nospaces in name! Concommand nessessitates such!
ITEM.NiceName = "Huge Attraction Bomb"
ITEM.Desc = "Attracts asteroids within range."
ITEM.Class = "base_bomb"
ITEM.Cost = 2500
ITEM.Category = "bomb"
ITEM.Subcategory = "Attraction"
ITEM.Warning = "Range = 1500; Will only be on for 8 seconds!"
ITEM.Model = "models/Roller.mdl"
ITEM.KeyValues = {Type="3",
				Strength="1500",
				Time="8",
				Health="10"}--So this dies really, really fast.
RegisterItem(ITEM.Name,ITEM)

--
--Weapons
--

local ITEM = {}

ITEM.Name = "SMG"
ITEM.Desc = "Sub Machine Gun"
ITEM.Class = "weapon_smg1"
ITEM.Cost = 150
ITEM.Category = "weapon"
ITEM.Subcategory = "SMGs"
ITEM.Ammo = 100
ITEM.AmmoType = "SMG1"
ITEM.Model = "models/Weapons/w_smg1.mdl"
RegisterItem(ITEM.Name,ITEM)

local ITEM = {}

ITEM.Name = "RPG"
ITEM.Desc = "Rocket Propelled Grenade"
ITEM.Class = "weapon_rpg"
ITEM.Cost = 350
ITEM.Category = "weapon"
ITEM.Subcategory = "Other"
ITEM.Ammo = 3
ITEM.AmmoType = "RPG_Round"
ITEM.Model = "models/Weapons/w_rocket_launcher.mdl"
RegisterItem(ITEM.Name,ITEM)

local ITEM = {}

ITEM.Name = "Shotgun"
ITEM.Desc = "Uses Buckshot"
ITEM.Class = "weapon_shotgun"
ITEM.Cost = 200
ITEM.Category = "weapon"
ITEM.Subcategory = "Other"
ITEM.Ammo = 64
ITEM.AmmoType = "Buckshot"
ITEM.Model = "models/Weapons/w_shotgun.mdl"
RegisterItem(ITEM.Name,ITEM)

local ITEM = {}

ITEM.Name = "AR2"
ITEM.Desc = "Assault Rifle 2 (Pulse Rifle)"
ITEM.Class = "weapon_ar2"
ITEM.Cost = 240
ITEM.Category = "weapon"
ITEM.Subcategory = "SMGs"
ITEM.Ammo = 80
ITEM.AmmoType = "AR2"
ITEM.Model = "models/Weapons/w_IRifle.mdl"
RegisterItem(ITEM.Name,ITEM)

local ITEM = {}

ITEM.Name = "357Magnum"
ITEM.NiceName = ".357 Magnum"
ITEM.Desc = ".357 Magnum Handgun"
ITEM.Class = "weapon_357"
ITEM.Cost = 500
ITEM.Category = "weapon"
ITEM.Subcategory = "Handguns"
ITEM.Ammo = 9
ITEM.AmmoType = "357"
ITEM.Model = "models/Weapons/w_357.mdl"
ITEM.FOV = 20
RegisterItem(ITEM.Name,ITEM)

local ITEM = {}

ITEM.Name = "Pistol" --Free
ITEM.NiceName = "9mm Pistol"
ITEM.Desc = "This pistol is free!! :D"
ITEM.Class = "weapon_pistol"
ITEM.Cost = 0
ITEM.Category = "weapon"
ITEM.Subcategory = "Handguns"
ITEM.Ammo = 18*4
ITEM.AmmoType = "Pistol"
ITEM.Model = "models/Weapons/w_pistol.mdl"
ITEM.FOV = 20
RegisterItem(ITEM.Name,ITEM)

--Engineer

local ITEM = {}

ITEM.Name = "Wrench"
ITEM.NiceName = "Wrench"
ITEM.Desc = "Heals Props"
ITEM.Class = "weapon_wrench"
ITEM.Cost = 5000
ITEM.Category = "weapon"
ITEM.Subcategory = "Engineering"
ITEM.Ammo = 0
ITEM.AmmoType = "none"
ITEM.Model = "models/Weapons/w_wrenchs.mdl"
ITEM.FOV = 20
ITEM.BuyCondition = {"NoMedkit","NoRailgun","NoWrench"}
ITEM.Warning = [[You may only take weapons from 1 of the "Class" categories.]]
RegisterItem(ITEM.Name,ITEM)

--Medic

local ITEM = {}

ITEM.Name = "Medkit"
ITEM.NiceName = "Medkit"
ITEM.Desc = "Heals People"
ITEM.Class = "weapon_medkits"
ITEM.Cost = 5000
ITEM.Category = "weapon"
ITEM.Subcategory = "Medic"
ITEM.Ammo = 0
ITEM.AmmoType = "none"
ITEM.Model = "models/Items/HealthKit.mdl"
ITEM.FOV = 20
ITEM.BuyCondition = {"NoWrench","NoRailgun","NoMedkit"}
ITEM.Warning = [[You may only take weapons from 1 of the "Class" categories.]]
RegisterItem(ITEM.Name,ITEM)

--Soldier

local ITEM = {}

ITEM.Name = "Railgun"
ITEM.Desc = "It's powerful."
ITEM.Class = "weapon_railgun"
ITEM.Cost = 5000
ITEM.Category = "weapon"
ITEM.Subcategory = "Soldier"
ITEM.Ammo = 0
ITEM.AmmoType = "none"
ITEM.Model = "models/Weapons/w_rocket_launcher.mdl"
ITEM.FOV = 20
ITEM.BuyCondition = {"NoWrench","NoMedkit","NoRailgun"}
ITEM.Warning = [[You may only take weapons from 1 of the "Class" categories.]]
RegisterItem(ITEM.Name,ITEM)



--
--Props
--

AddPropToList("models/props_c17/concrete_barrier001a.mdl",80,"Concrete Barrier")
AddPropToList("models/props_c17/fence01a.mdl",100,"Chainlink Fence")
AddPropToList("models/props_c17/FurnitureDresser001a.mdl",70,"Dresser")
AddPropToList("models/props_c17/oildrum001.mdl",50,"Oil Drum")
AddPropToList("models/props_c17/shelfunit01a.mdl",100,"Book Shelf")
AddPropToList("models/props_combine/breendesk.mdl",160,"Ornate Desk")
AddPropToList("models/props_combine/combine_window001.mdl",150,"Large Metal Window",120)
AddPropToList("models/props_combine/combine_barricade_short02a.mdl",60,"Small Barricade")
AddPropToList("models/props_debris/metal_panel02a.mdl",40,"Sheet Metal")
AddPropToList("models/props_doors/door03_slotted_left.mdl",90,"Metal Door")
AddPropToList("models/props_interiors/VendingMachineSoda01a.mdl",140,"Soda Machine")
AddPropToList("models/props_junk/iBeam01a_cluster01.mdl",120,"Metal Beams")
AddPropToList("models/props_junk/TrashDumpster02.mdl",230,"Dumpster",170)
AddPropToList("models/props_junk/TrashDumpster02b.mdl",70,"Dumpster Lid")
AddPropToList("models/props_lab/blastdoor001b.mdl",80,"Small Blast Door")
AddPropToList("models/props_lab/blastdoor001c.mdl",130,"Large Blast Door")
AddPropToList("models/props_wasteland/cargo_container01.mdl",5000,"Cargo Container",250) --Mmmm... I need to jack the price up on these, they're simply too powerful.
AddPropToList("models/props_wasteland/controlroom_desk001b.mdl",100,"Metal Desk")
AddPropToList("models/props_wasteland/interior_fence002d.mdl",180,"Large Chainlink Fence")
AddPropToList("models/props_wasteland/kitchen_fridge001a.mdl",110,"Industrial Sized Fridge")
AddPropToList("models/props_wasteland/medbridge_post01.mdl",80,"Concrete Post")
AddPropToList("models/props_wasteland/wood_fence01a.mdl",60,"Wooden Fence")
AddPropToList("models/props_c17/Lockers001a.mdl",90,"Lockers")
AddPropToList("models/props_c17/gravestone_coffinpiece002a.mdl",110,"Coffin Cover")
AddPropToList("models/props_lab/servers.mdl",110,"Server Block") --For the lulz


--[[-----------------------------------------------------
Turrets - STILL WIP
--------------------------------------------------------]]
--[[
local ITEM = {}

ITEM.Name = "LargeMGTurret"--nospaces in name! Concommand nessessitates such!
ITEM.NiceName = "Large Machine Gun Turret"
ITEM.Desc = "Shoot things damnit!"
ITEM.Class = "base_turret"
ITEM.Cost = 5000
ITEM.Category = "turret"
ITEM.Subcategory = "Machine Gun"
ITEM.Warning = "Has 5000 health."
ITEM.Model = "models/turret/large_pod.mdl"
ITEM.KeyValues = {Type="1",
				Size="2",
				Health="15000"}
RegisterItem(ITEM.Name,ITEM)
]]