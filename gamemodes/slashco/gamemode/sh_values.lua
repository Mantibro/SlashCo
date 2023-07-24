AddCSLuaFile()
SlashCo = SlashCo or {}

local typeMap = {
	[0] = "string",
	"number",
	"vector",
	"color",
	"angle",
	"entity",
	"table",
	"boolean"
}

local typeWrite
typeWrite = {
	string = function(val)
		net.WriteUInt(0, 4)
		net.WriteString(val)
	end,
	number = function(val)
		net.WriteUInt(1, 4)
		net.WriteDouble(val)
	end,
	Vector = function(val)
		net.WriteUInt(2, 4)
		net.WriteVector(val)
	end,
	Color = function(val)
		net.WriteUInt(3, 4)
		net.WriteColor(val)
	end,
	Angle = function(val)
		net.WriteUInt(4, 4)
		net.WriteAngle(val)
	end,
	Entity = function(val)
		net.WriteUInt(5, 4)
		net.WriteEntity(val)
	end,
	table = function(val)
		if IsColor(val) then
			typeWrite["color"](val)
			return
		end

		if isvector(val) then
			typeWrite["vector"](val)
			return
		end

		if isangle(val) then
			typeWrite["angle"](val)
			return
		end

		net.WriteUInt(6, 4)
		net.WriteUInt(table.Count(val), 8)
		for _, v in pairs(val) do
			typeWrite[type(v)](v)
		end
	end,
	boolean = function(val)
		net.WriteUInt(7, 4)
		net.WriteBool(val)
	end,
	Player = function(val)
		net.WriteUInt(5, 4)
		net.WriteEntity(val)
	end,
	["nil"] = function()
		net.WriteUInt(7, 4)
		net.WriteBool(false)
	end
}

local typeRead
typeRead = {
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
	end,
	table = function(val)
		local inTable = {}
		for i = 1, net.ReadInt(8) do
			local _type = typeMap[net.ReadUInt(4)]
			typeRead[_type](inTable)
		end
		table.insert(val, inTable)
	end,
	boolean = function(val)
		table.insert(val, net.ReadBool())
	end
}

function table.pack(...)
	return { n = select("#", ...); ... }
end

if SERVER then
	util.AddNetworkString("slashCoValue")

	local doNetwork

	---networks any amount of values to provided clients with an included message
	function SlashCo.SendValue(ply, message, ...)
		doNetwork(message, ...)

		if not ply then
			net.Broadcast()
		else
			net.Send(ply)
		end
	end

	---similar to above, but omits the player specified and sends to all others
	function SlashCo.SendValueOmit(ply, message, ...)
		doNetwork(message, ...)

		net.SendOmit(ply)
	end

	---internal function to handle the "sending message" part of the above functions
	function doNetwork(message, ...)
		net.Start("slashCoValue")
		net.WriteString(message)

		local args = table.pack(...)

		net.WriteUInt(args.n, 8)
		for i = 1, args.n do
			typeWrite[type(args[i])](args[i])
		end
	end

	net.Receive("slashCoValue", function(_, ply)
		local message = net.ReadString()
		local amount = net.ReadUInt(8)

		local vals = {}
		for i = 1, amount do
			local _type = typeMap[net.ReadUInt(4)]
			typeRead[_type](vals)
		end

		hook.Run("scValue_" .. message, ply, unpack(vals))
	end)

	return
end

---networks any amount of values to the server
function SlashCo.SendValue(message, ...)
	net.Start("slashCoValue")
	net.WriteString(message)

	local valAmount = #{ ... }
	net.WriteUInt(valAmount, 8)
	if valAmount > 0 then
		for _, v in ipairs({ ... }) do
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
		local _type = typeMap[net.ReadUInt(4)]
		typeRead[_type](vals)
	end

	hook.Run("scValue_" .. message, unpack(vals))
end)
