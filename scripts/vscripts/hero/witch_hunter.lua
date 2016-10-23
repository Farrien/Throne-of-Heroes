function SoulBreak( keys )
	local caster 	= keys.caster
	local ability	= keys.ability
	local level 	= ability:GetLevel() - 1
	local target	= keys.target
	local target_loc = target:GetAbsOrigin()

	if not ( target:IsHero() or target:IsCreep() or target:IsAncient() ) or target:GetMaxMana() == 0 or target:IsMagicImmune() then
		return nil
	end

	EmitSoundOnLocationForAllies(target_loc, "Hero_Antimage.ManaBreak", caster)
	if target:CanEntityBeSeenByMyTeam(caster) then
		EmitSoundOnLocationForAllies(target_loc, "Hero_Antimage.ManaBreak", target)
	end
	
	local burn_effect = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(burn_effect, 0, target_loc )

	local current_mana_burn	= ability:GetLevelSpecialValueFor("current_mana_burn", level)
	local max_mana_burn		= ability:GetLevelSpecialValueFor("max_mana_burn", level)
	local target_mana		= target:GetMana()
	local target_maxmana	= target:GetMaxMana()
	local dmg_multiplier	= ability:GetLevelSpecialValueFor("dmg_multiplier", level)

	-- Общая выжженная мана
	local burned_mana		= (target_maxmana * max_mana_burn / 100) + (target_mana * current_mana_burn / 100)

	-- Выжигаем ману
	target:SetMana(target_mana - burned_mana)
--	target:ReduceMana(target_mana - burned_mana)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, target, burned_mana, nil)

	local soulbreakdamage 	= dmg_multiplier * burned_mana
	if soulbreakdamage > 100 then
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, burned_mana, nil)
	end

	local spellDamage = SpellDamage:Deal({ caster = caster, damage_amount = soulbreakdamage, damage_ratio = 0.5 })
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = spellDamage, damage_type = ability:GetAbilityDamageType()})

	local debuff = "modifier_witch_hunter_soul_break_debuff"
	if not target:HasModifier(debuff) then
		ability:ApplyDataDrivenModifier(caster, target, debuff, {})
		target:SetModifierStackCount(debuff, ability, 1)
	end


end

function SoulBreakDebuff( event )
	local caster 		= event.caster
	local attacker		= event.attacker
	local dying			= event.target
	local ability		= event.ability
	local debuff 		= event.mod_stacks

	if dying then
		dying:SetModifierStackCount(debuff, ability, dying:GetModifierStackCount(debuff, ability) + 1)
	end
end

function ManaVoid(keys)
	local caster 		= keys.caster
	local target 		= keys.target_entities[1]
	local ability 		= keys.ability
	local targetLocation = target:GetAbsOrigin()
	local damagePerMana = ability:GetLevelSpecialValueFor('damage', ability:GetLevel() -1)
	local radius 		= ability:GetLevelSpecialValueFor('mana_void_aoe_radius', ability:GetLevel() -1)
	local damageToDeal 	= 0
	local targetMana 	= target:GetMana()
	local targetMaxMana = target:GetMaxMana()

	if HasScepter(caster) then
		damagePerMana = damagePerMana * 2
		ability:ApplyDataDrivenModifier(caster, target, "modifier_witch_hunter_mana_void_scepter_silence", {})
	end

	damageToDeal = (targetMaxMana - targetMana) * damagePerMana
	local spellDamage = SpellDamage:Deal({ caster = caster, damage_amount = damageToDeal, damage_ratio = 0.35 })

	local damageTable = {}
	damageTable.attacker = caster
	damageTable.ability = ability
	damageTable.damage_type = DAMAGE_TYPE_PURE
	damageTable.damage = spellDamage

	-- Находим всех врагов в радиусе
	local unitsToDamage = FindUnitsInRadius(caster:GetTeam(), targetLocation, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)
	-- Через цикл наносим каждому урон
	for _,v in ipairs(unitsToDamage) do
		damageTable.victim = v
		ApplyDamage(damageTable)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, v, damageToDeal, nil)
	end	
end

function SpellShield( keys )
	local caster = keys.caster
	local particle_stacks = keys.effect 
	local current_stacks = 1

	if not caster.spell_shield_particle then
		caster.spell_shield_particle = ParticleManager:CreateParticle(particle_stacks, PATTACH_OVERHEAD_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(caster.spell_shield_particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	end
end

function SpellShieldDestroy( keys )
	local caster = keys.caster

	ParticleManager:DestroyParticle(caster.spell_shield_particle, false)
	caster.spell_shield_particle = nil
end