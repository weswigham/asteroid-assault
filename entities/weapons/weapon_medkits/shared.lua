
SWEP.Author			= "Levybreak"
SWEP.Contact		= "Facepunch"
SWEP.Purpose		= "Heals on the way!"
SWEP.Instructions	= "Left Click to toss out a medkit, Right Click to deploy invulnerability charge (15 seconds)"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.ViewModel			= ""
SWEP.WorldModel			= ""
SWEP.HoldType			= "slam"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.MaxKits = 7
SWEP.Force = 250

function SWEP:Initialize()
	if ( SERVER ) then
       self:SetWeaponHoldType( self.HoldType )
	else
		self.Bar1Per = 100
		self.Bar2Per = 100
		self.Bar2TS = 0
		self.Bar1TS = 0
	end
end

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

local zerovec = Vector(0,0,0)

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	
	if not self.Owner.MedkitCount then self.Owner.MedkitCount = 0 end
	if self.Owner.MedkitCount < self.MaxKits then
	
		self.Weapon:SetNextPrimaryFire(CurTime() + 1)
		if CLIENT then
			if self.Bar1TS <= CurTime() then
				self.Bar1Per = 0
				self.Bar1TS = CurTime() + 1
			end
		end
		
		if (!SERVER) then return end
		
		local kit = ents.Create("item_medkit")
		kit.owner = self.Owner
		kit:SetPos(self.Owner:GetShootPos()+(self.Owner:GetAimVector()*25))
		kit:Spawn()
		kit:GetPhysicsObject():AddVelocity((self.Owner:GetVelocity() or zerovec)*0.1)--just a slight influence, instead of 1/2 and 1/2
		kit:GetPhysicsObject():AddVelocity(self.Owner:GetAimVector()*self.Force)
		
		self.Owner:EmitSound(Sound("weapons/iceaxe/iceaxe_swing1.wav"))
		GAMEMODE:SetPlayerAnimation( self.Owner, PLAYER_ATTACK1 )
	
	end
	
	

end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	
	self.Weapon:SetNextSecondaryFire(CurTime() + 60)
	
	if CLIENT then
		if self.Bar2TS <= CurTime() then
			self.Bar2Per = 0
			self.Bar2TS = CurTime() + 60
		end
	end
	
	if (!SERVER) then return end
	
	local ply = self.Owner
	local tr = ply:GetEyeTrace()
	
	if tr.Entity:IsPlayer() then
		tr.Entity.TempGodmode = true
		tr.Entity.TempGodmodeRemaining = 15
	end
	
	ply.TempGodmode = true
	ply.TempGodmodeRemaining = 15
	
	ply:EmitSound("ambient.electrical_zap_"..math.random(1,3),SNDLVL_40dB,100)
	
end


/*---------------------------------------------------------
   Name: ShouldDropOnDie
   Desc: Should this weapon be dropped when its owner dies?
---------------------------------------------------------*/
function SWEP:ShouldDropOnDie()
	return false
end

local color_gray = Color(0,0,0,150)
local color_white = Color(250,250,250,255)

function SWEP:DrawHUD()

	if (!CLIENT) then return end
	
	draw.RoundedBox(4,ScrW()-72,ScrH()-108,20,104,color_gray)
	draw.RoundedBox(4,ScrW()-50,ScrH()-108,20,104,color_gray)
	
	self.Bar2Per = 100-((math.Clamp(self.Bar2TS-CurTime(),0,60)/60)*100)
	self.Bar1Per = 100-((math.Clamp(self.Bar1TS-CurTime(),0,1)/1)*100)
	
	draw.RoundedBox(4,ScrW()-70,ScrH()-104+(100-self.Bar1Per),18,self.Bar1Per,color_white)
	draw.RoundedBox(4,ScrW()-48,ScrH()-104+(100-self.Bar2Per),18,self.Bar2Per,color_white)

end
