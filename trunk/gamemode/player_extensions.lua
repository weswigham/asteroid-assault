
local Player = FindMetaTable("Player")

require("datastream")

function Player:SetDiscount(num)
	self.discount = num
end 

function Player:GetDiscount()
	return self.discount or 0
end 

if (SERVER) then 
function Player:GiveMoney(money)
	self:SetNWInt("money", self:GetNWInt("money")+math.ceil(money))
end

function Player:TakeMoney(money)
	self:SetNWInt("money", math.Clamp(self:GetNWInt("money")-math.ceil(money),0,self:GetNWInt("money")))
end 

function Player:SendHPEntityData(ent)
	if not ent.MaxHP then return end
	local data = ent:Health()/ent.MaxHP
	if not self.LastSent then self.LastSent = {} end
	if not self.LastSent[ent:EntIndex()] or self.LastSent[ent:EntIndex()] ~= data then
		--proceed to send zhe data
		datastream.StreamToClients({self},"EntityHPInfo",{HP=data,entity=ent})
		self.LastSent[ent:EntIndex()] = data
	end
end

end 

if (CLIENT) then
local function EntHPInfo(name,id,enc,dec)
	dec.entity.HP = dec.HP
end
datastream.Hook("EntityHPInfo",EntHPInfo)
end

if (SERVER) then
function CheckForPlayerAuth()
	for k,v in pairs(player.GetAll()) do
		if v and v:IsValid() and not v.Validated then
			v.Validated = true
			gamemode.Call( "PlayerValid", v )
		end
	end
end 
hook.Add("Think","CheckForPlayerAuth",CheckForPlayerAuth)
elseif (CLIENT) then
function CheckForPlayerAuth2()
	if LocalPlayer() and LocalPlayer():IsValid() and not LocalPlayer().Validated then
		LocalPlayer().Validated = true
		gamemode.Call( "PlayerValid", LocalPlayer() )
	end
end 
hook.Add("Think","CheckForPlayerAuth2",CheckForPlayerAuth2)
end 