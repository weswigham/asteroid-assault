
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
	
	self.ShadowParams = {}

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
	
	self:StartMotionController()
	
end

function ENT:ArmageddonEnd()

	self:StopMotionController()

	self.Gun:SetPos(self:GetPos())
	self.Base:SetPos(self:GetPos())
	self.Seat:SetPos(self:GetPos()+SeatPos)
	
	constraint.Weld(self.Base,self,0,0,0,true)
	constraint.Weld(self.Gun,self,0,0,0,true)
end

local function LinkedCollideHook(ent1,ent2)
	if ent1.LinkedTo == ent2 or ent2.LinkedTo == ent1 then return false end
end
hook.Add("ShouldCollide","LinkedToShouldCollideHook",LinkedCollideHook)

function ENT:PhysicsSimulate( phys, deltatime )

	phys:Wake()
	
	if self.User then
	
		local ang = self.User:GetAimVector():Angle()
	
		self.ShadowParams.secondstoarrive = 1
		self.ShadowParams.pos = self.Base:GetPos()
		self.ShadowParams.angle = Angle( 0, ang.y-90, 0 ) 
		self.ShadowParams.maxangular = 5000 
		self.ShadowParams.maxangulardamp = 10000 
		self.ShadowParams.maxspeed = 1000000
		self.ShadowParams.maxspeeddamp = 10000
		self.ShadowParams.dampfactor = 0.8
		self.ShadowParams.teleportdistance = 0
		self.ShadowParams.deltatime = deltatime 
		
		phys:ComputeShadowControl(self.ShadowParams)
		
		local gun = self.Gun:GetPhysicsObject()
		
		gun:Wake()
		
		self.Gun.ShadowParams = {}
		self.Gun.ShadowParams.secondstoarrive = 1
		self.Gun.ShadowParams.pos = self.Base:GetPos()+(ang:Forward()*((math.Clamp(math.NormalizeAngle(ang.p),-30,40)/2)*-1.5)) --this is convoluted shit... I hope it works.
		self.Gun.ShadowParams.angle = Angle( 0, ang.y-90, math.Clamp(math.NormalizeAngle(ang.p*-1),-40,30) ) --I have no idea WTH is up with this.
		self.Gun.ShadowParams.maxangular = 5000 
		self.Gun.ShadowParams.maxangulardamp = 10000 
		self.Gun.ShadowParams.maxspeed = 1000000
		self.Gun.ShadowParams.maxspeeddamp = 10000
		self.Gun.ShadowParams.dampfactor = 0.4
		self.Gun.ShadowParams.teleportdistance = 0
		self.Gun.ShadowParams.deltatime = deltatime 
		
		gun:ComputeShadowControl(self.Gun.ShadowParams)
	
	else
	
		self.ShadowParams.secondstoarrive = 1
		self.ShadowParams.pos = self.Base:GetPos()
		self.ShadowParams.angle = self:GetAngles()
		self.ShadowParams.maxangular = 5000 
		self.ShadowParams.maxangulardamp = 10000 
		self.ShadowParams.maxspeed = 1000000
		self.ShadowParams.maxspeeddamp = 10000
		self.ShadowParams.dampfactor = 0.8
		self.ShadowParams.teleportdistance = 0
		self.ShadowParams.deltatime = deltatime 
		
		phys:ComputeShadowControl(self.ShadowParams)
		
		local gun = self.Gun:GetPhysicsObject()
		
		gun:Wake()
		
		
		self.Gun.ShadowParams = {}
		self.Gun.ShadowParams.secondstoarrive = 1
		self.Gun.ShadowParams.pos = self.Base:GetPos()
		self.Gun.ShadowParams.angle = self:GetAngles()
		self.Gun.ShadowParams.maxangular = 5000 
		self.Gun.ShadowParams.maxangulardamp = 10000 
		self.Gun.ShadowParams.maxspeed = 1000000
		self.Gun.ShadowParams.maxspeeddamp = 10000
		self.Gun.ShadowParams.dampfactor = 0.4
		self.Gun.ShadowParams.teleportdistance = 0
		self.Gun.ShadowParams.deltatime = deltatime 
		
		gun:ComputeShadowControl(self.Gun.ShadowParams)
	
	end
	
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
		self.User = ply
	end
end

function ENT:Think()
	if self.User then --we need to start monitoring his keystrokes.
		if self.User:KeyPressed(IN_USE) then
			self.User = nil
			self.User:ExitVehicle()
		end
		if self.User:KeyDown(IN_ATTACK) then
			self:ShootLeft()
		end
		if self.User:KeyDown(IN_ATTACK2) then
			self:ShootRight()
		end
	end
end

local UpAdd = Vector(0,0,50)

function ENT:ShootLeft()
	local ang = self.User:GetAimVector():Angle()
	local pos = self.Base:GetPos()+UpAdd
	
	local bull = {}
	bull.Num=5
	bull.Src=pos+(ang:Forward()*35)+(ang:Right()*-5)
	bull.Dir=Angle(ang.p,ang.y,0) --What.The.Fuck.
	bull.Spread=Vector(0.01,0.01,0.01)
	bull.Tracer=1	
	bull.Force=2
	bull.Damage=5

	
	self:FireBullets(bull)
end

function ENT:ShootRight()
	local ang = self.User:GetAimVector():Angle()
	local pos = self.Base:GetPos()+UpAdd
	
	local bull = {}
	bull.Num=5
	bull.Src=pos+(ang:Forward()*35)+(ang:Right()*5)
	bull.Dir=Angle(ang.y,ang.p,0)
	bull.Spread=Vector(0.01,0.01,0.01)
	bull.Tracer=1	
	bull.Force=2
	bull.Damage=5

	
	self:FireBullets(bull)
end 