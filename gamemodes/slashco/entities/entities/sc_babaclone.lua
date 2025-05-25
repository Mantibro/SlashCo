AddCSLuaFile()

local SlashCo = SlashCo

ENT.Type = "anim"

ENT.ClassName 		= "sc_babaclone"
ENT.PrintName		= "babaclone"
ENT.Author			= "Manti"
ENT.Contact			= ""
ENT.Purpose			= "A Bababooey clone."
ENT.Instructions	= ""
ENT.PingType = "SLASHER"

ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "CloneTripped")
end

if SERVER then
	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end

	function ENT:Initialize()
		self:SetModel("models/slashco/slashers/baba/baba.mdl")
		self:SetMoveType(MOVETYPE_NONE)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(false)
		self:SetColor(color_transparent)
		self:SetRenderMode(RENDERMODE_TRANSALPHA)

		self:SetCloneTripped(false)

		timer.Simple(0.1, function()
			self:ResetSequence("prowl")
			self:SetPoseParameter("move_x", 1)
			self:SetPlaybackRate(2)
		end)
	end

	local offset = Vector(0, 0, 40)
	function ENT:Think()
		local entIndex = self:EntIndex()
		if not SlashCo.CurRound.SlasherEntities[entIndex] then
			self:Remove()
			return
		end
		
		local endPosTr = self:LocalToWorld(offset)
		endPosTr:Add(self:GetForward())
		endPosTr:Mult(1150)
		local tr = util.TraceLine({
			start = self:LocalToWorld(offset),
			endpos = endPosTr
		})
		
		local endPosGround = self:LocalToWorld(offset)
		endPosGround:Add(self:GetUp())
		endPosGround:Mult(-10000)
		local ground = util.TraceLine({
			start = self:LocalToWorld(offset),
			endpos = endPosGround
		})

		if tr.Entity:IsPlayer() and tr.Entity:Team() == TEAM_SURVIVOR and not self.activateWalk and SlashCo.CurRound.SlasherEntities[self:EntIndex()].activateSpook == false then
			self.activateWalk = true
			self:EmitSound("slashco/slasher/baba_reveal.mp3")
		end

		if self.activateWalk == true then
			if SlashCo.CurRound.SlasherEntities[entIndex].PostActivation == false then
				for s = 1, #team.GetPlayers(TEAM_SLASHER) do
					local sl = team.GetPlayers(TEAM_SLASHER)[s]
					sl:ChatPrint("A Bababooey Clone has been tripped!")
				end
			end

			SlashCo.CurRound.SlasherEntities[entIndex].PostActivation = true

			self:SetCloneTripped(true)

			self:DrawShadow(true)
			self:SetColor(color_white)
			self:SetRenderMode(RENDERMODE_TRANSCOLOR)
			self:SetNoDraw(false)

			self:SetPos(self:GetPos() + self:GetForward() * 2)
			self:SetPos(Vector(self:GetPos()[1],self:GetPos()[2],ground.HitPos[3]))

			local etr = util.TraceLine({
				start = self:LocalToWorld(offset),
				endpos = self:LocalToWorld(offset) + self:GetForward() * 30
			})

			if etr.Hit then table.RemoveByValue(SlashCo.CurRound.SlasherEntities, entIndex) self:Remove()  end
		elseif SlashCo.CurRound.SlasherEntities[entIndex].activateSpook == true then
			if SlashCo.CurRound.SlasherEntities[entIndex].PostActivation == false then
				for s = 1, #team.GetPlayers(TEAM_SLASHER) do
					local sl = team.GetPlayers(TEAM_SLASHER)[s]
					sl:ChatPrint("A Bababooey Clone has been tripped!")
				end
			end

			if SlashCo.CurRound.SlasherEntities[entIndex].PostActivation == true then return end

			self:SetCloneTripped(true)

			self:EmitSound("slashco/slasher/baba_reveal.mp3")

			self:EmitSound("slashco/slasher/baba_scare.mp3")
			self:DrawShadow(true)
			self:SetColor(color_white)
			self:SetRenderMode(RENDERMODE_TRANSCOLOR)
			self:SetNoDraw(false)
			self:ResetSequence("spook")
			self:SetPlaybackRate(2)

			SlashCo.CurRound.SlasherEntities[entIndex].PostActivation = true

			timer.Simple(1.75, function()
				table.RemoveByValue(SlashCo.CurRound.SlasherEntities, entIndex)
				self:Remove()
			end)
		end

		for i = 1, team.NumPlayers(TEAM_SURVIVOR) do
			local ply = team.GetPlayers(TEAM_SURVIVOR)[i]

			if ply:GetPos():Distance(self:GetPos()) < 150 then
				SlashCo.CurRound.SlasherEntities[entIndex].activateSpook = true
				self:SetAngles(Angle(0, (ply:GetPos() - self:GetPos()):Angle()[2], 0))
			end
		end

		self:NextThink(CurTime())
		return true
	end
else
	function ENT:Draw()
		self:DrawModel()
	end
end