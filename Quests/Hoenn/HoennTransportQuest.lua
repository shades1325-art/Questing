-- Hoenn Transport Quest
--
-- This quest is deliberately kept as a Lua quest module.  It uses the
-- existing Quest/Pathfinder actions and the existing QuestManager ordering;
-- it does not add a second story controller or a C# battle/navigation path.
--
-- The transport quest is started after the Hoenn E4 quest returns the player
-- to Littleroot.  The three PC locations are server-selected, so the quest
-- visits the supported Hoenn PC list in a deterministic tour and lets the
-- station response decide which locations count.

local sys   = require "Libs/syslib"
local team  = require "Libs/teamlib"
local Quest = require "Quests/Quest"

local name        = "Hoenn Transport Quest"
local description = "Unlock the Hoenn Transmat and continue to Lilycove for Sinnoh access."
local level       = 0

local STATE_FILE_PREFIX = "flag/hoenn_transport_state_"

local function accountStateFile()
	local account = "unknown"
	if type(getAccountName) == "function" then
		account = getAccountName()
	end
	account = string.gsub(tostring(account or "unknown"), "[^%w_]", "_")
	if account == "" then
		account = "unknown"
	end
	return STATE_FILE_PREFIX .. account .. ".txt"
end

local function boolValue(value)
	return value == "1" or value == "true"
end

local function newState()
	return {
		phase = "to_mauville",
		routeName = "to_mauville",
		routeStep = 1,
		routeWaiting = false,
		centerIndex = 1,
		currentCenter = 1,
		lastCenter = 1,
		gruntsDefeated = 0,
		adminsDefeated = 0,
		keyFound = false,
		keyAttempt = "",
		keySweep = 1,
		newMauvilleSweep = 1,
		plusle = false,
		minun = false,
		pendingCreature = "",
		installCount = 0,
		stationAttempted = false,
		computerAttempted = false,
		computerAttemptedAt = 0,
		installResult = "",
		pendingBattle = false,
		divePrepared = 0,
	}
end

local function loadState()
	local state = newState()
	if type(readLinesFromFile) ~= "function" then
		return state
	end

	local lines = readLinesFromFile(accountStateFile())
	if type(lines) ~= "table" then
		return state
	end

	for _, line in ipairs(lines) do
		local key, value = string.match(tostring(line), "^([^=]+)=(.*)$")
		if key ~= nil then
			if key == "phase" then state.phase = value
			elseif key == "routeName" then state.routeName = value
			elseif key == "routeStep" then state.routeStep = tonumber(value) or 1
			elseif key == "routeWaiting" then state.routeWaiting = boolValue(value)
			elseif key == "centerIndex" then state.centerIndex = tonumber(value) or 1
			elseif key == "currentCenter" then state.currentCenter = tonumber(value) or 1
			elseif key == "lastCenter" then state.lastCenter = tonumber(value) or 1
			elseif key == "gruntsDefeated" then state.gruntsDefeated = tonumber(value) or 0
			elseif key == "adminsDefeated" then state.adminsDefeated = tonumber(value) or 0
			elseif key == "keyFound" then state.keyFound = boolValue(value)
			elseif key == "keyAttempt" then state.keyAttempt = value
			elseif key == "keySweep" then state.keySweep = tonumber(value) or 1
			elseif key == "newMauvilleSweep" then state.newMauvilleSweep = tonumber(value) or 1
			elseif key == "plusle" then state.plusle = boolValue(value)
			elseif key == "minun" then state.minun = boolValue(value)
			elseif key == "pendingCreature" then state.pendingCreature = value
			elseif key == "installCount" then state.installCount = tonumber(value) or 0
			elseif key == "stationAttempted" then state.stationAttempted = boolValue(value)
			elseif key == "computerAttempted" then state.computerAttempted = boolValue(value)
			elseif key == "computerAttemptedAt" then state.computerAttemptedAt = tonumber(value) or 0
			elseif key == "installResult" then state.installResult = value
			elseif key == "pendingBattle" then state.pendingBattle = boolValue(value)
			elseif key == "divePrepared" then state.divePrepared = tonumber(value) or 0
			end
		end
	end

	-- Migrate the short-lived earlier implementation name.  The transport
	-- quest's final battle is Steven; keep an interrupted account resumable if
	-- it was written while that phase was still called Courtney.
	if state.phase == "fight_final_courtney" then
		state.phase = "fight_final_steven"
	end

	return state
end

local function saveState(state)
	if type(logToFile) ~= "function" then
		return
	end

	local lines = {
		"phase=" .. tostring(state.phase or "to_mauville"),
		"routeName=" .. tostring(state.routeName or ""),
		"routeStep=" .. tostring(state.routeStep or 1),
		"routeWaiting=" .. (state.routeWaiting and "1" or "0"),
		"centerIndex=" .. tostring(state.centerIndex or 1),
		"currentCenter=" .. tostring(state.currentCenter or 1),
		"lastCenter=" .. tostring(state.lastCenter or 1),
		"gruntsDefeated=" .. tostring(state.gruntsDefeated or 0),
		"adminsDefeated=" .. tostring(state.adminsDefeated or 0),
		"keyFound=" .. (state.keyFound and "1" or "0"),
		"keyAttempt=" .. tostring(state.keyAttempt or ""),
		"keySweep=" .. tostring(state.keySweep or 1),
		"newMauvilleSweep=" .. tostring(state.newMauvilleSweep or 1),
		"plusle=" .. (state.plusle and "1" or "0"),
		"minun=" .. (state.minun and "1" or "0"),
		"pendingCreature=" .. tostring(state.pendingCreature or ""),
		"installCount=" .. tostring(state.installCount or 0),
		"stationAttempted=" .. (state.stationAttempted and "1" or "0"),
		"computerAttempted=" .. (state.computerAttempted and "1" or "0"),
		"computerAttemptedAt=" .. tostring(state.computerAttemptedAt or 0),
		"installResult=" .. tostring(state.installResult or ""),
		"pendingBattle=" .. (state.pendingBattle and "1" or "0"),
		"divePrepared=" .. tostring(state.divePrepared or 0),
	}
	logToFile(accountStateFile(), lines, true)
end

local function normalizedMapName(mapName)
	return string.lower(string.gsub(tostring(mapName or ""), "[^%w]", ""))
end

local function mapFunctionKey(mapName)
	local key = tostring(mapName or "")
	key = string.gsub(key, " ", "")
	key = string.gsub(key, "%.", "")
	key = string.gsub(key, "-", "")
	return key
end

