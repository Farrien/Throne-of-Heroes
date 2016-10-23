THRONE_PATCH_VERSION = "1.0"
--[[
 Этот LUA файл предназначен для удобства изменения значений в настройках игры.


]]

print ( "[Throne of Heroes] Patch version "..THRONE_PATCH_VERSION )

-- BOOLEAN VALUES
--------------------
UNIVERSAL_SHOP								= true -- универсальный магазин (базовый и секретный лавки в одном)
RECOMMENDED_BUILDS							= false -- Рекомендуемая сборка для героя
FIRST_BLOOD									= true -- бонус за первое убийство
LOSE_GOLD_ON_DEATH							= false -- золото теряется при смерти
USE_BASE_HERO_BOUNTY 						= false 
USE_MAXHEROLEVEL							= false -- включает возможность изменить максимальный уровень героев. Значение меняется от MAXHEROLEVEL.
GAME_OPTIONS_SET							= false

-- INTEGER VALUES
--------------------
RUNE_SPAWN_TIME								= 60 -- Цикл появления рун на карте (в секундах)
FOUNTAIN_HP_REGEN							= 10 -- Восстановление здоровья фонтаном каждую секунду (в процентах)
FOUNTAIN_MP_REGEN							= 10 -- Восстановление маны фонтаном каждую секунду (в процентах)
GOLD_PER_TICK 								= 5 -- количество золота даримое всем героям каждые GOLD_TICK секунд


INITIAL_GOLD 								= 625 -- Стартовое золото
HERO_STARTING_LEVEL							= 1
MAXHEROLEVEL								= 25 -- Максимальный уровень героя. USE_MAXHEROLEVEL должна быть true
MAX_AS 										= 1000 -- Максимальная скорость атаки
FIXED_RESPAWN_TIME							= 3 -- Время возрождения героя (по умолчанию -1)

BASE_TALENT_POINTS							= 1 -- Стартовое количество очков талантов

BUYBACK_COST_BASE							= 125
BUYBACK_COST_LEVELED						= 70 -- увеличение байбека за каждый уровень
BUYBACK_COST_TIMED 							= 12 -- увеличение байбека за каждую минуту
BUYBACK_PENALTY_DURATION					= 30
BUYBACK_COOLDOWN							= 60

SPELLDAMAGE_AMPLIFIER_BASE 					= 15

HERO_KILL_BOUNTY_BASE						= 75
HERO_KILL_BOUNTY_LVL_DIFF					= 35
HERO_KILL_MINIMUM_LOSS						= 75
HERO_KILL_LVL_LOSS							= 15

-- FLOAT VALUES
--------------------
MAP_ICON_SIZE								= 1.35 -- Размер иконки героев на карте
HERO_SELECTION_TIME							= 45.0 -- Время на выбор героев
PREGAMETIME									= 30.0 -- Время до начала игры
GOLD_TICK 									= 5.0
CAMERA_DISTANCE 							= 1210.0 -- Высота камеры (по умолчанию в Dota 2 это 1134.0)

BASE_RESPAWN_TIME 							= 0.5 -- Базовое время возрождения
LEVEL_RESPAWN_TIME 							= 0.9 -- Дополнительное время возрождения за каждый уровень 
TREE_REGROW_TIME							= 120.0

-- STRING VALUES
--------------------


-- NOT SORTED
--------------------

IMBA_PICK_MODE_ALL_RANDOM = false
ALLOW_SAME_HERO_SELECTION = true
IMBA_ALL_RANDOM_HERO_SELECTION_TIME = 0
IMBA_ABILITY_MODE_RANDOM_OMG = false

HERO_INITIAL_REPICK_GOLD = 0
HERO_INITIAL_RANDOM_GOLD = 0

HERO_GOLD_BONUS = 0
CREEP_GOLD_BONUS = 0
CREEP_XP_BONUS = 0
HERO_XP_BONUS = 0


