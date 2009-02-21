AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')


local function physgunPickup( userid, Ent )  	
	if Ent:GetClass() == "asteroid" then  		
		return false
	end  
end     
hook.Add( "PhysgunPickup", "AA_Asteroid_PhysGun_ARMEGGADONNN", physgunPickup )

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	if self:GetModel() == nil then self:Remove() ErrorNoHalt("Model for asteroid was not set.") end
	self:SetHealth(math.Clamp((self:GetPhysicsObject():GetVolume()/900)-100,50,1000)) --Default health
	self:GetPhysicsObject():EnableGravity(false)
	
	self.DoesNotHaveTargetYet = true
	self.FirstPush = true
	self.Damagers = {}
	
	if GAMEMODE.MaxAsteroids:GetInt() <= 50 then --trail doubles entity count. :P
		self.trail = util.SpriteTrail(self, 0, Color(255,50,50,200), true, 60, 10, 1.5, 1/(60+10)*0.5, "fire/tileable_fire.vmt") 
	end
	
end

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetDamage())
	if dmg:GetAttacker():IsPlayer() and not table.HasValue(self.Damagers, dmg:GetAttacker()) then table.insert(self.Damagers,dmg:GetAttacker()) end
	if self:Health() < 1 then
		for k,v in pairs(self.Damagers) do
			GAMEMODE:GiveMoney(v,math.floor(math.Clamp(math.ceil(math.floor(self:GetPhysicsObject():GetVolume()/500)/#self.Damagers)+20,10,1000)*(dmg:GetAttacker().MunyMul or 1)))
			if HasPerk(v,"EXP From Asteroids") == true then v:SetNWInt("exp",v:GetNWInt("exp")+math.ceil(math.floor(self:GetPhysicsObject():GetVolume()/8000)/#self.Damagers)) end
		end
		self:EmitSound("Weapon_Mortar.Impact")
		self:Remove()
	end
end

function ENT:OnRemove()
	GAMEMODE:DestroyVolume(self.volname)
end

function ENT:Think()
	if self.Frozen and self.Frozen == true then return end
	if self:GetPhysicsObject():GetVelocity():Length() >= 700 then
		self:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity():Normalize()*700)
	elseif self:GetPhysicsObject():GetVelocity():Length() <= 1 then
		self:GetPhysicsObject():SetVelocity((GAMEMODE.LastKnownPlayerPos-self:GetPos()):Normalize()*100)
	end
	
	if self.DoesNotHaveTargetYet == false then
		local gforce = (GAMEMODE.GravityConstant*GAMEMODE.MassOfEarth*self:GetPhysicsObject():GetMass())/(self.Target:Distance(self:GetPos())^2)
		local vect = (self.Target-self:GetPos()):Normalize()
		if self.Target:Distance(self:GetPos()) < 120 then self.DoesNotHaveTargetYet = true end
		if self.FirstPush == true then --let's get this bastud headin in the right direction, then!
			self:GetPhysicsObject():SetVelocity(vect*gforce)
			self.FirstPush = false
		else
			self:GetPhysicsObject():ApplyForceCenter((vect*gforce)+(Vector(math.Rand(-200,200),math.Rand(-200,200),math.Rand(-200,200))))
		end
	end
end

function ENT:PhysicsCollide( data, physobj )
	if (data.Speed > 100 && data.DeltaTime > 0.2 ) then
		util.BlastDamage(self,self,data.HitPos,100,100)
		local eftdata = EffectData()
		eftdata:SetStart(data.HitPos)
		eftdata:SetOrigin(data.HitPos)
		eftdata:SetMagnitude(1)
		util.Effect("HelicopterMegaBomb",eftdata)
		self:EmitSound("PortableThumper.ThumpSound")
		self:EmitSound("Weapon_Mortar.Impact")
		self:Remove()
	end 
end

function ENT:CanTool()
	return false
end

function ENT:GravGunPunt()
	return false
end

function ENT:GravGunPickupAllowed()
	return false
end
