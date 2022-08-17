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

    local decoy = SlashCo.CreateItem("sc_stepdecoy", ply:LocalToWorld( Vector(10 , 0, 5) ) , ply:LocalToWorldAngles( Angle(0,0,0) ))
    Entity( decoy ):SetNWBool("StepDecoyActive", true)
    SlashCo.CurRound.Items[decoy] = true
    SlashCo.MakeSelectable(decoy)
end
SlashCoItems.StepDecoy.OnDrop = function(ply)
    local droppeditem = SlashCo.CreateItem("sc_stepdecoy", ply:LocalToWorld(Vector(30, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):DropToFloor()
    --Entity(droppeditem):GetPhysicsObject():ApplyForceCenter(ply:GetAimVector() * 250)
    SlashCo.CurRound.Items[droppeditem] = true
    SlashCo.MakeSelectable(droppeditem)
end