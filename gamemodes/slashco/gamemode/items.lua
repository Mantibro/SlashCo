local SlashCo = SlashCo

SlashCo.GetHeldItem = function(ply)
	local id = ply:SteamID64()

	for _, v in ipairs(SlashCo.CurRound.SurvivorData.Items) do
        if v.steamid == id then
			return v.itemid
		end	      
	end
end

function IsPlayerHoldingItem(id)
	for _, v in ipairs(SlashCo.CurRound.SurvivorData.Items) do
        if v.steamid == id then
	        if v.itemid > 0 then
		    return true
            else
                return false
	        end
        else
            return false
        end
	end
end

SlashCo.UseItem = function(ply)

	if SERVER then

	if game.GetMap() == "sc_lobby" then return end

	if ply:Team() != TEAM_SURVIVOR then return end

	local itid = SlashCo.GetHeldItem(ply)

	--Skip the non-usable items
	if itid < 3 or itid == 6 or itid == 11 then return end

	if itid == 3 then

		--While the item is stored, a survivor can press R to consume it. It will set their sprint speed to 400 for 15 seconds.

		ply:SetRunSpeed( 400 )

		ply:EmitSound("slashco/survivor/drink_milk.mp3")

		timer.Simple(15, function()

			ply:SetRunSpeed( 300 )

			ply:EmitSound("slashco/survivor/effectexpire_breath.mp3")

        end)

	end

	if itid == 4 then

		--While the item is stored, a survivor can press R to consume it. It will set their sprint speed to 350 for 30 seconds.

		ply:SetRunSpeed( 350 )

		ply:EmitSound("slashco/survivor/eat_cookie.mp3")

		timer.Simple(30, function()

			ply:SetRunSpeed( 300 )

			ply:EmitSound("slashco/survivor/effectexpire_breath.mp3")

        end)

	end

	if itid == 5 then

		--While the item is stored, a survivor can press R to consume it. It will set their health to 200, regardless of current health.

		ply:SetHealth( 200 )

		ply:EmitSound("slashco/survivor/eat_mayo.mp3")

	end

	if itid == 7 then

		--When used, half of the survivors health is consumed, and the survivor is teleported to a random location which is at least 2000u away from their currect position. 
		--Activation takes 1 second. If the survivors health is lower than 51, the chance that the survivor will die upon use of the item will start increasing the lower their health. 
		--(50 - 10%, 25 - 60% ,1 - 100%). 
		--Using it will spawn a spent baby in the position the survivor used it.

		ply:EmitSound("slashco/survivor/baby_use.mp3")

		local deathchance = math.random(0, math.floor( ply:Health() / 5 ) )

		local hpafter = ply:Health() / 2 

		ply:SetHealth( hpafter )

		timer.Simple(1, function()


			if ply:Health() < 51 then

				if deathchance < 2 then ply:Kill() return end

			end

			--TODO TraceHull to find a good position and teleport there. For now will just respawn

			local player = ply

			SlashCo.RespawnPlayer(player,hpafter)

        end)

	end

	if itid == 8 then

		--When used, the survivor will become invisible for 30 seconds.

		ply:EmitSound("slashco/survivor/soda_drink"..math.random(1,2)..".mp3")

		ply:SetMaterial("Models/effects/vol_light001")
		ply:SetColor(Color(0,0,0,0))

		timer.Simple(30, function()

			ply:SetMaterial("")
			ply:SetColor(Color(255,255,255,255))

			ply:EmitSound("slashco/survivor/effectexpire_breath.mp3")

        end)

	end

	if itid == 9 then

		--If the holder of the item is the last one alive and at least one generator has been activated, the rescue helicopter will come prematurely.

		if #team.GetPlayers(TEAM_SURVIVOR) > 1 then ply:ChatPrint("You can activate the beacon only if you're the last living survivor.") return end

		if SlashCo.CurRound.EscapeHelicopterSummoned then ply:ChatPrint("The Helicopter is already on its way.") return end

		local r1 = ents.FindByClass( "sc_generator")[1]:EntIndex()
		local r2 = ents.FindByClass( "sc_generator")[2]:EntIndex()

		if SlashCo.CurRound.Generators[r1].Running or SlashCo.CurRound.Generators[r2].Running then 

			if SlashCo.CurRound.DistressBeaconUsed == false then 

				SlashCo.SummonEscapeHelicopter()

				SlashCo.CurRound.DistressBeaconUsed = true 

			end

		else
			ply:ChatPrint("You can activate the beacon once one generator has been turned on.")
		end

	end

	if itid == 10 then

		--[[

		Upon use, this item will apply a random effect from the set.
		-Spawn two Fuel Cans in front of the Survivor
		-Set their sprint speed to 450 for 45 seconds.
		-Heal the Survivor by 1-100
		-Damage the Survivor by 1-100
		-Teleport them 100u in front of the Slasher and hardlock their speed at 200 for 5 seconds.
		-Play a really loud sound which can be heard mapwide
		-Kill the Survivor

		]]

		--emitsound

		timer.Simple(2, function()

			local rand = math.random(1,6)

			if rand == 1 then 

				SlashCo.CreateGasCan(ply:LocalToWorld( Vector(30 , 20, 60) ) , ply:LocalToWorldAngles( Angle(0,0,0) ))
				SlashCo.CreateGasCan(ply:LocalToWorld( Vector(30 , -20, 60) ) , ply:LocalToWorldAngles( Angle(0,0,0) ))

			elseif rand == 2 then

				ply:SetRunSpeed( 450 )

				timer.Simple(45, function()

					ply:SetRunSpeed( 300 )

					ply:EmitSound("slashco/survivor/effectexpire_breath.mp3")

        		end)

			elseif rand == 3 then

				ply:SetHealth( ply:Health() + math.random(-100,100) )

			elseif rand == 4 then

				if #team.getPlayers(TEAM_SLASHER) < 1 then return end

				local slasher = team.getPlayers(TEAM_SLASHER)[1]

				ply:SetPos(slasher:LocalToWorld( Vector(100 , 0, 10) ) )
				ply:SetRunSpeed( 200 )

				timer.Simple(5, function()
					ply:SetRunSpeed( 300 )
					ply:EmitSound("slashco/survivor/effectexpire_breath.mp3")
        		end)

			elseif rand == 5 then

				--louddsound

			elseif rand == 6 then

				ply:Kill()

			end

        end)

	end

	SlashCo.ChangeSurvivorItem(ply:SteamID64(), 0)

