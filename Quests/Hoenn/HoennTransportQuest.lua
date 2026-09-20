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
		keyAttemptAt = 0,
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
		gruntAttempts = {},
		southPassageStep = "find_grunt",
		southPassageComplete = false,
		southPassageAttemptedAt = 0,
		entranceShellyTalked = false,
		entranceWattsonTalked = false,
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
			elseif key == "keyAttemptAt" then state.keyAttemptAt = tonumber(value) or 0
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
			elseif key == "gruntAttempts" then
				for attempt in string.gmatch(value, "[^,]+") do
					state.gruntAttempts[attempt] = true
				end
			elseif key == "southPassageStep" then state.southPassageStep = value
			elseif key == "southPassageComplete" then state.southPassageComplete = boolValue(value)
			elseif key == "southPassageAttemptedAt" then state.southPassageAttemptedAt = tonumber(value) or 0
			elseif key == "entranceShellyTalked" then state.entranceShellyTalked = boolValue(value)
			elseif key == "entranceWattsonTalked" then state.entranceWattsonTalked = boolValue(value)
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
		"keyAttemptAt=" .. tostring(state.keyAttemptAt or 0),
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
		"gruntAttempts=" .. (function()
			local attempts = {}
			for key, attempted in pairs(state.gruntAttempts or {}) do
				if attempted then
					attempts[#attempts + 1] = key
				end
			end
			table.sort(attempts)
			return table.concat(attempts, ",")
		end)(),
		"southPassageStep=" .. tostring(state.southPassageStep or "find_grunt"),
		"southPassageComplete=" .. (state.southPassageComplete and "1" or "0"),
		"southPassageAttemptedAt=" .. tostring(state.southPassageAttemptedAt or 0),
		"entranceShellyTalked=" .. (state.entranceShellyTalked and "1" or "0"),
		"entranceWattsonTalked=" .. (state.entranceWattsonTalked and "1" or "0"),
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

local function step(mapNames, x, y, maxX, maxY)
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
		rectangle = maxX ~= nil and {x, y, maxX, maxY} or nil,
	}
end

local function moveToRouteStep(routeStep)
	if routeStep.rectangle ~= nil then
		return moveToRectangle(
			routeStep.rectangle[1], routeStep.rectangle[2],
			routeStep.rectangle[3], routeStep.rectangle[4]
		)
	end
	return moveToCell(routeStep.x, routeStep.y)
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
	step({"Route 110", "Route 110_B"}, 39, 60, 39, 62),
	step("Route 110_A", 24, 3, 25, 3),
	step("Mauville City Stop House 1", 3, 2),
	step("Mauville City", 28, 13),
}

-- Initial Wattson objective: PC -> New Mauville.
routes.to_new_mauville = {
	step("Pokecenter Mauville City", 8, 22),
	step("Mauville City", 21, 30),
	step("Mauville City Stop House 1", 3, 12),
	step("Route 110_A", 52, 36),
	step("Route 110_C", 56, 33, 57, 33),
	step("New Mauville Entrance", 12, 4, 13, 4),
}

-- Return from New Mauville to the first PC after finding Plusle and Minun.
routes.to_mauville_pc = {
	step("New Mauville", 47, 53),
	step("New Mauville Entrance", 12, 15),
	step("Route 110_C", 20, 30, 22, 30),
	step("Route 110_A", 24, 3, 25, 3),
	step("Mauville City Stop House 1", 3, 2),
	step("Mauville City", 28, 13),
}

-- Final hand-off route.  It ends in Lilycove City so QuestManager can select
-- the existing To Sinnoh quest without changing its region navigation.
routes.to_lilycove = {
	step("New Mauville", 47, 53),
	step("New Mauville Entrance", 12, 15),
	step("Route 110_C", 20, 30, 22, 30),
	step("Route 110_A", 24, 3, 25, 3),
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
	step("Route 110_A", 41, 60, 41, 62),
	step("Route 110_B", 23, 140, 25, 140),
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
	step("Route 110_A", 41, 60, 41, 62),
	step("Route 110_B", 0, 98, 0, 100),
	step({"Route 103", "Route 103_A", "Route 103_B"}, 25, 35),
	step("Oldale Town", 16, 26),
}
routes.center_15 = { -- Oldale -> Mauville (tour wrap)
	step("Pokecenter Oldale Town", 8, 22),
	step("Oldale Town", 23, 0),
	step({"Route 103", "Route 103_A", "Route 103_B"}, 100, 19),
	step({"Route 110", "Route 110_B"}, 39, 60, 39, 62),
	step("Route 110_A", 24, 3, 25, 3),
	step("Mauville City Stop House 1", 3, 2),
	step("Mauville City", 28, 13),
}

