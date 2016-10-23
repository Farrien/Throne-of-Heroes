function ForgottenKnowledge( keys )
	local caster = keys.caster	
	local ability = keys.ability
	local bonusInt = keys.bonus_intellect
	
	ability:StartCooldown(ability:GetSpecialValueFor("interval"))

	ability.modifierStacks = ability.modifierStacks+bonusInt

	caster:ModifyIntellect(bonusInt)
	caster:CalculateStatBonus()

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_time_lord_forgotten_knowledge", {}) 
	caster:SetModifierStackCount("modifier_time_lord_forgotten_knowledge", ability, ability.modifierStacks)

--	EmitSoundOnClient("Hero_FacelessVoid.TimeLockImpact", caster:GetPlayerOwnerID() )
--	EmitSoundOn("Hero_FacelessVoid.TimeLockImpact", caster)
	EmitSoundOnLocationForAllies(caster:GetAbsOrigin(), "Hero_FacelessVoid.TimeLockImpact", caster)
end 

function StartCooldown(keys)
	local caster = keys.caster
	local ability = keys.ability

	if not ability.modifierStacks then
	    ability.modifierStacks = 0
	end

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_time_lord_forgotten_knowledge", {}) 
	ability:StartCooldown(ability:GetSpecialValueFor("interval"))
	caster:SetModifierStackCount("modifier_time_lord_forgotten_knowledge", ability, ability.modifierStacks)
end


function StopCooldown(keys)
	keys.ability:EndCooldown()
end


function BlackVoid( event )
	local caster 	= event.caster
	local ability 	= event.ability
	local group 	= event.target_entities

	ability:ApplyDataDrivenModifier(caster, caster, "modifier_time_lord_black_void_self", {})
--	caster:RemoveModifierByName("modifier_time_lord_black_void_debuff")

	for _,target in pairs(group) do 
		if target ~= caster then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_time_lord_black_void_debuff", {})
		end
	end

	EmitGlobalSound("Hero_FacelessVoid.Chronosphere")
end