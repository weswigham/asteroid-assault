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
	self:SetHealth(math.Clamp((self:GetPhysicsObject():GetVolume()/800)-100,50,1000)) --Default health
	self:GetPhysicsObject():EnableGravity(false)
	
	self.DoesNotHaveTargetYet = true
	
	if GAMEMODE.MaxAsteroids:GetInt() <= 50 then --trail doubles entity count. :P
		self.trail = util.SpriteTrail(self, 0, Color(255,50,50,200), false, 100, 80, 1, 1/(100+80)*0.5, "trails/plasma.vmt") 
	end
	
end

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetDamage())
	if self:Health() < 1 then
		local ply = dmg:GetAttacker()
		if ply:IsPlayer() then
			GAMEMODE:GiveMoney(ply,math.Clamp(math.floor(self:GetPhysicsObject():GetVolume()/500),10,1000))
			self:EmitSound("Weapon_Mortar.Impact")
		end
		self:Remove()
	end
end

function ENT:OnRemove()
	GAMEMODE:DestroyVolume(self.volname)
end

function ENT:Think()
	if self:GetPhysicsObject():GetVelocity():Length() >= 700 then
		self:GetPhysicsObject():SetVelocity(self:GetPhysicsObject():GetVelocity():Normalize()*700)
	elseif self:GetPhysicsObject():GetVelocity():Length() <= 1 then
		self:GetPhysicsObject():SetVelocity((GAMEMODE.LastKnownPlayerPos-self:GetPos()):Normalize()*100)
	end
	
	if self.DoesNotHaveTargetYet == false then
		local gforce = (GAMEMODE.GravityConstant*GAMEMODE.MassOfEarth*self:GetPhysicsObject():GetMass())/(self.Target:Distance(self:GetPos())^2)
		local vect = (self.Target-self:GetPos()):Normalize()
		if self.Target:Distance(self:GetPos()) < 120 then self.DoesNotHaveTargetYet = true end
		self:GetPhysicsObject():ApplyForceCenter((vect*gforce)+(Vector(math.Rand(-200,200),math.Rand(-200,200),math.Rand(-200,200))))
	end
end

function ENT:PhysicsCollide( data, physobj )
	if (data.Speed > 100 && data.DeltaTime > 0.2 ) then
		util.BlastDamage(self,self,data.HitPos,70,50)
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