-- Return routes are used only after the final Steven fight.  They all
-- begin by leaving the current station and finish in New Mauville.
local mauvilleToNew = {
	step("Mauville City", 21, 30),
	step("Mauville City Stop House 1", 3, 12),
	step("Route 110_A", 52, 36),
	step("Route 110_C", 56, 33, 57, 33),
	step("New Mauville Entrance", 12, 4, 13, 4),
}

routes.return_1 = concatRoutes({
	step("Transmat Station", 9, 10),
	step("Pokecenter Mauville City", 8, 22),
}, mauvilleToNew)
routes.return_2 = concatRoutes({
	step("Transmat Station", 9, 10),
	step("Pokecenter Slateport", 8, 22),
	step("Slateport City", 30, 0),
	step({"Route 110", "Route 110_B"}, 39, 60, 39, 62),
	step("Route 110_A", 24, 3, 25, 3),
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
	step({"Route 110", "Route 110_B"}, 39, 60, 39, 62),
	step("Route 110_A", 24, 3, 25, 3),
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
	step({"Route 110", "Route 110_B"}, 39, 60, 39, 62),
	step("Route 110_A", 24, 3, 25, 3),
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
	step({"Route 110", "Route 110_B"}, 39, 60, 39, 62),
	step("Route 110_A", 24, 3, 25, 3),
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
	step({"Route 110", "Route 110_B"}, 39, 60, 39, 62),
	step("Route 110_A", 24, 3, 25, 3),
	step("Mauville City Stop House 1", 3, 2),
}, mauvilleToNew)

local newMauvilleSearchRectangles = {
	{1, 1, 15, 15},
	{16, 1, 32, 15},
	{1, 16, 15, 35},
	{16, 16, 32, 35},
	{33, 1, 60, 35},
	{1, 36, 32, 53},
	{33, 36, 60, 53},
	{1, 54, 32, 64},
	{33, 54, 60, 64}, -- includes the blocked passage at (41,58)-(41,59)
}

local creatureSearchRectangles = {
	{4, 15, 20, 40}, -- west generator room / Plusle area
	{30, 8, 48, 30}, -- east generator room / Minun area
	{1, 1, 47, 53},
}

function HoennTransportQuest:new()
	local o = Quest.new(HoennTransportQuest, name, description, level, nil)
	o.state = loadState()
	-- A prior session's response wait must not prevent one fresh interaction.
	o.state.keyAttemptAt = 0
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

local newMauvilleGruntPatterns = {"aqua grunt", "magma grunt"}
local newMauvilleSouthGrunt = {x = 21, y = 55}
-- Do not use the two gate cells as a movement destination.  They are the
-- scripted passage itself; asking moveToRectangle(21, 40, 22, 40) can make
-- the pathfinder repeatedly target the barrier instead of crossing it.
local newMauvilleSouthExit = {x = 21, y = 39}
local newMauvilleSouthGruntKey = cellKey(
	newMauvilleSouthGrunt.x,
	newMauvilleSouthGrunt.y
)
-- The remote-control interaction is the fixed active object at (7,45).  Do
-- not scan New Mauville's type-11 discoverable items here: that list contains
-- optional pickups such as Rare Candy and makes the quest wander after a wild
-- battle interrupts the actual story objective.
local newMauvilleRemoteControl = {x = 7, y = 45}
local newMauvilleRemoteControlKey = cellKey(
	newMauvilleRemoteControl.x,
	newMauvilleRemoteControl.y
)
-- (7,45) is the interactive object itself and is not a walkable destination.
-- Use the adjacent walkable cell when the current NPC snapshot is delayed.
local newMauvilleRemoteControlApproach = {x = 6, y = 45}