end

end

SlashCo.DropItem = function(ply)

	if SERVER then

	--if game.GetMap() == "sc_lobby" then return end

	if ply:Team() != TEAM_SURVIVOR then return end

	local itid = SlashCo.GetHeldItem(ply)

	--Skip the non-droppable items
	if itid == 0 or itid == 2 or itid == 11 then return end

	if itid == 1 then 
		local droppeditem = SlashCo.CreateGasCan(ply:LocalToWorld( Vector(30 , 0, 60) ) , ply:LocalToWorldAngles( Angle(0,0,0) ))

	elseif itid == 3 then 
		local droppeditem = SlashCo.CreateItem("sc_milkjug", ply:LocalToWorld( Vector(30 , 0, 60) ) , ply:LocalToWorldAngles( Angle(0,0,0) )) 
		Entity( droppeditem ):GetPhysicsObject():ApplyForceCenter( ply:GetAimVector() * 250 )

	elseif itid == 4 then 
		local droppeditem = SlashCo.CreateItem("sc_cookie", ply:LocalToWorld( Vector(30 , 0, 60) ) , ply:LocalToWorldAngles( Angle(0,0,0) )) 
		Entity( droppeditem ):GetPhysicsObject():ApplyForceCenter( ply:GetAimVector() * 250 )

	elseif itid == 5 then 
		local droppeditem = SlashCo.CreateItem("sc_mayo", ply:LocalToWorld( Vector(30 , 0, 60) ) , ply:LocalToWorldAngles( Angle(0,0,0) )) 
		Entity( droppeditem ):GetPhysicsObject():ApplyForceCenter( ply:GetAimVector() * 250 )

	elseif itid == 6 then 
		local droppeditem = SlashCo.CreateItem("sc_stepdecoy", ply:LocalToWorld( Vector(30 , 0, 60) ) , ply:LocalToWorldAngles( Angle(0,0,0) )) 
		Entity( droppeditem ):GetPhysicsObject():ApplyForceCenter( ply:GetAimVector() * 250 )

	elseif itid == 7 then 
		local droppeditem = SlashCo.CreateItem("sc_baby", ply:LocalToWorld( Vector(30 , 0, 60) ) , ply:LocalToWorldAngles( Angle(0,0,0) )) 
		Entity( droppeditem ):GetPhysicsObject():ApplyForceCenter( ply:GetAimVector() * 250 )

	elseif itid == 8 then 
		local droppeditem = SlashCo.CreateItem("sc_soda", ply:LocalToWorld( Vector(30 , 0, 60) ) , ply:LocalToWorldAngles( Angle(0,0,0) )) 
		Entity( droppeditem ):GetPhysicsObject():ApplyForceCenter( ply:GetAimVector() * 250 )

	elseif itid == 9 then 
		local droppeditem = SlashCo.CreateItem("sc_beacon", ply:LocalToWorld( Vector(30 , 0, 60) ) , ply:LocalToWorldAngles( Angle(0,0,0) )) 
		Entity( droppeditem ):GetPhysicsObject():ApplyForceCenter( ply:GetAimVector() * 750 )

	elseif itid == 10 then 
		local droppeditem = SlashCo.CreateItem("sc_devildie", ply:LocalToWorld( Vector(30 , 0, 60) ) , ply:LocalToWorldAngles( Angle(0,0,0) )) 
		Entity( droppeditem ):GetPhysicsObject():ApplyForceCenter( ply:GetAimVector() * 250 )
	
	end

	SlashCo.ChangeSurvivorItem(ply:SteamID64(), 0)

end
	
end

concommand.Add( "give_item", function( ply, cmd, args )

	if SERVER then
	
	if ply:Team() != TEAM_SURVIVOR then print("Only survivors can have items") return end

	SlashCo.ChangeSurvivorItem(ply:SteamID64(), tonumber(args[1]))

	if tonumber(args[1]) == 2 then SlashCo.PlayerData[ply:SteamID64()].Lives = 2 end

	end

end )

SlashCo.ChangeSurvivorItem = function(plyid, id)

if SERVER then

	--Change the survivor's item.
	for _, v in ipairs(SlashCo.CurRound.SurvivorData.Items) do
		if v.steamid == plyid then
			v.itemid = id
		end
	end

	if id != 0 then player.GetBySteamID64(plyid):EmitSound("slashco/survivor/item_equip"..math.random(1,2)..".mp3") end

    SlashCo.BroadcastItemData()

end

end

SlashCo.ItemPickUp = function(plyid, item, itid)

	if SERVER then

	local ply = player.GetBySteamID64(plyid)

	if SlashCo.GetHeldItem(ply) > 0 then return end

	SlashCo.ChangeSurvivorItem(ply:SteamID64(), itid)

	ents.GetByIndex( item ):Remove()

	end

end