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

--[[ all values for functions:
local SlashCoItems = SlashCoItems

SlashCoItems.NameMePlease = {}
SlashCoItems.NameMePlease.Model = ""
SlashCoItems.NameMePlease.Name = ""
SlashCoItems.NameMePlease.Icon = ""
SlashCoItems.NameMePlease.Price = 0 --don't include to remove from shop
SlashCoItems.NameMePlease.Description = "" --optional if price isn't included
SlashCoItems.NameMePlease.CamPos = Vector(0,0,0) --optional if price isn't included
SlashCoItems.NameMePlease.MaxAllowed = function() --optional, return the number of allowed items
    return 1
end
SlashCoItems.NameMePlease.OnUse = function(ply) --optional, when pressing r
end
SlashCoItems.NameMePlease.OnDrop = function(ply) --optional, when pressing q
end
SlashCoItems.NameMePlease.OnDie = function(ply) --optional, on death (return true to disable ticking down a life)
end
SlashCoItems.NameMePlease.OnPickUp = function(ply) --optional, when received
end
SlashCoItems.NameMePlease.OnBuy = function(plyid) --optional, when buying from lobby store
end
]]