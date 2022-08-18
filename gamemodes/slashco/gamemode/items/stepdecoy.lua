local SlashCoItems = SlashCoItems

SlashCoItems.StepDecoy = {}
SlashCoItems.StepDecoy.Model = "models/props_junk/Shoe001a.mdl"
SlashCoItems.StepDecoy.Name = "Step Decoy"
SlashCoItems.StepDecoy.Icon = "slashco/ui/icons/items/item_6"
SlashCoItems.StepDecoy.Price = 10
SlashCoItems.StepDecoy.Description = "A worn, metallic boot. \nIf placed on a solid surface, it will imitate footsteps sounds which can\ndistract Slashers."
SlashCoItems.StepDecoy.CamPos = Vector(50,0,20)
SlashCoItems.StepDecoy.OnUse = function(ply)
    --Active Step Decoy

    local decoy = SlashCo.CreateItem("sc_stepdecoy", ply:LocalToWorld( Vector(0, 0, 30) ) , ply:LocalToWorldAngles( Angle(0,0,0) ))
    Entity(decoy):DropToFloor()
    Entity( decoy ):SetNWBool("StepDecoyActive", true)
    SlashCo.CurRound.Items[decoy] = true
    SlashCo.MakeSelectable(decoy)
end
SlashCoItems.StepDecoy.OnDrop = function(ply)
    local droppeditem = SlashCo.CreateItem("sc_stepdecoy", ply:LocalToWorld(Vector(0, 0, 30)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):DropToFloor()
    --Entity(droppeditem):GetPhysicsObject():ApplyForceCenter(ply:GetAimVector() * 250)
    SlashCo.CurRound.Items[droppeditem] = true
    SlashCo.MakeSelectable(droppeditem)
end
SlashCoItems.StepDecoy.ViewModel = {
    model = "models/props_junk/Shoe001a.mdl",
    pos = Vector(65, 0, -5),
    angle = Angle(120, -120, -80),
    size = Vector(0.5, 0.5, 0.5),
    color = Color(255, 255, 255, 255),
    surpresslightning = false,
    material = "",
    skin = 0,
    bodygroup = {}
}
