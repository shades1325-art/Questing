-- Offline regression test; run from the BetterQuesting script root:
-- lua Tests/test_giovanni_battle.lua
-- Also compatible with the client's MoonSharp interpreter. Only the host
-- APIs/dependencies are mocked; the actual P13 battle method is exercised.
local actions, calls = {}, {}
local health, pp, active, map, wild

local function action(value)
	table.insert(actions, value)
	return true
end

local BaseQuest = {}
function BaseQuest:new(name, description, level, dialogs)
	self.__index = self
	return setmetatable({ name = name, description = description,
		level = level, dialogs = dialogs, canSwitch = true }, self)
end
function BaseQuest:battle()
	table.insert(calls, "shared")
	return action("shared")
end
function BaseQuest:getHeroPokemonIndex() return 1 end

local modules = {
	["Quests/Quest"] = BaseQuest,
	["Quests/Dialog"] = { new = function() return { state = false } end },
	["Libs/syslib"] = {}, ["Libs/gamelib"] = {}, ["Libs/teamlib"] = {},
	["Libs/pclib"] = {}, ["Data/luaPokemonData"] = {},
}
local originalRequire = require
require = function(name)
	assert(modules[name], "Unexpected dependency: " .. name)
	return modules[name]
end
local loaded, Giovanni = pcall(dofile, "Quests/Kanto/P13RocketCeladonQuest.lua")
require = originalRequire
assert(loaded, Giovanni)

function getMapName() return map end
function isWildBattle() return wild end
function getTeamSize() return #health end
function getActivePokemonNumber() return active end
function getPokemonHealth(index)
	assert(health[index] ~= nil, "Out-of-range party slot: " .. index)
	return health[index]
end
function attack()
	table.insert(calls, "attack")
	if health[active] > 0 and pp[active] > 0 then
		return action("attack:" .. active)
	end
	return false
end
local function sendAvailable(needPP)
	for index = 1, #health do
		if index ~= active and health[index] > 0 and (not needPP or pp[index] > 0) then
			active = index
			return action("switch:" .. index)
		end
	end
	return false
end
function sendUsablePokemon()
	table.insert(calls, "usable")
	return sendAvailable(true)
end
function sendAnyPokemon()
	table.insert(calls, "any")
	return sendAvailable(false)
end
function useAnyMove()
	table.insert(calls, "move")
	return health[active] > 0 and action("move:" .. active)
end
function sendPokemon() error("Do not force hero/backup slots before attacking") end
function useItem() error("Superboss battle must not use items") end
function useItemOnPokemon() error("Superboss battle must not use items") end
function relog() error("Do not relog when the hero faints in this battle") end

local assertions = 0
local function setup(size)
	health, pp, active, map, wild = {}, {}, 1, "Rocket Hideout B4F", false
	for index = 1, size do health[index], pp[index] = 100, 10 end
	return Giovanni:new()
end
local function tick(quest, expected, firstCall)
	actions, calls = {}, {}
	local result = quest:battle()
	assert(calls[1] == (firstCall or "attack"), "Wrong first action: " .. tostring(calls[1]))
	if expected then
		assert(result == true and #actions == 1 and actions[1] == expected,
			"Expected only " .. expected .. ", got " .. table.concat(actions, ","))
	else
		assert(not result and #actions == 0, "Exhausted party must not fabricate an action")
	end
	assertions = assertions + 1
end

-- Slot 1 Charizard attacks, then each surviving backup attacks repeatedly.
-- No backup changes until its own HP reaches zero. Covers all party sizes.
for size = 1, 6 do
	local quest = setup(size)
	tick(quest, "attack:1")
	for slot = 2, size do
		health[active] = 0
		tick(quest, "switch:" .. slot)
		tick(quest, "attack:" .. slot)
		tick(quest, "attack:" .. slot)
	end
	health[active] = 0
	tick(quest, nil)
end

-- Exact reported loop: start/reload with Charizard fainted, Dodrio active.
local quest = setup(3)
health[1], active = 0, 2
tick(quest, "attack:2")
tick(quest, "attack:2")
health[2] = 0
tick(quest, "switch:3")
tick(quest, "attack:3")

-- Exhausted offensive PP: prefer an available member with usable PP.
quest = setup(4)
health[1], pp[2], active = 0, 0, 2
tick(quest, "switch:3")
tick(quest, "attack:3")

-- The existing fallback remains available when no offensive move is usable.
quest = setup(1)
pp[1] = 0
tick(quest, "move:1")

-- Pending story encounter and mid-battle reload both use the same method.
quest = setup(2)
quest.giovanniBattlePending = true
map = "Celadon City"
tick(quest, "attack:1")
quest = setup(2)
tick(quest, "attack:1")

-- Do not change normal wild-battle policy or other maps' shared battle flow.
quest = setup(3)
wild = true
tick(quest, "shared", "shared")
wild, map = false, "Route 3"
tick(quest, "shared", "shared")

print("Giovanni battle regression: " .. assertions .. " action checks passed")
