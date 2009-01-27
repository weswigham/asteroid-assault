
SWEP.Author			= "Levybreak"
SWEP.Contact		= "Facepunch"
SWEP.Purpose		= "Remove your own props"
SWEP.Instructions	= "Shoot a prop to remove it.\nRight click to nocollide/unnocollide (with all) it."

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

local ShootSound = Sound( "Metal.SawbladeStick" )

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
	
	self.Owner:GiveMoney(math.floor(tr.Entity:Health()/2))
	tr.Entity:Remove()

end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	local tr = self.Owner:GetEyeTrace()
	if ( tr.HitWorld or (tr.Entity.owner and tr.Entity.owner:EntIndex() != self.Owner:EntIndex())) then return end

	self:ShootEffects( self )
	
	if (!SERVER) then return end
	
	if ( tr.Entity.CollisionGroup == COLLISION_GROUP_WORLD ) then
	
		tr.Entity:SetColor(255,255,255,255)
		tr.Entity:SetCollisionGroup( COLLISION_GROUP_NONE )
		tr.Entity.CollisionGroup = COLLISION_GROUP_NONE
	
	else
		tr.Entity:SetColor(255,255,255,100)
		tr.Entity:SetCollisionGroup( COLLISION_GROUP_WORLD )
		tr.Entity.CollisionGroup = COLLISION_GROUP_WORLD
		
	end
	
end


/*---------------------------------------------------------
   Name: ShouldDropOnDie
   Desc: Should this weapon be dropped when its owner dies?
---------------------------------------------------------*/
function SWEP:ShouldDropOnDie()
	return false
end
