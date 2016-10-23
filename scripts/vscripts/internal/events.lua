--[[ events.lua ]]
require( "libraries/notifications" )
---------------------------------------------------------------------------
-- Event: Game state change handler
---------------------------------------------------------------------------
function COverthrowGameMode:OnGameRulesStateChange()
	local nNewState 	= GameRules:State_Get()
	print( "OnGameRulesStateChange: " .. nNewState )

	if nNewState == 2 then
		print( "On Stage: Players selecting teams." )
	end

	if nNewState == 3 then
		print( "On Stage: Players picking heroes. "..HERO_SELECTION_TIME.." seconds to next stage" )
	end

	if nNewState == 4 then
		print( "On Stage: Pre game time. "..PREGAMETIME.." seconds to start match." )

	end
	
	if nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
		local numberOfPlayers = PlayerResource:GetPlayerCount()
		if numberOfPlayers > 7 then
			self.TEAM_KILLS_TO_WIN = 40
			nCOUNTDOWNTIMER = 301
		elseif numberOfPlayers > 4 and numberOfPlayers <= 7 then
			self.TEAM_KILLS_TO_WIN = 20
			nCOUNTDOWNTIMER = 721
		elseif numberOfPlayers > 2 and numberOfPlayers <= 4 then
			self.TEAM_KILLS_TO_WIN = 10
			nCOUNTDOWNTIMER = 301
		elseif numberOfPlayers == 2 then
			self.TEAM_KILLS_TO_WIN = 2
			nCOUNTDOWNTIMER = 301
		elseif numberOfPlayers == 1 then
			self.TEAM_KILLS_TO_WIN = 50
			nCOUNTDOWNTIMER = 721
			print("Practice match.")
		end

--[[	if GetMapName() == "thunderhome" then
			self.TEAM_KILLS_TO_WIN = 20
		elseif GetMapName() == "desert_duo" then
			self.TEAM_KILLS_TO_WIN = 25
		else
			self.TEAM_KILLS_TO_WIN = 30
		end 		]]
		--print( "Kills to win = " .. tostring(self.TEAM_KILLS_TO_WIN) )

		CustomNetTables:SetTableValue( "game_state", "victory_condition", { kills_to_win = self.TEAM_KILLS_TO_WIN } );

		self._fPreGameStartTime = GameRules:GetGameTime()
	end

	if nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "OnGameRulesStateChange: Game In Progress" )
		self.countdownEnabled = true
		CustomGameEventManager:Send_ServerToAllClients( "show_timer", {} )
		DoEntFire( "center_experience_ring_particles", "Start", "0", 0, self, self  )
		GlobalBountyEnabled = true
	end
end

--------------------------------------------------------------------------------
-- Event: OnNPCSpawned
--------------------------------------------------------------------------------
function COverthrowGameMode:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )
	-- Ставим новую максимульную скорость бега для героев
	if spawnedUnit:IsHero() and spawnedUnit:GetName() ~= "npc_dota_hero_bloodseeker" then
		spawnedUnit:AddNewModifier( spawnedUnit, nil, 'modifier_movespeed_cap', nil )
	--	Attributes:ModifyBonuses(spawnedUnit)
	end
	-- Увеличиваем скорость для Bloodseeker отдельно
	if spawnedUnit:IsRealHero() and spawnedUnit:GetName() == "npc_dota_hero_bloodseeker" then
		spawnedUnit:AddNewModifier( spawnedUnit, nil, 'modifier_movespeed_new_thirst', nil )
	end

	if spawnedUnit:IsRealHero() and spawnedUnit.bFirstSpawned == nil then
        spawnedUnit.bFirstSpawned = true
        COverthrowGameMode:OnHeroInGame(spawnedUnit)
    end

	if spawnedUnit:IsRealHero() then
		local gold_bounty = 1
		local xp_bounty = 100
		spawnedUnit:SetDeathXP(xp_bounty)
		spawnedUnit:SetMaximumGoldBounty(gold_bounty)
		spawnedUnit:SetMinimumGoldBounty(gold_bounty)
	end
