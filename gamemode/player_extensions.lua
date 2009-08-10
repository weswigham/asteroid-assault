
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