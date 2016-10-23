LinkLuaModifier("modifier_movespeed_cap", "internal/movespeed", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_movespeed_new_thirst", "internal/movespeed_thirst", LUA_MODIFIER_MOTION_NONE)

_G.nNEUTRAL_TEAM = 4
_G.nCOUNTDOWNTIMER = 901

if COverthrowGameMode == nil then
	_G.COverthrowGameMode = class({})
end

if Notifications == nil then
	_G.Notifications = class({})
end

require( "throne_rules" )
require( "internal/functions" )
require( "internal/events" )
require( "libraries/animations" )
require( "libraries/attributes" )
require( "libraries/notifications" )
require( "libraries/timers" )
require( "throne_custom" )
require( "throne_bounty_sys" )
require( "items" )
require( "utility_functions" )
require( "libraries/spelldamage" )
require( "storageapi/json" )
require( "storageapi/storage" )

Storage:SetApiKey("364f67690a2cd906464b8fb3a1d36c9dd52eb0c1")

function Precache( context )
	print("[PRECACHE]")
	-- Particles
	PrecacheResource( "particle", "particles/ui_mouseactions/unit_highlight.vpcf", context )

	-- Models
--	PrecacheResource( "model", "models/heroes/nevermore/nevermore.vmdl", context)
--	PrecacheResource( "model", "models/heroes/weaver/weaver.vmdl", context)

	PrecacheResource("model_folder", "models/heroes/abaddon", context)
	PrecacheResource("model_folder", "models/heroes/antimage", context)
	PrecacheResource("model_folder", "models/heroes/bloodseeker", context)
	PrecacheResource("model_folder", "models/heroes/huskar", context)
	PrecacheResource("model_folder", "models/heroes/nevermore", context)
	PrecacheResource("model_folder", "models/heroes/sniper", context)
	PrecacheResource("model_folder", "models/heroes/storm_spirit", context)
	PrecacheResource("model_folder", "models/heroes/weaver", context)
	 	--[[
			Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
		]]

	PrecacheUnitByNameSync("npc_dota_hero_antimage", context)
	PrecacheUnitByNameSync("npc_dota_hero_weaver", context)
	PrecacheUnitByNameSync("npc_dota_hero_sniper", context)
	PrecacheUnitByNameSync("npc_dota_hero_nevermore", context)
	PrecacheUnitByNameSync("npc_dota_hero_weaver", context)
	PrecacheUnitByNameSync("npc_dota_hero_elder_titan", context)
end

-- Create the game mode when we activate
function Activate()
	print( "Throne of Heroes is initialized." )
	-- Create our game mode and initialize it
	COverthrowGameMode:InitGameMode()
	ToH:Init()
	Attributes:Init()
	-- Register a listener for the game mode configuration
	print( "Map Name: "..GetMapName() )
end

function COverthrowGameMode:InitGameMode()
	-- Количество команд и игроков в каждой команде
--	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 3 )
--	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 3 )
	GameRules:SetCustomGameTeamMaxPlayers( 2, 3 ) -- Radiant
	GameRules:SetCustomGameTeamMaxPlayers( 3, 3 ) -- Dire
