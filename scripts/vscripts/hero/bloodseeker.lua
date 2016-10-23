function BloodRite( keys )
--	PrintTable("BloodRite", keys)
	local caster 	= keys.caster
	local ability	= keys.ability
	local group		= keys.target_entities
	local hp_steal	= ability:GetLevelSpecialValueFor('health_steal', ability:GetLevel() -1) / 100
	local damage 	= ability:GetLevelSpecialValueFor('damage', ability:GetLevel() -1)
	local heal_amount = 0

	local damageTable = {}
	damageTable.attacker = caster
	damageTable.ability = ability
	damageTable.damage_type = ability:GetAbilityDamageType()
	damageTable.damage = damage

	for _,target in pairs(group) do 
		if not target:IsMagicImmune() then
			damageTable.damage = damage + target:GetMaxHealth() * hp_steal
			damageTable.victim = target
			ApplyDamage(damageTable)
			ability:ApplyDataDrivenModifier(caster, target, "modifier_strygwyr_blood_rite_silence", {})

			heal_amount = heal_amount + target:GetMaxHealth() * hp_steal
		end
	end

	caster:Heal(heal_amount, caster)
	caster:EmitSound("Hero_OgreMagi.Bloodlust.Cast")
end


function ThirstTick( keys )
	local caster 	= keys.caster
	local ability	= keys.ability
	local group		= keys.target_entities
	local thrist_b = "modifier_thirst_new"
	local ablvl 	= ability:GetLevel() - 1

	if caster.BloodShield == nil then
		caster.BloodShield = 1
	end

	local stacks = 0
	for _,target in pairs(group) do 
		local hp = target:GetHealthPercent() 

		if hp <= 95 and hp > 90  then
			stacks = stacks + 1
		elseif hp <= 90 and hp > 80 then
			stacks = stacks + 2
		elseif hp <= 80 and hp > 70 then
			stacks = stacks + 3
		elseif hp <= 70 and hp > 60 then
			stacks = stacks + 4
		elseif hp <= 60 and hp > 50 then
			stacks = stacks + 5
		elseif hp <= 50 and hp > 40 then
			stacks = stacks + 6
		elseif hp <= 40 and hp > 30 then
			stacks = stacks + 7
		elseif hp <= 30 and hp > 20 then
			stacks = stacks + 8
		elseif hp <= 20 and hp > 10 then
			stacks = stacks + 9
		elseif hp <= 10 and hp > 0 then
			stacks = stacks + 10
		end
	end

	if stacks > 0 then
		ability:ApplyDataDrivenModifier(caster, caster, thrist_b, {})
		caster:SetModifierStackCount(thrist_b, ability, stacks)
	end
	if stacks == 0 then
		caster:RemoveModifierByName(thrist_b) 
	end
	
	local shield_buff = "modifier_thirst_blood_shield_blank"
	local maxsize 	= ability:GetLevelSpecialValueFor("shield_maxsize", ablvl)
	local reduction = ability:GetLevelSpecialValueFor("shield_reduce_per_sec", ability:GetLevel()-1)
	if caster.BloodShield > 0 then
		caster.BloodShield = caster.BloodShield - (reduction / 2)

		ability:ApplyDataDrivenModifier(caster, caster, shield_buff, {})
		local shield_count = math.floor(caster.BloodShield / maxsize * 100)
		caster:SetModifierStackCount(shield_buff, ability, shield_count)
	end

	if caster.BloodShield <= 0 then
		caster.BloodShield = 0
		if caster:HasModifier(shield_buff) then
			caster:RemoveModifierByName(shield_buff)
		end
	end
end

function ThirstDeal( keys )
--	PrintTable("ThirstDeal", keys)
	local caster 	= keys.caster
	local ability	= keys.ability
	local ablvl 	= ability:GetLevel() - 1
	local maxsize 	= ability:GetLevelSpecialValueFor("shield_maxsize", ablvl)
	local dmg 		= math.ceil(keys.dmg)

	caster.BloodShield = caster.BloodShield + dmg
	if caster.BloodShield > maxsize then
		caster.BloodShield = maxsize
	end
end

function ThirstTake( keys )
--	PrintTable("ThirstTake", keys)
	local caster 	= keys.caster
	local ability	= keys.ability
	local ablvl 	= ability:GetLevel() - 1
	local maxsize 	= ability:GetLevelSpecialValueFor("shield_maxsize", ablvl)
	local dmga 		= math.ceil(keys.dmga)

	local heal_amount = 0
	if caster.BloodShield >= dmga then
		heal_amount = dmga
		caster.BloodShield = caster.BloodShield - dmga
	elseif caster.BloodShield < dmga then
		heal_amount = caster.BloodShield
		caster.BloodShield = 0
	elseif caster.BloodShield <= 0 then
		heal_amount = 0
	end

	if heal_amount > 0 then
		PseudoHeal(caster, heal_amount)
	end
end