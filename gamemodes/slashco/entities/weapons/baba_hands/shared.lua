SWEP.Author			= "Garry Newman"
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= "Left click spawns manhack, right click spawns Rollermine"
 
SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true
 
SWEP.ViewModel			= "models/slashco/slashers/baba/baba.mdl"
SWEP.WorldModel		= ""
 
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "none"
 
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"
 
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
 
	
 
end
 
/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
 
	
end

