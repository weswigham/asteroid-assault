
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
		if not ply.Perks then ply.Perks = {} end
		table.insert(ply.Perks,perk)
		Perks[perk].Shared(ply)
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
	if not ply.Perks then return false end
	return (#ply.Perks == table.Count(Perks))
end

--[[--------------------------------------------------------
	Shopping Perks
---------------------------------------------------------]]

local PERK = {}

PERK.Name = "Slight Discount"
PERK.Desc = "1% Discount in shop. -Culmative"
PERK.Level = 0 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "shopping"
PERK.Shared = function(ply) --Run on server and client
	ply:SetDiscount(ply:GetDiscount()+1) -- A percent value
end 
PERK.Server = function(ply) --Run on Server
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)

local PERK = {}

PERK.Name = "Larger Discount"
PERK.Desc = "5% Discount in shop. -Culmative"
PERK.Level = 3 --So that players who have done extra-good get to choose from the better perks.
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

PERK.Name = "Huge Discount"
PERK.Desc = "10% Discount in shop. -Culmative"
PERK.Level = 8 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "shopping"
PERK.Shared = function(ply) --Run on server and client
	ply:SetDiscount(ply:GetDiscount()+10) -- A percent value
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
	if not HasPerk(ply,"Larger Speed Increase") and not HasPerk(ply,"Epic Speed Increase") and not HasPerk(ply,"Legendary Speed Increase") and not HasPerk(ply,"Godlike Speed Increase") then
		GAMEMODE:SetPlayerSpeed( ply, 250, 500 )
	end
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)

local PERK = {}

PERK.Name = "Larger Speed Increase"
PERK.Desc = "+50 walking speed, +100 sprint speed - Not Culmative"
PERK.Level = 3 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "physical"
PERK.Shared = function(ply) --Run on server and client
end 
PERK.Server = function(ply) --Run on Server
	if not HasPerk(ply,"Epic Speed Increase") and not HasPerk(ply,"Legendary Speed Increase") and not HasPerk(ply,"Godlike Speed Increase") then
		GAMEMODE:SetPlayerSpeed( ply, 270, 540 )
	end
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)

local PERK = {}

PERK.Name = "Epic Speed Increase"
PERK.Desc = "+80 walking speed, +160 sprint speed - Not Culmative"
PERK.Level = 5 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "physical"
PERK.Shared = function(ply) --Run on server and client
end 
PERK.Server = function(ply) --Run on Server
	if not HasPerk(ply,"Legendary Speed Increase") and not HasPerk(ply,"Godlike Speed Increase") then
		GAMEMODE:SetPlayerSpeed( ply, 300, 600 )
	end
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)

local PERK = {}

PERK.Name = "Legendary Speed Increase"
PERK.Desc = "+100 walking speed, +200 sprint speed - Not Culmative"
PERK.Level = 7 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "physical"
PERK.Shared = function(ply) --Run on server and client
end 
PERK.Server = function(ply) --Run on Server
	if not HasPerk(ply,"Godlike Speed Increase") then
		GAMEMODE:SetPlayerSpeed( ply, 320, 640 )
	end
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)

local PERK = {}

PERK.Name = "Godlike Speed Increase"
PERK.Desc = "+120 walking speed, +240 sprint speed - Not Culmative"
PERK.Level = 9 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "physical"
PERK.Shared = function(ply) --Run on server and client
end 
PERK.Server = function(ply) --Run on Server
	GAMEMODE:SetPlayerSpeed( ply, 340, 680 )
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

local PERK = {}

PERK.Name = "Legendary MaxHP Increase"
PERK.Desc = "+75 MaxHP! -Stacking"
PERK.Level = 6 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "physical"
PERK.Shared = function(ply) --Run on server and client
	if not ply.MaxHP then ply.MaxHP = 100 end
	ply.MaxHP = ply.MaxHP+75
end 
PERK.Server = function(ply) --Run on Server
	
