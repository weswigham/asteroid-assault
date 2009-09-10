
include('shared.lua')

function ENT:OnRemove()
	if LocalPlayer().MedkitCount then LocalPlayer().MedkitCount = LocalPlayer().MedkitCount - 1 end
end 