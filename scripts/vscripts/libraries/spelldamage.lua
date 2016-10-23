-- ===========================================================================
-- Simple Spell Damage Amplifier System
-- ===========================================================================

-- ===========================================================================
-- Описание

--[[
	Эта простенькая система применяется для увеличения наносимого урона какими-либо источниками.
	Система создает новый аттрибут для героев (и для не-героев), типа силы, ловкости, интеллекта, брони и т.д..
	Этот новый аттрибут позволяет увеличивать наносимый урон какими-либо способностями юнитов.
	Аттрибут можно увеличивать с помощью тех же предметов или способностей, которые могут увеличить стандартные аттрибуты.
	К примеру, "Посох", дающий +10 интеллекта и +15 силы заклинаний.
	 
	Также функция SpellDamage предназначена заменить стандартную 
	функцию ApplyDamage, потому что первая функция уже имеет в себе вторую.
]]

-- ===========================================================================
-- Использование
-- 
--[[
	local values = {
		caster = caster,
		target = target,
		ability = ability,
		damage_amount = 1000, -- базовый урон от способности
		damage_type = DAMAGE_TYPE_MAGICAL, -- or DAMAGE_TYPE_PURE or DAMAGE_TYPE_PHYSICAL (можно не указывать)
		damage_ratio = 0.5, -- множитель дополнительного урона от показателя силы заклинаний героя
	}

	SpellDamage:Deal( values )
]]


-- ===========================================================================
-- Будущие возможности
-- 
-- / Подобие магического сопротивления, касающегося уменьшения урона от Spell Damage
-- / Добавить увеличитель показателя RATIO



SPELLDAMAGE_VERSION = "1.01 ALPHA"

if SpellDamage == nil then
	_G.SpellDamage = class({})
end

function SpellDamage:Deal( args )
	local aUnit 			= args.caster
	local aTarget 			= args.target
	if aUnit.SpellAmplifier == nil then
		aUnit.SpellAmplifier = SPELLDAMAGE_AMPLIFIER_BASE
	end
	local aAmplifier 		= aUnit.SpellAmplifier
	local dmg 				= math.floor(args.damage_amount)
	local ratio 			= args.damage_ratio
	local isPrint 			= args.isPrint or false

	local newDmg = math.floor(dmg + ratio * aAmplifier)

	local dmgTable = {}
	dmgTable[1] = "Base Damage = "..dmg
	dmgTable[2] = "Current Spell Power = "..aAmplifier
	dmgTable[3] = "Spell Power Ratio = "..ratio
	dmgTable[4] = "Final Damage = "..newDmg

	if isPrint then
		print( "-- Spell Power Table --")
		for i = 1, 4 do
			print(dmgTable[i])
		end
		print( "-- End --")
	end

	return newDmg
end

function SpellDamage:Reduction( keys )

end

-- HealthRemoval(nil, target, ability, 100, 0, nil)
function HealthRemoval(caster, target, ability, damage, dmg_type, lethal)
	local current_health = target:GetHealth()
	local resistance = 0
	local real_dmg = 0
	local killable = false

	if ability == nil then
		return nil
	end

--[[
	Variables of dmg_type
	0 - pure damage
	1 - magical damage
	2 - physical damage
]]

	if dmg_type == 0 then
		------------
		real_dmg = damage
	elseif dmg_type == 1 then
		------------
		resistance = target:GetMagicalArmorValue()
	elseif dmg_type == 2 then
		------------
		resistance = target:GetPhysicalArmorValue()
	end
	
	real_dmg = damage * (1 - resistance)

	if real_dmg > current_health then
		real_dmg = current_health + 1
		killable = true
	end

	if lethal ~= nil and caster ~= nil and killable == true then
		target:Kill(ability, caster)
	end

	if caster ~= nil then
		caster.TotalDamageValue = caster.TotalDamageValue + real_dmg
	end

end

-- ===========================================================================
-- Изменения
--[[
	v1.01
	- Из-за того, что функция ApplyDamage не работает внутри другой функции, теперь SpellDamage:Deal лишь возвращает число урона.
	
	v1.01b
	- Аргументы ability и damage_type больше не нужны.
	- Количество урона теперь возводится в целое число.
	- Аргумент isPercentage удален.

	v1.02
	- Добавлен новый аргумент isPrint (можно не указывать). При true отображает таблицу урона в консоле.
	- Теперь аргумент target необязательный (можно не указывать). При указывании возвращает урон, уменьшая магическим сопротивлением юнита.
]]
