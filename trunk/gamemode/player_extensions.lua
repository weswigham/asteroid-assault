
local Player = FindMetaTable("Player")

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
end 