 local Laser = Material("effects/energysplash")

 function EFFECT:Init( data )
	

	self.Pos = data:GetOrigin()
	self.Ang = data:GetAngle()
	
	local tbl = {}
	table.Add(ents.GetAll(),tbl)
	table.Add(player.GetAll(),tbl)
	
	self.tr = util.QuickTrace(self.Pos,self.Ang:Forward()*10000,tbl)
	self.Entity:SetRenderBounds( self.Pos-(Vector()*-100), self.tr.HitPos )
	local Lifetime = 1
	
	self.EndTime = CurTime() + Lifetime
	
	self.Entity:SetPos(LocalPlayer():GetShootPos())

end


/*---------------------------------------------------------
   THINK
   Returning false makes the entity die
---------------------------------------------------------*/
function EFFECT:Think( )
	

	if CurTime() >= self.EndTime then return false end

	return true
	
end


/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()

	local frac = math.Clamp((self.EndTime-CurTime())/2,0,1)
	render.SetMaterial( Laser )
	
	render.DrawBeam( self.Pos, self.tr.HitPos, 40*frac, 0.5, 0.7, Color(255,255,255,(255*frac)) )

end 