--	GameRules:SetCustomGameTeamMaxPlayers( 6, 3 )
	----
	
	-- Цвета команд
	self.m_TeamColors = {}
	self.m_TeamColors[DOTA_TEAM_GOODGUYS] = { 52, 85, 255 }
	self.m_TeamColors[DOTA_TEAM_BADGUYS]  = { 255, 5, 9 }

	for team = 0, (DOTA_TEAM_COUNT-1) do
		color = self.m_TeamColors[ team ]
		if color then
			SetTeamCustomHealthbarColor( team, color[1], color[2], color[3] )
		end
	end
	-- Надпись при победе (?)
	self.m_VictoryMessages = {}
	self.m_VictoryMessages[DOTA_TEAM_GOODGUYS] = "#VictoryMessage_GoodGuys"
	self.m_VictoryMessages[DOTA_TEAM_BADGUYS]  = "#VictoryMessage_BadGuys"

	self.m_GatheredShuffledTeams = {}
	self.numSpawnCamps = 5
	self.specialItem = ""
	self.spawnTime = 120
	self.nNextSpawnItemNumber = 1
	self.hasWarnedSpawn = false
	self.allSpawned = false
	self.leadingTeam = -1
	self.runnerupTeam = -1
	self.leadingTeamScore = 0
	self.runnerupTeamScore = 0
	self.isGameTied = true
	self.countdownEnabled = false
	self.itemSpawnIndex = 1
	self.itemSpawnLocation = Entities:FindByName( nil, "greevil" )
	self.tier1ItemBucket = {}
	self.tier2ItemBucket = {}
	self.tier3ItemBucket = {}
	self.tier4ItemBucket = {}


	rule = GameRules:GetGameModeEntity()
	self.TEAM_KILLS_TO_WIN = 25
	self.CLOSE_TO_VICTORY_THRESHOLD = 5

--	self:GatherAndRegisterValidTeams()


	rule.COverthrowGameMode = self

	GameRules:SetCustomGameEndDelay( 0 )
	GameRules:SetCustomVictoryMessageDuration( 6 )
	GameRules:SetPreGameTime( PREGAMETIME )
	GameRules:SetHeroSelectionTime( HERO_SELECTION_TIME )
	GameRules:SetUseUniversalShopMode( UNIVERSAL_SHOP )
	GameRules:SetHideKillMessageHeaders( false )
	GameRules:SetHeroMinimapIconScale( MAP_ICON_SIZE )
	GameRules:SetFirstBloodActive( FIRST_BLOOD )
	GameRules:SetGoldPerTick( GOLD_PER_TICK )
	GameRules:SetGoldTickTime( GOLD_TICK )
	GameRules:SetUseBaseGoldBountyOnHeroes( USE_BASE_HERO_BOUNTY )
	GameRules:SetRuneSpawnTime( RUNE_SPAWN_TIME )
	GameRules:SetTreeRegrowTime( TREE_REGROW_TIME )


	rule:SetTopBarTeamValuesOverride( true )
	rule:SetTopBarTeamValuesVisible( false )


	rule:SetCustomBuybackCooldownEnabled( true )
	rule:SetCustomBuybackCostEnabled( true )
	rule:SetBuybackEnabled( true )

	rule:SetLoseGoldOnDeath( LOSE_GOLD_ON_DEATH )
	rule:SetFountainPercentageHealthRegen( FOUNTAIN_HP_REGEN )
	rule:SetFountainPercentageManaRegen( FOUNTAIN_MP_REGEN )
	rule:SetFountainConstantManaRegen( 5 )
	rule:SetFixedRespawnTime( FIXED_RESPAWN_TIME )
	rule:SetMaximumAttackSpeed( MAX_AS )

	rule:SetCameraDistanceOverride( CAMERA_DISTANCE )
	rule:SetUseCustomHeroLevels ( USE_MAXHEROLEVEL )
	rule:SetCustomHeroMaxLevel ( MAXHEROLEVEL )
	--Runes

	rule:SetRuneEnabled( 0, false ) --Double Damage
	rule:SetRuneEnabled( 1, true ) --Haste
	rule:SetRuneEnabled( 2, false ) --Illusion
	rule:SetRuneEnabled( 3, false ) --Invis
	rule:SetRuneEnabled( 4, true ) --Regen
	rule:SetRuneEnabled( 5, true ) --Bounty

	rule:SetBountyRunePickupFilter( Dynamic_Wrap(COverthrowGameMode, "FilterBountyRunePickup"), self )
	rule:SetModifyGoldFilter( Dynamic_Wrap(COverthrowGameMode, "ModifyGoldFilter"), self )

	-- Игровые события
	ListenToGameEvent( "game_rules_state_change", 		Dynamic_Wrap( COverthrowGameMode, 'OnGameRulesStateChange' ), self )
	ListenToGameEvent( "npc_spawned", 					Dynamic_Wrap( COverthrowGameMode, "OnNPCSpawned" ), self )
