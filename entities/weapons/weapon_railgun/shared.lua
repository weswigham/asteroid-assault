
SWEP.Author			= "Levybreak"
SWEP.Contact		= "Facepunch"
SWEP.Purpose		= "Yea, muthafucka! Railgunz iz gunna burn a hola through ya!"
SWEP.Instructions	= "Shoot to destroy."

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.ViewModel			= "models/weapons/v_rpg.mdl"
SWEP.WorldModel			= "models/Weapons/w_rocket_launcher.mdl"


SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 0
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= 0
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.HoldType = "rpg"

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
local BoxSize = Vector(20,20,20)
local MaxHits = 7

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		if CLIENT then
			if self.Bar1TS <= CurTime() then
				self.Bar1Per = 0
				self.Bar1TS = CurTime() + 0.5
			end
		end
		
		if (!SERVER) then return end
		
		GAMEMODE:SetPlayerAnimation( self.Owner, PLAYER_ATTACK1 )
		self.Owner:EmitSound("PropJeep.FireChargedCannon",SNDLVL_20dB,100)
		
		local ply = self.Owner
		
		local data = EffectData()
		local wep = ply:GetViewModel()
		local pos = Vector()
		if wep and wep:IsValid() and wep:LookupBone("muzzle") and wep:GetBonePosition(wep:LookupBone("muzzle")) then
			pos,ang = wep:GetBonePosition(wep:LookupBone("muzzle"))
			print(pos)
			local vect = ply:OBBMaxs()
			pos=pos+Vector(0,0,vect.z-7)
		end
		local ang = ply:GetAimVector():Angle()
		
		for k,v in ipairs(player.GetAll()) do
		v:SendLua([[
		local data = EffectData()
		data:SetOrigin(Vector(]]..pos.x..","..pos.y..","..pos.z..[[))
		data:SetAngle(Angle(]]..ang.p..","..ang.y..","..ang.r..[[))
		util.Effect("railgun_shot",data)]])
		end
		
		
		local pos = ply:GetShootPos()
		local ang = ply:GetAimVector()
		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos+(ang*10000)
		tracedata.filter = ply
		tracedata.mins = BoxSize*-1
		tracedata.maxs = BoxSize
		local trace = util.TraceHull(tracedata)
		
		local HitEnts = {}
		if trace.Entity then
			table.insert(HitEnts,trace.Entity)
		end
		
		for i=1,(MaxHits-1) do
			tracedata = {}
			tracedata.start = trace.HitPos
			tracedata.endpos = trace.HitPos+(ang*10000)
			tracedata.filter = {ply,unpack(HitEnts)}
			tracedata.mins = BoxSize*-1
			tracedata.maxs = BoxSize
			trace = util.TraceHull(tracedata)
			if trace.Entity then
				table.insert(HitEnts,trace.Entity)
			end
		end
		
		for k,v in ipairs(HitEnts) do
			if v:IsValid() and v:GetClass() == "asteroid" then
				v:TakeDamage(100,self.Owner,self) --2 shot normal roids, 1 shot small ones, just like the magnum, I think.
			end
		end
end

local function SupahFireScreenWhiteness() 
 
	if LocalPlayer().BlindingLight then  
		local tab = {} 
		tab[ "$pp_colour_addr" ] = LocalPlayer().BlindingLight 
		tab[ "$pp_colour_addg" ] = LocalPlayer().BlindingLight 
		tab[ "$pp_colour_addb" ] = LocalPlayer().BlindingLight 
		tab[ "$pp_colour_brightness" ] = 0 
		tab[ "$pp_colour_contrast" ] = 1 
		tab[ "$pp_colour_colour" ] = 1 
		tab[ "$pp_colour_mulr" ] = 0 
		tab[ "$pp_colour_mulg" ] = 0 
		tab[ "$pp_colour_mulb" ] = 0 
 
		DrawColorModify( tab ) 
		LocalPlayer().BlindingLight = math.Clamp(LocalPlayer().BlindingLight-0.05,0,1) 
	end 
end 
hook.Add( "RenderScreenspaceEffects", "SupahFireScreenWhiteness", SupahFireScreenWhiteness ) 


/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	
	self.Weapon:SetNextSecondaryFire(CurTime() + 45)
	
	if CLIENT then
		if self.Bar2TS <= CurTime() then
			self.Bar2Per = 0
			self.Bar2TS = CurTime() + 45
			timer.Simple(1,function() LocalPlayer().BlindingLight = 1 end)
			timer.Simple(3,function() LocalPlayer().BlindingLight = nil end)
		end
	end
	
	if (!SERVER) then return end
	GAMEMODE:SetPlayerAnimation( self.Owner, PLAYER_ATTACK1 )
	self.Owner:EmitSound(Sound("railgun\\capacitor_overload.mp3"),SNDLVL_GUNFIRE,100)
	self.Owner:Lock()
	timer.Simple(3,function() self.Owner:UnLock() hook.Remove("Think",self.Owner:Nick().."ScreenShake") end)
	hook.Add("Think",self.Owner:Nick().."ScreenShake",function() self.Owner:ViewPunch(Angle(math.Rand(-0.5,0.5),math.Rand(-0.5,0.5),math.Rand(-0.5,0.5))) end)
	
	timer.Simple(1,function()
		local MaxDist = 1500
		
		local ply = self.Owner
		
		local tbl = ents.FindInCone(ply:GetShootPos(),ply:GetAimVector(),MaxDist,70)
		
		local data = EffectData()
		local wep = ply:GetViewModel()
		local pos = Vector()
		if wep and wep:IsValid() and wep:LookupBone("muzzle") and wep:GetBonePosition(wep:LookupBone("muzzle")) then
			pos,ang = wep:GetBonePosition(wep:LookupBone("muzzle"))
			print(pos)
			local vect = ply:OBBMaxs()
			pos=pos+Vector(0,0,vect.z-7)
		end
		local ang = ply:GetAimVector():Angle()
		
		for k,v in ipairs(player.GetAll()) do
		v:SendLua([[
		local data = EffectData()
		data:SetOrigin(Vector(]]..pos.x..","..pos.y..","..pos.z..[[))
		data:SetAngle(Angle(]]..ang.p..","..ang.y..","..ang.r..[[))
		util.Effect("railgun_burst",data)]])
		end
		
		for k,v in ipairs(tbl) do
			if v:IsValid() and v:IsPlayer() then --I'm a lazy mofo
				v:SendLua("LocalPlayer().BlindingLight = 1 timer.Simple(2,function() LocalPlayer().BlindingLight = nil end)")
			elseif v:IsValid() and v:GetClass() == "asteroid" then
				local MaxDamage = 1000
				local dist = self.Owner:GetShootPos():Distance(v:GetPos())
				if dist < 500 then
					v:TakeDamage(MaxDamage,self.Owner,self)
				else
					v:TakeDamage(MaxDamage*(1-(dist/MaxDist)),self.Owner,self)
				end
			end
		end
	end)
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
	
	self.Bar2Per = 100-((math.Clamp(self.Bar2TS-CurTime(),0,45)/45)*100)
	self.Bar1Per = 100-((math.Clamp(self.Bar1TS-CurTime(),0,0.5)/0.5)*100)
	
	draw.RoundedBox(4,ScrW()-70,ScrH()-104+(100-self.Bar1Per),18,self.Bar1Per,color_white)
	draw.RoundedBox(4,ScrW()-48,ScrH()-104+(100-self.Bar2Per),18,self.Bar2Per,color_white)

end
