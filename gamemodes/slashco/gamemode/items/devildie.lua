local SlashCoItems = SlashCoItems

SlashCoItems.DevilDie = {}
SlashCoItems.DevilDie.Model = "models/slashco/items/devildie.mdl"
SlashCoItems.DevilDie.Name = "Devil's Gamble"
SlashCoItems.DevilDie.Icon = "slashco/ui/icons/items/item_10"
SlashCoItems.DevilDie.Price = 40
SlashCoItems.DevilDie.Description = "A seemingly cursed die. \nUpon use, this item will grant you a random effect."
SlashCoItems.DevilDie.CamPos = Vector(30,0,10)
SlashCoItems.DevilDie.OnUse = function(ply)
    --[[

    Upon use, this item will apply a random effect from the set.
    -Spawn two Fuel Cans in front of the Survivor
    -Set their sprint speed to 450 for 45 seconds.
    -Heal the Survivor by 1-100
    -Damage the Survivor by 1-100
    -Teleport them 100u in front of the Slasher and hardlock their speed at 200 for 5 seconds.
    -Play a really loud sound which can be heard mapwide
    -Kill the Survivor

    ]]

    ply:EmitSound("slashco/survivor/devildie_roll.mp3")

    timer.Simple(2, function()

        ply:EmitSound("slashco/survivor/devildie_break.mp3")

        local rand = math.random(1, 6)

        if rand == 1 then

            SlashCo.CreateGasCan(ply:LocalToWorld(Vector(30, 20, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
            SlashCo.CreateGasCan(ply:LocalToWorld(Vector(30, -20, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
            SlashCo.BroadcastSelectables()

            ply:EmitSound("slashco/survivor/devildie_fuel.mp3")

        elseif rand == 2 then

            ply:SetRunSpeed(450)

            ply:EmitSound("slashco/survivor/devildie_speed.mp3")

            timer.Simple(45, function()

                ply:SetRunSpeed(300)

                ply:EmitSound("slashco/survivor/effectexpire_breath.mp3")

            end)

        elseif rand == 3 then

            local hpd = math.random(-100, 100)

            if hpd + ply:Health() > 200 then
                hpd = 200 - ply:Health()
            elseif hpd <= ply:Health() then
                hpd = (-ply:Health()) + 1
            end


            ply:SetHealth(ply:Health() + hpd)

            if hpd <= 0 then
                ply:EmitSound("slashco/survivor/devildie_hurt.mp3")

                local vPoint = ply:GetPos() + Vector(0, 0, 50)
                local bloodfx = EffectData()
                bloodfx:SetOrigin(vPoint)
                util.Effect("BloodImpact", bloodfx)
            end

            if hpd > 0 then
                ply:EmitSound("slashco/survivor/devildie_heal.mp3")

                local vPoint = ply:GetPos() + Vector(0, 0, 50)
                local healfx = EffectData()
                healfx:SetOrigin(vPoint)
                util.Effect("TeslaZap", healfx)
            end

        elseif rand == 4 then

            if #team.GetPlayers(TEAM_SLASHER) < 1 then
                return
            end

            local slasher = team.GetPlayers(TEAM_SLASHER)[1]

            ply:SetPos(slasher:LocalToWorld(Vector(100, 0, 10)))
            ply:SetRunSpeed(200)

            timer.Simple(5, function()
                ply:SetRunSpeed(300)
                ply:EmitSound("slashco/survivor/effectexpire_breath.mp3")
            end)

        elseif rand == 5 then

            PlayGlobalSound("slashco/survivor/devildie_siren.mp3", 96, ply)

        elseif rand == 6 then

            ply:EmitSound("slashco/survivor/devildie_kill.mp3")

            timer.Simple(0.5, function()
                local vPoint = ply:GetPos() + Vector(0, 0, 50)
                local killfx = EffectData()
                killfx:SetOrigin(vPoint)
                util.Effect("HelicopterImpact", killfx)

                ply:Kill()
            end)

        end

    end)
    
end
SlashCoItems.DevilDie.OnDrop = function(ply)
    local droppeditem = SlashCo.CreateItem("sc_devildie", ply:LocalToWorld(Vector(0, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):GetPhysicsObject():SetVelocity(ply:GetAimVector() * 250)
    SlashCo.CurRound.Items[droppeditem] = true
    SlashCo.MakeSelectable(droppeditem)
end
SlashCoItems.DevilDie.ViewModel = {
    model = "models/slashco/items/devildie.mdl",
    pos = Vector(64, 0, -6),
    angle = Angle(45, -70, -120),
    size = Vector(0.5, 0.5, 0.5),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}