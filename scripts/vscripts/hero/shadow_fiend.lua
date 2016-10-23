
function Necromastery( keys )
	local caster 			= keys.attacker
	local ability			= keys.ability
	local unit 				= keys.target
	local level 			= ability:GetLevel() - 1
	local soul_count 		= 1
	local hero_soul 		= ability:GetLevelSpecialValueFor("souls_hero_bonus", level)
	local max_souls 		= ability:GetLevelSpecialValueFor("max_souls", level)
	local modifier_base 	= keys.modifier
	local modifier_bonus 	= "modifier_shadow_fiend_necromastery_blank"
	local current_souls 	= caster:GetModifierStackCount(modifier_base, ability)
	local first_time 		= false

	if not unit == nil then
		print( unit:GetName() )
	end

--	if target:IsHero() then
--		soul_count = soul_count + hero_soul
--	end

	if not caster:HasModifier(modifier_base) then
		ability:ApplyDataDrivenModifier(caster, caster, modifier_base, {}) 
		caster:SetModifierStackCount(modifier_base, ability, soul_count)
		first_time = true
	end

	if first_time == false then
		if current_souls < max_souls then
			caster:SetModifierStackCount(modifier_base, ability, current_souls + soul_count)
		else
			ability:ApplyDataDrivenModifier(caster, caster, modifier_bonus, {}) 
		end
	end
end

function NecromasteryStack( keys )
	local caster 			= keys.caster
	local ability 			= keys.ability

	local modifier_bonus 	= "modifier_shadow_fiend_necromastery_bonus"
	local current_bonus 	= caster:GetModifierStackCount(modifier_bonus, ability)

	
	ability:ApplyDataDrivenModifier(caster, caster, modifier_bonus, {}) 
	
	caster:SetModifierStackCount(modifier_bonus, ability, current_bonus + 1)
end

function NecromasteryExpire( keys )
	local caster 			= keys.caster
	local ability 			= keys.ability
	local modifier_bonus 	= "modifier_shadow_fiend_necromastery_bonus"
	local current_bonus 	= caster:GetModifierStackCount(modifier_bonus, ability)

	caster:SetModifierStackCount(modifier_bonus, ability, current_bonus - 1)
end

function SoulRealease( event )
	local caster 			= event.caster
	local skill 			= caster:FindAbilityByName("shadow_fiend_necromastery")
	local ability 			= caster:FindAbilityByName("shadow_fiend_requiem")
	local multiplier 		= event.multiplier
	local level 			= ability:GetLevel() - 1
	local dmg				= ability:GetLevelSpecialValueFor("soul_damage", level)
	local radius			= ability:GetLevelSpecialValueFor("radius", level)
	local modifier_base 	= "modifier_shadow_fiend_necromastery_base"
	local modifier_bonus 	= "modifier_shadow_fiend_necromastery_bonus"
	local current_souls 	= caster:GetModifierStackCount(modifier_base, skill)
	local current_bonus 	= caster:GetModifierStackCount(modifier_bonus, skill)
	local location 			= caster:GetAbsOrigin()

	local overdamage 		= (current_souls + current_bonus) * dmg * multiplier * 0.5

	if multiplier == 0.5 then
		caster:SetModifierStackCount(modifier_base, skill, current_souls / 2)
	end

	if not ability then
		return nil
	end

	-- Special Effect
	local speceffect = ParticleManager:CreateParticle("particles/hero/shadow_fiend/custom_particle_4/particle_base.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(speceffect, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(speceffect, 1, Vector(radius,0,0))
	ParticleManager:SetParticleControl(speceffect, 2, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(speceffect, 2, Vector(radius,0,0))

	-- Sound
	caster:EmitSound("Hero_Nevermore.RequiemOfSouls") 

	local damageTable = {}
	damageTable.attacker 	= caster
	damageTable.ability 	= ability
	damageTable.damage_type = DAMAGE_TYPE_MAGICAL

	local unitsToDamage 	= FindUnitsInRadius(caster:GetTeam(), location, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
	
	for _,v in ipairs(unitsToDamage) do
		local distance = caster:GetRangeToUnit(v)
		damageTable.damage = (1 - distance / radius) * overdamage
		if damageTable.damage < 0 then
			damageTable.damage = damageTable.damage * (-1)
		end
		damageTable.victim = v
		ApplyDamage(damageTable)
	--	print(v:GetName().." damaged by "..damageTable.damage.." in range "..distance)
	end	
end