function HoennTransportQuest:waitForRemoteProgress(reason)
	local now = os.time()
	if self.remoteWaitStarted == nil then
		self.remoteWaitStarted = now
	end
	-- A successful wait action is not evidence of progress. Never renew this
	-- deadline every tick: that hid failed paths as an endless intentional wait.
	if now - self.remoteWaitStarted >= 8 then
		return fatal("New Mauville remote objective blocked at (" .. getPlayerX()
			.. "," .. getPlayerY() .. "): " .. reason
			.. ". Gate/key state was not changed; no item search or relog attempted.")
	end
	if type(waitForState) == "function" then
		return waitForState(1000)
	end
	return false
end

function HoennTransportQuest:isRemoteGateOpen()
	-- Absence from an empty/delayed NPC list is NOT proof of completion.
	-- Require a recognizable live quest NPC and two consistent observations.
	local anchor, blocked = false, false
	for _, npc in ipairs(type(getNpcData) == "function" and getNpcData() or {}) do
		local x, y = tonumber(npc.x), tonumber(npc.y)
		if y == 40 and (x == 21 or x == 22) then blocked = true end
		if x == 21 and y == 55 and npcMatches(npc, "aqua grunt") then
			anchor = true
		end
	end
	if not anchor or blocked then
		self.remoteGateObservedAt = nil
		return false
	end
	if self.remoteGateObservedAt == nil then
		self.remoteGateObservedAt = os.time()
		return false
	end
	return os.time() - self.remoteGateObservedAt >= 1
end

function HoennTransportQuest:handleRemoteControl()
	local state = self.state
	if not state.keyFound and self:isRemoteGateOpen() then
		state.keyFound = true
		state.keyAttempt = ""
		state.keyAttemptAt = 0
		self.remoteWaitStarted = nil
		saveState(state)
		self:debug("quest", "Remote barrier already open; resuming north of the gate.", false)
	end

	if state.keyFound then
		-- A queued path may be interrupted by a wild battle. Complete crossing
		-- only on arrival, not merely when moveToCell returns true.
		local x, y = getPlayerX(), getPlayerY()
		if x >= 16 and x <= 32 and y >= 16 and y <= 39 then
			state.southPassageStep = "done"
			state.southPassageComplete = true
			state.pendingBattle = false
			state.phase = "clear_remaining_trainers"
			self.remoteWaitStarted = nil
			saveState(state)
			return false
		end
		if moveToCell(newMauvilleSouthExit.x, newMauvilleSouthExit.y) then
			self.remoteWaitStarted = nil
			return true
		end
		return self:waitForRemoteProgress("cannot reach the north side of the open gate (21,39)")
	end

	-- Discard obsolete optional-pickup attempts, but retain the actual story
	-- target across interrupted movement. No type-11 discovery is performed.
	if state.keyAttempt ~= "" and state.keyAttempt ~= newMauvilleRemoteControlKey then
		state.keyAttempt = ""
		state.keyAttemptAt = 0
		saveState(state)
	end
	local x, y = getPlayerX(), getPlayerY()
	local adjacent = math.abs(x - newMauvilleRemoteControl.x)
		+ math.abs(y - newMauvilleRemoteControl.y) <= 1
	if isNpcOnCell(newMauvilleRemoteControl.x, newMauvilleRemoteControl.y) then
		-- The response timer starts beside the object, not when a path is queued.
		if adjacent and state.keyAttemptAt > 0 then
			self.remoteWaitStarted = self.remoteWaitStarted or state.keyAttemptAt
			return self:waitForRemoteProgress("remote interaction returned no gate-opening response")
		end
		if talkToNpcOnCell(newMauvilleRemoteControl.x, newMauvilleRemoteControl.y) then
			state.keyAttempt = newMauvilleRemoteControlKey
			state.keyAttemptAt = adjacent and os.time() or 0
			self.remoteWaitStarted = nil
			saveState(state)
			return true
		end
		return self:waitForRemoteProgress("remote object is visible but unreachable")
	end

	-- A consumed remote disappears. Check the live gate above before returning
	-- to its former position. Never wait indefinitely for it to respawn.
	if x ~= newMauvilleRemoteControlApproach.x or y ~= newMauvilleRemoteControlApproach.y then
		if moveToCell(newMauvilleRemoteControlApproach.x, newMauvilleRemoteControlApproach.y) then
			self.remoteWaitStarted = nil
			return true
		end
	end
	return self:waitForRemoteProgress("remote is absent and the gate cannot yet be confirmed open")
end

