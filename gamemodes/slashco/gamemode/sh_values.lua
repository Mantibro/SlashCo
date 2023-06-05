AddCSLuaFile()
SlashCo = SlashCo or {}

local typeWrite = {
    string = function(val)
        net.WriteString("string")
        net.WriteString(val)
    end,
    number = function(val)
        net.WriteString("number")
        net.WriteDouble(val)
    end,
    vector = function(val)
        net.WriteString("vector")
        net.WriteVector(val)
    end,
    color = function(val)
        net.WriteString("color")
        net.WriteColor(val)
    end,
    angle = function(val)
        net.WriteString("angle")
        net.WriteAngle(val)
    end,
    entity = function(val)
        net.WriteString("entity")
        net.WriteEntity(val)
    end
}

local typeRead = {
    string = function(val)
        table.insert(val, net.ReadString())
    end,
    number = function(val)
        table.insert(val, net.ReadDouble())
    end,
    vector = function(val)
        table.insert(val, net.ReadVector())
    end,
    color = function(val)
        table.insert(val, net.ReadColor())
    end,
    angle = function(val)
        table.insert(val, net.ReadAngle())
    end,
    entity = function(val)
        table.insert(val, net.ReadEntity())
    end
}

if SERVER then
    util.AddNetworkString("slashCoValue")

    function SlashCo.SendValue(ply, message, ...)
        net.Start("slashCoValue")
        net.WriteString(message)

        local valAmount = #{...}
        net.WriteUInt(valAmount, 8)
        if valAmount > 0 then
            for _, v in ipairs({...}) do
                typeWrite[type(v)](v)
            end
        end

        if not ply then
            net.Broadcast()
        else
            net.Send(ply)
        end
    end

    net.Receive("slashCoValue", function(_, ply)
        local message = net.ReadString()
        local amount = net.ReadUInt(8)

        local vals = {}
        for i = 1, amount do
            local type = net.ReadString()
            typeRead[type](vals)
        end

        hook.Run("slashCoValue", ply, message, vals)
    end)

    return
end

function SlashCo.SendValue(message, ...)
    net.Start("slashCoValue")
    net.WriteString(message)

    local valAmount = #{...}
    net.WriteUInt(valAmount, 8)
    if valAmount > 0 then
        for _, v in ipairs({...}) do
            typeWrite[type(v)](v)
        end
    end

    net.SendToServer()
end

net.Receive("slashCoValue", function()
    local message = net.ReadString()
    local amount = net.ReadUInt(8)

    local vals = {}
    for i = 1, amount do
        local type = net.ReadString()
        typeRead[type](vals)
    end

    hook.Run("slashCoValue", message, vals)
end)