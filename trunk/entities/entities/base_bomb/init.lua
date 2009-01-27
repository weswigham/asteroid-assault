
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:KeyValue(k,v)
	if k == "Type" then --1 = Stasis, 2 = Replusion, 3 = Attraction
		self.Type = tonumber(v)
	elseif k == "Time" then --Must rig up called per second timer on this shitz.
		self.Time = tonumber(v)
	elseif k == "Strength" then
		self.Strength = tonumber(v)
	elseif k == "Health" then
		self.MaxHP = tonumber(v)
		self:SetHealth(tonumber(v))
	end
end

function ENT:Initialize()
	if not self.Type then self:Remove() return end
	if not self.Time then self.Time = 10 end
	if not self.Strength then self.Strength = 0 end
	self.Active = false
	if self.Type == 1 then
		self:SetModel("models/Roller.mdl")
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:PhysicsInit(SOLID_VPHYSICS)
	end
	self.NextSecond = true
end

function ENT:Use(ply)
	if GAMEMODE.Build != true then
		self.Active = !self.Active
		self:EmitSound("Buttons.snd19")
	end
end

function ENT:Think()
	if self.NextSecond == true then
	self.NextSecond = false
	timer.Simple(1,ToBeCalledEverySecond,self)
	end
	if self.Active == true and self.Time > 0 then
		if self.Type == 1 then
			for k,v in pairs(ents.FindByClass("asteroid")) do
				if v:GetPos():Distance(self:GetPos()) <= self.Strength then
					v.Freezer = self:EntIndex()
					v.Frozen = true
					v:GetPhysicsObject():EnableMotion(false)
					v:SetVelocity(Vector(0,0,0))
					local efct = EffectData()
					efct:SetEntity(v)
					util.Effect( "stasis_freeze", efct )
				elseif not v.Freezer or v.Freezer == self:EntIndex() then
					v.Freezer = nil
					v.Frozen = false
					v:GetPhysicsObject():EnableMotion(true)
				end
			end
			local efct = EffectData()
			efct:SetEntity(self)
			util.Effect( "stasis_freeze", efct )
		end
	elseif self.Active == false then
		for k,v in pairs(ents.FindByClass("asteroid")) do
			if v:GetPos():Distance(self:GetPos()) <= self.Strength and v.Freezer and v.Freezer == self:EntIndex() then
				v:GetPhysicsObject():EnableMotion(true)
				v.Frozen = false
				v.Freezer = nil
			end
		end
	end
	if self.Time <= 0 then 
		for k,v in pairs(ents.FindByClass("asteroid")) do
			if v:GetPos():Distance(self:GetPos()) <= self.Strength then
				v:GetPhysicsObject():EnableMotion(true)
				v.Frozen = false
			end
		end
	self:Remove()
	end
end

function ToBeCalledEverySecond(ent)
	if ent.Active == true and ent.Time > 0 then
		ent.Time = ent.Time - 1
	end
	ent.NextSecond = true
end
 