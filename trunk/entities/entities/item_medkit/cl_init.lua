
include('shared.lua')

function ENT:OnRemove()
	LocalPlayer().MedkitCount = LocalPlayer().MedkitCount - 1
end 