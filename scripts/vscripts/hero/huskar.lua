function BerserkerBloodUpdate( keys )
	local caster 		= keys.caster
	local ability 		= keys.ability
	local modifier 		= "modifier_huskar_berserker_blood"
	local hp			= caster:GetHealthPercent() 
	
	if caster.BerserkerCount == nil then
		caster.BerserkerCount = 1
		caster:SetModifierStackCount(modifier, ability, 1)
	end

	if hp > 87 then
		caster:SetModifierStackCount(modifier, ability, 1)
	elseif hp <= 87 and hp > 80 then
		caster:SetModifierStackCount(modifier, ability, 2)
	elseif hp <= 80 and hp > 73 then
		caster:SetModifierStackCount(modifier, ability, 3)
	elseif hp <= 73 and hp > 66 then
		caster:SetModifierStackCount(modifier, ability, 4)
	elseif hp <= 66 and hp > 59 then
		caster:SetModifierStackCount(modifier, ability, 5)
	elseif hp <= 59 and hp > 52 then
		caster:SetModifierStackCount(modifier, ability, 6)
	elseif hp <= 52 and hp > 45 then
		caster:SetModifierStackCount(modifier, ability, 7)
	elseif hp <= 45 and hp > 38 then
		caster:SetModifierStackCount(modifier, ability, 8)
	elseif hp <= 38 and hp > 31 then
		caster:SetModifierStackCount(modifier, ability, 9)
	elseif hp <= 31 and hp > 24 then
		caster:SetModifierStackCount(modifier, ability, 10)
	elseif hp <= 24 and hp > 17 then
		caster:SetModifierStackCount(modifier, ability, 11)
	elseif hp <= 17 and hp > 10 then
		caster:SetModifierStackCount(modifier, ability, 12)
	elseif hp <= 10 and hp > 3 then
		caster:SetModifierStackCount(modifier, ability, 13)
	elseif hp <= 3 then
		caster:SetModifierStackCount(modifier, ability, 14)
	end

	local modifier_count = caster:GetModifierStackCount(modifier, ability) * 10
	if not caster.berserkers_blood then
		caster.berserkers_blood = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_berserkers_blood_glow.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
	end
	ParticleManager:SetParticleControl(caster.berserkers_blood, 1, Vector(modifier_count,0,0))
	ParticleManager:SetParticleControlEnt(caster.berserkers_blood, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
end


function BerserkerEnrage( keys )
	local caster 		= keys.caster
	local ability 		= keys.ability
	local enrage 		= keys.enrage_buff
	local modifier 		= caster:GetModifierStackCount("modifier_huskar_berserker_blood", ability)
	local proc_chance 	= ability:GetLevelSpecialValueFor("enrage_chance", ability:GetLevel() - 1)

	if RandomInt(0, 100) <= proc_chance then
		ability:ApplyDataDrivenModifier(caster, caster, enrage, {})
		caster:SetModifierStackCount(enrage, ability, modifier)
	end
end