function RocketKnockback( event )
	local caster 	= event.caster
	local target 	= event.target
	local ability 	= event.ability
	local level 	= ability:GetLevel() - 1
	local distance 	= ability:GetLevelSpecialValueFor("knockback_range", level)
	local speed 	= ability:GetLevelSpecialValueFor("rocket_speed", level)

	local pos1 		= caster:GetAbsOrigin()
	-- Knockback
	local rocket_knockback =	{
		should_stun = 0,
		knockback_duration = distance / speed,
		duration = distance / speed,
		knockback_distance = distance,
		knockback_height = distance * 0.3,
		center_x = pos1.x,
		center_y = pos1.y,
		center_z = pos1.z
	}

	target:RemoveModifierByName("modifier_knockback")
	target:AddNewModifier(caster, ability, "modifier_knockback", rocket_knockback)
end