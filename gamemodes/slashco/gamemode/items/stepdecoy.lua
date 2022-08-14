local SlashCo = SlashCo

SlashCo.Items.StepDecoy.Model = "models/props_lab/jar01a.mdl"
SlashCo.Items.StepDecoy.Name = "Step Decoy"
SlashCo.Items.StepDecoy.Icon = "slashco/ui/icons/items/item_6"
SlashCo.Items.StepDecoy.Price = 10
SlashCo.Items.StepDecoy.Description = "A worn, metallic boot. \nIf placed on a solid surface, it will imitate footsteps sounds which can\ndistract Slashers."
SlashCo.Items.StepDecoy.CamPos = Vector(50,0,20)
SlashCo.Items.StepDecoy.OnUse = function(ply)
    --Active Step Decoy

    local decoy = SlashCo.CreateItem("sc_stepdecoy", ply:LocalToWorld( Vector(10 , 0, 5) ) , ply:LocalToWorldAngles( Angle(0,0,0) ))

    Entity( decoy ):SetNWBool("StepDecoyActive", true)
end
SlashCo.Items.StepDecoy.OnDrop = function(ply)
    local droppeditem = SlashCo.CreateItem("sc_stepdecoy", ply:LocalToWorld(Vector(30, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):GetPhysicsObject():ApplyForceCenter(ply:GetAimVector() * 250)
end