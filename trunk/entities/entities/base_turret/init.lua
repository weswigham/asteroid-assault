
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:KeyValue(k,v)
	if k == "Type" then --1 = MG, 2 = Explosive Shell, 3 = Dumbfire Rockets, 4 = Seeking Rockets
		self.Type = tonumber(v)
	elseif k == "Size" then --1 for small, 2 for large
		self.Size = tonumber(v)
	elseif k == "Health" then
		self.MaxHP = tonumber(v)
		self:SetHealth(tonumber(v))
	end
end

function ENT:Initialize()
	if not self.Type then self:Remove() return end
	if not self.Size then self.Size= 2 end

	self:SetModel("models/turret/large_pod.mdl")
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysicsInit(SOLID_VPHYSICS)
	
	self.Gun = ents.Create("prop_physics")
	self.Gun:SetModel("models/turret/large_mg.mdl")

	self.Base = ents.Create("prop_physics")
	self.Base:SetModel("models/turret/large_base.mdl")
	
	self.Seat = ents.Create( "prop_vehicle_prisoner_pod" )
	self.Seat:SetModel("models/nova/jeep_seat.mdl")
	self.Seat:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
	self.Seat:SetKeyValue("limitview", 0)
	
	local tabl = self.Seat:GetTable()
	table.HandleAnimation = function (vec, ply)
		return ply:SelectWeightedSequence( ACT_HL2MP_SIT ) 
	end 
	self.Seat:SetTable(tabl)
	

end

local SeatPos = Vector(0,0,25) 

function ENT:PostSpawn()
	self.Gun:SetPos(self:GetPos())
	self.Base:SetPos(self:GetPos())
	self.Seat:SetPos(self:GetPos()+SeatPos)
	self.Gun:Spawn()
	self.Base:Spawn()
	self.Seat:Spawn()
	
	self.Gun.owner = self.owner
	self.Base.owner = self.owner
	self.Seat.owner = self.owner
	
	self.Gun.LinkedTo = self
	self.Base.LinkedTo = self
	self.Seat.LinkedTo = self
	
	constraint.Weld(self.Base,self,0,0,0,true)
	constraint.Weld(self.Gun,self,0,0,0,true)
	constraint.Weld(self.Seat,self,0,0,0,true)
end

function ENT:ArmageddonBegin()
	self.Base:GetPhysicsObject():EnableMotion(false)
	
	constraint.RemoveConstraints(self.Gun,"Weld")
	constraint.RemoveConstraints(self.Base,"Weld")
end

function ENT:ArmageddonEnd()
	self.Gun:SetPos(self:GetPos())
	self.Base:SetPos(self:GetPos())
	self.Seat:SetPos(self:GetPos()+SeatPos)
	
	constraint.Weld(self.Base,self,0,0,0,true)
	constraint.Weld(self.Gun,self,0,0,0,true)
	constraint.Weld(self.Seat,self,0,0,0,true)
end

function ENT:OnRemove()
	self.Gun:Remove()
	self.Base:Remove()
	self.Seat:Remove()
end

function ENT:Use(ply)
	if GAMEMODE.Build != true then
		self:EmitSound("Buttons.snd19")
		ply:SetPos(self.Seat:GetPos())
		self.Seat:Input("Use",ply,ply)
	end
end

function ENT:Think()
	
end
