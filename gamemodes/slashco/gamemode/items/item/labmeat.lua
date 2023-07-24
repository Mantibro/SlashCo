local ITEM = SlashCoItems.LabMeat or {}
SlashCoItems.LabMeat = ITEM

ITEM.Model = "models/slashco/items/labmeat.mdl"
ITEM.Name = "Lab-Grown Meat"
ITEM.EntClass = "sc_labmeat"
ITEM.Price = 35
ITEM.Description = "Now cleared for sale in the United States! Is it worth it?"
ITEM.CamPos = Vector(50, 0, 0)
ITEM.ReplacesWorldProps = true
ITEM.IsSpawnable = true
ITEM.OnDrop = function(ply)
    local droppeditem = SlashCo.CreateItem(ITEM.EntClass, ply:LocalToWorld(Vector(0, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))

    local physCount = Entity(droppeditem).ragdoll:GetPhysicsObjectCount()
    for i = 0, (physCount - 1) do
        local PhysBone = Entity(droppeditem).ragdoll:GetPhysicsObjectNum(i)

        if PhysBone:IsValid() then
            PhysBone:SetVelocity( ply:GetAimVector() * 150 )
            PhysBone:AddAngleVelocity( VectorRand( -5, 5 ) )
        end
    end

    SlashCo.CurRound.Items[droppeditem] = true
end
ITEM.OnUse = function(ply)

    ply:EmitSound("slashco/survivor/benadryl_eat.mp3")
    ply:EmitSound("slashco/slasher/amogus_transform"..math.random(1,2)..".mp3")

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
    bone = "ValveBiped.Bip01_Head",
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