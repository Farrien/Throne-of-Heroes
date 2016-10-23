function SecondChance( keys )
--	PrintTable( "Second Chance", keys )
	local caster = keys.caster
	local ability = keys.ability

	if not caster:HasModifier("modifier_talent_id1_2_checker") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_talent_id1_2_checker", {})
	end

	if caster:GetHealth() <= 5 then
		caster:RemoveModifierByName("modifier_talent_id1_2")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_talent_id1_2_active", {})
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_talent_id1_2_cooldown", {})

	end
end

function SecondChanceChecker( keys )
	local caster = keys.caster
	local ability = keys.ability

	if caster:HasModifier("modifier_talent_id1_2_cooldown") then
		return nil
	end

	if not caster:HasModifier("modifier_talent_id1_2") then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_talent_id1_2", {})
	end
end

function LeechEnergy( keys )
	local caster = keys.attacker

	caster:SetMana( caster:GetMana() + 7 )
end