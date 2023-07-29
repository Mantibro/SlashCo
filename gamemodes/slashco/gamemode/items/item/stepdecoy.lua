local SlashCoItems = SlashCoItems

SlashCoItems.StepDecoy = SlashCoItems.StepDecoy or {}
SlashCoItems.StepDecoy.Model = "models/props_junk/Shoe001a.mdl"
SlashCoItems.StepDecoy.Name = "StepDecoy"
SlashCoItems.StepDecoy.EntClass = "sc_stepdecoy"
SlashCoItems.StepDecoy.Icon = "slashco/ui/icons/items/item_6"
SlashCoItems.StepDecoy.Price = 10
SlashCoItems.StepDecoy.Description = "StepDecoy_desc"
SlashCoItems.StepDecoy.CamPos = Vector(50,0,20)
SlashCoItems.StepDecoy.IsSpawnable = true
SlashCoItems.StepDecoy.OnUse = function(ply)
    --Active Step Decoy

    local decoy = SlashCo.CreateItem("sc_stepdecoy", ply:LocalToWorld( Vector(0, 0, 30) ) , ply:LocalToWorldAngles( Angle(0,0,0) ))
    Entity(decoy):DropToFloor()
    Entity( decoy ):SetNWBool("StepDecoyActive", true)
    SlashCo.CurRound.Items[decoy] = true
end
SlashCoItems.StepDecoy.OnDrop = function(ply)
    return 30, nil, true
end
SlashCoItems.StepDecoy.ItemDropped = function(_, itemEnt)
    itemEnt:DropToFloor()
end

SlashCoItems.StepDecoy.ViewModel = {
    model = "models/props_junk/Shoe001a.mdl",
    pos = Vector(65, 0, -5),
    angle = Angle(120, -120, -80),
    size = Vector(0.5, 0.5, 0.5),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
SlashCoItems.StepDecoy.WorldModelHolstered = {
    model = "models/props_junk/Shoe001a.mdl",
    bone = "ValveBiped.Bip01_R_Foot",
    pos = Vector(2.5, 3, -0.2),
    angle = Angle(0, -33, 90),
    size = Vector(1.3, 1.3, 1.3),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
SlashCoItems.StepDecoy.WorldModel = {
    holdtype = "slam",
    model = "models/props_junk/Shoe001a.mdl",
    bone = "ValveBiped.Bip01_R_Hand",
    pos = Vector(4, 6, -1),
    angle = Angle(180, 90, 0),
    size = Vector(1, 1, 1),
    color = color_white,
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}