
local Player = FindMetaTable("Player")

function Player:SetDiscount(num)
	self.discount = num
end 

function Player:GetDiscount()
	return self.discount or 0
end 