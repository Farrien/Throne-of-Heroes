function MistCoil( keys )
	local caster 	= keys.caster
	local target 	= keys.target
	local ability 	= keys.ability
	local level 	= ability:GetLevel() - 1
	local dmg 		= ability:GetLevelSpecialValueFor( "target_damage" , level  )
	local self_dmg = ability:GetLevelSpecialValueFor( "self_damage" , level  )
	local heal 		= ability:GetLevelSpecialValueFor( "heal_amount" , level )
	local self_heal = ability:GetLevelSpecialValueFor( "self_heal" , level )
	local proj_speed = ability:GetSpecialValueFor( "projectile_speed" )
	local particle 	= "particles/units/heroes/hero_abaddon/abaddon_death_coil.vpcf"
	local modifier 	= "modifier_netherlyte_shadow_edge_buff"

	caster:EmitSound("Hero_Abaddon.DeathCoil.Cast")
	target:EmitSound("Hero_Abaddon.DeathCoil.Target")

	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		ApplyDamage({ victim = target, attacker = caster, damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL })
	else
		target:Heal(heal, caster)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, heal, nil)
	end

	if caster:HasModifier(modifier) then
		caster:Heal(self_heal, caster)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, self_heal, nil)
	else
		ApplyDamage({ victim = caster, attacker = caster, damage = self_dmg, damage_type = DAMAGE_TYPE_MAGICAL })
	end
	
	local info = {
		Target = target,
		Source = caster,
		Ability = ability,
		EffectName = particle,
		bDodgeable = false,
			bProvidesVision = true,
			iMoveSpeed = proj_speed,
        iVisionRadius = 0,
        iVisionTeamNumber = caster:GetTeamNumber(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	ProjectileManager:CreateTrackingProjectile( info )

end

function UnholyPowerShield( keys )
	--print("Unholy Power Shield is casted!")
	local caster 		= keys.caster
	local target 		= keys.target
	local ability 		= keys.ability
	local shield_modifier 	= keys.shield_modifier
	local cast_sound 	= keys.cast_sound
	local purge 		= true
	local shield_size 	= target:GetModelRadius() * 0.8
	
	--target:Heal(heal, caster)
	--SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, heal, nil)
	--print("Healed!")
	
	EmitSoundOn(cast_sound, target)
	target:RemoveModifierByName(shield_modifier)
	ability:ApplyDataDrivenModifier(caster, target, shield_modifier, {})
--	target:PowerShield = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) 
	if purge then
		local RemovePositiveBuffs = false
		local RemoveDebuffs = true
		local BuffsCreatedThisFrameOnly = false
		local RemoveStuns = true
		local RemoveExceptions = false
		target:Purge(RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)	
	end

	Timers:CreateTimer(0.01, function() 
		target.ShieldParticle = ParticleManager:CreateParticle("particles/hero/netherlyte/unholy_power_shield.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(target.ShieldParticle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	end)

end

function UnholyPowerShieldEnd( keys )
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	target:EmitSound("Hero_Abaddon.AphoticShield.Destroy")
	ParticleManager:DestroyParticle(target.ShieldParticle,false)

end

function ShadowEdgeHit( keys )
	local caster 	= keys.caster
	local target 	= keys.target
	local ability 	= keys.ability
	local level 	= ability:GetLevel() - 1
	local maxstacks	= ability:GetLevelSpecialValueFor("max_stacks", level)
	local debuff	= "modifier_netherlyte_shadow_edge_debuff"
	local buff		= "modifier_netherlyte_shadow_edge_buff"

	local stacks 	= target:GetModifierStackCount(debuff, ability)

	if stacks < maxstacks then
		ability:ApplyDataDrivenModifier(caster, target, debuff, {})
		target:SetModifierStackCount(debuff, ability, target:GetModifierStackCount(debuff, ability) + 1)
	elseif  stacks == 3 then
		ability:ApplyDataDrivenModifier(caster, caster, buff, {})
		target:RemoveModifierByName(debuff)
	end
end

function ShadowEdge( keys )
	local caster	= keys.caster
	local ability 	= keys.ability
	local level 	= ability:GetLevel() - 1
	local heal 		= ability:GetLevelSpecialValueFor("heal_boost", level)

	caster:Heal(heal / 2, caster)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, heal / 2, nil)

end