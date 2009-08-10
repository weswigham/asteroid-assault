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
   
 	return true
 	 
 end 
   
   
   
 /*--------------------------------------------------------- 
    Draw the effect 
 ---------------------------------------------------------*/ 
function EFFECT:Render() 
	if LocalPlayer():Alive() and LocalPlayer().LaserSights and GetGlobalInt("armeggadon") > 1 then
		render.SetMaterial( Laser )
		local wep = LocalPlayer():GetActiveWeapon()
		if wep and wep:IsValid() then
			local pos = wep:GetAttachment(wep:LookupAttachment("muzzle")).Pos
			local tr = util.QuickTrace(pos,LocalPlayer():GetAimVector()*26000,{wep,LocalPlayer()})
			render.DrawBeam( pos, tr.HitPos, 55, 0, 0, Color( 255, 255, 255, 255 ) )
		end
	end
end  