--	if spawnedUnit:GetName() == "npc_dota_creep_lane" then
--		spawnedUnit:SetBaseMoveSpeed(150)
--		spawnedUnit:SetMaxHealth(1000) 
--	end
	if spawnedUnit:IsRealHero() then
		-- Destroys the last hit effects
		local deathEffects = spawnedUnit:Attribute_GetIntValue( "effectsID", -1 )
		if deathEffects ~= -1 then
			ParticleManager:DestroyParticle( deathEffects, true )
			spawnedUnit:DeleteAttribute( "effectsID" )
		end
		if self.allSpawned == false then
			if GetMapName() == "thunderhome" then
				--print("mines_trio is the map")
				--print("self.allSpawned is " .. tostring(self.allSpawned) )
				local unitTeam = spawnedUnit:GetTeam()
				local particleSpawn = ParticleManager:CreateParticleForTeam( "particles/addons_gameplay/player_deferred_light.vpcf", PATTACH_ABSORIGIN, spawnedUnit, unitTeam )
				ParticleManager:SetParticleControlEnt( particleSpawn, PATTACH_ABSORIGIN, spawnedUnit, PATTACH_ABSORIGIN, "attach_origin", spawnedUnit:GetAbsOrigin(), true )
			end
		end
	end
end

function COverthrowGameMode:OnHeroInGame(hero)
	local hero_name = hero:GetUnitName()
	Attributes:ModifyBonuses(hero)
end

--------------------------------------------------------------------------------
-- Event: BountyRunePickupFilter
--------------------------------------------------------------------------------
function COverthrowGameMode:BountyRunePickupFilter( filterTable )
      filterTable["xp_bounty"] = 3*filterTable["xp_bounty"]
      filterTable["gold_bounty"] = 3*filterTable["gold_bounty"]
      return true
end

function COverthrowGameMode:FilterBountyRunePickup( filter_table )
      filter_table["xp_bounty"] = 3*filter_table["xp_bounty"]
      filter_table["gold_bounty"] = 3*filter_table["gold_bounty"]
      return true
end

function COverthrowGameMode:ModifyGoldFilter( table )
      if table["reason_const"] == DOTA_ModifyGold_HeroKill then
      	print("gold bounty "..tostring(table["gold"]))
		table["gold"] = 1
		return true
	end
	return false
end

---------------------------------------------------------------------------
-- Event: OnTeamKillCredit, see if anyone won
---------------------------------------------------------------------------
function COverthrowGameMode:OnTeamKillCredit( event )
--	print( "OnKillCredit" )
--	DeepPrint( event )

	local nKillerID = event.killer_userid
	local nTeamID = event.teamnumber
	local nTeamKills = event.herokills
	local nKillsRemaining = self.TEAM_KILLS_TO_WIN - nTeamKills
	
	local broadcast_kill_event =
	{
		killer_id = event.killer_userid,
		team_id = event.teamnumber,
		team_kills = nTeamKills,
		kills_remaining = nKillsRemaining,
		victory = 0,
		close_to_victory = 0,
		very_close_to_victory = 0,
	}

	if nKillsRemaining <= 0 then
		GameRules:SetCustomVictoryMessage( self.m_VictoryMessages[nTeamID] )
		GameRules:SetGameWinner( nTeamID )
		broadcast_kill_event.victory = 1
	elseif nKillsRemaining == 1 then
		EmitGlobalSound( "ui.npe_objective_complete" )
		broadcast_kill_event.very_close_to_victory = 1
	elseif nKillsRemaining <= self.CLOSE_TO_VICTORY_THRESHOLD then
		EmitGlobalSound( "ui.npe_objective_given" )
		broadcast_kill_event.close_to_victory = 1
	end


	CustomGameEventManager:Send_ServerToAllClients( "kill_event", broadcast_kill_event )
end

