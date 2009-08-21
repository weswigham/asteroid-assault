
SWEP.Author			= "Levybreak"
SWEP.Contact		= "Facepunch"
SWEP.Purpose		= "Repairs props."
SWEP.Instructions	= "Beat on props to repair them, lol."

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.ViewModel			= "models/weapons/v_wrenchs.mdl"
SWEP.WorldModel			= "models/weapons/w_wrenchs.mdl"
SWEP.HoldType			= "melee"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Initialize()
	if ( SERVER ) then
       self:SetWeaponHoldType( self.HoldType )
	end
end


function SWEP:Reload()
	
end

function SWEP:Think()

	if (!SERVER) then return end
	local tr = self.Owner:GetEyeTrace()
	if ( tr.HitWorld or (tr.Entity.owner and tr.Entity.owner:EntIndex() != self.Owner:EntIndex()) or (tr.HitPos:Distance(self.Owner:GetShootPos()) > 2000)) then return end

	self.Owner:SendHPEntityData(tr.Entity)
	
end

local color_gray = Color(0,0,0,200)
local color_white = Color(250,250,250,255)

function SWEP:DrawHUD()

	if (!CLIENT) then return end
	local tr = self.Owner:GetEyeTrace()
	if ( tr.HitWorld or (tr.Entity.owner and tr.Entity.owner:EntIndex() != self.Owner:EntIndex()) or (tr.HitPos:Distance(self.Owner:GetShootPos()) > 2000)) then return end

	local x = tr.HitPos:ToScreen()
	surface.SetFont("TargetID")
	local wid,high = surface.GetTextSize("Health: "..(math.floor((tr.Entity.HP or 1)*100)).."%")
	
	draw.RoundedBox(4,x.x,x.y,wid+4,high+4,color_gray)
	draw.SimpleText( "Health: "..(math.floor((tr.Entity.HP or 1)*100)).."%", "TargetID", x.x+2, x.y+2, color_white )

end

function SWEP:PrimaryAttack()
	if (!SERVER) then return end

	local tr = self.Owner:GetEyeTrace()
	if ( tr.HitWorld or (tr.Entity.owner and tr.Entity.owner:EntIndex() != self.Owner:EntIndex()) or (tr.HitPos:Distance(self.Owner:GetShootPos()) > 150) or tr.Entity:IsPlayer()) then return end

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
    self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
    self.Owner:EmitSound(Sound("weapons/iceaxe/iceaxe_swing1.wav"))
	GAMEMODE:SetPlayerAnimation( self.Owner, PLAYER_ATTACK1 )

	if not tr.Entity.LinkedTo then
		if tr.Entity.MaxHP and tr.Entity:Health() < tr.Entity.MaxHP then
			tr.Entity:SetHealth(math.Clamp(tr.Entity:Health()+math.floor(tr.Entity.MaxHP*0.20)+300,0,tr.Entity.MaxHP))
			self.Owner:GiveMoney(450)
		end
	else
		if tr.Entity.LinkedTo.MaxHP and tr.Entity.LinkedTo:Health() < tr.Entity.LinkedTo.MaxHP then
			tr.Entity.LinkedTo:SetHealth(math.Clamp(tr.Entity.LinkedTo:Health()+math.floor(tr.Entity.LinkedTo.MaxHP*0.20)+300,0,tr.Entity.LinkedTo.MaxHP))
			self.Owner:GiveMoney(450)
		end
	end
	
end

function SWEP:SecondaryAttack()

end


function SWEP:ShouldDropOnDie()
	return false
end 