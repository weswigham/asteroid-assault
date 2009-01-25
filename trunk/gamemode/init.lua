/*---------------------------------------------------------
Asteroid Assault
By Levybreak
---------------------------------------------------------*/

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( 'shared.lua' )
include( 'chatcommands.lua' )
include( 'sg_compatability.lua' )

GM.VolCheckIterations = CreateConVar( "AA_VolumeCheckIterations", "11",{ FCVAR_CHEAT, FCVAR_ARCHIVE } ) --Seriously, no need to skrew with it.
GM.MaxAsteroids = CreateConVar( "AA_MaxAsteroids", "20",{ FCVAR_ARCHIVE } ) --Don't set this to over 50 or so on large maps... you may crash for having too many entities. (I was crashing around 75, you can double the ammount by disabling trails, though (now done automatically))

resource.AddFile("resource/fonts/armalite.ttf")
resource.AddFile("models/asteroids/asteroid1.mdl")
resource.AddFile("models/asteroids/asteroid2.mdl")
resource.AddFile("materials/models/asteroids/asteroid_large.vmt")
resource.AddFile("materials/models/asteroids/asteroid_large.vtf")
resource.AddFile("materials/models/asteroids/asteroid_large_bump.vtf")
resource.AddFile("materials/fire/tileable_fire.vmt")
resource.AddFile("materials/fire/tileable_fire.vtf")
resource.AddFile("materials/fire/tileable_fire_bump.vtf")
resource.AddFile("materials/fire/tileable_fire_selfillum.vtf")

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

function GM:DoPlayerDeath( ply, attacker, dmginfo )

	ply:CreateRagdoll()
	ply:AddDeaths( 1 )

	if ply.AliveCounter and ply.AliveCounter > ply:Frags() then
		ply:SetFrags(ply.AliveCounter)
	end
	
	ply.PreviousTotal = ply.PreviousTotal + ply.AliveCounter
	ply.AliveCounter = 0

	ply:SetNWInt("money", math.Clamp(ply:GetNWInt("money")-200,0,ply:GetNWInt("money")))--there's a toll for respawning. xD
end 

function GM:PhysgunPickup(ply, ent)
	if ent:GetClass() == "func_breakable" then return false end
	if ent.owner and ent.owner:EntIndex() != ply:EntIndex() then return false end
	return true
end

function GM:PlayerNoClip( pl ) 
	if self.Armeggadon == true then
		return false
	end
end


function GM:PlayerSpawn( pl )

	self.BaseClass.PlayerSpawn( self, pl )
	
	// Set the player's speed
	GAMEMODE:SetPlayerSpeed( pl, 250, 500 )
	pl:SetMaxHealth(100)
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

function GM:PlayerLoadout( pl )

	pl:RemoveAllAmmo()
	
	if self.Build == true then
		pl:Give( "weapon_physgun" )
		pl:Give( "tool_pistol" )
	elseif self.Armeggadon == true then
		pl:Give( "weapon_smg1" )
		pl:GiveAmmo(400,"SMG1")
		pl:GiveAmmo(4,"SMG1_Grenade")
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
	ply:ConCommand( "OpenBuyWindow" )
end

function GM:PlayerInitialSpawn( ply )
	self.BaseClass:PlayerInitialSpawn( ply )
	
	ply.NextSecond = true
	ply.PreviousTotal = 0
	ply:SetNetworkedInt("money", 500)
	ply:SetNetworkedInt("exp", ply.PreviousTotal)
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
	local save = util.TableToKeyValues(tbl)
	file.Write("AASaves/"..string.gsub(ply:SteamID(),":","-")..".txt",save)
end

function GM:Load(ply)
	if not file.Exists("AASaves/"..string.gsub(ply:SteamID(),":","-")..".txt") then return end
	local save = file.Read("AASaves/"..string.gsub(ply:SteamID(),":","-")..".txt")
	local tbl = util.KeyValuesToTable(save)
	ply.PreviousTotal = tbl["exp"]
	ply:SetNetworkedInt("exp", ply.PreviousTotal)
end

