local ITEM = SlashCoItems.Brick or {}
SlashCoItems.Brick = ITEM

ITEM.Model = "models/props_junk/cinderblock01a.mdl"
ITEM.Name = "Cinder Block"
ITEM.EntClass = "sc_brick"
ITEM.Price = 5
ITEM.Description = "Just some cinder block we found, nothing special. Can be thrown."
ITEM.CamPos = Vector(50, 0, 0)
ITEM.ReplacesWorldProps = true
ITEM.OnDrop = function(ply)
    local droppeditem = SlashCo.CreateItem(ITEM.EntClass, ply:LocalToWorld(Vector(0, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):GetPhysicsObject():SetVelocity(ply:GetAimVector() * 250)
    SlashCo.CurRound.Items[droppeditem] = true
end
ITEM.OnUse = function(ply)
    ply:EmitSound("Weapon_Crowbar.Miss")
    local droppeditem = SlashCo.CreateItem(ITEM.EntClass, ply:LocalToWorld(Vector(0, 0, 60)), ply:LocalToWorldAngles(Angle(0, 0, 0)))
    Entity(droppeditem):GetPhysicsObject():SetVelocity(ply:GetAimVector() * 1500)
    SlashCo.CurRound.Items[droppeditem] = true

    Entity(droppeditem):SetCollisionGroup(COLLISION_GROUP_NONE)
    Entity(droppeditem):SetCustomCollisionCheck(true)
    timer.Simple(3, function()
        if not IsValid(Entity(droppeditem)) then
            return
        end
        Entity(droppeditem):SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    end)
end
ITEM.ViewModel = {
    model = ITEM.Model,
    pos = Vector(64, 0, -6),
    angle = Angle(45, -70, -120),
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