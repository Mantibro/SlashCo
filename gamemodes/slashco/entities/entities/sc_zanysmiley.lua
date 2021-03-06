AddCSLuaFile()

local SlashCo = SlashCo

ENT.Base 			= "base_nextbot"
ENT.Type			= "nextbot"
ENT.ClassName 		= "sc_zanysmiley"
ENT.Spawnable		= true

function ENT:Initialize()

	self:SetModel( "models/Humans/Group01/male_07.mdl" )

	self.CollideSwitch = 3

	self.LoseTargetDist	= 2000	-- How far the enemy has to be before we lose them
	self.SearchRadius 	= 3000	-- How far to search for enemies

end

----------------------------------------------------
-- ENT:Get/SetEnemy()
-- Simple functions used in keeping our enemy saved
----------------------------------------------------
function ENT:SetEnemy(ent)
	self.Enemy = ent
end
function ENT:GetEnemy()
	return self.Enemy
end

----------------------------------------------------
-- ENT:HaveEnemy()
-- Returns true if we have an enemy
----------------------------------------------------
function ENT:HaveEnemy()
	-- If our current enemy is valid
	if ( self:GetEnemy() and IsValid(self:GetEnemy()) ) then
		-- If the enemy is too far
		if ( self:GetRangeTo(self:GetEnemy():GetPos()) > self.LoseTargetDist ) then
			-- If the enemy is lost then call FindEnemy() to look for a new one
			-- FindEnemy() will return true if an enemy is found, making this function return true
			return self:FindEnemy()
		-- If the enemy is dead( we have to check if its a player before we use Alive() )
		elseif ( self:GetEnemy():IsPlayer() and !self:GetEnemy():Alive() ) then
			return self:FindEnemy()		-- Return false if the search finds nothing
		end	
		-- The enemy is neither too far nor too dead so we can return true
		return true
	else
		-- The enemy isn't valid so lets look for a new one
		return self:FindEnemy()
	end
end

----------------------------------------------------
-- ENT:FindEnemy()
-- Returns true and sets our enemy if we find one
----------------------------------------------------
function ENT:FindEnemy()
	-- Search around us for entities
	-- This can be done any way you want eg. ents.FindInCone() to replicate eyesight
	local _ents = ents.FindInSphere( self:GetPos(), self.SearchRadius )
	-- Here we loop through every entity the above search finds and see if it's the one we want
	for k,v in ipairs( _ents ) do
		if ( v:IsPlayer() and v:Team() == TEAM_SURVIVOR ) then
			-- We found one so lets set it as our enemy and return true
			local tr = util.TraceLine( {
				start = self:GetPos()+Vector(0,0,60),
				endpos = v:GetPos()+Vector(0,0,60),
				filter = self
			} )
			if tr.Entity == v then
				self:SetEnemy(v)
				return true
			end
		end
	end	
	-- We found nothing so we will set our enemy as nil (nothing) and return false
	self:SetEnemy(nil)
	return false
end




function ENT:RunBehaviour()

	while ( true ) do
		-- Lets use the above mentioned functions to see if we have/can find a enemy
		if ( self:HaveEnemy() ) then
			-- Now that we have a enemy, the code in this block will run
			self.loco:FaceTowards(self:GetEnemy():GetPos())	-- Face our enemy
			self:StartActivity( ACT_WALK )			-- Set the animation
			self.loco:SetDesiredSpeed( 400 )		-- Set the speed that we will be moving at. Don't worry, the animation will speed up/slow down to match
			self.loco:SetAcceleration(900)			-- We are going to run at the enemy quickly, so we want to accelerate really fast
			self:ChaseEnemy( ) 						-- The new function like MoveToPos that will be looked at soon.
			self.loco:SetAcceleration(400)			-- Set this back to its default since we are done chasing the enemy
			self:StartActivity( ACT_IDLE )			--We are done so go back to idle
			-- Now once the above function is finished doing what it needs to do, the code will loop back to the start
			-- unless you put stuff after the if statement. Then that will be run before it loops
		else
			-- Since we can't find an enemy, lets wander
			-- Its the same code used in Garry's test bot
			self:StartActivity( ACT_WALK )			-- Walk anmimation
			self.loco:SetDesiredSpeed( 50 )		-- Walk speed
			self:MoveToPos( SlashCo.TraceHullLocator() ) -- Walk to a random place within about 400 units (yielding)
			self:StartActivity( ACT_IDLE )
		end
		-- At this point in the code the bot has stopped chasing the player or finished walking to a random spot
		-- Using this next function we are going to wait 2 seconds until we go ahead and repeat it 
		coroutine.wait(math.Rand( 0, 6 ))
		
	end

end

function ENT:ChaseEnemy( options )

	local options = options or {}
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, self:GetEnemy():GetPos() )		-- Compute the path towards the enemy's position

	if ( !path:IsValid() ) then return "failed" end

	while ( path:IsValid() and self:HaveEnemy() ) do
	
		if ( path:GetAge() > 0.1 ) then					-- Since we are following the player we have to constantly remake the path
			path:Compute(self, self:GetEnemy():GetPos())-- Compute the path towards the enemy's position again
		end
		path:Update( self )								-- This function moves the bot along the path
		
		if ( options.draw ) then path:Draw() end
		-- If we're stuck then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end

		coroutine.yield()

	end

	return "ok"

end

function ENT:Think()

	if SERVER then

		if self.CollideSwitch > 0 then
			self:SetNotSolid(true)
			self.CollideSwitch = self.CollideSwitch - FrameTime()
		else
			self:SetNotSolid(false)
		end

		local tr = util.TraceLine( {
			start = self:GetPos() + Vector(0,0,50),
			endpos = self:GetPos() + self:GetForward() * 10000,
			filter = self
		} )

		if tr.Entity:GetClass() == "prop_door_rotating" then

			if self:GetPos():Distance( tr.Entity:GetPos() ) > 150 then return end

			tr.Entity:Fire("Open")

		end

	end

end

--[[function ENT:Use( activator )

	if SERVER then


	end

end]]

function ENT:UpdateTransmitState()	
	return TRANSMIT_ALWAYS 
end

if CLIENT then
    function ENT:Draw()
		self:DrawModel()
	end
end