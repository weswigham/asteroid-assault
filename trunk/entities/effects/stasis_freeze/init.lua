 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
 	 
 	// This is how long the spawn effect  
 	// takes from start to finish. 
 	self.Time = 10
 	self.LifeTime = CurTime() + self.Time 
	
	self.Ent = data:GetEntity()
	
	if not self.Ent or not self.Ent:IsValid() then return end
	self.emitter = ParticleEmitter( self.Ent:GetPos() )
		
	local particle = self.emitter:Add( "particles/blue_gas", self.Ent:GetPos()+Vector(0,0,20) )
	if (particle) then
		particle:SetVelocity( Vector(0,0,-1) * math.random(20, 30) )
		particle:SetLifeTime( 1 )
		particle:SetDieTime( math.random( 3, 4 ) )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 0 )
		particle:SetStartSize( 40 )
		particle:SetEndSize( 38 )
		particle:SetRoll( math.Rand(0, 360) )
		particle:SetRollDelta( math.Rand(-0.2, 0.2) )
		particle:SetColor( 255 , 255 , 255 )
	end
	self.emitter:Finish()

	if self.Entity then
		self.Entity:SetPos( self.Ent:GetPos() )  
	end
 end 
   
   
 /*--------------------------------------------------------- 
    THINK 
    Returning false makes the entity die 
 ---------------------------------------------------------*/ 
 function EFFECT:Think( ) 
   
 	return ( self.LifeTime > CurTime() )  
 	 
 end 
   
   
   
 /*--------------------------------------------------------- 
    Draw the effect 
 ---------------------------------------------------------*/ 
function EFFECT:Render() 

end  