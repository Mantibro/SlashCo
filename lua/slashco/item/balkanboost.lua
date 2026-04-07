local ITEM = {}

ITEM.Model = "models/slashco/items/BalkanBoost.mdl"
ITEM.EntClass = "sc_balkanboost"
ITEM.Name = "BalkanBoost"
ITEM.Icon = "slashco/ui/icons/items/item_20"
ITEM.Price = 100
ITEM.Description = "BalkanBoost_desc"
ITEM.CamPos = Vector(50, 0, 0)
ITEM.IsSpawnable = false

function ITEM.DisplayColor()
	return 232, 23, 55, 255
end

function ITEM.MaxAllowed()
	return 4
end

function ITEM.OnUse(ply)
	-- RaphaelIT7: Disallow balkan stacking
	if ply:GetNWBool("SurvivorBalkan") then
		return true
	end

	SlashCo.AudioSystem.PlaySound({
		soundPath = "slashco/survivor/balkan_eat.wav",
		identifier = "BalkanEat",
		minDistance = 250,
		maxDistance = 550,
		entity = ply,
		volume = 1,
		fadeIn = 0,
	})

	ply:SetNWBool("SurvivorBalkan", true)
	ply:AddEffect("Slowness", 31.5)

	timer.Create("BalkanBoostStart:" .. ply:UserID(), 32, 1, function()
		if IsValid(ply) and ply:Team() == TEAM_SURVIVOR then
			ply:SetNWBool("SurvivorBalkanFull", true)
			ply:SetNWBool("MarkedBySmiley", true)
			ply:AddEffect("BalkanTrip", 132)
		end
	end)
		
	timer.Create("BalkanBoostFinish:" .. ply:UserID(), 164, 1, function()
		if IsValid(ply) and ply:Team() == TEAM_SURVIVOR then
			ply:SetNWBool("SurvivorBalkanFull", false)
			ply:SetNWBool("SurvivorBalkan", false)
			ply:SetNWBool("MarkedBySmiley", false)
			ply:AddEffect("Slowness", 9999)
			local hpafter = ply:Health() / 6
			ply:SetHealth(hpafter)
		end
	end)
end

ITEM.ViewModel = {
	model = ITEM.Model,
	pos = Vector(64, 0, -6),
	angle = Angle(-40, -90, -120),
	size = Vector(0.5, 0.5, 0.5),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}
ITEM.WorldModelHolstered = {
	model = ITEM.Model,
	bone = "ValveBiped.Bip01_Pelvis",
	pos = Vector(5, 2, 5),
	angle = Angle(110, -80, 0),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}
ITEM.WorldModel = {
	holdtype = "slam",
	model = ITEM.Model,
	bone = "ValveBiped.Bip01_R_Hand",
	pos = Vector(3, 2.5, -1),
	angle = Angle(180, -50, 0),
	size = Vector(1, 1, 1),
	color = color_white,
	surpresslightning = false,
	material = "",
	skin = 0,
	bodygroup = {}
}

SlashCo.RegisterItem(ITEM, "BalkanBoost")

if SERVER then
	hook.Add("PlayerChangedTeam", "SlashCo:BalkanBoost", function(ply)
		ply:SetNWBool("SurvivorBalkan", false)
		ply:SetNWBool("SurvivorBalkanFull", false)
		ply:SetNWBool("MarkedBySmiley", false)
	end)

	hook.Add("SlashCo:OnDeathWardUsed", "SlashCo:CancelBalkanBoost", function(ply)
		timer.Remove("BalkanBoostStart:" .. ply:UserID())
		timer.Remove("BalkanBoostFinish:" .. ply:UserID())

		ply:SetNWBool("SurvivorBalkan", false)
		ply:SetNWBool("SurvivorBalkanFull", false)
		ply:SetNWBool("MarkedBySmiley", false)
	end)

	return
end

hook.Add("RenderScreenspaceEffects", "SlashCo:BalkanBoost", function()
	if GameData.LocalPlayer:GetNWBool("SurvivorBalkanFull") then
		local tab = {
			["$pp_colour_addr"] = 0.07,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 2,
			["$pp_colour_colour"] = 4,
			["$pp_colour_mulr"] = 0.07,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		}

		DrawColorModify(tab)
	end
end)

hook.Add("Think", "SlashCo:BalkanBoost", function()
	if GameData.LocalPlayer:GetNWBool("SurvivorBalkan") then
		if not IsValid(GameData.BalkanSound) and CurTime() > ((GameData.BalkanSoundLastCreation or 0) + 5) then
			SlashCo.AudioSystem.PlaySound({
				soundPath = "slashco/balkan_icantstopnow.mp3",
				identifier = "BalkanBoost",
				entity = GameData.LocalPlayer,
				volume = 3,
				fadeIn = 0,
				forceStereo = true,
				modifyGroup = "BackgroundMusic",
				modifyGroupVolumeMult = 0, -- Silence background music while were playing
				modifyGroupVolumeFadeTime = 3,
				callback = function(channel)
					GameData.BalkanSound = channel

					-- RaphaelIT7: I did not yet implement modifyGroupVolumeFadeTime so hacky workaround till then.
					if IsValid(SlashCo.AudioSystem.BackgroundChannel) then
						SlashCo.AudioSystem.FadeToVolume(SlashCo.AudioSystem.BackgroundChannel, 3, 0)
					end
				end
			})

			GameData.BalkanSoundLastCreation = CurTime()
		end
	elseif IsValid(GameData.BalkanSound) then
		SlashCo.AudioSystem.DestroyChannel(GameData.BalkanSound, 1)
	end
end)