function GM:Think()
	if not NextSecond or NextSecond == true then
		timer.Simple(1,function() GAMEMODE:CalledEverySecond() end)
		NextSecond = false
	end
	
	local playersdead = false
	self.LowestPlayerZ = nil
	if player.GetAll() != nil then
	for k,v in pairs(player.GetAll()) do
		self:PlayerThink(v)
		if v:Alive() == false then playersdead = true end
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
					if ply.TempGodmodeRemaining > 0 then ply.TempGodmodeRemaining = ply.TempGodmodeRemaining - 1 end
					if ply.TempGodmodeRemaining <= 0 then ply.TempGodmode = false end
					ply.NextSecond = true 
				end 
			end)
		end
		
		if ply.AliveCounter and ply.AliveCounter > ply:Frags() then
			ply:SetFrags(ply.AliveCounter)
		end
		
		if math.fmod(ply.AliveCounter,60) == 0 and ply.NextSecond == true then --save for every minute you're alive
			self:Save(ply)
			ply:PrintMessage( HUD_PRINTTALK, "Your experience has been saved.")
		end
		
	end 
	ply:SetNetworkedInt("exp", ply.PreviousTotal + ply.AliveCounter)
	if not self.LowestPlayerZ or ply:GetPos().z < self.LowestPlayerZ then self.LowestPlayerZ = ply:GetPos().z end
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

function GM:StartBuild()
	PrintMessage( HUD_PRINTTALK, "Buildmode has begun!")
	self.Build = true
	self.Armeggadon = false
	self:RespawnEveryone()
	
	for k,v in pairs(ents.FindByClass("asteroid")) do
		v:Remove()
	end
	
end

function GM:StartArmeggadon()
	PrintMessage( HUD_PRINTTALK, "The Armaggadon has started! Find shelter or defend yourself!")
	self.Build = false
	self.Armeggadon = true
	self:RespawnEveryone()
	
	for k,v in pairs(ents.FindByClass("prop_physics")) do
		v:SetCollisionGroup( COLLISION_GROUP_WORLD )
		v.CollisionGroup = COLLISION_GROUP_WORLD
		v:EnableMovement(false)
	end
end

function GM:RespawnEveryone()
	if player.GetAll() != nil then
	for k,v in pairs(player.GetAll()) do
		v.NoCountDeath = true
		v:KillSilent()
	end
	end
end

function GM:GiveMoney(ply,money)
	ply:SetNWInt("money", ply:GetNWInt("money")+money)
end

function BuySomething(ply,cmd,args)
	if ply and ply:IsValid() then
		local args = string.Explode(" ",args[1])
		local name = args[1]
		if ItemExists(name) then
			local nicename = Items[name].NiceName or Items[name].Name
			if ply:GetNWInt("money") >= Items[name].Cost then
				if Items[name].Category == "weapon" then
					ply:SetNWInt("money", ply:GetNWInt("money") - Items[name].Cost)
					ply:Give(Items[name].Class)
					ply:GiveAmmo(Items[name].Ammo,Items[name].AmmoType)
					ply:PrintMessage( HUD_PRINTTALK, "You sucessfully bought a "..nicename.." you now have $"..ply:GetNWInt("money") )
				else
					local pos = Vector(args[2],args[3],args[4])
					if pos and pos:Distance(ply:GetPos()) <= 2600 then
					ply:SetNWInt("money", ply:GetNWInt("money") - Items[name].Cost)
					local ent = ents.Create(Items[name].Class)
					ent:SetPos(pos)
					ent:SetModel(Items[name].Model)
					if Items[name].KeyValues then
						for k,v in pairs(Items[name].KeyValues) do
							ent:SetKeyValue(tostring(k),tostring(v))
						end
					end
					ent:Spawn()
					ent.owner = ply
					ent:SetHealth(math.Clamp(ent:GetPhysicsObject():GetMass(),50,1000))
					ply:PrintMessage( HUD_PRINTTALK, "You sucessfully bought a "..nicename.." you now have $"..ply:GetNWInt("money") )
					end
				end
			end
		end
	end
end 
concommand.Add("BuySomeShit", BuySomething)


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
					--if v and v.pos and (v.pos == pos or v.pos:Distance(pos) < v.radius) then -- Hur hur. This is why i had planetary collisions.
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
	--if self.LowestPlayerZ and volumes[name].pos.z and volumes[name].pos.z <= self.LowestPlayerZ then volumes[name].pos.z = self.LowestPlayerZ + 200 end -- to make allll asteroids come from above!
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
