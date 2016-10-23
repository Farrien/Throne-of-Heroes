--[[
	Описание

]]

-------------------------------------------------------------------------------------------------
-- Главная функция
-------------------------------------------------------------------------------------------------
function ToH:_OnEntityKilled( event )
	
	local dying = EntIndexToHScript( event.entindex_killed )
	local dyingTeam = dying:GetTeam()
	local killer = EntIndexToHScript( event.entindex_attacker )
	local killerTeam = killer:GetTeam()

	-------------------------------------------------------------------------------------------------
	-- Отправляемые данные
	-------------------------------------------------------------------------------------------------
	local values = { dying = dying, killer = killer }

	-------------------------------------------------------------------------------------------------
	-- IMBA: Hero kill bounty calculation
	-------------------------------------------------------------------------------------------------
	not_neutral_kill = false
	if killer:GetTeam() == DOTA_TEAM_GOODGUYS or killer:GetTeam() == DOTA_TEAM_BADGUYS then
		not_neutral_kill = false
	end

	if dying:IsRealHero() and dying:GetTeam() ~= killer:GetTeam() and killer:IsRealHero() and not_neutral_kill then
		local dying_level = dying:GetLevel()
		local killer_level = killer:GetLevel()
		local level_difference = 0

		if killer_level >= dying_level then
			level_difference = 0
		else
			level_difference = dying_level - killer_level
		end


		local dying_gold_loss = math.max(dying_level * HERO_KILL_LVL_LOSS, HERO_KILL_MINIMUM_LOSS)
		local killer_bounty = math.floor(HERO_KILL_BOUNTY_BASE + level_difference * HERO_KILL_BOUNTY_LVL_DIFF )
		
		killer:ModifyGold(killer_bounty, true, DOTA_ModifyGold_HeroKill)
		dying:ModifyGold(dying_gold_loss, false, DOTA_ModifyGold_Death)

		local tablePrint = {}
		tablePrint.leveldiffirence = level_difference
		tablePrint.dying_gold_loss = dying_gold_loss
		tablePrint.killer_bounty = killer_bounty
		PrintTable("Kill Bounty", tablePrint)
	end

	-------------------------------------------------------------------------------------------------
	-- Настройки выкупа
	-------------------------------------------------------------------------------------------------
	if dying:IsRealHero() then
		local dying_player = dying:GetPlayerID() 
		if dying:IsRealHero() then
			local buyback_cost = ToH:cBuyback( values )
			print( buyback_cost )
			PlayerResource:SetCustomBuybackCost(dying_player, buyback_cost)
			PlayerResource:SetBuybackGoldLimitTime(dying_player, BUYBACK_PENALTY_DURATION)
			PlayerResource:SetCustomBuybackCooldown(dying_player, BUYBACK_COOLDOWN)
		end
	end
end

-------------------------------------------------------------------------------------------------
-- Вычисление выкупа
-------------------------------------------------------------------------------------------------
function ToH:cBuyback( val )
	local dying_level 	= val.dying:GetLevel()
	local buyback_cost 	= dying_level * BUYBACK_COST_LEVELED + BUYBACK_COST_BASE + BUYBACK_COST_TIMED * (self.gameTime / 60)
--	PrintTable("cBuyback", val)
	return buyback_cost
end