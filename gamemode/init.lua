/*---------------------------------------------------------
Asteroid Assault
By Levybreak
---------------------------------------------------------*/

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "player_extensions.lua" )
AddCSLuaFile( "perks.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )


include( 'shared.lua' )
include( 'chatcommands.lua' )
include( 'player_extensions.lua' )
include( 'perks.lua' )

GM.VolCheckIterations = CreateConVar( "AA_VolumeCheckIterations", "11",{ FCVAR_CHEAT, FCVAR_ARCHIVE } ) --Seriously, no need to skrew with it.
GM.MaxAsteroids = CreateConVar( "AA_MaxAsteroids", "20",{ FCVAR_ARCHIVE } ) --Don't set this to over 50 or so on large maps... you may crash for having too many entities. (I was crashing around 75, you can double the ammount by disabling trails, though (now done automatically))

resource.AddFile("resource/fonts/arvigo.ttf")
resource.AddFile("models/asteroids/asteroid1.mdl")
resource.AddFile("models/asteroids/asteroid2.mdl")
resource.AddFile("materials/models/asteroids/asteroid_large.vmt")
resource.AddFile("materials/models/asteroids/asteroid_large.vtf")
resource.AddFile("materials/models/asteroids/asteroid_large_bump.vtf")
resource.AddFile("materials/particles/blue_gas.vtf")
resource.AddFile("materials/particles/blue_gas.vmt")
resource.AddFile("materials/particles/green_gas.vtf")
resource.AddFile("materials/particles/green_gas.vmt")
resource.AddFile("materials/particles/red_gas.vtf")
resource.AddFile("materials/particles/red_gas.vmt")
resource.AddFile("materials/fire/tileable_fire.vmt")
resource.AddFile("materials/fire/tileable_fire.vtf")
resource.AddFile("materials/fire/tileable_fire_bump.vtf")
resource.AddFile("materials/fire/tileable_fire_selfillum.vtf")

GM.MaxProps = 100 --Sufficiently high that most people won't notice it.

function GM:Initialize()
	self.GravityConstant = (6.67428 + math.random(-0.00067,0.00067)) * 10^-11
	self.MassOfEarth = (3.9742 * (10^18)) --Not really. Too lazy to change name.
	
	for k,v in pairs(ents.FindByClass("logic_case")) do
		local kvs = v:GetKeyValues()
		PrintTable(kvs)
		if kvs.case01 == "planet" or kvs.case01 == "planet2" then
			self:AddCustomVolume(util.CRC(tostring(v:GetPos())), v:GetPos(), kvs.case02)
		end
	end
	
end

function GM:InitPostEntity()
	for k,v in pairs(ents.FindByClass("prop_physics")) do
		if not v.owner then v.owner = GetWorldEntity() end
	end
	
	GetWorldEntity().UniqueID = function() return "World" end -- cheap, quick, hacky fix.
end

function GM:DoPlayerDeath( ply, attacker, dmginfo )

	ply:CreateRagdoll()
	ply:AddDeaths( 1 )

	if ply.AliveCounter and ply.AliveCounter > ply:Frags() then
		ply:SetFrags(ply.AliveCounter)
	end
	
	ply.PreviousTotal = ply.PreviousTotal + ply.AliveCounter
	ply.AliveCounter = 0

	if (ply.NoCountDeath != true and self.Build != true) then
	ply:SetNWInt("money", math.Clamp(ply:GetNWInt("money")-200,0,ply:GetNWInt("money")))--there's a toll for respawning. xD
	end
end 

function GM:PhysgunPickup(ply, ent)
	if ent:GetClass() == "func_breakable" then return false end
	if not ent.owner or ent.owner:UniqueID() != ply:UniqueID() then return false end
	return true
end

function GM:PlayerNoClip( pl ) 
	if self.Armeggadon == true then
		return false
	end
end


function GM:PlayerSpawn( pl )

	self.BaseClass.PlayerSpawn( self, pl )
	
	pl:SetMaxHealth(pl.MaxHP or 100)
	pl:SetHealth(pl:GetMaxHealth())
	pl.AliveCounter = 0
	pl.TempGodmode = true
	pl.TempGodmodeRemaining = 3
	
end

function GM:EntityTakeDamage( ent, inflictor, attacker, dmgi )
	if (not ent:IsPlayer() and not attacker:IsPlayer()) and not (ent:EntIndex() == 0 or ent:EntIndex() == 1) then
		ent:SetHealth(ent:Health()-dmgi)
		if ent:Health() <= 0 then
			ent:Remove()
		end
	end
end

function GM:SetupVote(name,duration,percent,OnPass,OnFail)
	self.ActiveVoting = true
	self.CurrentVote = {}
	self.CurrentVote.Name = name
	self.CurrentVote.Yes = 0
	self.CurrentVote.No = 0
	PrintMessage( HUD_PRINTTALK, "A Vote For "..name.." has commenced! You have "..duration.." seconds to vote. Just say yes or no! "..(percent*100).."% is required to pass it.")
	timer.Simple(duration,function() 
		self.ActiveVoting = nil
		if self.CurrentVote.Yes/#player.GetAll() >= percent then OnPass() else OnFail() end 
		for k,v in pairs(player.GetAll()) do
			v.HasVoted = nil
		end
		self.CurrentVote = nil
	end)
end

function GM:PlayerLoadout( pl )

	pl:RemoveAllAmmo()
	
	if self.Build == true then
		pl:Give( "weapon_physgun" )
		pl:Give( "tool_pistol" )
	elseif self.Armeggadon == true then
		pl:Give( "weapon_smg1" )
		pl:GiveAmmo(280+(pl.PrimaryAmmoAdd*45),"SMG1")
		pl:GiveAmmo(3+(pl.SecondaryAmmoAdd),"SMG1_Grenade")
		if pl.AR2Loadout then
			pl:Give("weapon_ar2")
			pl:GiveAmmo(30,"AR2")
		end
		if pl.RPGLoadout then
			pl:Give("weapon_rpg")
			pl:GiveAmmo(3,"RPG")
		end
		if pl.ShotgunLoadout then
			pl:Give("weapon_shotgun")
			pl:GiveAmmo(3,"Buckshot")
		end
	end

	local cl_defaultweapon = pl:GetInfo( "cl_defaultweapon" )

	if ( pl:HasWeapon( cl_defaultweapon )  ) then
		pl:SelectWeapon( cl_defaultweapon ) 
	end
end

function GM:PlayerShouldTakeDamage( ply, attacker )
	if ( attacker:IsValid() and attacker:IsPlayer() ) then
		return false
	elseif ply.TempGodmode then
		return !ply.TempGodmode
	else 
		return true 
	end
end

function GM:ShowHelp( ply )
	--ply:ConCommand( "OpenBuyWindow", "Help" )
	umsg.Start("OpenBuyMenuFromServer",ply)
		umsg.String("Help")
	umsg.End()
end

function GM:ShowTeam(ply)
	--ply:ConCommand( "OpenBuyWindow", "Bombs")
	umsg.Start("OpenBuyMenuFromServer",ply)
		umsg.String("Bombs")
	umsg.End()
end

function GM:ShowSpare1(ply)
	--ply:ConCommand( "OpenBuyWindow", "Turrets")
	umsg.Start("OpenBuyMenuFromServer",ply)
		umsg.String("Turrets")
	umsg.End()
end

function GM:ShowSpare2(ply)
	--ply:ConCommand( "OpenBuyWindow", "Weapons")
	umsg.Start("OpenBuyMenuFromServer",ply)
		umsg.String("Weapons")
	umsg.End()
end

function GM:PlayerInitialSpawn( ply )
	self.BaseClass:PlayerInitialSpawn( ply )
	
	ply.NextSecond = true
	ply.PreviousTotal = 0
	ply.NextLevel = 1
	ply.SecondaryAmmoAdd = 0
	ply.PrimaryAmmoAdd = 0
	ply.Perks = {}
	ply:SetNetworkedInt("money", 1000)
	ply:SetNetworkedInt("exp", ply.PreviousTotal)
	ply.NumProps = 0
	
	GAMEMODE:SetPlayerSpeed( ply, 220, 440 )
	ply:SetMaxHealth(100)
	
end

function GM:PlayerValid(ply) --Had to move load into this hook due to latency.
	self:Load(ply)
end

function GM:PlayerDisconnected( ply )
	self:Save(ply)
end

function GM:Save(ply)
	local tbl = {}
	tbl["name"] = ply:Nick()
	tbl["exp"] = ply:GetNWInt("exp")
	tbl["best"] = ply:Frags() --Just for show. Won't be loaded to anywhere.
	if ply.Perks then tbl["perks"] = ply.Perks end
	local save = util.TableToKeyValues(tbl)
	file.Write("AASaves/"..string.gsub(ply:SteamID(),":","-")..".txt",save)
end

function GM:Load(ply)
	if not file.Exists("AASaves/"..string.gsub(ply:SteamID(),":","-")..".txt") then return end
	local save = file.Read("AASaves/"..string.gsub(ply:SteamID(),":","-")..".txt")
	local tbl = util.KeyValuesToTable(save)
	ply.PreviousTotal = tbl["exp"]
	ply:SetNetworkedInt("exp", ply.PreviousTotal)
	ply.NextLevel = math.floor(ply.PreviousTotal/600)+1
	if tbl.perks then 
		for k,v in pairs(tbl.perks) do
			GivePerk(ply,v)
		end
	end
	ply.HasLoaded = true
end

function GivePerkClient(ply,perk)
	if ply and ply:IsValid() then
		umsg.Start("RecievePerks",ply)
		umsg.String(perk)
		umsg.End()
	end
end

function GimmieThisPerk(ply,cmd,args)
	if args[1] and PerkExists(args[1]) and not HasPerk(ply,args[1]) and math.floor(ply:GetNWInt("exp")/600) >= Perks[args[1]].Level and #ply.Perks <= math.floor(ply:GetNWInt("exp")/600) then
		GivePerk(ply,args[1])
		GAMEMODE:Save(ply)
	end
end
concommand.Add("IdLikeToBuyAVowelIMeanPerk",GimmieThisPerk)

function GM:Think()
	if not NextSecond or NextSecond == true then
		timer.Simple(1,function() GAMEMODE:CalledEverySecond() end)
		NextSecond = false
	end
	
	local playersdead = true
	self.LowestPlayerZ = nil
	if player.GetAll() != nil then
	for k,v in pairs(player.GetAll()) do
		self:PlayerThink(v)
		if v:Alive() == true then playersdead = false end
	end
	end
	if playersdead == true then --considering I have decided not to limit respawn times, this should not heppen often.
		self:AllPlayersAreDead()
	end
end 

function GM:AllPlayersAreDead() --Let the round continue, but don't leave the asteroids just STANDING THERE!
	if not self.LastKnownPlayerPos then self.LastKnownPlayerPos = Vector(0,0,0) end
	for k,v in pairs(ents.FindByClass("asteroid")) do
		if v and v:IsValid() and v:GetMoveType() == MOVETYPE_VPHYSICS and v.DoesNotHaveTargetYet == true then
			if v:GetPhysicsObject() and v:GetPhysicsObject():IsValid() then 
				local gforce = (self.GravityConstant*(self.MassOfEarth/1000)*v:GetPhysicsObject():GetMass())/(self.LastKnownPlayerPos:Distance(v:GetPos())^2)
				if not (gforce < 1) then
					local vect = (self.LastKnownPlayerPos-v:GetPos()):Normalize()
					v:GetPhysicsObject():EnableGravity(false)
					v:GetPhysicsObject():ApplyForceCenter((vect*gforce)+(Vector(math.Rand(-900,900),math.Rand(-900,900),math.Rand(-900,900))))
					v.Target = self.LastKnownPlayerPos
					v.DoesNotHaveTargetYet = false
				end
			end
		end
	end
end

function GM:PlayerThink(ply)
	if self.Armeggadon == true and ply:Alive() == true then
		for k,v in pairs(ents.FindByClass("asteroid")) do
			if v and v:IsValid() and v:GetMoveType() == MOVETYPE_VPHYSICS and v.DoesNotHaveTargetYet == true then
				if v:GetPhysicsObject() and v:GetPhysicsObject():IsValid() then 
					local gforce = (self.GravityConstant*self.MassOfEarth*v:GetPhysicsObject():GetMass())/(ply:GetPos():Distance(v:GetPos())^2)
					if not (gforce < 1) then
						local vect = (ply:GetPos()-v:GetPos()):Normalize()
						v:GetPhysicsObject():EnableGravity(false)
						v:GetPhysicsObject():ApplyForceCenter((vect*gforce)+(Vector(math.Rand(-200,200),math.Rand(-200,200),math.Rand(-200,200))))
						v.Target = ply:GetPos()
						v.DoesNotHaveTargetYet = false
					end
				end
			end
		end
		self.LastKnownPlayerPos = ply:GetPos()
		
		if ply:Alive() == true and ply.NextSecond == true then 
			ply.NextSecond = false
			timer.Simple(1, function() 
				if ply and ply:IsValid() then 
					ply.AliveCounter = ply.AliveCounter + 1
					ply:SetNetworkedInt("exp", ply:GetNWInt("exp")+(1*(ply.EXPMul or 1)))
					if ply.TempGodmodeRemaining > 0 then ply.TempGodmodeRemaining = ply.TempGodmodeRemaining - 1 end
					if ply.TempGodmodeRemaining <= 0 then ply.TempGodmode = false end
					ply.NextSecond = true 
				end 
			end)
		end
		
		if ply.AliveCounter and ply.AliveCounter > ply:Frags() then
			ply:SetFrags(ply.AliveCounter)
		end
		
		if math.fmod(CurTime(),120) <= 0 and ply.NextSecond == true then --save every so often :V
			self:Save(ply)
			ply:PrintMessage( HUD_PRINTTALK, "Your experience has been saved.")
		end
		
	end
	if not self.LowestPlayerZ or ply:GetPos().z < self.LowestPlayerZ then self.LowestPlayerZ = ply:GetPos().z end
	if ply:GetNWInt("exp")/600 > ply.NextLevel then
		umsg.Start("ChoseNewPerk",ply)
		umsg.End()
		self:Save(ply)
		ply.NextLevel = ply.NextLevel + 1
	end
end

function GM:SpawnAnAsteroid()
	if table.Count(ents.FindByClass("asteroid")) >= self.MaxAsteroids:GetInt() then return end
	local name = "AA_"..util.CRC(CurTime())
	local volumetbl = GAMEMODE:FindVolume(name, 100)
	if volumetbl then
		local ent1 = ents.Create("asteroid")
		ent1:SetModel("models/asteroids/asteroid"..math.random(1,2)..".mdl")
		ent1:SetPos(volumetbl.pos)
		ent1:PhysicsInit( SOLID_VPHYSICS )
		ent1:SetMoveType( MOVETYPE_VPHYSICS )
		ent1:SetSolid( SOLID_VPHYSICS )
		ent1.volname = name
		ent1:Spawn()
		ent1:Activate()
	end
end

function GM:CalledEverySecond()
	if GetGlobalInt("buildmode") > 0 then
		SetGlobalInt("buildmode", GetGlobalInt("buildmode")-1)
		self:BuildThink()
		if GetGlobalInt("buildmode") <= 0 then
			SetGlobalInt("armeggadon",60*60*12)
			self:StartArmeggadon()
		end
	elseif GetGlobalInt("armeggadon") > 0 then
		SetGlobalInt("armeggadon", GetGlobalInt("armeggadon")-1)
		self:ArmeggadonThink()
	else
		SetGlobalInt("buildmode", 60*60*3)
		self:StartBuild()
	end
	NextSecond = true
end

function GM:BuildThink()

end

function GM:ArmeggadonThink()
	if math.floor(math.fmod(math.floor(GetGlobalInt("armeggadon")/60),5)) <= 0 then
		for i=1,#player.GetAll()*2 do
			self:SpawnAnAsteroid()
		end
	end
end

function GM:QueCleanup()
	self.GunnaCleanUpNow = true
end

function GM:StartBuild()
	PrintMessage( HUD_PRINTTALK, "Buildmode has begun!")
	self.Build = true
	self.Armeggadon = false
	self:RespawnEveryone()
	
	for k,v in pairs(ents.FindByClass("asteroid")) do
		v:Remove()
	end

	RunConsoleCommand("stopsounds")
	
	for k,v in pairs(player.GetAll()) do
		self:Save(v)
	end
	
	if self.GunnaCleanUpNow and self.GunnaCleanUpNow == true then
		game.CleanUpMap()
		self.GunnaCleanUpNow = nil
	end
	
	self:CheckForOwnerlessProps()
	
end

function GM:CheckForOwnerlessProps()
	for k,v in pairs(ents.FindByClass("prop_physics")) do
		if not v.owner or v.owner == NULL then v:Remove() end
	end
end

function GM:StartArmeggadon()
	PrintMessage( HUD_PRINTTALK, "The Armaggadon has started! Find shelter or defend yourself!")
	self.Build = false
	self.Armeggadon = true
	self:RespawnEveryone()
	WorldSound("canals_citadel_siren",Vector(0,0,0))
	WorldSound("streetwar.distant_siren_distant_loop",Vector(0,0,0))
	
	for k,v in pairs(ents.FindByClass("prop_physics")) do
		v:SetCollisionGroup( COLLISION_GROUP_NONE )
		v.CollisionGroup = COLLISION_GROUP_NONE
		if v:GetPhysicsObject() and v:GetPhysicsObject():IsValid() then
		v:GetPhysicsObject():EnableMotion(false)
		end
		v:SetColor(255,255,255,255)
	end
	
	for k,v in pairs(player.GetAll()) do
		self:Save(v)
	end
	
	self:CheckForOwnerlessProps()
	
end

function GM:RespawnEveryone()
	if player.GetAll() != nil then
	for k,v in pairs(player.GetAll()) do
		v.NoCountDeath = true
		v:KillSilent()
	end
	end
end

function GM:NextMap()
	if game.GetMap() == "aa_rundown" then
		return "aa_field"
	else
		return "aa_rundown"
	end
end

function GM:GiveMoney(ply,money)
	ply:SetNWInt("money", ply:GetNWInt("money")+math.ceil(money))
end

function GM:TakeMoney(ply,money)
	ply:SetNWInt("money", math.Clamp(ply:GetNWInt("money")-math.ceil(money),0,ply:GetNWInt("money")))
end

function BuySomething(ply,cmd,args)
	if ply and ply:IsValid() and ply:Alive() then
		local args = string.Explode(" ",args[1])
		local name = args[1]
		if ItemExists(name) then
			local nicename = Items[name].NiceName or Items[name].Name
			if ply:GetNWInt("money") >= (Items[name].Cost*((100-ply:GetDiscount())/100)) then
				if Items[name].Category == "weapon" then
					if GAMEMODE.Build == true then 
						ply:PrintMessage( HUD_PRINTTALK, "You can't buy a "..nicename.." during the build phase!" )
						return nil
					end
					ply:SetNWInt("money", ply:GetNWInt("money") - (Items[name].Cost*((100-ply:GetDiscount())/100)))
					ply:Give(Items[name].Class)
					ply:GiveAmmo(Items[name].Ammo,Items[name].AmmoType)
					ply:PrintMessage( HUD_PRINTTALK, "You sucessfully bought a "..nicename.." you now have $"..ply:GetNWInt("money") )
				else
					if ply.NumProps < GAMEMODE.MaxProps then
						local pos = Vector(args[2],args[3],args[4])
						
						if pos and pos:Distance(ply:GetPos()) <= 2600 then
							ply:SetNWInt("money", ply:GetNWInt("money") - (Items[name].Cost*((100-ply:GetDiscount())/100)))
							local ent = ents.Create(Items[name].Class)
							ent:SetPos(pos+Vector(0,0,20))
							ent:SetModel(Items[name].Model)
							if Items[name].KeyValues then
								for k,v in pairs(Items[name].KeyValues) do
									if k == "Time" and string.find(string.lower(name),"stasis") then v = v + (ply.StasisAdd or 0) end
									ent:SetKeyValue(tostring(k),tostring(v))
								end
							end
							ent:Spawn()
							ent.owner = ply
							ent.ReturnValue = math.floor(Items[name].Cost/2.5)
							ent:SetHealth(math.Clamp((ent:GetPhysicsObject():GetVolume()) or 50,50,1000)*(1.5*(1-(ply.NumProps/GAMEMODE.MaxProps))))
							ply.NumProps = ply.NumProps + 1
							ply:PrintMessage( HUD_PRINTTALK, "You sucessfully bought a "..nicename.." you now have $"..ply:GetNWInt("money") )
							if GAMEMODE.Build != true then
								ent:GetPhysicsObject():EnableMotion(false)
							end
							
						end
						
					else
						ply:PrintMessage( HUD_PRINTTALK, "You've already reached the prop/item limit! It's "..GAMEMODE.MaxProps.." props and you have "..ply.NumProps.." props." )
					end
				end
			end
		end
	end
end 
concommand.Add("BuySomeShit", BuySomething)
--[[
function mySetupVis(ply)
	AddOriginToPVS(Vector(0,0,0))
end
hook.Add("SetupPlayerVisibility", "mySetupVis", mySetupVis)]]

local function MahEntitysBeenRemoved(ent)
	if ent.owner and ent.owner:IsValid() and ent.owner:UniqueID() != "World" then
		ent.owner.NumProps = ent.owner.NumProps - 1
	end
end
hook.Add("EntityRemoved","AAEntityRemoved",MahEntitysBeenRemoved)

--Spacebuild 3 volume code, edited to not need Environments/Certain SB3 functions. This code *could* now be made into a reusable module...buuuttt... I don't feel like it. (And i modified it for this gamemode) ;)
local volumes = {}
/**
* @param name
* @return Volume(table) or nil
*
*/
function GM:GetVolume(name)
	return volumes[name]
end

/**
* @param name
* @param radius
* @return Volume(table) or ( false + errormessage)
*
* Notes: If the volume name already exists, that volume is returned! 
*
*/
function GM:CreateVolume(name, radius)
	return self:FindVolume(name, radius)
end

/**
* @param name
* @param radius
* @return Volume(table) or ( false + errormessage)
*
* Notes: If the volume name already exists, that volume is returned! 
*
*/
function GM:FindVolume(name, radius)
	if not name then return false, "No Name Entered!" end
	if not radius or radius < 0 then radius = 0 end
	if not volumes[name] then
		volumes[name] = {}
		volumes[name].radius = radius
		volumes[name].pos = Vector(0, 0 ,0 )
		local tries = self.VolCheckIterations:GetInt()
		local found = 0
		while ( ( found == 0 ) and ( tries > 0 ) ) do
			tries = tries - 1
			pos = VectorRand()*16384
			if (util.IsInWorld( pos ) == true) then
				found = 1
				for k, v in pairs(volumes) do
					if v and v.pos and (v.pos == pos or v.pos:Distance(pos) < v.radius+radius) then
						found = 0
					end
				end
				if found == 1 then
					if Environments then
						for k, v in pairs(Environments) do
							if v and ValidEntity(v) and ((v.IsPlanet and v.IsPlanet()) or (v.IsStar and v.IsStar())) and (v:GetPos() == pos or v:GetPos():Distance(pos) < v:GetSize()) then
								found = 0
							end
						end
					end
				end
				if (found == 1) and radius > 0 then
					local edges = {
						pos+(Vector(1, 0, 0)*radius),
						pos+(Vector(0, 1, 0)*radius),
						pos+(Vector(0, 0, 1)*radius),
						pos+(Vector(-1, 0, 0)*radius),
						pos+(Vector(0, -1, 0)*radius),
						pos+(Vector(0, 0, -1)*radius)
					}
					local trace = {}
					trace.start = pos
					for _, edge in pairs( edges ) do
						trace.endpos = edge
						trace.filter = { }
						local tr = util.TraceLine( trace )
						if (tr.Hit) then
							found = 0
							break
						end
					end
				end
				if (found == 0) then Msg( "Rejected Volume.\n" ) end
			end
			if (found == 1) then
				volumes[name].pos = pos
			elseif tries <= 0 then
				volumes[name] = nil
			end
		end
	end
	if self.LowestPlayerZ and volumes[name] and volumes[name].pos and volumes[name].pos.z and volumes[name].pos.z <= self.LowestPlayerZ then volumes[name].pos.z = self.LowestPlayerZ + 200 end -- to make allll asteroids come from above!
	return volumes[name]
end

/**
* @param name
* @return nil
*
*/
function GM:DestroyVolume(name)
	self:RemoveVolume(name);
end

/**
* @param name
* @return nil
*
*/
function GM:RemoveVolume(name)
	if name and volumes[name] then volumes[name] = nil end
end

/**
* @param name
* @param pos
* @param radius
* @return nil
*
* Note: this is meant for people who spawn their props in space using a custom Spawner (like the Stargate Spawner)
*/
function GM:AddCustomVolume(name, pos, radius)
	if not name or not radius or not pos then return false, "Invalid Parameters" end
	if volumes[name] then return false, "this volume already exists!" end
	volumes[name] = {}
	volumes[name].pos = pos
	volumes[name].radius = radius
end
