 local Laser = Material( "cable/redlaser" )
 
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
 	 
 end 
   
   
 /*--------------------------------------------------------- 
    THINK 
    Returning false makes the entity die 
 ---------------------------------------------------------*/ 
 function EFFECT:Think( ) 
   
    self:SetPos(LocalPlayer():GetPos())
 	return true
 	 
 end 
   
   
   
 /*--------------------------------------------------------- 
    Draw the effect 
 ---------------------------------------------------------*/ 
function EFFECT:Render() 
	if LocalPlayer():Alive() and LocalPlayer().LaserSights and GetGlobalInt("armeggadon") > 1 then
		render.SetMaterial( Laser )
		local wep = LocalPlayer():GetViewModel()
		if wep and wep:IsValid() and wep:LookupAttachment("muzzle") and wep:GetAttachment(wep:LookupAttachment("muzzle")) then
			local pos = wep:GetAttachment(wep:LookupAttachment("muzzle")).Pos
			render.DrawBeam( pos, LocalPlayer():GetEyeTrace().HitPos, 2, 0, 12.5, Color( 255, 0, 0, 255 ) )
		end
	end
end  