end 
PERK.Client = function(ply) --Run on Client

end 
RegisterPerk(PERK.Name,PERK)

local PERK = {}

PERK.Name = "Godlike MaxHP Increase"
PERK.Desc = "+100 MaxHP! -Stacking"
PERK.Level = 10 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "physical"
PERK.Shared = function(ply) --Run on server and client
	if not ply.MaxHP then ply.MaxHP = 100 end
	ply.MaxHP = ply.MaxHP+100
end 
PERK.Server = function(ply) --Run on Server
	
end 
PERK.Client = function(ply) --Run on Client

end 
RegisterPerk(PERK.Name,PERK)

local PERK = {}

PERK.Name = "+1 HP Regeneration"
PERK.Desc = "+1 HP Regeneration -Stacking"
PERK.Level = 12 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "physical"
PERK.Shared = function(ply) --Run on server and client
	if not ply.HPRegen then ply.HPRegen = 0 end
	ply.HPRegen = ply.HPRegen+1
	ply.HPRegenTime = true
end 
PERK.Server = function(ply) --Run on Server
	hook.Add("Think",util.CRC(ply:SteamID()).."HPRegen",function() 
		if ply:Alive() and ply.HPRegenTime == true then
			ply.HPRegenTime = false
			ply:SetHealth(math.Clamp(ply:Health()+(ply.HPRegen or 0),0,ply:GetMaxHealth()))
			timer.Simple(2,function() ply.HPRegenTime = true end)
		end
	end)
end 
PERK.Client = function(ply) --Run on Client

end 
RegisterPerk(PERK.Name,PERK)

local PERK = {}

PERK.Name = "+2 HP Regeneration"
PERK.Desc = "+2 HP Regeneration -Stacking"
PERK.Level = 14 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "physical"
PERK.Shared = function(ply) --Run on server and client
	if not ply.HPRegen then ply.HPRegen = 0 end
	ply.HPRegen = ply.HPRegen+2
	ply.HPRegenTime = true
end 
PERK.Server = function(ply) --Run on Server
	hook.Add("Think",util.CRC(ply:SteamID()).."HPRegen",function() 
		if ply:Alive() and ply.HPRegenTime == true then
			ply.HPRegenTime = false
			ply:SetHealth(math.Clamp(ply:Health()+(ply.HPRegen or 0),0,ply:GetMaxHealth()))
			timer.Simple(2,function() ply.HPRegenTime = true end)
		end
	end)
end 
PERK.Client = function(ply) --Run on Client

end 
RegisterPerk(PERK.Name,PERK)

local PERK = {}

PERK.Name = "+3 HP Regeneration"
PERK.Desc = "+3 HP Regeneration -Stacking"
PERK.Level = 16 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "physical"
PERK.Shared = function(ply) --Run on server and client
	if not ply.HPRegen then ply.HPRegen = 0 end
	ply.HPRegen = ply.HPRegen+3
	ply.HPRegenTime = true
end 
PERK.Server = function(ply) --Run on Server
	hook.Add("Think",util.CRC(ply:SteamID()).."HPRegen",function() 
		if ply:Alive() and ply.HPRegenTime == true then
			ply.HPRegenTime = false
			ply:SetHealth(math.Clamp(ply:Health()+(ply.HPRegen or 0),0,ply:GetMaxHealth()))
			timer.Simple(2,function() ply.HPRegenTime = true end)
		end
	end)
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
PERK.Level = 2 --So that players who have done extra-good get to choose from the better perks.
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

local PERK = {}

PERK.Name = "More Stasis Bomb Time"
PERK.Desc = "+5 Seconds."
PERK.Level = 11 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "Weapons"
PERK.Shared = function(ply) --Run on server and client
end 
PERK.Server = function(ply) --Run on Server
	if not ply.StasisAdd then ply.StasisAdd = 0 end
	ply.StasisAdd = ply.StasisAdd + 5
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)

