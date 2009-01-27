/*---------------------------------------------------------
Asteroid Assault
By Levybreak
---------------------------------------------------------*/

GM.Name 	= "Asteroid Assault"
GM.Author 	= "Levybreak"
GM.Email 	= "-snip-"
GM.Website 	= "N/A"

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
Test Items
---------------------------------------------------------*/
local ITEM = {}

ITEM.Name = "SmallStasisBomb"--nospaces in name! Concommand nessessitates such!
ITEM.NiceName = "Small Stasis Bomb"
ITEM.Desc = "Stops asteroids within range."
ITEM.Class = "base_bomb"
ITEM.Cost = 500
ITEM.Category = "bomb"
ITEM.Subcategory = "Stasis"
ITEM.Warning = "Range = 1000; Press Use to activate!"
ITEM.Model = "models/Roller.mdl"
ITEM.KeyValues = {Type="1",
				Strength="1000",
				Time="10"}
RegisterItem(ITEM.Name,ITEM)

ITEM.Name = "MedStasisBomb"--nospaces in name! Concommand nessessitates such!
ITEM.NiceName = "Medium Stasis Bomb"
ITEM.Desc = "Stops asteroids within range."
ITEM.Class = "base_bomb"
ITEM.Cost = 1500
ITEM.Category = "bomb"
ITEM.Subcategory = "Stasis"
ITEM.Warning = "Range = 1500; Will only be on for 15 seconds!"
ITEM.Model = "models/Roller.mdl"
ITEM.KeyValues = {Type="1",
				Strength="1500",
				Time="15"}
RegisterItem(ITEM.Name,ITEM)

ITEM.Name = "LarStasisBomb"--nospaces in name! Concommand nessessitates such!
ITEM.NiceName = "Huge Stasis Bomb"
ITEM.Desc = "Stops asteroids within range."
ITEM.Class = "base_bomb"
ITEM.Cost = 2500
ITEM.Category = "bomb"
ITEM.Subcategory = "Stasis"
ITEM.Warning = "Range = 2500; Will only be on for 20 seconds!"
ITEM.Model = "models/Roller.mdl"
ITEM.KeyValues = {Type="1",
				Strength="2500",
				Time="20"}
RegisterItem(ITEM.Name,ITEM)

--
--Weapons
--

local ITEM = {}

ITEM.Name = "SMG"
ITEM.Desc = "Sub Machine Gun"
ITEM.Class = "weapon_smg1"
ITEM.Cost = 50
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
ITEM.Cost = 250
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
ITEM.Cost = 100
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
ITEM.Cost = 140
ITEM.Category = "weapon"
ITEM.Subcategory = "SMGs"
ITEM.Ammo = 80
ITEM.AmmoType = "AR2"
ITEM.Model = "models/Weapons/w_IRifle.mdl"
RegisterItem(ITEM.Name,ITEM)

--
--Props
--

AddPropToList("models/props_c17/concrete_barrier001a.mdl",50,"Concrete Barrier")
AddPropToList("models/props_c17/fence01a.mdl",70,"Chainlink Fence")
AddPropToList("models/props_c17/FurnitureDresser001a.mdl",40,"Dresser")
AddPropToList("models/props_c17/oildrum001.mdl",20,"Oil Drum")
AddPropToList("models/props_c17/shelfunit01a.mdl",80,"Book Shelf")
AddPropToList("models/props_combine/breendesk.mdl",130,"Ornate Desk")
AddPropToList("models/props_combine/combine_window001.mdl",120,"Large Metal Window",100)
AddPropToList("models/props_combine/combine_barricade_short02a.mdl",30,"Small Barricade")
AddPropToList("models/props_debris/metal_panel02a.mdl",10,"Sheet Metal")
AddPropToList("models/props_doors/door03_slotted_left.mdl",50,"Metal Door")
AddPropToList("models/props_interiors/VendingMachineSoda01a.mdl",110,"Soda Machine")
AddPropToList("models/props_junk/iBeam01a_cluster01.mdl",90,"Metal Beams")
AddPropToList("models/props_junk/TrashDumpster02.mdl",200,"Dumpster",100)
AddPropToList("models/props_junk/TrashDumpster02b.mdl",40,"Dumpster Lid")
AddPropToList("models/props_lab/blastdoor001b.mdl",50,"Small Blast Door")
AddPropToList("models/props_lab/blastdoor001c.mdl",100,"Large Blast Door")
AddPropToList("models/props_wasteland/cargo_container01.mdl",400,"Cargo Container",110)
AddPropToList("models/props_wasteland/controlroom_desk001b.mdl",70,"Metal Desk")
AddPropToList("models/props_wasteland/interior_fence002d.mdl",150,"Large Chainlink Fence")
AddPropToList("models/props_wasteland/kitchen_fridge001a.mdl",80,"Industrial Sized Fridge")
AddPropToList("models/props_wasteland/medbridge_post01.mdl",50,"Concrete Post")
AddPropToList("models/props_wasteland/wood_fence01a.mdl",30,"Wooden Fence")
AddPropToList("models/props_c17/Lockers001a.mdl",60,"Lockers")
AddPropToList("models/props_c17/gravestone_coffinpiece002a.mdl",80,"Coffin Cover")
AddPropToList("models/props_lab/servers.mdl",80,"Server Block")