function HoennTransportQuest:isGruntAttempted(npc)
	if npc == nil then
		return false
	end
	local key = cellKey(npc.x, npc.y)
	return self.state.gruntAttempts ~= nil
		and self.state.gruntAttempts[key] == true
end

function HoennTransportQuest:findNewMauvilleGrunt()
	-- Prefer the normal active-battler API when the server exposes the grunt
	-- as a battle NPC.  Some New Mauville event grunts are delivered as
	-- ordinary scripted NPCs, however, so they are not returned by
	-- getActiveBattlers() even though talking to them starts the battle.
	local active = self:findActiveBattler(newMauvilleGruntPatterns)
	if active ~= nil and not self:isGruntAttempted(active) then
		return active
	end

	if type(getNpcData) ~= "function" then
		return nil
	end

	local best = nil
	local bestDistance = nil
	local px = type(getPlayerX) == "function" and getPlayerX() or 0
	local py = type(getPlayerY) == "function" and getPlayerY() or 0
	for _, npc in ipairs(getNpcData() or {}) do
		if npcMatches(npc, newMauvilleGruntPatterns) then
			local x = tonumber(npc.x)
			local y = tonumber(npc.y)
			local candidate = {x = x, y = y, name = npc.name}
			if x ~= nil and y ~= nil and not self:isGruntAttempted(candidate) then
				local distance = math.abs(px - x) + math.abs(py - y)
				if best == nil or distance < bestDistance then
					best = candidate
					bestDistance = distance
				end
			end
		end
	end
	return best
end

function HoennTransportQuest:findNewMauvilleGruntAtCell(x, y)
	local targetX = tonumber(x)
	local targetY = tonumber(y)
	if targetX == nil or targetY == nil then
		return nil
	end

	-- Check the battle list first when this scripted grunt is exposed as an
	-- active battler.  New Mauville can also expose the same NPC as a normal
	-- scripted NPC, so fall back to getNpcData below.
	if type(getActiveBattlers) == "function" then
		for trainer, position in pairs(getActiveBattlers() or {}) do
			local candidateX = tonumber(position.x)
			local candidateY = tonumber(position.y)
			if candidateX == targetX and candidateY == targetY
				and npcMatches({name = trainer}, newMauvilleGruntPatterns)
			then
				local candidate = {name = trainer, x = targetX, y = targetY}
				if not self:isGruntAttempted(candidate) then
					return candidate
				end
			end
		end
	end

	if type(getNpcData) == "function" then
		for _, npc in ipairs(getNpcData() or {}) do
			local candidateX = tonumber(npc.x)
			local candidateY = tonumber(npc.y)
			if candidateX == targetX and candidateY == targetY
				and npcMatches(npc, newMauvilleGruntPatterns)
			then
				local candidate = {name = npc.name, x = targetX, y = targetY}
				if not self:isGruntAttempted(candidate) then
					return candidate
				end
			end
		end
	end

	return nil
end

function HoennTransportQuest:challengeNewMauvilleGrunt(preferredTrainer)
	local trainer = preferredTrainer or self:findNewMauvilleGrunt()
	if trainer == nil or not self:talkToFoundNpc(trainer) then
		return false
	end

	self.state.gruntAttempts[cellKey(trainer.x, trainer.y)] = true
	if tonumber(trainer.x) == newMauvilleSouthGrunt.x
		and tonumber(trainer.y) == newMauvilleSouthGrunt.y
	then
		-- Keep movement away from the gate until the NPC battle has ended and
		-- the server has published the opened passage.
		self.state.southPassageStep = "await_grunt"
		self.state.southPassageAttemptedAt = os.time()
	end
	self.state.pendingBattle = true
	saveState(self.state)
	return true
end

function HoennTransportQuest:challengeNewMauvilleSouthGrunt()
	local trainer = self:findNewMauvilleGruntAtCell(
		newMauvilleSouthGrunt.x,
		newMauvilleSouthGrunt.y
	)
	if trainer == nil
		and type(isNpcOnCell) == "function"
		and isNpcOnCell(newMauvilleSouthGrunt.x, newMauvilleSouthGrunt.y)
	then
		-- Type 157 is the map's Aqua Grunt at this fixed cell.  Use the
		-- coordinate directly because it is a scripted NPC, not an active
		-- battler in getActiveBattlers().
		trainer = {
			name = "Aqua Grunt",
			x = newMauvilleSouthGrunt.x,
			y = newMauvilleSouthGrunt.y,
		}
	end
	if trainer == nil then
		return false
	end
	return self:challengeNewMauvilleGrunt(trainer)
