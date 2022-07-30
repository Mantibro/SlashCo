function EFFECT:Init( data )

	local vOffset = data:GetOrigin()
	--local Dir = data:GetStart()

    local Dir = Entity(1):EyeAngles():Forward()

	local NumParticles = 32

	local emitter = ParticleEmitter( vOffset, true )

	for i = 0, NumParticles do

		local Pos = Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -1, 1 ) )

		local particle = emitter:Add( "particle/particle_smokegrenade1", vOffset + Pos * 2 )
		if ( particle ) then

			particle:SetVelocity( (Dir + (Pos/4)) * math.random(100,250))

			particle:SetLifeTime( 0 )
			particle:SetDieTime( 6 )

			particle:SetStartAlpha( 255 )
			particle:SetEndAlpha( 0 )

			local Size = math.Rand( 1, 3 )
			particle:SetStartSize( Size )
			particle:SetEndSize( 150 )

			particle:SetRoll( math.Rand( 0, 360 ) )
			particle:SetRollDelta( math.Rand( -6, 6 ) )

			particle:SetAirResistance( 100 )
			particle:SetGravity( Vector( 0, 0, 50+(Pos[1]*25) ) )

			local RandDarkness = math.Rand( 0.8, 1.0 )
			particle:SetColor( 50, 50, 50 )

			particle:SetCollide( true )

			particle:SetAngleVelocity( Angle( math.Rand( -25, 25 ), math.Rand( -25, 25 ), math.Rand( -25, 25 ) ) )


		end

        local particleflash = emitter:Add( "particles/flamelet4", vOffset + Pos * 2 )
		if ( particleflash ) then

			particleflash:SetVelocity( (Dir + (Pos/4)) * math.random(100,250))

			particleflash:SetLifeTime( 0 )
			particleflash:SetDieTime( 0.12 )

			particleflash:SetStartAlpha( 255 )
			particleflash:SetEndAlpha( 100 )

			local Size = math.Rand( 1, 3 )
			particleflash:SetStartSize( 20 + Size )
			particleflash:SetEndSize(  Size )

			particleflash:SetRoll( math.Rand( 0, 360 ) )
			particleflash:SetRollDelta( math.Rand( -6, 6 ) )

			particleflash:SetAirResistance( 100 )
			particleflash:SetGravity( Vector( 0, 0, 50+(Pos[1]*25) ) )

			local RandDarkness = math.Rand( 0.8, 1.0 )
			particleflash:SetColor( 50, 50, 50 )

			particleflash:SetCollide( true )

			particleflash:SetAngleVelocity( Angle( math.Rand( -25, 25 ), math.Rand( -25, 25 ), math.Rand( -25, 25 ) ) )


		end

        if i == 1 then

            local dlight = DynamicLight( 24984 )
		    if ( dlight ) then
			    dlight.pos = vOffset
			    dlight.r = 255
			    dlight.g = 100
			    dlight.b = 100
			    dlight.brightness = 3
			    dlight.Decay = 1000
			    dlight.Size = 150
			    dlight.DieTime = CurTime() + 0.12
		    end

        end

	end

	emitter:Finish()

end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end