AddCSLuaFile()

local SlashCo = SlashCo

ENT.Base 			= "base_nextbot"
ENT.Type			= "nextbot"
ENT.ClassName 		= "sc_maleclone"
ENT.Spawnable		= true

function ENT:Initialize()

	self:SetModel( "models/Humans/Group01/male_07.mdl" )

	self.CollideSwitch = 3

end

function ENT:RunBehaviour()

	while ( true ) do							-- Here is the loop, it will run forever

		self:StartActivity( ACT_WALK )			-- Walk anmimation
		self.loco:SetDesiredSpeed( 100 )		-- Walk speed
		self:MoveToPos( SlashCo.TraceHullLocator() ) -- Walk to a random place 
		self:StartActivity( ACT_IDLE )

		coroutine.wait(math.Rand( 0, 35 ))						

		coroutine.yield()
		-- The function is done here, but will start back at the top of the loop and make the bot walk somewhere else

		if self:GetPos()[3] < -2000 then 

			self:Remove()

			SlashCo.CreateItem("sc_maleclone", SlashCo.TraceHullLocator(), Angle(0,0,0))

		end
	end

end

function ENT:Think()

	if SERVER then

		if self.CollideSwitch > 0 then
			self:SetNotSolid(true)
			self.CollideSwitch = self.CollideSwitch - FrameTime()
		else
			self:SetNotSolid(false)
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