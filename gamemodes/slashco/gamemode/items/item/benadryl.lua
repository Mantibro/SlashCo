local ITEM = SlashCoItems.Benadryl or {}
SlashCoItems.Benadryl = ITEM

ITEM.Model = "models/slashco/items/benadryl.mdl"
ITEM.Name = "25 gram Benadryl"
ITEM.EntClass = "sc_benadryl"
ITEM.Price = 60
ITEM.Description = "All new 25 gram Benadryl, made from 1200 pills."
ITEM.CamPos = Vector(50, 0, 0)
ITEM.ReplacesWorldProps = true
ITEM.OnDrop = function(ply)
    local droppeditem = SlashCo.CreateItem(ITEM.EntClass, ply:LocalToWorld(Vector(0, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):GetPhysicsObject():SetVelocity(ply:GetAimVector() * 250)
    SlashCo.CurRound.Items[droppeditem] = true
end
ITEM.OnUse = function(ply)

    ply:EmitSound("slashco/survivor/benadryl_eat.mp3")

    timer.Simple(60, function() 
        if IsValid( ply ) and ply:Team() == TEAM_SURVIVOR then
            ply:SetNWBool("SurvivorBenadryl", true)
        end

        timer.Simple(60, function() 
            if IsValid( ply ) and ply:Team() == TEAM_SURVIVOR then
                ply:SetNWBool("SurvivorBenadrylFull", true)
            end
        end)
    
        timer.Simple(480, function() 
            if IsValid( ply ) and ply:Team() == TEAM_SURVIVOR then
                ply:SetNWBool("SurvivorBenadrylFull", false)
            end
        end)
    
        timer.Simple(535, function() 
            if IsValid( ply ) and ply:Team() == TEAM_SURVIVOR then
                ply:SetNWBool("SurvivorBenadryl", false)
            end
        end)

    end)
end
ITEM.ViewModel = {
    model = ITEM.Model,
    pos = Vector(64, 0, -6),
    angle = Angle(180, 20, 90),
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
    pos = Vector(10, 2, 5),
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
    pos = Vector(1, 4.5, -1),
    angle = Angle(180, 0, 0),
    size = Vector(1, 1, 1),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}