--	ListenToGameEvent( "npc_spawned", 					Dynamic_Wrap( COverthrowGameMode, "OnHeroInGame" ), self )
	ListenToGameEvent( "dota_team_kill_credit", 		Dynamic_Wrap( COverthrowGameMode, 'OnTeamKillCredit' ), self )
	ListenToGameEvent( "entity_killed", 				Dynamic_Wrap( COverthrowGameMode, 'OnEntityKilled' ), self )
	ListenToGameEvent( "dota_item_picked_up", 			Dynamic_Wrap( COverthrowGameMode, "OnItemPickUp"), self )
	ListenToGameEvent( "dota_npc_goal_reached", 		Dynamic_Wrap( COverthrowGameMode, "OnNpcGoalReached" ), self )
--	ListenToGameEvent( "dota_tower_kill",				Dynamic_Wrap( COverthrowGameMode, "OnTowerKill" ), self )
--	Event when tower kills anybody
	ListenToGameEvent("dota_player_gained_level", 		Dynamic_Wrap( COverthrowGameMode, "OnPlayerGainedLevel"), self)


--	Convars:RegisterCommand( "overthrow_force_item_drop", function(...) self:ForceSpawnItem() end, "Force an item drop.", FCVAR_CHEAT )
--	Convars:RegisterCommand( "overthrow_force_gold_drop", function(...) self:ForceSpawnGold() end, "Force gold drop.", FCVAR_CHEAT )
	Convars:RegisterCommand( "overthrow_set_timer", function(...) return SetTimer( ... ) end, "Set the timer.", FCVAR_CHEAT )
	Convars:RegisterCommand( "overthrow_force_end_game", function(...) return self:EndGame( DOTA_TEAM_GOODGUYS ) end, "Force the game to end.", FCVAR_CHEAT )
	
	CustomGameEventManager:RegisterListener("set_game_options", OnSetGameMode)
	CustomGameEventManager:RegisterListener("throne_btn1", FireEventOne)
	CustomGameEventManager:RegisterListener("throne_talent_tree_get", TalentsCheck)

	CustomGameEventManager:RegisterListener("StorageCheck", StorageCheck)


	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 1 ) 

	--[[ Spawning monsters
	spawncamps = {}
	for i = 1, self.numSpawnCamps do
		local campname = "camp"..i.."_path_customspawn"
		spawncamps[campname] =
		{
			NumberToSpawn = RandomInt(3,5),
			WaypointName = "camp"..i.."_path_wp1"
		}
	end
	]]
end

