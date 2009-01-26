
SWEP.Author			= "Levybreak"
SWEP.Contact		= "Facepunch"
SWEP.Purpose		= "Yea, muthafucka! Railgunz ig gunna burn a hola through ya!"
SWEP.Instructions	= "Shoot to destroy."

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

SWEP.Primary.ClipSize		= 6
SWEP.Primary.DefaultClip	= 3
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "EnergyCells"

SWEP.Secondary.ClipSize		= 1
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "ChargedCapacitor"

/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
	
end

/*---------------------------------------------------------
   Think does nothing
---------------------------------------------------------*/
function SWEP:Think()

end


/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	local tr = self.Owner:GetEyeTrace()
	if ( tr.HitWorld or (tr.Entity.owner and tr.Entity.owner:EntIndex() != self.Owner:EntIndex())) then return end

	self:ShootEffects( self )
	
	if (!SERVER) then return end
	

end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	local tr = self.Owner:GetEyeTrace()
	if ( tr.HitWorld or (tr.Entity.owner and tr.Entity.owner:EntIndex() != self.Owner:EntIndex())) then return end

	self:ShootEffects( self )
	
	if (!SERVER) then return end

	
end


/*---------------------------------------------------------
   Name: ShouldDropOnDie
   Desc: Should this weapon be dropped when its owner dies?
---------------------------------------------------------*/
function SWEP:ShouldDropOnDie()
	return true
end
