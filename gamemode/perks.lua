
--[[-------------------------------------------------------
  Perk system
---------------------------------------------------------]]
Perks = {}

function RegisterPerk(cmd,tbl)
         Perks[cmd] = tbl
		-- print("Perks Registered!")
end

--Checks to see if Perk even exists
function PerkExists(perk)
	if Perks[perk] != nil then
		return true
	else
		return false
	end
end 

function GivePerk(ply,perk)
	if PerkExists(perk) and not HasPerk(ply,perk) then
		Perks[perk].Shared(ply)
		if not ply.Perks then ply.Perks = {} end
		table.insert(ply.Perks,perk)
		if (SERVER) then 
			Perks[perk].Server(ply)
			GivePerkClient(ply,perk)
		elseif (CLIENT) then
			Perks[perk].Client(ply)
		end
	end
end

function HasPerk(ply,perk)
	if not ply.Perks then return false end
	local retval = table.HasValue(ply.Perks,perk)
	return retval
end

function GetAllTypesOfPerks()
	local retval = {}
	for k,v in pairs(Perks) do
		if not table.HasValue(retval,v.Type) then
			table.insert(retval,v.Type)
		end
	end
	return retval
end

function GetAllPerksOfType(typez)
	local retval = {}
	for k,v in pairs(Perks) do
		if v.Type == typez then
			table.insert(retval,v)
		end
	end
	return retval
end

function HasAllPerks(ply)
	return (#ply.Perks == table.Count(Perks))
end

--[[--------------------------------------------------------
	Shopping Perks
---------------------------------------------------------]]

local PERK = {}

PERK.Name = "Slight Discount"
PERK.Desc = "5% Discount in shop. -Culmative"
PERK.Level = 0 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "shopping"
PERK.Shared = function(ply) --Run on server and client
	ply:SetDiscount(ply:GetDiscount()+5) -- A percent value
end 
PERK.Server = function(ply) --Run on Server
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)

local PERK = {}

PERK.Name = "Larger Discount"
PERK.Desc = "15% Discount in shop. -Culmative"
PERK.Level = 3 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "shopping"
PERK.Shared = function(ply) --Run on server and client
	ply:SetDiscount(ply:GetDiscount()+15) -- A percent value
end 
PERK.Server = function(ply) --Run on Server
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)

local PERK = {}

PERK.Name = "Huge Discount"
PERK.Desc = "25% Discount in shop. -Culmative"
PERK.Level = 8 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "shopping"
PERK.Shared = function(ply) --Run on server and client
	ply:SetDiscount(ply:GetDiscount()+25) -- A percent value
end 
PERK.Server = function(ply) --Run on Server
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)

--[[--------------------------------------------------------
	Physical Ability Perks
---------------------------------------------------------]]

--Speed Upgrades
local PERK = {}

PERK.Name = "Slight Speed Increase"
PERK.Desc = "+30 walking speed, +60 sprint speed - Not Culmative"
PERK.Level = 0 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "physical"
PERK.Shared = function(ply) --Run on server and client
end 
PERK.Server = function(ply) --Run on Server
	if not HasPerk(ply,"Larger Speed Increase") and not HasPerk(ply,"Epic Speed Increase") then
		GAMEMODE:SetPlayerSpeed( ply, 250, 500 )
	end
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)

local PERK = {}

PERK.Name = "Larger Speed Increase"
PERK.Desc = "+50 walking speed, +100 sprint speed - Not Culmative"
PERK.Level = 2 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "physical"
PERK.Shared = function(ply) --Run on server and client
end 
PERK.Server = function(ply) --Run on Server
	if not HasPerk(ply,"Epic Speed Increase") then
		GAMEMODE:SetPlayerSpeed( ply, 270, 540 )
	end
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)

local PERK = {}

PERK.Name = "Epic Speed Increase"
PERK.Desc = "+80 walking speed, +160 sprint speed - Not Culmative"
PERK.Level = 3 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "physical"
PERK.Shared = function(ply) --Run on server and client
end 
PERK.Server = function(ply) --Run on Server
	GAMEMODE:SetPlayerSpeed( ply, 300, 600 )
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)

--HP Upgrades
local PERK = {}

PERK.Name = "Slight MaxHP Increase"
PERK.Desc = "+15 MaxHP! -Stacking"
PERK.Level = 0 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "physical"
PERK.Shared = function(ply) --Run on server and client
	if not ply.MaxHP then ply.MaxHP = 100 end
	ply.MaxHP = ply.MaxHP+15
end 
PERK.Server = function(ply) --Run on Server
	
end 
PERK.Client = function(ply) --Run on Client

end 
RegisterPerk(PERK.Name,PERK)

local PERK = {}

PERK.Name = "Larger MaxHP Increase"
PERK.Desc = "+35 MaxHP! -Stacking"
PERK.Level = 1 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "physical"
PERK.Shared = function(ply) --Run on server and client
	if not ply.MaxHP then ply.MaxHP = 100 end
	ply.MaxHP = ply.MaxHP+35
end 
PERK.Server = function(ply) --Run on Server
	
end 
PERK.Client = function(ply) --Run on Client

end 
RegisterPerk(PERK.Name,PERK)

local PERK = {}

PERK.Name = "Epic MaxHP Increase"
PERK.Desc = "+50 MaxHP! -Stacking"
PERK.Level = 2 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "physical"
PERK.Shared = function(ply) --Run on server and client
	if not ply.MaxHP then ply.MaxHP = 100 end
	ply.MaxHP = ply.MaxHP+50
end 
PERK.Server = function(ply) --Run on Server
	
end 
PERK.Client = function(ply) --Run on Client

end 
RegisterPerk(PERK.Name,PERK)

--[[--------------------------------------------------------
	Weapon Perks
---------------------------------------------------------]]

--SMG
local PERK = {}

PERK.Name = "More Default SMG Ammo"
PERK.Desc = "2 more clips primary, 1 more secondary."
PERK.Level = 1 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "Weapons"
PERK.Shared = function(ply) --Run on server and client
end 
PERK.Server = function(ply) --Run on Server
	if not ply.PrimaryAmmoAdd then ply.PrimaryAmmoAdd = 0 end
	ply.PrimaryAmmoAdd = ply.PrimaryAmmoAdd + 2
	if not ply.SecondaryAmmoAdd then ply.SecondaryAmmoAdd = 0 end
	ply.SecondaryAmmoAdd = ply.SecondaryAmmoAdd + 1
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)