function OnSetGameMode( eventSourceIndex, args )
	print("Custom Game Event: OnSetGameMode")
	local player_id = args.PlayerID
	local player = PlayerResource:GetPlayer(player_id)
	local is_host = GameRules:PlayerHasCustomGameHostPrivileges(player)
	local mode_info = args.modes
	local rule = GameRules:GetGameModeEntity()    

	-- If the player who sent the game options is not the host, do nothing
	if not is_host then
		return nil
	end

	-- If nothing was captured from the game options, do nothing
	if not mode_info then
		return nil
	end

	-- If the game options were already chosen, do nothing
	if GAME_OPTIONS_SET then
		return nil
	end

	-- Retrieve information
	if tonumber(mode_info.enable_wtf) == 1 then
		Say(nil, "-wtf", false)
		print("WTF mode activated!")
		SendToServerConsole("sv_cheats")
		SendToServerConsole("dota_ability_debug")
		SendToServerConsole("sv_cheats")
	end

	-- Set game end on kills
	if tonumber(mode_info.number_of_kills) > 0 then
		END_GAME_ON_KILLS = true
		KILLS_TO_END_GAME_FOR_TEAM = tonumber(mode_info.number_of_kills)
		print("Game will end on "..KILLS_TO_END_GAME_FOR_TEAM.." kills!")
	end

	-------------------------------------------------------------------------------------------------
	-- IMBA: Gold/bounties setup
	-------------------------------------------------------------------------------------------------

	-- Starting gold information
	if mode_info.gold_start == "1500" then
		INITIAL_GOLD = 1500
		HERO_INITIAL_REPICK_GOLD = 1200
		HERO_INITIAL_RANDOM_GOLD = 2000
	elseif mode_info.gold_start == "4000" then
		INITIAL_GOLD = 4000
		HERO_INITIAL_REPICK_GOLD = 3300
		HERO_INITIAL_RANDOM_GOLD = 5000
	elseif mode_info.gold_start == "10000" then
		INITIAL_GOLD = 10000
		HERO_INITIAL_REPICK_GOLD = 8500
		HERO_INITIAL_RANDOM_GOLD = 12000
	elseif mode_info.gold_start == "50000" then
		INITIAL_GOLD = 50000
		HERO_INITIAL_REPICK_GOLD = 45000
		HERO_INITIAL_RANDOM_GOLD = 55000
	end
	print("hero starting gold: "..INITIAL_GOLD)

	-- Gold bounties information
	CREEP_GOLD_BONUS = tonumber(mode_info.gold_bounty)
	HERO_GOLD_BONUS = tonumber(mode_info.gold_bounty)
	print("gold bounty increased by: "..HERO_GOLD_BONUS)

	-- XP bounties information
	CREEP_XP_BONUS = tonumber(mode_info.xp_bounty)
	HERO_XP_BONUS = tonumber(mode_info.xp_bounty)
	print("xp bounty increased by: "..HERO_XP_BONUS)

	-- Passive gold adjustment
	local adjusted_gold_per_tick = GOLD_TICK_TIME / ( 1 + CREEP_GOLD_BONUS / 100 )
	GameRules:SetGoldTickTime( adjusted_gold_per_tick )

	-------------------------------------------------------------------------------------------------
	-- IMBA: Hero levels and respawn setup
	-------------------------------------------------------------------------------------------------

	-- Enable higher starting level
	HERO_STARTING_LEVEL = tonumber(mode_info.level_start)
	print("Heroes will start the game on level "..HERO_STARTING_LEVEL)

--[[Enable higher level cap
	if tonumber(mode_info.level_cap) > 25 then
		USE_MAXHEROLEVEL = true
		MAXHEROLEVEL = tonumber(mode_info.level_cap)
		rule:SetUseCustomHeroLevels ( USE_MAXHEROLEVEL )
		rule:SetCustomHeroMaxLevel ( MAXHEROLEVEL )
		print("Heroes can level up to level "..MAXHEROLEVEL)
	end
]]
	-- Respawn time information
	if mode_info.respawn == "respawn_half" then
		LEVEL_RESPAWN_TIME = LEVEL_RESPAWN_TIME / 2
	elseif mode_info.respawn == "respawn_zero" then
		LEVEL_RESPAWN_TIME = 0
	end
	print("Respawn timer: Base "..BASE_RESPAWN_TIME..", + Each Level "..LEVEL_RESPAWN_TIME)

	-- Set the game options as being chosen
	GAME_OPTIONS_SET = true

	-- Finish mode setup and start the game
	GameRules:FinishCustomGameSetup()

end

function COverthrowGameMode:ColorForTeam( teamID )
	local color = self.m_TeamColors[ teamID ]
	if color == nil then
		color = { 255, 255, 255 } -- default to white
	end
	return color
end

function COverthrowGameMode:EndGame( victoryTeam )
	GameRules:SetGameWinner( victoryTeam )
end

function COverthrowGameMode:UpdatePlayerColor( nPlayerID )
	if not PlayerResource:HasSelectedHero( nPlayerID ) then
		return
	end

	local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
	if hero == nil then
		return
	end

	local teamID = PlayerResource:GetTeam( nPlayerID )
	local color = self:ColorForTeam( teamID )
	PlayerResource:SetCustomPlayerColor( nPlayerID, color[1], color[2], color[3] )
end