local function step(mapNames, x, y)
	if type(mapNames) == "string" then
		mapNames = {mapNames}
	end
	local rawNames = {}
	local normalizedNames = {}
	local functionKeys = {}
	for _, mapName in ipairs(mapNames) do
		rawNames[#rawNames + 1] = mapName
		normalizedNames[#normalizedNames + 1] = normalizedMapName(mapName)
		functionKeys[#functionKeys + 1] = mapFunctionKey(mapName)
	end
	return {
		rawNames = rawNames,
		names = normalizedNames,
		keys = functionKeys,
		x = x,
		y = y,
	}
end

local function concatRoutes(...)
	local result = {}
	local routes = {...}
	for _, route in ipairs(routes) do
		for _, routeStep in ipairs(route or {}) do
			result[#result + 1] = routeStep
		end
	end
	return result
end

local function containsAny(message, words)
	local text = string.lower(tostring(message or ""))
	for _, word in ipairs(words) do
		if string.find(text, string.lower(word), 1, true) ~= nil then
			return true
		end
	end
	return false
end

local function cellKey(x, y)
	return tostring(tonumber(x) or -1) .. ":" .. tostring(tonumber(y) or -1)
end

local HoennTransportQuest = Quest:new()

-- The server can choose any three of these PC locations.  The order is a
-- route-friendly tour rather than an assumption about the server's random
-- choice.  The response from each Transmat Station determines whether the
-- location counts.
local centers = {
	{city = "Mauville City",       pc = "Pokecenter Mauville City"},
	{city = "Slateport City",      pc = "Pokecenter Slateport"},
	{city = "Dewford Town",        pc = "Pokecenter Dewford Town"},
	{city = "Petalburg City",      pc = "Pokecenter Petalburg City"},
	{city = "Rustboro City",       pc = "Pokecenter Rustboro City"},
	{city = "Verdanturf Town",     pc = "Pokecenter Verdanturf"},
	{city = "Lavaridge Town",      pc = "Pokecenter Lavaridge Town"},
	{city = "Fallarbor Town",      pc = "Pokecenter Fallarbor Town"},
	{city = "Fortree City",        pc = "Pokecenter Fortree City"},
	{city = "Lilycove City",       pc = "Pokecenter Lilycove City"},
	{city = "Mossdeep City",       pc = "Pokecenter Mossdeep City"},
	{city = "Sootopolis City",     pc = "Pokecenter Sootopolis City"},
	{city = "Pacifidlog Town",     pc = "Pokecenter Pacifidlog Town"},
	{city = "Ever Grande City",    pc = "Pokecenter Ever Grande City"},
	{city = "Oldale Town",         pc = "Pokecenter Oldale Town"},
}

local routes = {}

-- From the post-E4 Littleroot bedroom to Wattson's PC.
routes.to_mauville = {
	step("Player Bedroom Littleroot Town", 11, 5),
	step("Player House Littleroot Town", 11, 12),
	step("Littleroot Town", 23, 0),
	step("Route 101", 23, 0),
	-- Route 103 leaves from the north side of Oldale.  (25,35) is the
	-- reverse link on Route 103_A and is not a reachable Oldale exit.
	step("Oldale Town", 23, 0),
	step({"Route 103", "Route 103_A", "Route 103_B"}, 100, 19),
	step({"Route 110", "Route 110_A", "Route 110_B"}, 24, 3),
	step("Mauville City Stop House 1", 3, 2),
	step("Mauville City", 28, 13),
}

-- Initial Wattson objective: PC -> New Mauville.
routes.to_new_mauville = {
	step("Pokecenter Mauville City", 8, 22),
	step("Mauville City", 21, 30),
	step("Mauville City Stop House 1", 3, 12),
	step({"Route 110", "Route 110_A", "Route 110_C"}, 56, 33),
	step("New Mauville Entrance", 12, 4),
}

-- Return from New Mauville to the first PC after finding Plusle and Minun.
routes.to_mauville_pc = {
	step("New Mauville", 47, 53),
	step("New Mauville Entrance", 12, 15),
	step({"Route 110", "Route 110_A", "Route 110_C"}, 24, 3),
	step("Mauville City Stop House 1", 3, 2),
	step("Mauville City", 28, 13),
}

-- Final hand-off route.  It ends in Lilycove City so QuestManager can select
-- the existing To Sinnoh quest without changing its region navigation.
routes.to_lilycove = {
	step("New Mauville", 47, 53),
	step("New Mauville Entrance", 12, 15),
	step({"Route 110", "Route 110_A", "Route 110_C"}, 24, 3),
	step("Mauville City Stop House 1", 3, 2),
	step("Mauville City", 48, 17),
	step("Mauville City Stop House 4", 10, 6),
	step({"Route 118", "Route 118_A"}, 59, 0),
	step("Route 119B", 9, 0),
	step("Route 119A", 55, 8),
	step("Fortree City", 54, 14),
	step({"Route 120", "Route 120_A"}, 50, 101),
	step("Route 121", 85, 7),
}

-- A route segment for each possible PC-to-PC transition.
routes.center_1 = { -- Mauville -> Slateport
	step("Pokecenter Mauville City", 8, 22),
	step("Mauville City", 21, 30),
	step("Mauville City Stop House 1", 3, 12),
	step({"Route 110", "Route 110_A", "Route 110_B"}, 23, 140),
	step("Slateport City", 32, 25),
}
routes.center_2 = { -- Slateport -> Dewford
	step("Pokecenter Slateport", 8, 22),
	step("Slateport City", 13, 90),
	step("Route 109", 0, 57),
	step("Route 108", 0, 8),
	step("Route 107", 0, 5),
	step("Dewford Town", 13, 14),
}
routes.center_3 = { -- Dewford -> Petalburg
	step("Pokecenter Dewford Town", 8, 22),
	step("Dewford Town", 13, 0),
	step("Route 106", 7, 0),
	step("Route 105", 19, 0),
	step({"Route 104", "Route 104_B"}, 78, 110),
	step("Petalburg City", 27, 22),
}
routes.center_4 = { -- Petalburg -> Rustboro
	step("Pokecenter Petalburg City", 8, 22),
	step("Petalburg City", 0, 17),
	step({"Route 104", "Route 104_B"}, 35, 79),
	step({"Petalburg Woods", "Petalburg Woods_A"}, 24, 60),
	step({"Route 104", "Route 104_A"}, 41, 65),
	step({"Rustboro City", "Rustboro City_A"}, 38, 38),
}
routes.center_5 = { -- Rustboro -> Verdanturf
	step("Pokecenter Rustboro City", 8, 22),
	step({"Rustboro City", "Rustboro City_A"}, 78, 8),
	step({"Route 116", "Route 116_A"}, 62, 19),
	step({"Rusturf Tunnel", "Rusturf Tunnel_B"}, 35, 26),
	step("Verdanturf Town", 26, 9),
}
routes.center_6 = { -- Verdanturf -> Lavaridge
	step("Pokecenter Verdanturf", 8, 22),
	step("Verdanturf Town", 35, 12),
	step("Route 117", 101, 32),
	step("Mauville City Stop House 2", 10, 7),
	step("Mauville City", 21, 4),
	step("Mauville City Stop House 3", 4, 2),
	step("Route 111 South", 0, 23),
	step({"Route 112", "Route 112_B", "Route 112_C"}, 0, 59),
	step("Lavaridge Town", 20, 12),
}
routes.center_7 = { -- Lavaridge -> Fallarbor
	step("Pokecenter Lavaridge Town", 8, 22),
	step("Lavaridge Town", 43, 14),
	step({"Route 112", "Route 112_C"}, 20, 61),
	step("Fiery Path", 8, 43),
	step({"Route 112", "Route 112_A"}, 38, 8),
	step("Route 111 North", 45, 9),
	step("Route 113", 0, 18),
	step("Fallarbor Town", 30, 12),
}
routes.center_8 = { -- Fallarbor -> Fortree
	step("Pokecenter Fallarbor Town", 8, 22),
	step("Fallarbor Town", 0, 18),
	step("Route 114", 12, 119),
	step({"Meteor Falls 1F 1R", "Meteor Falls 1F 1R_A"}, 19, 46),
	step({"Route 115", "Route 115_A"}, 60, 150),
	step({"Rustboro City", "Rustboro City_A"}, 78, 8),
	step({"Route 116", "Route 116_A"}, 62, 19),
	step({"Rusturf Tunnel", "Rusturf Tunnel_B"}, 35, 26),
	step("Verdanturf Town", 35, 12),
	step("Route 117", 101, 32),
	step("Mauville City Stop House 2", 10, 7),
	step("Mauville City", 48, 17),
	step("Mauville City Stop House 4", 10, 6),
	step({"Route 118", "Route 118_A"}, 59, 0),
	step("Route 119B", 9, 0),
	step("Route 119A", 55, 8),
	step("Fortree City", 8, 11),
}
routes.center_9 = { -- Fortree -> Lilycove
	step("Pokecenter Fortree City", 8, 22),
	step("Fortree City", 54, 14),
	step({"Route 120", "Route 120_A"}, 50, 101),
	step("Route 121", 85, 7),
	step("Lilycove City", 26, 20),
}
routes.center_10 = { -- Lilycove -> Mossdeep
	step("Pokecenter Lilycove City", 8, 22),
	step("Lilycove City", 95, 18),
	step({"Route 124", "Route 124_A"}, 91, 39),
	step("Mossdeep City", 36, 21),
}
routes.center_11 = { -- Mossdeep -> Sootopolis
	step("Pokecenter Mossdeep City", 8, 22),
	step("Mossdeep City", 31, 55),
	step({"Route 127", "Route 127_A"}, 0, 48),
	step({"Route 126", "Route 126_A"}, 15, 71),
	step({"Route 126 Underwater", "Route 126 Underwater_A"}, 58, 96),
	step("Sootopolis City Underwater", 17, 11),
	step("Sootopolis City", 79, 56),
}
routes.center_12 = { -- Sootopolis -> Pacifidlog
	step("Pokecenter Sootopolis City", 8, 22),
	step("Sootopolis City", 50, 91),
	step("Sootopolis City Underwater", 17, 20),
	step({"Route 126 Underwater", "Route 126 Underwater_A"}, 15, 71),
	step({"Route 126", "Route 126_A"}, 125, 64),
	step({"Route 127", "Route 127_A"}, 38, 93),
	step("Route 128", 123, 33),
	step({"Route 129", "Route 129_A"}, 0, 24),
	step({"Route 130", "Route 130_A"}, 0, 38),
	step("Route 131", 0, 30),
	step("Pacifidlog Town", 19, 12),
}
routes.center_13 = { -- Pacifidlog -> Ever Grande
	step("Pokecenter Pacifidlog Town", 8, 22),
	step("Pacifidlog Town", 40, 16),
	step("Route 131", 80, 31),
	step({"Route 130", "Route 130_A"}, 80, 7),
	step({"Route 129", "Route 129_A"}, 57, 0),
	step("Route 128", 123, 33),
	step({"Ever Grande City", "Ever Grande City_A"}, 45, 64),
}
routes.center_14 = { -- Ever Grande -> Oldale
	step("Pokecenter Ever Grande City", 8, 22),
	step({"Ever Grande City", "Ever Grande City_A"}, 123, 32),
	step("Route 128", 38, 93),
	step({"Route 127", "Route 127_A"}, 37, 0),
	step({"Route 124", "Route 124_A"}, 0, 7),
	step("Lilycove City", 0, 25),
	step("Route 121", 0, 22),
	step({"Route 120", "Route 120_A"}, 0, 12),
	step("Fortree City", 0, 12),
	step("Route 119A", 11, 100),
	step("Route 119B", 25, 100),
	step({"Route 118", "Route 118_A"}, 3, 16),
	step("Mauville City Stop House 4", 0, 6),
	step("Mauville City", 21, 30),
	step("Mauville City Stop House 1", 3, 12),
	step({"Route 110", "Route 110_A", "Route 110_C"}, 0, 98),
	step({"Route 103", "Route 103_A", "Route 103_B"}, 25, 35),
	step("Oldale Town", 16, 26),
}
routes.center_15 = { -- Oldale -> Mauville (tour wrap)
	step("Pokecenter Oldale Town", 8, 22),
	step("Oldale Town", 23, 0),
	step({"Route 103", "Route 103_A", "Route 103_B"}, 100, 19),
	step({"Route 110", "Route 110_A", "Route 110_B"}, 24, 3),
	step("Mauville City Stop House 1", 3, 2),
	step("Mauville City", 28, 13),
}

-- Return routes are used only after the final Steven fight.  They all
-- begin by leaving the current station and finish in New Mauville.
local mauvilleToNew = {
	step("Mauville City", 21, 30),
	step("Mauville City Stop House 1", 3, 12),
	step({"Route 110", "Route 110_A", "Route 110_C"}, 56, 33),
	step("New Mauville Entrance", 12, 4),
}

routes.return_1 = concatRoutes({
	step("Transmat Station", 9, 10),
	step("Pokecenter Mauville City", 8, 22),
}, mauvilleToNew)
routes.return_2 = concatRoutes({
	step("Transmat Station", 9, 10),
	step("Pokecenter Slateport", 8, 22),
	step("Slateport City", 30, 0),
	step({"Route 110", "Route 110_A", "Route 110_B"}, 24, 3),
	step("Mauville City Stop House 1", 3, 2),
}, mauvilleToNew)
routes.return_3 = concatRoutes({
	step("Transmat Station", 9, 10),
	step("Pokecenter Dewford Town", 8, 22),
	step("Dewford Town", 55, 5),
	step("Route 107", 85, 4),
	step("Route 108", 0, 57),
	step("Route 109", 33, 0),
	step("Slateport City", 30, 0),
	step({"Route 110", "Route 110_A", "Route 110_B"}, 24, 3),
	step("Mauville City Stop House 1", 3, 2),
}, mauvilleToNew)
routes.return_4 = concatRoutes({
	step("Transmat Station", 9, 10),
	step("Pokecenter Petalburg City", 8, 22),
	step("Petalburg City", 0, 17),
	step({"Route 104", "Route 104_B"}, 45, 148),
	step("Route 105", 56, 125),
	step("Route 106", 96, 42),
	step("Dewford Town", 55, 5),
	step("Route 107", 85, 4),
	step("Route 108", 0, 57),
	step("Route 109", 33, 0),
	step("Slateport City", 30, 0),
	step({"Route 110", "Route 110_A", "Route 110_B"}, 24, 3),
	step("Mauville City Stop House 1", 3, 2),
}, mauvilleToNew)
routes.return_5 = concatRoutes({
	step("Transmat Station", 9, 10),
	step("Pokecenter Rustboro City", 8, 22),
	step({"Rustboro City", "Rustboro City_A"}, 41, 65),
	step({"Route 104", "Route 104_A"}, 24, 60),
	step({"Petalburg Woods", "Petalburg Woods_A"}, 35, 79),
	step({"Route 104", "Route 104_B"}, 0, 17),
	step("Petalburg City", 0, 17),
	step({"Route 104", "Route 104_B"}, 45, 148),
	step("Route 105", 56, 125),
	step("Route 106", 96, 42),
	step("Dewford Town", 55, 5),
	step("Route 107", 85, 4),
	step("Route 108", 0, 57),
	step("Route 109", 33, 0),
	step("Slateport City", 30, 0),
	step({"Route 110", "Route 110_A", "Route 110_B"}, 24, 3),
	step("Mauville City Stop House 1", 3, 2),
}, mauvilleToNew)
routes.return_6 = concatRoutes({
	step("Transmat Station", 9, 10),
	step("Pokecenter Verdanturf", 8, 22),
	step("Verdanturf Town", 35, 12),
	step("Route 117", 101, 32),
	step("Mauville City Stop House 2", 10, 7),
	step("Mauville City", 21, 4),
	step("Mauville City Stop House 3", 4, 2),
}, mauvilleToNew)
routes.return_7 = concatRoutes({
	step("Transmat Station", 9, 10),
	step("Pokecenter Lavaridge Town", 8, 22),
	step("Lavaridge Town", 43, 14),
	step({"Route 112", "Route 112_C"}, 0, 59),
	step("Route 111 South", 21, 97),
	step("Mauville City Stop House 3", 4, 2),
}, mauvilleToNew)
routes.return_8 = concatRoutes({
	step("Transmat Station", 9, 10),
	step("Pokecenter Fallarbor Town", 8, 22),
	step("Fallarbor Town", 0, 18),
	step("Route 113", 145, 19),
	step("Route 111 North", 27, 65),
	step("Route 111 Desert", 9, 57),
	step("Route 111 South", 21, 97),
	step("Mauville City Stop House 3", 4, 2),
}, mauvilleToNew)
routes.return_9 = concatRoutes({
	step("Transmat Station", 9, 10),
	step("Pokecenter Fortree City", 8, 22),
	step("Fortree City", 0, 12),
	step("Route 119A", 11, 100),
	step("Route 119B", 25, 100),
	step({"Route 118", "Route 118_A"}, 3, 16),
	step("Mauville City Stop House 4", 0, 6),
	step("Mauville City", 21, 30),
	step("Mauville City Stop House 1", 3, 12),
}, mauvilleToNew)
routes.return_10 = concatRoutes({
	step("Transmat Station", 9, 10),
	step("Pokecenter Lilycove City", 8, 22),
	step("Lilycove City", 0, 22),
	step({"Route 121", "Route 120_A"}, 0, 12),
	step("Fortree City", 0, 12),
	step("Route 119A", 11, 100),
	step("Route 119B", 25, 100),
	step({"Route 118", "Route 118_A"}, 3, 16),
	step("Mauville City Stop House 4", 0, 6),
	step("Mauville City", 21, 30),
	step("Mauville City Stop House 1", 3, 12),
}, mauvilleToNew)
routes.return_11 = concatRoutes({
	step("Transmat Station", 9, 10),
	step("Pokecenter Mossdeep City", 8, 22),
	step("Mossdeep City", 0, 7),
	step({"Route 124", "Route 124_A"}, 0, 25),
	step("Lilycove City", 0, 22),
	step("Route 121", 0, 22),
	step({"Route 120", "Route 120_A"}, 0, 12),
	step("Fortree City", 0, 12),
	step("Route 119A", 11, 100),
	step("Route 119B", 25, 100),
	step({"Route 118", "Route 118_A"}, 3, 16),
	step("Mauville City Stop House 4", 0, 6),
	step("Mauville City", 21, 30),
	step("Mauville City Stop House 1", 3, 12),
}, mauvilleToNew)
routes.return_12 = concatRoutes({
	step("Transmat Station", 9, 10),
	step("Pokecenter Sootopolis City", 8, 22),
	step("Sootopolis City", 50, 91),
	step("Sootopolis City Underwater", 17, 20),
	step({"Route 126 Underwater", "Route 126 Underwater_A"}, 15, 71),
	step({"Route 126", "Route 126_A"}, 125, 64),
	step({"Route 127", "Route 127_A"}, 37, 0),
	step("Mossdeep City", 0, 7),
	step({"Route 124", "Route 124_A"}, 0, 25),
	step("Lilycove City", 0, 22),
	step("Route 121", 0, 22),
	step({"Route 120", "Route 120_A"}, 0, 12),
	step("Fortree City", 0, 12),
	step("Route 119A", 11, 100),
	step("Route 119B", 25, 100),
	step({"Route 118", "Route 118_A"}, 3, 16),
	step("Mauville City Stop House 4", 0, 6),
	step("Mauville City", 21, 30),
	step("Mauville City Stop House 1", 3, 12),
}, mauvilleToNew)
routes.return_13 = concatRoutes({
	step("Transmat Station", 9, 10),
	step("Pokecenter Pacifidlog Town", 8, 22),
	step("Pacifidlog Town", 0, 30),
	step({"Route 131", "Route 131_A"}, 80, 31),
	step({"Route 130", "Route 130_A"}, 80, 7),
	step({"Route 129", "Route 129_A"}, 57, 0),
	step("Route 128", 38, 93),
	step({"Route 127", "Route 127_A"}, 37, 0),
	step("Mossdeep City", 0, 7),
	step({"Route 124", "Route 124_A"}, 0, 25),
	step("Lilycove City", 0, 22),
	step("Route 121", 0, 22),
	step({"Route 120", "Route 120_A"}, 0, 12),
	step("Fortree City", 0, 12),
	step("Route 119A", 11, 100),
	step("Route 119B", 25, 100),
	step({"Route 118", "Route 118_A"}, 3, 16),
	step("Mauville City Stop House 4", 0, 6),
	step("Mauville City", 21, 30),
	step("Mauville City Stop House 1", 3, 12),
}, mauvilleToNew)
routes.return_14 = concatRoutes({
	step("Transmat Station", 9, 10),
	step({"Pokecenter Ever Grande City", "Pokecenter Ever Grande City"}, 8, 22),
	step({"Ever Grande City", "Ever Grande City_A"}, 123, 32),
	step("Route 128", 38, 93),
	step({"Route 127", "Route 127_A"}, 37, 0),
	step("Mossdeep City", 0, 7),
	step({"Route 124", "Route 124_A"}, 0, 25),
	step("Lilycove City", 0, 22),
	step("Route 121", 0, 22),
	step({"Route 120", "Route 120_A"}, 0, 12),
	step("Fortree City", 0, 12),
	step("Route 119A", 11, 100),
	step("Route 119B", 25, 100),
	step({"Route 118", "Route 118_A"}, 3, 16),
	step("Mauville City Stop House 4", 0, 6),
	step("Mauville City", 21, 30),
	step("Mauville City Stop House 1", 3, 12),
}, mauvilleToNew)
routes.return_15 = concatRoutes({
	step("Transmat Station", 9, 10),
	step("Pokecenter Oldale Town", 8, 22),
	step("Oldale Town", 23, 0),
	step({"Route 103", "Route 103_A", "Route 103_B"}, 100, 19),
	step({"Route 110", "Route 110_A", "Route 110_B"}, 24, 3),
	step("Mauville City Stop House 1", 3, 2),
}, mauvilleToNew)

local newMauvilleSearchRectangles = {
	{1, 1, 15, 15},
	{16, 1, 32, 15},
	{1, 16, 15, 35},
	{16, 16, 32, 35},
	{33, 1, 47, 53},
}

local creatureSearchRectangles = {
	{4, 15, 20, 40}, -- west generator room / Plusle area
	{30, 8, 48, 30}, -- east generator room / Minun area
	{1, 1, 47, 53},
}

function HoennTransportQuest:new()
	local o = Quest.new(HoennTransportQuest, name, description, level, nil)
	o.state = loadState()
	if o.state.centerIndex < 1 or o.state.centerIndex > #centers then o.state.centerIndex = 1 end
	if o.state.currentCenter < 1 or o.state.currentCenter > #centers then o.state.currentCenter = 1 end
	if o.state.lastCenter < 1 or o.state.lastCenter > #centers then o.state.lastCenter = 1 end
	if o.state.routeStep < 1 then o.state.routeStep = 1 end
	o.stateFile = accountStateFile()
	o.lastDebugMessage = nil
	o.repeatCount = 0
	return o
end

function HoennTransportQuest:isDoable()
	return hasItem("Rain Badge")
		and not hasItem("Coal Badge")
		and self.state.phase ~= "complete"
		and self:hasMap()
end

function HoennTransportQuest:isDone()
	if self.state.phase == "complete" then
		return true
	end

	if self.state.phase == "handoff_to_lilycove"
		and (normalizedMapName(getMapName()) == normalizedMapName("Lilycove City")
			or normalizedMapName(getMapName()) == normalizedMapName("Pokecenter Lilycove City"))
	then
		self.state.phase = "complete"
		saveState(self.state)
		return true
	end

	return false
end

function HoennTransportQuest:isPersistentCompletionValid()
	return self.state.phase == "complete"
end

function HoennTransportQuest:isRequiredStoryBattle()
	local map = normalizedMapName(getMapName())
	return not isWildBattle()
		and (map == normalizedMapName("New Mauville")
			or map == normalizedMapName("Transmat Station"))
end

function HoennTransportQuest:checkDiscoverables()
	-- The station computer and New Mauville key are handled by this quest.
	-- Prevent the generic item finder from consuming those interactions before
	-- the quest state records them.
	local map = normalizedMapName(getMapName())
	if map == normalizedMapName("New Mauville")
		or map == normalizedMapName("Transmat Station")
	then
		return false
	end
	return Quest.checkDiscoverables(self)
end

local function npcMatches(npc, patterns)
	local nameText = string.lower(tostring(npc.name or ""))
	if type(patterns) == "string" then
		patterns = {patterns}
	end
	for _, pattern in ipairs(patterns or {}) do
		if string.find(nameText, string.lower(pattern), 1, true) ~= nil then
			return true
		end
	end
	return false
end

function HoennTransportQuest:findNpc(patterns, battlerOnly)
	if type(getNpcData) ~= "function" then
		return nil
	end
	local best = nil
	local bestDistance = nil
	local px = type(getPlayerX) == "function" and getPlayerX() or 0
	local py = type(getPlayerY) == "function" and getPlayerY() or 0
	for _, npc in ipairs(getNpcData() or {}) do
		if npcMatches(npc, patterns)
			and (not battlerOnly or npc.isBattler == true)
		then
			local x = tonumber(npc.x)
			local y = tonumber(npc.y)
			if x ~= nil and y ~= nil then
				local distance = math.abs(px - x) + math.abs(py - y)
				if best == nil or distance < bestDistance then
					best = npc
					bestDistance = distance
				end
			end
		end
	end
	return best
end

function HoennTransportQuest:findActiveBattler(patterns)
	if type(getActiveBattlers) ~= "function" then
		return nil
	end
	local best = nil
	local bestDistance = nil
	local px = type(getPlayerX) == "function" and getPlayerX() or 0
	local py = type(getPlayerY) == "function" and getPlayerY() or 0
	for trainer, position in pairs(getActiveBattlers() or {}) do
		local fakeNpc = {name = trainer}
		if npcMatches(fakeNpc, patterns) then
			local x = tonumber(position.x)
			local y = tonumber(position.y)
			if x ~= nil and y ~= nil then
				local distance = math.abs(px - x) + math.abs(py - y)
				if best == nil or distance < bestDistance then
					best = {name = trainer, x = x, y = y}
					bestDistance = distance
				end
			end
		end
	end
	return best
end

function HoennTransportQuest:talkToFoundNpc(npc)
	if npc == nil then
		return false
	end
	local x = tonumber(npc.x)
	local y = tonumber(npc.y)
	if x == nil or y == nil then
		return false
	end
	return talkToNpcOnCell(x, y)
end

function HoennTransportQuest:talkToNpcPatterns(patterns, battlerOnly)
	return self:talkToFoundNpc(self:findNpc(patterns, battlerOnly))
end

function HoennTransportQuest:currentCenterIndex()
	local map = normalizedMapName(getMapName())
	for index, center in ipairs(centers) do
		if map == normalizedMapName(center.pc) then
			return index
		end
	end
	return nil
end

function HoennTransportQuest:matchesStep(routeStep)
	local map = normalizedMapName(getMapName())
	for _, nameValue in ipairs(routeStep.names or {}) do
		if map == nameValue then
			return true
		end
	end
	return false
end

function HoennTransportQuest:prepareDive(routeStepIndex)
	local map = normalizedMapName(getMapName())
	if string.find(map, "route126", 1, true) ~= nil
		or string.find(map, "route127", 1, true) ~= nil
	then
		if self.state.divePrepared ~= routeStepIndex then
			local pokemonId = team.getFirstPkmWithMove("Dive")
			if pokemonId ~= nil then
				pushDialogAnswer(1)
				pushDialogAnswer(pokemonId)
				self.state.divePrepared = routeStepIndex
				saveState(self.state)
			end
		end
	end
end

function HoennTransportQuest:followRoute(routeName)
	local route = routes[routeName]
	if route == nil then
		return false
	end

	local routeStepIndex = tonumber(self.state.routeStep) or 1
	if routeStepIndex < 1 then
		routeStepIndex = 1
	end

	if self.state.routeWaiting then
		if route[routeStepIndex] == nil or self:matchesStep(route[routeStepIndex]) then
			self.state.routeWaiting = false
			saveState(self.state)
		elseif routeStepIndex > 1
			and self:matchesStep(route[routeStepIndex - 1])
		then
			-- The movement action may have mounted a water mount or been
			-- interrupted by a reconnect before the map transition arrived.
			-- Retrying the previous map's link is safer than returning false,
			-- which makes BotClient stop with "No action executed".
			local previousStep = route[routeStepIndex - 1]
			self:debug("quest", "Retrying Hoenn transport map transition.", false)
			return moveToCell(previousStep.x, previousStep.y)
		else
			-- Do not leave the bot idle merely because the persisted wait flag
			-- survived a reconnect.  The forward resynchronization below can
			-- select the live map when it is already farther along the route.
			self.state.routeWaiting = false
			saveState(self.state)
		end
	end

	local routeStep = route[routeStepIndex]
	if routeStep == nil then
		return false
	end

	-- A reconnect can place the account on a later map than the saved step.
	-- Resynchronize forward without ever issuing the deprecated moveToMap API.
	if not self:matchesStep(routeStep) then
		local foundStep = nil
		for index = routeStepIndex + 1, #route do
			if self:matchesStep(route[index]) then
				foundStep = index
				break
			end
		end
		if foundStep == nil then
			return false
		end
		routeStepIndex = foundStep
		routeStep = route[routeStepIndex]
		self.state.routeStep = routeStepIndex
		saveState(self.state)
	end

	self:prepareDive(routeStepIndex)
	self:debug("quest", "Following Hoenn transport route.", false)
	if moveToCell(routeStep.x, routeStep.y) then
		self.state.routeStep = routeStepIndex + 1
		self.state.routeWaiting = true
		saveState(self.state)
		return true
	end
	return false
end

function HoennTransportQuest:startRoute(phase, routeName)
	self.state.phase = phase
	self.state.routeName = routeName
	self.state.routeStep = 1
	self.state.routeWaiting = false
	saveState(self.state)
end

function HoennTransportQuest:searchNewMauville(rectangles, fieldName)
	local index = tonumber(self.state[fieldName]) or 1
	if index > #rectangles then
		index = 1
	end
	local rectangle = rectangles[index]
	self.state[fieldName] = (index % #rectangles) + 1
	saveState(self.state)
	self:debug("quest", "Searching New Mauville for the next story objective.", false)
	return moveToRectangle(rectangle[1], rectangle[2], rectangle[3], rectangle[4])
end

function HoennTransportQuest:talkWattsonAtCurrentMap()
	local wattson = self:findNpc("wattson")
	if wattson ~= nil then
		if self:talkToFoundNpc(wattson) then
			self:startRoute("to_new_mauville", "to_new_mauville")
			return true
		end
	end
	return false
end

function HoennTransportQuest:handleNewMauvilleTrainerPhase()
	local state = self.state

	if state.phase == "clear_trainers" then
		if state.gruntsDefeated >= 2 then
			state.phase = "find_remote_key"
			saveState(state)
			return false
		end
		local trainer = self:findActiveBattler({"aqua grunt", "magma grunt", " grunt"})
		if trainer ~= nil then
			if self:talkToFoundNpc(trainer) then
				state.pendingBattle = true
				saveState(state)
				return true
			end
		end
		return self:searchNewMauville(newMauvilleSearchRectangles, "newMauvilleSweep")
	end

	if state.phase == "find_remote_key" then
		if state.keyFound then
			state.phase = "clear_remaining_trainers"
			saveState(state)
			return false
		end

		if type(getDiscoverableItems) == "function" then
			for _, item in ipairs(getDiscoverableItems() or {}) do
				local x = tonumber(item.x)
				local y = tonumber(item.y)
				local key = cellKey(x, y)
				if x ~= nil and y ~= nil and state.keyAttempt ~= key and isNpcOnCell(x, y) then
					if talkToNpcOnCell(x, y) then
						state.keyAttempt = key
						saveState(state)
						return true
					end
				end
			end
		end

		local namedKey = self:findNpc({"remote", "cardboard", "control key", "key"})
		if namedKey ~= nil and self:talkToFoundNpc(namedKey) then
			state.keyAttempt = cellKey(namedKey.x, namedKey.y)
			saveState(state)
			return true
		end
		return self:searchNewMauville(newMauvilleSearchRectangles, "keySweep")
	end

	if state.phase == "clear_remaining_trainers" then
		local trainer = self:findActiveBattler({"aqua grunt", "magma grunt", " grunt"})
		if trainer ~= nil then
			if self:talkToFoundNpc(trainer) then
				state.pendingBattle = true
				saveState(state)
				return true
			end
		end
		state.phase = "fight_admins"
		saveState(state)
		return false
	end

	if state.phase == "fight_admins" then
		if state.adminsDefeated >= 2 then
			state.phase = "report_plusle_minun"
			saveState(state)
			return false
		end
		local adminName = state.adminsDefeated == 0 and "courtney" or "shelly"
		local admin = self:findActiveBattler(adminName)
		if admin ~= nil then
			if self:talkToFoundNpc(admin) then
				state.pendingBattle = true
				saveState(state)
				return true
			end
		end
		return self:searchNewMauville(newMauvilleSearchRectangles, "newMauvilleSweep")
	end

	return false
end

function HoennTransportQuest:handlePlusleMinun()
	local state = self.state
	if state.plusle and state.minun then
		state.phase = "report_plusle_minun"
		saveState(state)
		return false
	end

	local targetName = nil
	if not state.plusle then
		targetName = "plusle"
	elseif not state.minun then
		targetName = "minun"
	end

	local creature = self:findNpc(targetName)
	if creature ~= nil and self:talkToFoundNpc(creature) then
		if targetName == "plusle" then
			state.plusle = true
		else
			state.minun = true
		end
		state.pendingCreature = targetName
		saveState(state)
		return true
	end

	return self:searchNewMauville(creatureSearchRectangles, "newMauvilleSweep")
end

function HoennTransportQuest:handleStationComputer()
	local state = self.state
	if state.installResult ~= "" then
		return moveToCell(9, 10)
	end
	if state.computerAttempted then
		-- Dialog callbacks normally provide the result immediately.  If the
		-- server only returned the station map response, do not leave the
		-- account permanently parked in the station; treat the attempt as a
		-- non-selected PC after a short, bounded wait.
		if state.computerAttemptedAt > 0
			and os.difftime(os.time(), state.computerAttemptedAt) >= 8
		then
			state.installResult = "countermeasure"
			saveState(state)
			return moveToCell(9, 10)
		end
		return false
	end

	local computer = nil
	if type(getDiscoverableItems) == "function" then
		for _, item in ipairs(getDiscoverableItems() or {}) do
			local x = tonumber(item.x)
			local y = tonumber(item.y)
			if x ~= nil and y ~= nil and isNpcOnCell(x, y) then
				if computer == nil or x < computer.x then
					computer = {x = x, y = y}
				end
			end
		end
	end
	if computer == nil then
		computer = self:findNpc("computer")
	end

	if computer ~= nil and self:talkToFoundNpc(computer) then
		state.computerAttempted = true
		state.computerAttemptedAt = os.time()
		saveState(state)
		return true
	end

	-- The known station computer is west of the entrance.  Move there first;
	-- the next tick will re-read the live NPC list before talking.
	return moveToCell(4, 4)
end

function HoennTransportQuest:handleTransmatStation()
	local state = self.state
	if state.phase == "fight_final_steven" then
		-- Prefer the battle-enabled list, but fall back to the live NPC list.
		-- Some story NPCs are not exposed as active battlers until the player
		-- is close enough to them.
		local steven = self:findActiveBattler("steven") or self:findNpc("steven")
		if steven ~= nil and self:talkToFoundNpc(steven) then
			state.pendingBattle = true
			saveState(state)
			return true
		end
		return moveToRectangle(1, 1, 12, 9)
	end

	return self:handleStationComputer()
end

function HoennTransportQuest:finishStationAttempt()
	local state = self.state
	local centerIndex = self:currentCenterIndex() or state.currentCenter or state.centerIndex
	state.currentCenter = centerIndex
	state.lastCenter = centerIndex

	if state.installResult == "success" then
		state.installCount = state.installCount + 1
		log("Hoenn Transmat program installed at " .. centers[centerIndex].city .. ".")
	else
		self:debug("quest", "This Hoenn PC was not selected for the Transmat program.", false)
	end

	state.stationAttempted = false
	state.computerAttempted = false
	state.computerAttemptedAt = 0
	state.installResult = ""

	if state.installCount >= 3 then
		state.phase = "fight_final_steven"
		state.routeName = ""
		state.routeStep = 1
		state.routeWaiting = false
	else
		local nextCenter = centerIndex + 1
		if nextCenter > #centers then
			nextCenter = 1
		end
		state.centerIndex = nextCenter
		state.phase = "install_programs"
		state.routeName = "center_" .. tostring(centerIndex)
		state.routeStep = 1
		state.routeWaiting = false
	end
	saveState(state)
	return true
end

function HoennTransportQuest:handlePokecenter()
	local state = self.state
	local currentCenter = self:currentCenterIndex()
	if currentCenter ~= nil then
		state.currentCenter = currentCenter
	end

	-- The first post-E4 route must reach Mauville before Wattson is queried.
	-- If the account was interrupted at another PC, heal/exit that PC and let
	-- the saved to_mauville route resynchronize from its city step.  This also
	-- repairs the short-lived state written by the previous implementation,
	-- which incorrectly changed to talk_wattson at any Hoenn PC.
	if state.phase == "talk_wattson" and currentCenter ~= 1 then
		state.phase = "to_mauville"
		state.routeName = "to_mauville"
		state.routeStep = 1
		state.routeWaiting = false
		saveState(state)
		return self:pokecenter(centers[currentCenter].city)
	end

	if state.phase == "to_mauville" then
		if currentCenter == 1 then
			state.phase = "talk_wattson"
			state.routeName = ""
			state.routeStep = 1
			state.routeWaiting = false
			saveState(state)
			return self:pokecenter("Mauville City")
		end
		return self:pokecenter(centers[currentCenter].city)
	end

	if state.phase == "talk_wattson" then
		if self:talkWattsonAtCurrentMap() then
			return true
		end
		-- Wattson is normally in this PC.  If the NPC list has not arrived yet,
		-- wait on the tile instead of calling talkToNpc with a guessed name.
		return false
	end

	if state.phase == "install_programs" then
		-- After a station result the next PC is a travel waypoint, not a new
		-- installation target.  Let the center_N route leave this PC first;
		-- when its final step has completed, the same branch falls through to
		-- the officer/computer handling below.
		if string.find(tostring(state.routeName or ""), "^center_") ~= nil then
			local route = routes[state.routeName]
			local routeResult = self:followRoute(state.routeName)
			if routeResult or state.routeWaiting or (route ~= nil and state.routeStep <= #route) then
				return routeResult
			end
		end
		if state.installResult ~= "" and state.stationAttempted then
			return self:finishStationAttempt()
		end
		if state.stationAttempted then
			return false
		end

		local officer = self:findNpc({"security", "officer"})
		if officer ~= nil and self:talkToFoundNpc(officer) then
			state.stationAttempted = true
			state.computerAttempted = false
			state.computerAttemptedAt = 0
			saveState(state)
			return true
		end

		-- The station entrance is an existing map link at the north of the PC.
		-- Use it only after the live NPC lookup failed; no C# switching logic is
		-- involved.
		if moveToCell(8, 3) then
			state.stationAttempted = true
			state.computerAttempted = false
			state.computerAttemptedAt = 0
			saveState(state)
			return true
		end
	end

	if state.phase == "fight_final_steven" then
		if moveToCell(8, 3) then
			state.computerAttempted = false
			state.computerAttemptedAt = 0
			saveState(state)
			return true
		end
	end

	return self:followRoute(state.routeName)
end

function HoennTransportQuest:handleNewMauville()
	local state = self.state

	if state.phase == "to_new_mauville" then
		state.phase = "clear_trainers"
		state.routeName = ""
		state.routeStep = 1
		state.routeWaiting = false
		saveState(state)
		return false
	end

	if state.phase == "return_wattson" then
		if self:talkWattsonAtCurrentMap() then
			self:startRoute("handoff_to_lilycove", "to_lilycove")
			return true
		end
		return false
	end

	if state.phase == "report_plusle_minun" then
		if self:talkWattsonAtCurrentMap() then
			self:startRoute("install_programs", "to_mauville_pc")
			return true
		end
		return false
	end

	if state.phase == "find_plusle_minun" then
		return self:handlePlusleMinun()
	end

	if state.phase == "clear_trainers"
		or state.phase == "find_remote_key"
		or state.phase == "clear_remaining_trainers"
		or state.phase == "fight_admins"
	then
		return self:handleNewMauvilleTrainerPhase()
	end

	return false
end

function HoennTransportQuest:handleCurrentMap()
	local map = normalizedMapName(getMapName())
	local state = self.state

	if map == normalizedMapName("New Mauville") then
		return self:handleNewMauville()
	end

	if map == normalizedMapName("New Mauville Entrance") then
		if state.phase == "to_new_mauville" or state.phase == "to_mauville_pc"
			or state.phase == "handoff_to_lilycove"
		then
			return self:followRoute(state.routeName)
		end
	end

	if map == normalizedMapName("Transmat Station") then
		return self:handleTransmatStation()
	end

	if self:currentCenterIndex() ~= nil then
		return self:handlePokecenter()
	end

	if state.phase == "talk_wattson"
		and map == normalizedMapName("Mauville City")
	then
		if self:talkWattsonAtCurrentMap() then
			return true
		end
		return moveToCell(28, 13)
	end

	if state.phase == "handoff_to_lilycove" then
		return self:followRoute("to_lilycove")
	end

	return self:followRoute(state.routeName)
end

function HoennTransportQuest:path()
	-- Keep Quest's common evolution/leftovers handling and the existing
	-- Pathfinder tick semantics.  Map-specific actions are dispatched back to
	-- this module through the registered map handlers below.
	return Quest.path(self)
end

function HoennTransportQuest:dialog(message)
	Quest.dialog(self, message)
	local state = self.state

	if state.phase == "find_remote_key"
		and state.keyAttempt ~= ""
		and containsAny(message, {"remote", "control", "cardboard", "key"})
	then
		state.keyFound = true
		state.phase = "clear_remaining_trainers"
		saveState(state)
	elseif state.phase == "install_programs"
		and state.stationAttempted
		and state.computerAttempted
	then
		if containsAny(message, {"countermeasure", "not selected", "not chosen", "failed", "unavailable"}) then
			state.installResult = "countermeasure"
		elseif containsAny(message, {"success", "installed", "uploaded", "program is ready"}) then
			state.installResult = "success"
		end
		saveState(state)
	end
	return true
end

function HoennTransportQuest:battleMessage(message)
	Quest.battleMessage(self, message)
	local state = self.state
	if state.pendingBattle and containsAny(message, {"won the battle", "defeated"}) then
		state.pendingBattle = false
		if state.phase == "clear_trainers" then
			state.gruntsDefeated = state.gruntsDefeated + 1
		elseif state.phase == "clear_remaining_trainers" then
			-- Remaining grunts are not counted toward the initial two-grunt key
			-- trigger; the phase ends when no active grunt remains.
		elseif state.phase == "fight_admins" then
			state.adminsDefeated = state.adminsDefeated + 1
			if state.adminsDefeated >= 2 then
				state.phase = "report_plusle_minun"
			end
		elseif state.phase == "fight_final_steven" then
			state.phase = "return_wattson"
			state.routeName = "return_" .. tostring(state.lastCenter or state.currentCenter or 1)
			state.routeStep = 1
			state.routeWaiting = false
		end
		saveState(state)
	end
	return true
end

-- Register every map used by the route tables.  Quest:hasMap() uses the same
-- space/dot/hyphen removal as mapFunctionKey(), so reconnects remain inside
-- this quest as long as the current map is one of the configured steps.
local function registerRouteMaps(route)
	for _, routeStep in ipairs(route or {}) do
		for _, key in ipairs(routeStep.keys or {}) do
			if HoennTransportQuest[key] == nil then
				HoennTransportQuest[key] = function(self)
					return self:handleCurrentMap()
				end
			end
		end
	end
end

for _, route in pairs(routes) do
	registerRouteMaps(route)
end
registerRouteMaps(mauvilleToNew)
registerRouteMaps({
	step("New Mauville", 47, 53),
	step("New Mauville Entrance", 12, 4),
	step("Transmat Station", 9, 10),
})
for _, center in ipairs(centers) do
	local pcKey = mapFunctionKey(center.pc)
	if HoennTransportQuest[pcKey] == nil then
		HoennTransportQuest[pcKey] = function(self)
			return self:handleCurrentMap()
		end
	end
end

return HoennTransportQuest
