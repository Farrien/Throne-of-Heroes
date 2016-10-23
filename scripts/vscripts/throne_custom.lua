
_G.SPELLPOWER = nil
_G.pseudoRandom = 0
_G.GlobalBountyEnabled = false

if ToH == nil then
	print( "Throne of Heroes: Custom LUA library created.")
	_G.ToH = class({})
end

function ToH:Init()
	print( "ToH Init...")
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 1 ) 

	self.gameTime = 0
	self.warVeteran = 0
end



function ToH:MagicDamage()
	return nil
end


function ToH:TalentTreeInit()
	local N = nil

	return N
end

function TalentsCheck( eventSourceIndex, args )
--	print( "Event: "..eventSourceIndex..". It works!" )
	local player_id 		= args.PlayerID
	local talent_id 		= args.id
	local tier_num 			= args.tier
	local player 			= PlayerResource:GetPlayer(player_id)
	local hero 				= player:GetAssignedHero() 
	
	if not hero:IsAlive() then
		return nil
	end

	if hero.talentPoints == nil then
		hero.talentPoints = BASE_TALENT_POINTS
	end

	if hero.talentPoints == 0 then
		return nil
	end

	if hero.HiddenTalents == nil then
		hero.HiddenTalents = { tier1 = false, tier2 = false, tier3 = false, tier4 = false }
	end

	local tierNum = false
	local hlvl = hero:GetLevel()
	if tier_num == 1 then
		tierNum = hero.HiddenTalents.tier1
	elseif tier_num == 2 then
		if hlvl < 6 then
			Notifications:Bottom(player_id, {text = "#talent_tier_blocked", duration = 2, style={color="red"}})
			return nil
		end
		tierNum = hero.HiddenTalents.tier2
	elseif tier_num == 3 then
		if hlvl < 12 then
			Notifications:Bottom(player_id, {text = "#talent_tier_blocked", duration = 2, style={color="red"}})
			return nil
		end
		tierNum = hero.HiddenTalents.tier3
	elseif tier_num == 4 then
		if hlvl < 18 then
			Notifications:Bottom(player_id, {text = "#talent_tier_blocked", duration = 2, style={color="red"}})
			return nil
		end
		tierNum = hero.HiddenTalents.tier4
	end

	if tierNum then
		Notifications:Bottom(player_id, {text = "#talent_banned", duration = 2, style={color="red"}})
		return nil
	else
		local ability = nil
		if hero then
			if not hero:HasAbility("talent_tree_cont") then
				hero:AddAbility("talent_tree_cont")
			end
			ability = hero:FindAbilityByName("talent_tree_cont")
		end

		if ability then
			ability:ApplyDataDrivenModifier(hero, hero, "modifier_talent_id"..talent_id.."_"..tier_num, {})
		end

		Notifications:Bottom(player_id, {text = "#talent_"..talent_id.."_tier_"..tier_num, duration = 3})
		Notifications:Bottom(player_id, {text = ": Талант изучен!", duration = 3, continue=true})
		Notifications:Bottom(player_id, {text = "#talent_"..talent_id.."_tier_"..tier_num.."_desc", duration = 3})

		local newArgs = 
		{
			aPlayer 	= player,
			aTalent 	= talent_id,
			aTier		= tier_num
		}

		CustomGameEventManager:Send_ServerToPlayer(player, "hide_tier", newArgs)

		local talent_learn_effect = ParticleManager:CreateParticle("particles/effects/hero_talentup.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
		ParticleManager:SetParticleControl(talent_learn_effect, 0, hero:GetAbsOrigin() )
		ParticleManager:SetParticleControl(talent_learn_effect, 1, Vector(100,0,0) )

		if tier_num == 1 then
			hero.HiddenTalents.tier1 = true
		elseif tier_num == 2 then
			hero.HiddenTalents.tier2 = true
		elseif tier_num == 3 then
			hero.HiddenTalents.tier3 = true
		elseif tier_num == 4 then
			hero.HiddenTalents.tier4 = true
		end

		hero.talentPoints = hero.talentPoints - 1
	end
end

function ToH:OnThink()
	self.gameTime = self.gameTime + 1
	return 1
end

function PrintTable(name,table)
	print("--------------------"..name.."--------------------")
	for k,v in pairs(table) do
		print(k,v)
	end
	print("--------------------End of table--------------------------")
end

function ToH:_HeroLevel( event )
	PrintTable("Hero Reach Level", event)
	print("hero player reach level:" .. event.player)
	local lvl 				= event.level
	local player_id 		= event.player
 --	local player 			= PlayerResource:GetPlayer(player_id - 1)
 	local player 			= PlayerResource:GetPlayer(event.player - 1)
--	local hero 				= player:GetAssignedHero()
	local hero 				= player:GetAssignedHero()

	if hero.talentPoints == nil then
		hero.talentPoints = BASE_TALENT_POINTS
	end

	local player_n = hero:GetPlayerID()

	if lvl == 6 then
		hero.talentPoints = hero.talentPoints + 1
		Notifications:Bottom(player_n, {text="#talent_reached", duration=3, style={color="green"}})
	end

	if lvl == 12 then
		hero.talentPoints = hero.talentPoints + 1
		Notifications:Bottom(player_n, {text="#talent_reached", duration=3, style={color="green"}})
	end

	if lvl == 18 then
		hero.talentPoints = hero.talentPoints + 1
		Notifications:Bottom(player_n, {text="#talent_reached", duration=3, style={color="green"}})
	end
	
end

function RandomFromTable(table)
	local array = {}
	local n = 0
	for _,v in pairs(table) do
		array[#array+1] = v
		n = n + 1
	end

	if n == 0 then return nil end

	return array[RandomInt(1,n)]
end

-- Возвращает указанное количество случайных значений из таблицы
-- number количество 
function RandomTableVars(number, table)
	if number == nil or number == 1 then
		return nil
	end

	local array = {}
	local n = 0

	for _,v in pairs(table) do
		array[#array+1] = v
		n = n + 1
	end

	if n <= 1 then return nil end

	local nTable = {}
	local a = 1

	while a < number do
		local r = array[RandomInt(1,n)]
		if nTable[a] ~= r then
			nTable[a] = r
			a = a + 1
		end

		if a == number then break end
	end

	return nTable
end

function IsHardDisabled( unit )
	if unit:IsStunned() or unit:IsHexed() or unit:IsNightmared() or unit:IsOutOfGame() or unit:HasModifier("modifier_axe_berserkers_call") then
		return true
	end
	return false
end

function PseudoHeal(target, amount)
	local target_hp = target:GetHealth() 

	target:SetHealth(target_hp + amount)
end

_G.GlobalBountyCap = 0

function GlobalBountyAura( keys )
	if GlobalBountyEnabled == false then
		return nil
	end
	local heroes = keys.target_entities
	local xp_amount = keys.xp
	local gold_amount = keys.goldbounty
	local bonus_xp = 0
	if RandomInt( 1, 100 ) > 90 then
		bonus_xp = 50 + GlobalBountyCap
		GlobalBountyCap = GlobalBountyCap + 1
	end

	for _,v in pairs(heroes) do
		local memberID = v:GetPlayerID()
		v:AddExperience( xp_amount + bonus_xp, 0, false, false )
		PlayerResource:ModifyGold( memberID, gold_amount, true, 0 )
	end
end

function PseudoRandom(ability, chance)
	if ability.pChance == nil then
		ability.pChance = chance
	end

	local cGrow = chance * 0.01
	local current_chance = RandomInt(1, 100)

	if current_chance > (100 - ability.pChance) then
		if ability.pChance > chance then
			ability.pChance = chance
		end
		ability.pChance = ability.pChance - cGrow
		return true
	else
		if ability.pChance < chance then
			ability.pChance = chance
		end
	end

	ability.pChance = ability.pChance + cGrow
	return false
end

function StorageCheck( eventSourceIndex, args )
	local player_id 		= args.PlayerID
	local btn_type 			= args.btype
	local gold_amount 		= PlayerResource:GetGold(player_id)
	local tier_num 			= args.tier
	local steam_id 			= PlayerResource:GetSteamAccountID(player_id)
	local player 			= PlayerResource:GetPlayer(player_id)
	local hero 				= player:GetAssignedHero() 

	local data = {}

	print("gold "..gold_amount..", hero name "..hero:GetName() )
	print("steam id "..steam_id)
	if btn_type == "save" then
		local hero_hp = hero:GetHealth()
		table.insert(data, gold_amount)
		table.insert(data, hero_hp)
		local rankings = PlayerRankingsGet(player)
		table.insert(data, rankings)
		Storage:Put( steam_id, data, function( resultTable, successBool )
			if successBool then
				print("Successfully put data [gold, hp] in storage")
			end
		end)
	end

	if btn_type == "load" then
		Storage:Get( steam_id, function( resultTable, successBool )
			if successBool then
				print("successBool true")
				PrintTable("resutls",resultTable)
				PlayerResource:SetGold(player_id,resultTable[1],false)
				hero:SetHealth(resultTable[2])
				print("Successfully get data")
			end
		end)
	end
end

function PlayerRankingsGet( player )
	local table = {
		baseMMR = 0,
		newMMR = 0


	}
	local winStatus = player.winStatus

	local current_mmr = 0

	Storage:Get( steam_id, function( resultTable, successBool )
		if successBool then
			table["baseMMR"] = resultTable[3]["baseMMR"]
			current_mmr = resultTable[3]["newMMR"]
		end
	end)

	if winStatus == true then
		current_mmr = current_mmr + 25
	else
		current_mmr = current_mmr - 25
	end
	
	table["baseMMR"] = current_mmr

	return table
end

