function Decay( event )
	local caster 	= event.caster
	local ability	= event.ability
	local level 	= ability:GetLevel() - 1
	local radius 	= ability:GetLevelSpecialValueFor('radius', level)
	local dmg 		= ability:GetLevelSpecialValueFor('decay_damage', level)

	local damageTable = {}
	damageTable.attacker = caster
	damageTable.ability = ability
	damageTable.damage_type = DAMAGE_TYPE_MAGICAL
	damageTable.damage = dmg

	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 950, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,unit in pairs(units) do
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_dirge_decay_self", {})
		if caster:HasModifier("modifier_dirge_flesh_golem") then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_dirge_decay_self", {})
		end
		ability:ApplyDataDrivenModifier(caster, unit, "modifier_dirge_decay_enemy", {})
		damageTable.victim = unit
		ApplyDamage(damageTable)
	end
	
end