end

function HoennTransportQuest:handleNewMauvilleSouthPassage()
	local state = self.state
	local passageStep = tostring(state.southPassageStep or "find_grunt")

	-- Older state files could record the passage as done after targeting the
	-- gate rectangle, without ever completing the fixed-cell interaction.
	-- Replay only that one-time sequence once, then mark it explicitly after
	-- the player reaches the upper side of the passage.
	if passageStep == "done" and not state.southPassageComplete then
		state.southPassageStep = "find_grunt"
		state.gruntAttempts[newMauvilleSouthGruntKey] = nil
		state.pendingBattle = false
		saveState(state)
		passageStep = "find_grunt"
	end

	-- This is a one-time lower-to-upper passage sequence.  Once it is done,
	-- return nil so the normal New Mauville trainer/key flow can continue.
	if passageStep == "done" then
		return nil
	end

	if passageStep == "find_grunt" then
		if self:challengeNewMauvilleSouthGrunt() then
			return true
		end

		-- An interrupted/reconnected account may already have attempted this
		-- cell.  Do not challenge another grunt before opening the passage.
		if state.gruntAttempts ~= nil
			and state.gruntAttempts[newMauvilleSouthGruntKey]
		then
			state.southPassageStep = "wait_for_gate"
			saveState(state)
			passageStep = "wait_for_gate"
		else
			-- Always perform the interaction at the fixed cell before trying
			-- the passage.  Bot.TalkToNpc will path to an adjacent cell; moving
			-- to the NPC's blocked tile first is not required and can make the
			-- client walk toward the gate instead.
			if self:challengeNewMauvilleSouthGrunt() then
				return true
			end
			-- The map/NPC snapshot can arrive one tick after a transition.
			-- Wait in place instead of issuing a gate movement request.
			if type(waitForState) == "function" then
				return waitForState(1000)
			end
			return false
		end
	end

	if passageStep == "await_grunt" then
		-- The battle callback advances this to wait_for_gate.  Never issue a
		-- movement request while the required grunt battle is still pending.
		if state.pendingBattle then
			-- A stale state file or a reconnect can leave pendingBattle set even
			-- though no battle is currently active.  Retry the fixed NPC after a
			-- short bounded interval instead of waiting forever.
			local attemptedAt = tonumber(state.southPassageAttemptedAt) or 0
			if attemptedAt == 0 or os.time() - attemptedAt >= 8 then
				state.pendingBattle = false
				state.gruntAttempts[newMauvilleSouthGruntKey] = nil
				state.southPassageStep = "find_grunt"
				state.southPassageAttemptedAt = 0
				saveState(state)
				if self:challengeNewMauvilleSouthGrunt() then
					return true
				end
				if type(waitForState) == "function" then
					return waitForState(1000)
				end
				return false
			end
			if type(waitForState) == "function" then
				return waitForState(1000)
			end
			return true
		end
		state.southPassageStep = "wait_for_gate"
		state.southPassageAttemptedAt = 0
		saveState(state)
		passageStep = "wait_for_gate"
	end

	if passageStep == "open_path" then
		-- Migrate state written by the previous implementation.  That version
		-- targeted the gate rectangle directly, which could oscillate on the
		-- two scripted cells.
		state.southPassageStep = "wait_for_gate"
		saveState(state)
		passageStep = "wait_for_gate"
	end

	if passageStep == "wait_for_gate" then
		if type(waitForState) == "function" then
			state.southPassageStep = "cross_gate"
			saveState(state)
			return waitForState(2000)
		end
		state.southPassageStep = "cross_gate"
		saveState(state)
		passageStep = "cross_gate"
	end

	if passageStep == "cross_gate" then
		-- Aim at a safe cell north of the passage, never at (21,40) or
		-- (22,40) themselves.  This lets the pathfinder cross the opened
		-- gate once and prevents the old gate-cell oscillation.
		if moveToCell(newMauvilleSouthExit.x, newMauvilleSouthExit.y) then
			state.southPassageStep = "go_top"
			saveState(state)
			return true
		end
		if type(waitForState) == "function" then
			return waitForState(1500)
		end
		return false
	end

	if state.southPassageStep == "go_top" then
		local result = moveToRectangle(16, 16, 32, 35)
		if result then
			state.southPassageStep = "done"
			state.southPassageComplete = true
			saveState(state)
		end
		return result
	end

	-- Unknown persisted values should not strand the quest.  Reset the
	-- one-time passage marker and let the regular quest logic continue.
	state.southPassageStep = "done"
	saveState(state)
	return nil
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
			return moveToRouteStep(previousStep)
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
	if moveToRouteStep(routeStep) then
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

	if state.phase == "clear_trainers"
		or state.phase == "clear_remaining_trainers"
	then
		local southPassageResult = self:handleNewMauvilleSouthPassage()
		if southPassageResult ~= nil then
			return southPassageResult
		end
	end

	if state.phase == "clear_trainers" then
		-- The fixed south-grunt interaction is the entry requirement for the
		-- upper New Mauville route.  Once that passage has completed, do not
		-- restart the broad lower-map grunt sweep after a wild battle; continue
		-- with the existing remote-control objective instead.
		if state.southPassageComplete then
			state.phase = "find_remote_key"
			state.pendingBattle = false
			saveState(state)
			return false
		end
		if state.gruntsDefeated >= 2 then
			state.phase = "find_remote_key"
			saveState(state)
			return false
		end
		if self:challengeNewMauvilleGrunt() then
			return true
		end
		return self:searchNewMauville(newMauvilleSearchRectangles, "newMauvilleSweep")
	end

	if state.phase == "find_remote_key" then
		return self:handleRemoteControl()
	end

	if state.phase == "clear_remaining_trainers" then
		if self:challengeNewMauvilleGrunt() then
			return true
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
		if state.phase == "to_new_mauville" then
			-- Shelly blocks the New Mauville entrance until the scripted
			-- conversation at this fixed cell has been triggered.
			if not state.entranceShellyTalked and isNpcOnCell(12, 7) then
				if talkToNpcOnCell(12, 7) then
					state.entranceShellyTalked = true
					saveState(state)
					return true
				end
			end
			-- The entrance scene leaves Wattson at (13,7).  He must be
			-- acknowledged before the New Mauville map link becomes usable.
			if not state.entranceWattsonTalked and isNpcOnCell(13, 7) then
				if talkToNpcOnCell(13, 7) then
					state.entranceWattsonTalked = true
					saveState(state)
					return true
				end
			end
			return self:followRoute(state.routeName)
		end

		if state.phase == "to_mauville_pc"
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

	if state.southPassageStep == "await_grunt"
		and containsAny(message, {
			"hid the remote-control key",
			"hid the remote control key",
			"hid the remote-control keys",
			"hid the remote control keys",
		})
	then
		-- The type-157 NPC can answer with the remote-control dialogue without
		-- opening a normal battle.  Treat that response as a successful fixed
		-- cell interaction so the quest does not talk to the same NPC forever.
		state.pendingBattle = false
		state.southPassageStep = "wait_for_gate"
		state.southPassageAttemptedAt = 0
		saveState(state)
	elseif containsAny(message, {
		"found the hidden remote control",
		"found the hidden remote-control",
		"deactivated the nearby electro-barrier",
		"deactivated the nearby electro barrier",
	})
	then
		-- This response can arrive after a reconnect or after the south-grunt
		-- phase has already advanced.  Record it globally so a valid remote-key
		-- interaction is never lost just because the phase changed one tick late.
		state.keyFound = true
		state.keyAttempt = ""
		state.keyAttemptAt = 0
		self.remoteWaitStarted = nil
		if state.phase == "find_remote_key"
			or state.phase == "clear_trainers"
		then
			state.phase = "find_remote_key"
		end
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
	-- Battle time is not a failed overworld wait; keep the objective itself.
	self.remoteWaitStarted = nil
	self.remoteGateObservedAt = nil
	if state.phase == "find_remote_key" then state.keyAttemptAt = 0 end
	if state.pendingBattle and containsAny(message, {"won the battle", "defeated"}) then
		state.pendingBattle = false
		if state.southPassageStep == "await_grunt"
			and state.gruntAttempts ~= nil
			and state.gruntAttempts[newMauvilleSouthGruntKey]
		then
			state.southPassageStep = "wait_for_gate"
			state.southPassageAttemptedAt = 0
		end
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
	step("New Mauville Entrance", 12, 4, 13, 4),
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