---------------------------------------------------------------------------
-- Event: OnEntityKilled
---------------------------------------------------------------------------
function COverthrowGameMode:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	local killedTeam = killedUnit:GetTeam()
	local hero = EntIndexToHScript( event.entindex_attacker )
	local heroTeam = hero:GetTeam()

	ToH:_OnEntityKilled( event )

	if killedUnit:IsRealHero() then
		self.allSpawned = true
		--print("Hero has been killed")
		if hero:IsRealHero() and heroTeam ~= killedTeam then
			--print("Granting killer xp")
			if killedUnit:GetTeam() == self.leadingTeam and self.isGameTied == false then
				local memberID = hero:GetPlayerID()
				PlayerResource:ModifyGold( memberID, 500, true, 0 )

				hero:AddExperience( 100, 0, false, false )
				local name = hero:GetClassname()
				local victim = killedUnit:GetClassname()
				local kill_alert =
					{
						hero_id = hero:GetClassname()
					}
				CustomGameEventManager:Send_ServerToAllClients( "kill_alert", kill_alert )
				local killer_img = hero:GetName()
				local killed_img = killedUnit:GetName()
				local killer_credit = "#throne_kill_credit"
				local dur = 5.0
				Notifications:BottomToAll({hero=killer_img, duration=dur})
				Notifications:BottomToAll({text=killer_credit, duration=dur, continue = true})
				Notifications:BottomToAll({hero=killed_img, duration=dur, continue = true})
			else
				hero:AddExperience( 50, 0, false, false )
			end
		end
		--Granting XP to all heroes who assisted
		local allHeroes = HeroList:GetAllHeroes()
		for _,attacker in pairs( allHeroes ) do
			--print(killedUnit:GetNumAttackers())
			for i = 0, killedUnit:GetNumAttackers() - 1 do
				if attacker == killedUnit:GetAttacker( i ) then
					--print("Granting assist xp")
					attacker:AddExperience( 25, 0, false, false )

				end
			end
		end
		if killedUnit:GetRespawnTime() > 10 then
			--print("Hero has long respawn time")
			if killedUnit:IsReincarnating() == true then
				--print("Set time for Wraith King respawn disabled")
				return nil
			else
				COverthrowGameMode:SetRespawnTime( killedTeam, killedUnit )
			end
		else
			COverthrowGameMode:SetRespawnTime( killedTeam, killedUnit )
		end

		
	end
end

function COverthrowGameMode:SetRespawnTime( killedTeam, killedUnit )
	local herolevel = killedUnit:GetLevel() 
	local respawntime = BASE_RESPAWN_TIME + herolevel * LEVEL_RESPAWN_TIME
	if herolevel > 5 then
		killedUnit:SetTimeUntilRespawn( respawntime )
	else
		respawntime = 3
		killedUnit:SetTimeUntilRespawn( respawntime )
	end
	print(killedUnit:GetName().." respawns until "..respawntime.."s.")
end


--------------------------------------------------------------------------------
-- Event: OnItemPickUp
--------------------------------------------------------------------------------
function COverthrowGameMode:OnItemPickUp( event )
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner = EntIndexToHScript( event.HeroEntityIndex )
	r = 300
	--r = RandomInt(200, 400)
	if event.itemname == "item_bag_of_gold" then
		--print("Bag of gold picked up")
		PlayerResource:ModifyGold( owner:GetPlayerID(), r, true, 0 )
		SendOverheadEventMessage( owner, OVERHEAD_ALERT_GOLD, owner, r, nil )
		UTIL_Remove( item ) -- otherwise it pollutes the player inventory
	elseif event.itemname == "item_treasure_chest" then
		--print("Special Item Picked Up")
		DoEntFire( "item_spawn_particle_" .. self.itemSpawnIndex, "Stop", "0", 0, self, self )
		COverthrowGameMode:SpecialItemAdd( event )
		UTIL_Remove( item ) -- otherwise it pollutes the player inventory
	end
end


--------------------------------------------------------------------------------
-- Event: OnNpcGoalReached
--------------------------------------------------------------------------------
function COverthrowGameMode:OnNpcGoalReached( event )
	local npc = EntIndexToHScript( event.npc_entindex )
	if npc:GetUnitName() == "npc_dota_treasure_courier" then
		COverthrowGameMode:TreasureDrop( npc )
	end
end

function COverthrowGameMode:OnPlayerGainedLevel( event )
	ToH:_HeroLevel( event )
end

function COverthrowGameMode:OnGameInProgress( event )
--	ToH:GlobalBountyAura( event )
end