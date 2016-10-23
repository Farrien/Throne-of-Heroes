
function Shukuchi( keys )
	local caster = keys.caster



end


function TimeLapseThink( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ablvl = ability:GetLevel()-1
	local group = keys.target_entities

	local backward_warp = ability:GetLevelSpecialValueFor("warp_time", ablvl)
	local tickrate = ability:GetLevelSpecialValueFor("tickrate", ablvl)
	local ticks_count = math.modf(backward_warp/tickrate)

	for _,unit in pairs(group) do 
		if unit.TimeLapse == nil then
			unit.TimeLapse = {}
		end
		if unit:IsAlive() then
			if #unit.TimeLapse == ticks_count then
				table.remove(unit.TimeLapse,1)
			end
			table.insert(unit.TimeLapse,{unit:GetAbsOrigin(),unit:GetHealth(),unit:GetMana()})
		end
	end
end

function TimeLapseCast( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ablvl = ability:GetLevel()-1
	local group = keys.target_entities

	if caster:HasScepter() then
		group = FindUnitsInRadius(caster:GetTeam(), Vector(0, 0, 0), nil, 9999, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, 0, false)
	end

	for _,unit in pairs(group) do 
		FindClearSpaceForUnit(unit, unit.TimeLapse[1][1], true)
		unit:SetHealth(unit.TimeLapse[1][2])
		unit:SetMana(unit.TimeLapse[1][3])
		local visual = ParticleManager:CreateParticle("", PATTACH_OVERHEAD_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(visual, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	end
	
	EmitGlobalSound("Hero_Weaver.TimeLapse")
end
