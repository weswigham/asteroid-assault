
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	
	self:SetModel("models/Items/HealthKit.mdl")
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysicsInit(SOLID_VPHYSICS)
	self.owner.MedkitCount = self.owner.MedkitCount + 1
	
end

function ENT:Think()
	
end

function ENT:StartTouch(ent)
	if ent:IsValid() and ent:IsPlayer() and ent:Health() < ent:GetMaxHealth() then
		ent:SetHealth(math.Clamp(ent:Health()+25,0,ent:GetMaxHealth()))
		self:EmitSound("npc\\barnacle\\barnacle_gulp"..math.random(1,2)..".wav",SNDLVL_20dB,200)
		if ent ~= self.owner then
			self.owner:GiveMoney(750)
		end
		self:Remove()
	end
end

function ENT:OnRemove()
	self.owner.MedkitCount = self.owner.MedkitCount - 1
end
 