---------------------------------------------------------------------------
-- Simple scoreboard using debug text
---------------------------------------------------------------------------
function COverthrowGameMode:UpdateScoreboard()
	local sortedTeams = {}
	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		table.insert( sortedTeams, { teamID = team, teamScore = GetTeamHeroKills( team ) } )
	end

	-- reverse-sort by score
	table.sort( sortedTeams, function(a,b) return ( a.teamScore > b.teamScore ) end )

	for _, t in pairs( sortedTeams ) do
		local clr = self:ColorForTeam( t.teamID )

		-- Scaleform UI Scoreboard
		local score = 
		{
			team_id = t.teamID,
			team_score = t.teamScore
		}
		FireGameEvent( "score_board", score )
	end
	-- Leader effects (moved from OnTeamKillCredit)
	local leader = sortedTeams[1].teamID
	--print("Leader = " .. leader)
	self.leadingTeam = leader
	self.runnerupTeam = sortedTeams[2].teamID
	self.leadingTeamScore = sortedTeams[1].teamScore
	self.runnerupTeamScore = sortedTeams[2].teamScore
	if sortedTeams[1].teamScore == sortedTeams[2].teamScore then
		self.isGameTied = true
	else
		self.isGameTied = false
	end
	local allHeroes = HeroList:GetAllHeroes()
	for _,entity in pairs( allHeroes) do
		if entity:GetTeamNumber() == leader and sortedTeams[1].teamScore ~= sortedTeams[2].teamScore then
			if entity:IsAlive() == true then
				-- Attaching a particle to the leading team heroes
				local existingParticle = entity:Attribute_GetIntValue( "particleID", -1 )
       			if existingParticle == -1 then
       				local particleLeader = ParticleManager:CreateParticle( "particles/leader/leader_overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, entity )
					ParticleManager:SetParticleControlEnt( particleLeader, PATTACH_OVERHEAD_FOLLOW, entity, PATTACH_OVERHEAD_FOLLOW, "follow_overhead", entity:GetAbsOrigin(), true )
					entity:Attribute_SetIntValue( "particleID", particleLeader )
				end
			else
				local particleLeader = entity:Attribute_GetIntValue( "particleID", -1 )
				if particleLeader ~= -1 then
					ParticleManager:DestroyParticle( particleLeader, true )
					entity:DeleteAttribute( "particleID" )
				end
			end
		else
			local particleLeader = entity:Attribute_GetIntValue( "particleID", -1 )
			if particleLeader ~= -1 then
				ParticleManager:DestroyParticle( particleLeader, true )
				entity:DeleteAttribute( "particleID" )
			end
		end
	end
end

---------------------------------------------------------------------------
-- Update player labels and the scoreboard
---------------------------------------------------------------------------
function COverthrowGameMode:OnThink()
	for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
		self:UpdatePlayerColor( nPlayerID )
	end
	
	self:UpdateScoreboard()
	-- Stop thinking if game is paused
	if GameRules:IsGamePaused() == true then
        return 1
    end

	if self.countdownEnabled == true then
		CountdownTimer()
		if nCOUNTDOWNTIMER == 30 then
			CustomGameEventManager:Send_ServerToAllClients( "timer_alert", {} )
		end
		if nCOUNTDOWNTIMER <= 0 then
			--Check to see if there's a tie
			if self.isGameTied == false then
				GameRules:SetCustomVictoryMessage( self.m_VictoryMessages[self.leadingTeam] )
				COverthrowGameMode:EndGame( self.leadingTeam )
				self.countdownEnabled = false
			else
				self.TEAM_KILLS_TO_WIN = self.leadingTeamScore + 1
				local broadcast_killcount = 
				{
					killcount = self.TEAM_KILLS_TO_WIN
				}
				CustomGameEventManager:Send_ServerToAllClients( "overtime_alert", broadcast_killcount )
			end
       	end
	end
	
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--Spawn Gold Bags
	--	COverthrowGameMode:ThinkGoldDrop()
	--	COverthrowGameMode:ThinkSpecialItemDrop()
	end

	return 1
end

---------------------------------------------------------------------------
-- Scan the map to see which teams have spawn points
---------------------------------------------------------------------------
function COverthrowGameMode:GatherAndRegisterValidTeams()
--	print( "GatherValidTeams:" )

	local foundTeams = {}
	for _, playerStart in pairs( Entities:FindAllByClassname( "info_player_start_dota" ) ) do
		foundTeams[  playerStart:GetTeam() ] = true
	end

	local numTeams = TableCount(foundTeams)
	print( "GatherValidTeams - Found spawns for a total of " .. numTeams .. " teams" )
	
	local foundTeamsList = {}
	for t, _ in pairs( foundTeams ) do
		table.insert( foundTeamsList, t )
	end

	if numTeams == 0 then
		print( "GatherValidTeams - NO team spawns detected, defaulting to GOOD/BAD" )
		table.insert( foundTeamsList, DOTA_TEAM_GOODGUYS )
		table.insert( foundTeamsList, DOTA_TEAM_BADGUYS )
		numTeams = 2
	end

	local maxPlayersPerValidTeam = math.floor( 10 / numTeams )

	self.m_GatheredShuffledTeams = ShuffledList( foundTeamsList )

	print( "Final shuffled team list:" )
	for _, team in pairs( self.m_GatheredShuffledTeams ) do
		print( " - " .. team .. " ( " .. GetTeamName( team ) .. " )" )
	end

	print( "Setting up teams:" )
	for team = 0, (DOTA_TEAM_COUNT-1) do
		local maxPlayers = 0
		if ( nil ~= TableFindKey( foundTeamsList, team ) ) then
			maxPlayers = maxPlayersPerValidTeam
		end
		print( " - " .. team .. " ( " .. GetTeamName( team ) .. " ) -> max players = " .. tostring(maxPlayers) )
		GameRules:SetCustomGameTeamMaxPlayers( team, maxPlayers )
	end
end

-- Spawning individual camps
function COverthrowGameMode:spawncamp(campname)
	spawnunits(campname)
end

-- Simple Custom Spawn
function spawnunits(campname)
	local spawndata = spawncamps[campname]
	local NumberToSpawn = spawndata.NumberToSpawn --How many to spawn
    local SpawnLocation = Entities:FindByName( nil, campname )
    local waypointlocation = Entities:FindByName ( nil, spawndata.WaypointName )
	if SpawnLocation == nil then
		return
	end

    local randomCreature = 
    	{
			"basic_zombie",
			"berserk_zombie"
	    }
	local r = randomCreature[RandomInt(1,#randomCreature)]
	--print(r)
    for i = 1, NumberToSpawn do
        local creature = CreateUnitByName( "npc_dota_creature_" ..r , SpawnLocation:GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_NEUTRALS )
        --print ("Spawning Camps")
        creature:SetInitialGoalEntity( waypointlocation )
    end
end

--------------------------------------------------------------------------------
-- Event: Filter for inventory full
--------------------------------------------------------------------------------
function COverthrowGameMode:ExecuteOrderFilter( filterTable )
	--[[
	for k, v in pairs( filterTable ) do
		print("EO: " .. k .. " " .. tostring(v) )
	end
	]]

	local orderType = filterTable["order_type"]
	if ( orderType ~= DOTA_UNIT_ORDER_PICKUP_ITEM or filterTable["issuer_player_id_const"] == -1 ) then
		return true
	else
		local item = EntIndexToHScript( filterTable["entindex_target"] )
		if item == nil then
			return true
		end
		local pickedItem = item:GetContainedItem()
		--print(pickedItem:GetAbilityName())
		if pickedItem == nil then
			return true
		end
		if pickedItem:GetAbilityName() == "item_treasure_chest" then
			local player = PlayerResource:GetPlayer(filterTable["issuer_player_id_const"])
			local hero = player:GetAssignedHero()
			if hero:GetNumItemsInInventory() < 6 then
				--print("inventory has space")
				return true
			else
				--print("Moving to target instead")
				local position = item:GetAbsOrigin()
				filterTable["position_x"] = position.x
				filterTable["position_y"] = position.y
				filterTable["position_z"] = position.z
				filterTable["order_type"] = DOTA_UNIT_ORDER_MOVE_TO_POSITION
				return true
			end
		end
	end
	return true
end