--AR2
local PERK = {}

PERK.Name = "Spawn With AR2"
PERK.Desc = "You spawn with the AR2"
PERK.Level = 15 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "Weapons"
PERK.Shared = function(ply) --Run on server and client
end 
PERK.Server = function(ply) --Run on Server
	ply.AR2Loadout = true
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)


--Shotgun
local PERK = {}

PERK.Name = "Spawn With Shotgun"
PERK.Desc = "You spawn with the Shotgun"
PERK.Level = 15 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "Weapons"
PERK.Shared = function(ply) --Run on server and client
end 
PERK.Server = function(ply) --Run on Server
	ply.ShotgunLoadout = true
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)

--RPG
local PERK = {}

PERK.Name = "Spawn With RPG"
PERK.Desc = "You spawn with the RPG"
PERK.Level = 15 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "Weapons"
PERK.Shared = function(ply) --Run on server and client
end 
PERK.Server = function(ply) --Run on Server
	ply.RPGLoadout = true
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)

--Aim Aid

local PERK = {}

PERK.Name = "Laser Sight" --I think I can do this purely on the client...
PERK.Desc = "A laser sight is attached to each weapon"
PERK.Level = 7 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "Weapons"
PERK.Shared = function(ply) --Run on server and client
	ply.LaserSights = true
end 
PERK.Server = function(ply) --Run on Server
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)


--[[--------------------------------------------------------
	Money/EXP Perks
---------------------------------------------------------]]

--EXP
local PERK = {}

PERK.Name = "More EXP"
PERK.Desc = "1.5x EXP Rate :O"
PERK.Level = 12 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "Money/EXP"
PERK.Shared = function(ply) --Run on server and client
end 
PERK.Server = function(ply) --Run on Server
	if not ply.EXPMul then ply.EXPMul = 1 end
	ply.EXPMul = ply.EXPMul + 0.5
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)

--[[ --This perk is no more! With the introduction of the railgun, you'd get a perk every secondary fire. :V
local PERK = {}

PERK.Name = "EXP From Asteroids"
PERK.Desc = "Get EXP when you kill asteroids!"
PERK.Level = 6 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "Money/EXP"
PERK.Shared = function(ply) --Run on server and client
end 
PERK.Server = function(ply) --Run on Server
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)]]


--Money
local PERK = {}

PERK.Name = "More Money"
PERK.Desc = "1.25x Money Rate :O"
PERK.Level = 14 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "Money/EXP"
PERK.Shared = function(ply) --Run on server and client
end 
PERK.Server = function(ply) --Run on Server
	if not ply.MunyMul then ply.MunyMul = 1 end
	ply.MunyMul = ply.MunyMul + 1.25
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)

local PERK = {}

PERK.Name = "Cashback"
PERK.Desc = "Get more money back when you remove a prop."
PERK.Level = 4 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "Money/EXP"
PERK.Shared = function(ply) --Run on server and client
end 
PERK.Server = function(ply) --Run on Server
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)

--[[--------------------------------------------------------
	Frills
---------------------------------------------------------]]
--[[
local PERK = {}

PERK.Name = "Stasis Gas"
PERK.Desc = "You get the stasis gas effect. :D"
PERK.Level = 15 --So that players who have done extra-good get to choose from the better perks.
PERK.Type = "Frills"
PERK.Shared = function(ply) --Run on server and client
end 
PERK.Server = function(ply) --Run on Server
	ply.EffectTime = 0
	hook.Add("Think",util.CRC(ply:SteamID()).."Effect",function()
		if ply:Alive() and ply.EffectTime >= 100 then
			local efct = EffectData()
			efct:SetEntity(ply)
			util.Effect( "stasis_freeze", efct )
		end
		ply.EffectTime = ply.EffectTime + 1
	end)
end 
PERK.Client = function(ply) --Run on Client
end 
RegisterPerk(PERK.Name,PERK)]]



