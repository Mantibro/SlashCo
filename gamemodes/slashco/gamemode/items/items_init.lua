AddCSLuaFile()
AddCSLuaFile("baby.lua")
AddCSLuaFile("beacon.lua")
AddCSLuaFile("cookie.lua")
AddCSLuaFile("deathward.lua")
AddCSLuaFile("devildie.lua")
AddCSLuaFile("gascan.lua")
AddCSLuaFile("mayo.lua")
AddCSLuaFile("milkjug.lua")
AddCSLuaFile("soda.lua")
AddCSLuaFile("stepdecoy.lua")
AddCSLuaFile("deathward_used.lua")
AddCSLuaFile("battery.lua")
AddCSLuaFile("rock.lua")
AddCSLuaFile("pocketsand.lua")

if not SlashCoItems then SlashCoItems = {} end

include("baby.lua")
include("beacon.lua")
include("cookie.lua")
include("deathward.lua")
include("devildie.lua")
include("gascan.lua")
include("mayo.lua")
include("milkjug.lua")
include("soda.lua")
include("stepdecoy.lua")
include("deathward_used.lua")
include("battery.lua")
include("rock.lua")
include("pocketsand.lua")

--[[ all values for functions:
local SlashCoItems = SlashCoItems

SlashCoItems.NameMePlease = {}
SlashCoItems.NameMePlease.IsSecondary = false --optional, to let gascans and batteries not take up an item slot
SlashCoItems.NameMePlease.Model = ""
SlashCoItems.NameMePlease.Name = ""
SlashCoItems.NameMePlease.Icon = ""
SlashCoItems.NameMePlease.Price = 0 --don't include to remove from shop
SlashCoItems.NameMePlease.Description = "" --optional if price isn't included
SlashCoItems.NameMePlease.CamPos = Vector(0,0,0) --optional if price isn't included
SlashCoItems.NameMePlease.MaxAllowed = function() --optional, return the number of allowed items (runs clientside; don't use SlashCo)
    return 1
end
SlashCoItems.NameMePlease.DisplayColor = function(ply) --optional, color to display on the background of the name on player's hud (runs clientside; don't use SlashCo)
    return 0, 0, 128, 255
end
SlashCoItems.NameMePlease.OnUse = function(ply) --optional, when pressing r, return true to disable removing the item
end
SlashCoItems.NameMePlease.OnDrop = function(ply) --optional, when pressing q
end
SlashCoItems.NameMePlease.OnDie = function(ply) --optional, on death (return true to disable ticking down a life)
end
SlashCoItems.NameMePlease.OnPickUp = function(ply) --optional, when received
end
SlashCoItems.NameMePlease.OnBuy = function(plyid) --optional, when buying from lobby store
end
SlashCoItems.NameMePlease.OnSwitchFrom = function(ply) --optional, when item is removed without dropping (NOT called when item is dropped)
end
SlashCoItems.NameMePlease.EquipSound = function() --optional, string return of sound to play when equipping the item
end
SlashCoItems.NameMePlease.ViewModel = { --optional (i guess), use the SWEP construction kit on the workshop to help set this up
    model = "",
    pos = Vector(64, 0, -6),
    angle = Angle(45, -70, -120),
    size = Vector(0.5, 0.5, 0.5),
    color = Color(255, 255, 255, 255),
    surpresslightning = false, --this name is stupid but that's what the construction kit outputs so we're keeping it
    material = "",
    skin = 0,
    bodygroup = {}
}
--^IMPORTANT: The item display will ALWAYS place the item on "ValveBiped.Bip01_Spine4", with viewmodel set to "models/weapons/c_arms.mdl"
SlashCoItems.NameMePlease.WorldModel = {} --optional, similar to above but with choice of bone and holdtype
]]