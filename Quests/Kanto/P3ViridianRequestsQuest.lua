-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.

local sys   = require "Libs/syslib"
local game  = require "Libs/gamelib"
local Quest = require "Quests/Quest"

local name        = "Viridian Forest and Route 1 Requests"
local description = "beat Gerrald, collect Rattata Hair, and catch Sentret"

local RATTATA_HAIR = "Rattata Hair"

local RATTATA_RECTANGLE = { 22, 13, 26, 13 }
local SENTRET_RECTANGLE = { 22, 13, 26, 13 }
local OFFICER_JENNY_CELL = { x = 50, y = 43 }
local JENNY_FLAG_FILE = "viridian_jenny_flags.txt"
local GERRALD_FLAG = "gerrald_battle_complete"
local RATTATA_JENNY_FLAG = "rattata_turn_in_complete"
local SENTRET_JENNY_FLAG = "sentret_turn_in_complete"

-- The cell is intentionally configurable until it is confirmed in-game.
-- The active-battler lookup below still handles the normal trainer case.
local configuredGerraldCell = VIRIDIAN_GERRALD_CELL

local P3ViridianRequestsQuest = Quest:new()

local function validCell(cell)
	return type(cell) == "table"
		and tonumber(cell.x) ~= nil
		and tonumber(cell.y) ~= nil
end

local function containsIgnoreCase(value, fragment)
	if type(value) ~= "string" then
		return false
	end
	return string.find(string.lower(value), string.lower(fragment), 1, true) ~= nil
end

-- Persist Viridian side-story progress through the existing script file APIs.
-- logToFile/readLinesFromFile are restricted by PROBot to the Logs folder;
-- keeping the filename constant makes progress survive a script restart.
local function hasViridianFlag(flag)
	if type(readLinesFromFile) ~= "function" then
		return false
	end

	local lines = readLinesFromFile(JENNY_FLAG_FILE)
	if type(lines) ~= "table" then
		return false
	end

	for _, line in ipairs(lines) do
		if line == flag then
			return true
		end
	end
	return false
end

local function saveViridianFlags(gerraldDefeated, rattataTurnedIn, sentretTurnedIn)
	if type(logToFile) ~= "function" then
		return false
	end

	local flags = {}
	if gerraldDefeated then
		table.insert(flags, GERRALD_FLAG)
	end
	if rattataTurnedIn then
		table.insert(flags, RATTATA_JENNY_FLAG)
	end
	if sentretTurnedIn then
		table.insert(flags, SENTRET_JENNY_FLAG)
	end

	-- Overwrite instead of appending so repeated ticks never duplicate flags.
	logToFile(JENNY_FLAG_FILE, flags, true)
	return true
end

function P3ViridianRequestsQuest:new()
	local o = Quest.new(P3ViridianRequestsQuest, name, description, 1)
	o.gerraldDefeated = hasViridianFlag(GERRALD_FLAG)
	o.gerraldApproached = false
	o.gerraldBattlePending = false
	o.gerraldSearchAttempts = 0
	o.gerraldWarningShown = false
	o.rattataTurnedIn = hasViridianFlag(RATTATA_JENNY_FLAG)
	o.sentretTurnedIn = hasViridianFlag(SENTRET_JENNY_FLAG)
	o.pokemon = nil
	o.forceCaught = false
	-- Remember the intended destination while crossing the intermediate
	-- Viridian/Route 2 map links.  The current client no longer supports
	-- moveToMap(), so each hop is performed with moveToCell().
	o.navigationTarget = nil

	-- PC requirement state. This deliberately uses the existing PC globals
	-- instead of adding another party/PC manager.
	o.pcScan = nil
	o.pcScanTarget = nil
	o.pcScanNeedsHair = false
	o.pcOperation = nil
	o.pcScanned = {
		Rattata = false,
		Sentret = false,
	}
	o.pcFound = {
		Rattata = false,
		Sentret = false,
	}

	return o
end

function P3ViridianRequestsQuest:markGerraldDefeated()
	self.gerraldDefeated = true
	self.gerraldBattlePending = false
	saveViridianFlags(self.gerraldDefeated, self.rattataTurnedIn, self.sentretTurnedIn)
end

function P3ViridianRequestsQuest:isDoable()
	return not hasItem("Boulder Badge") and self:hasMap()
end

-- The next Boulder Badge quest expects to start from Route 2. We therefore
-- finish this quest after the final Jenny turn-in and the return to Route 2.
function P3ViridianRequestsQuest:isDone()
	return self.sentretTurnedIn and getMapName() == "Route 2"
end

function P3ViridianRequestsQuest:getRattataHairCount()
	local quantity = getItemQuantity(RATTATA_HAIR)
	if type(quantity) ~= "number" or quantity < 0 then
		return 0
	end
	return quantity
end

function P3ViridianRequestsQuest:takeTeamRattataHair()
	for pokemonIndex = 1, getTeamSize() do
		if getPokemonHeldItem(pokemonIndex) == RATTATA_HAIR then
			sys.debug("Viridian requests", "Taking Rattata Hair from " .. getPokemonName(pokemonIndex) .. ".")
			return takeItemFromPokemon(pokemonIndex)
		end
	end
	return false
end

function P3ViridianRequestsQuest:hasTargetPokemon(pokemonName)
	if game.hasPokemonWithName(pokemonName) then
		return true
	end
	return self.pcFound[pokemonName] == true
end

function P3ViridianRequestsQuest:findActiveGerraldCell()
	local activeBattlers = getActiveBattlers()
	if type(activeBattlers) ~= "table" then
		return nil, nil
	end

	for trainer, position in pairs(activeBattlers) do
		if containsIgnoreCase(trainer, "Gerrald")
			and type(position) == "table"
			and tonumber(position.x) ~= nil
			and tonumber(position.y) ~= nil
		then
			return tonumber(position.x), tonumber(position.y)
		end
	end

	return nil, nil
end

function P3ViridianRequestsQuest:talkToGerrald(x, y)
	self.gerraldApproached = true
	self.gerraldBattlePending = true
	return talkToNpcOnCell(x, y)
end

-- The shared Quest implementation still owns other trainer interaction. This
-- hook only gives Gerrald the confirmed coordinates and pending-battle flag;
-- it does not add a second trainer-battle state machine.
function P3ViridianRequestsQuest:fightTrainersOnMap()
	local x, y = self:findActiveGerraldCell()
	if x ~= nil and isNpcOnCell(x, y) then
		return self:talkToGerrald(x, y)
	end
	return Quest.fightTrainersOnMap(self)
end

function P3ViridianRequestsQuest:ViridianForest()
	if self.gerraldDefeated then
		sys.debug("Viridian requests", "Gerrald defeated; going to Route 1.")
		self.navigationTarget = "route1"
		return moveToCell(40, 70) -- Viridian Forest -> Route 2 Stop
	end

	-- Prefer the live trainer position. This keeps the quest independent of a
	-- hard-coded map cell and lets the existing active-NPC infrastructure find
	-- Gerrald when his confirmed cell is not known yet.
	local x, y = self:findActiveGerraldCell()
	if x ~= nil then
		self.gerraldSearchAttempts = 0
		if isNpcOnCell(x, y) then
			return self:talkToGerrald(x, y)
		end
		return moveToCell(x, y)
	end

	-- Once the active battler disappears after the common trainer-battle
	-- handler, the requested battle has completed.
	if self.gerraldApproached then
		self:markGerraldDefeated()
		self.navigationTarget = "route1"
		return moveToCell(40, 70) -- Viridian Forest -> Route 2 Stop
	end

	-- Use the confirmed cell when it is supplied later. It is checked only
	-- while the trainer has not yet been approached, so a defeated NPC that
	-- remains visible cannot cause an endless repeat battle.
	if validCell(configuredGerraldCell) then
		local configuredX = tonumber(configuredGerraldCell.x)
		local configuredY = tonumber(configuredGerraldCell.y)
		if isNpcOnCell(configuredX, configuredY) then
			return self:talkToGerrald(configuredX, configuredY)
		end
		return moveToCell(configuredX, configuredY)
	end

	if isNpcVisible("Bug Catcher Gerrald") then
		self.gerraldApproached = true
		self.gerraldBattlePending = true
		return talkToNpc("Bug Catcher Gerrald")
	elseif isNpcVisible("Gerrald") then
		self.gerraldApproached = true
		self.gerraldBattlePending = true
		return talkToNpc("Gerrald")
	end

	-- Map NPC data can take a tick to populate after entering the forest.
	-- Avoid skipping the trainer on the first empty lookup. If the active
	-- battler API cannot resolve him, wait for the configured cell instead of
	-- silently marking the required battle complete.
	self.gerraldSearchAttempts = self.gerraldSearchAttempts + 1
	if self.gerraldSearchAttempts < 3 then
		return false
	end

	if not self.gerraldWarningShown then
		sys.todo("Set VIRIDIAN_GERRALD_CELL after confirming Bug Catcher Gerrald's cell.")
		self.gerraldWarningShown = true
	end
	return false
end

function P3ViridianRequestsQuest:beginPcScan(targetName, needsHair)
	self.pcScanTarget = targetName
	self.pcScanNeedsHair = needsHair == true
	self.pcScan = {
		box = 1,
		targetName = targetName,
		needsHair = self.pcScanNeedsHair,
		target = nil,
		hair = nil,
	}
end

-- Scan every available box for the requested Pokemon and, during the
-- Rattata phase, a held Rattata Hair. The next action is always returned to
-- the existing Lua tick/pathfinder flow; no second PC state machine is made.
function P3ViridianRequestsQuest:advancePcScan()
	local scan = self.pcScan
	if scan == nil then
		return nil, false
	end

	if not isPCOpen() or not isCurrentPCBoxRefreshed() then
		return nil, true
	end

	local boxCount = getPCBoxCount()
	if type(boxCount) ~= "number" or boxCount < 1 then
		return { target = scan.target, hair = scan.hair }, false
	end

	if getCurrentPCBoxId() ~= scan.box then
		openPCBox(scan.box)
		return nil, true
	end

	local boxSize = getCurrentPCBoxSize()
	if type(boxSize) ~= "number" then
		boxSize = 0
	end
	for slot = 1, boxSize do
		local pokemonName = getPokemonNameFromPC(scan.box, slot)
		if scan.target == nil and pokemonName == scan.targetName then
			scan.target = {
				box = scan.box,
				slot = slot,
				name = pokemonName,
				uniqueId = getPokemonUniqueIdFromPC(scan.box, slot),
			}
		end

		if scan.needsHair and scan.hair == nil
			and getPokemonHeldItemFromPC(scan.box, slot) == RATTATA_HAIR
		then
			scan.hair = {
				box = scan.box,
				slot = slot,
				name = pokemonName,
				uniqueId = getPokemonUniqueIdFromPC(scan.box, slot),
			}
		end
	end

	if scan.box < boxCount then
		scan.box = scan.box + 1
		openPCBox(scan.box)
		return nil, true
	end

	return { target = scan.target, hair = scan.hair }, false
end

function P3ViridianRequestsQuest:finishPcScan(result)
	local targetName = self.pcScanTarget
	if targetName == nil then
		return false
	end

	if result ~= nil and result.target ~= nil then
		self.pcFound[targetName] = true
	end

	if result ~= nil and result.hair ~= nil then
		self.pcOperation = {
			box = result.hair.box,
			slot = result.hair.slot,
			targetName = result.hair.name,
			targetUniqueId = result.hair.uniqueId,
			step = "transfer",
		}
		return true
	end

	self.pcScanned[targetName] = true
	self.pcScan = nil
	self.pcScanTarget = nil
	self.pcScanNeedsHair = false
	return false
end

function P3ViridianRequestsQuest:finishPcOperation()
	local targetName = self.pcScanTarget
	if targetName ~= nil then
		self.pcScanned[targetName] = true
	end
	self.pcOperation = nil
	self.pcScan = nil
	self.pcScanTarget = nil
	self.pcScanNeedsHair = false
	self.navigationTarget = "route1"
	return moveToCell(9, 22) -- Pokecenter Viridian -> Viridian City
end

function P3ViridianRequestsQuest:processPcOperation()
	local operation = self.pcOperation
	if operation == nil then
		return false
	end

	if not isPCOpen() then
		return usePC()
	end
	if not isCurrentPCBoxRefreshed() then
		return false
	end

	if operation.step == "transfer" then
		if getTeamSize() < 6 then
			operation.mode = "withdraw"
			operation.teamIndex = getTeamSize() + 1
			local action = withdrawPokemonFromPC(operation.box, operation.slot)
			if action then
				operation.step = "waitTransfer"
			end
			return action
		end

		-- Preserve a full party by swapping temporarily. The original party
		-- member is swapped back after its held item is removed.
		operation.mode = "swap"
		operation.teamIndex = getTeamSize()
		operation.originalTeamName = getPokemonName(operation.teamIndex)
		operation.originalTeamUniqueId = getPokemonUniqueId(operation.teamIndex)
		local action = swapPokemonFromPC(operation.box, operation.slot, operation.teamIndex)
		if action then
			operation.step = "waitTransfer"
		end
		return action
	end

	if operation.step == "waitTransfer" then
		local ready
		if operation.mode == "withdraw" then
			ready = getTeamSize() >= operation.teamIndex
		else
			ready = getPokemonUniqueId(operation.teamIndex) == operation.targetUniqueId
		end
		if not ready then
			return false
		end
		operation.step = "take"
	end

	if operation.step == "take" then
		if getPokemonHeldItem(operation.teamIndex) == RATTATA_HAIR then
			local action = takeItemFromPokemon(operation.teamIndex)
			if action then
				operation.step = "waitTake"
			end
			return action
		end

		if operation.mode == "swap" then
			operation.step = "swapBack"
		else
			return self:finishPcOperation()
		end
	end

	if operation.step == "waitTake" then
		if getPokemonHeldItem(operation.teamIndex) == RATTATA_HAIR then
			return false
		end
		if operation.mode == "swap" then
			operation.step = "swapBack"
		else
			return self:finishPcOperation()
		end
	end

	if operation.step == "swapBack" then
		local action = swapPokemonFromPC(operation.box, operation.slot, operation.teamIndex)
		if action then
			operation.step = "waitSwapBack"
		end
		return action
	end

	if operation.step == "waitSwapBack" then
		if getPokemonUniqueId(operation.teamIndex) ~= operation.originalTeamUniqueId then
			return false
		end
		return self:finishPcOperation()
	end

	return false
end

function P3ViridianRequestsQuest:talkToOfficerJenny(turnIn)
	if not game.inCell(OFFICER_JENNY_CELL.x, OFFICER_JENNY_CELL.y)
		and not isNpcOnCell(OFFICER_JENNY_CELL.x, OFFICER_JENNY_CELL.y)
	then
		return moveToCell(OFFICER_JENNY_CELL.x, OFFICER_JENNY_CELL.y)
	end

	local action = talkToNpcOnCell(OFFICER_JENNY_CELL.x, OFFICER_JENNY_CELL.y)
	if action then
		if turnIn == "rattata" then
			self.rattataTurnedIn = true
		elseif turnIn == "sentret" then
			self.sentretTurnedIn = true
		end
		saveViridianFlags(self.gerraldDefeated, self.rattataTurnedIn, self.sentretTurnedIn)
	end
	return action
end

function P3ViridianRequestsQuest:Route1()
	if self.sentretTurnedIn then
		self.pokemon = nil
		self.navigationTarget = "route2"
		return moveToCell(14, 4) -- Route 1 -> Route 1 Stop House
	end

	if self:takeTeamRattataHair() then
		return true
	end

	if not self.rattataTurnedIn then
		self.pokemon = "Rattata"
		self.forceCaught = false

		if not self:hasTargetPokemon("Rattata") then
			if getTeamSize() >= 6 and not self.pcScanned.Rattata then
				self:beginPcScan("Rattata", true)
				self.navigationTarget = "pokecenter"
				return moveToCell(14, 4) -- Route 1 -> Route 1 Stop House
			end
			return moveToRectangle(
				RATTATA_RECTANGLE[1], RATTATA_RECTANGLE[2],
				RATTATA_RECTANGLE[3], RATTATA_RECTANGLE[4]
			)
		end

		if self:getRattataHairCount() < 3 then
			if not self.pcScanned.Rattata then
				self:beginPcScan("Rattata", true)
				self.navigationTarget = "pokecenter"
				return moveToCell(14, 4) -- Route 1 -> Route 1 Stop House
			end
			return moveToRectangle(
				RATTATA_RECTANGLE[1], RATTATA_RECTANGLE[2],
				RATTATA_RECTANGLE[3], RATTATA_RECTANGLE[4]
			)
		end

		self.pokemon = nil
		self.forceCaught = true
		return self:talkToOfficerJenny("rattata")
	end

	self.pokemon = "Sentret"
	self.forceCaught = false
	if not self:hasTargetPokemon("Sentret") then
		if getTeamSize() >= 6 and not self.pcScanned.Sentret then
			self:beginPcScan("Sentret", false)
			self.navigationTarget = "pokecenter"
			return moveToCell(14, 4) -- Route 1 -> Route 1 Stop House
		end
		return moveToRectangle(
			SENTRET_RECTANGLE[1], SENTRET_RECTANGLE[2],
			SENTRET_RECTANGLE[3], SENTRET_RECTANGLE[4]
		)
	end

	self.pokemon = nil
	self.forceCaught = true
	return self:talkToOfficerJenny("sentret")
end

function P3ViridianRequestsQuest:PokecenterViridian()
	if self.pcOperation ~= nil then
		return self:processPcOperation()
	end

	if self.pcScanTarget == nil then
		self.navigationTarget = "route1"
		return moveToCell(9, 22) -- Pokecenter Viridian -> Viridian City
	end

	if not isPCOpen() then
		return usePC()
	end

	local result, waiting = self:advancePcScan()
	if waiting then
		return true
	end

	if self:finishPcScan(result) then
		return self:processPcOperation()
	end

	self.navigationTarget = "route1"
	return moveToCell(9, 22) -- Pokecenter Viridian -> Viridian City
end

function P3ViridianRequestsQuest:ViridianCity()
	if self.pcScanTarget ~= nil or self.pcOperation ~= nil or self.navigationTarget == "pokecenter" then
		self.navigationTarget = "pokecenter"
		return moveToCell(44, 43) -- Viridian City -> Pokecenter Viridian
	end
	if self.sentretTurnedIn or self.navigationTarget == "route2" then
		self.navigationTarget = "route2"
		return moveToCell(37, 0) -- Viridian City -> Route 2_C/Route 2
	end
	self.navigationTarget = "route1"
	return moveToCell(48, 61) -- Viridian City -> Route 1 Stop House
end

function P3ViridianRequestsQuest:Route1StopHouse()
	if self.navigationTarget == "route2" or self.navigationTarget == "pokecenter" then
		return moveToCell(3, 2) -- Route 1 Stop House -> Viridian City
	end
	return moveToCell(3, 12) -- Route 1 Stop House -> Route 1
end

function P3ViridianRequestsQuest:Route2()
	if self.sentretTurnedIn then
		return false
	end
	if self.navigationTarget == "route1" or self.gerraldDefeated then
		self.navigationTarget = "route1"
		return moveToCell(10, 130) -- Route 2_C/Route 2 -> Viridian City
	end
	self.navigationTarget = "forest"
	return moveToCell(16, 96) -- Route 2 -> Route 2 Stop
end

function P3ViridianRequestsQuest:Route2Stop()
	if self.navigationTarget == "route1" then
		return moveToCell(3, 12) -- Route 2 Stop -> Route 2_C
	end
	return moveToCell(4, 2) -- Route 2 Stop -> Viridian Forest
end

-- Some Pathfinder map data exposes the lower Route 2 segment as Route 2_C;
-- keep an explicit handler so the shared Quest dispatcher never falls back to
-- the removed moveToMap() API if that map name is reported by the client.
function P3ViridianRequestsQuest:Route2_C()
	if self.navigationTarget == "route1" then
		return moveToCell(10, 130) -- Route 2_C -> Viridian City
	end
	return moveToCell(15, 96) -- Route 2_C -> Route 2 Stop
end

function P3ViridianRequestsQuest:dialog(message)
	-- Gerrald remains visible after his one-time battle and answers with this
	-- message on later interaction. Treat it as the completed story segment so
	-- the quest does not try to battle him again after a restart/interruption.
	if self.gerraldApproached
		and containsIgnoreCase(message, "haven't found anything else unique to battle you with")
	then
		self:markGerraldDefeated()
		return true
	end
	return Quest.dialog(self, message)
end

function P3ViridianRequestsQuest:battleMessage(message)
	Quest.battleMessage(self, message)
	if self.gerraldBattlePending and containsIgnoreCase(message, "won the battle") then
		-- Do not wait for Gerrald to disappear from getActiveBattlers(); the
		-- server keeps the NPC visible and only changes his dialogue.
		self:markGerraldDefeated()
	end

	if containsIgnoreCase(message, "caught") then
		if self.pokemon == "Rattata" then
			self.pcScanned.Rattata = false
			self.pcFound.Rattata = false
		elseif self.pokemon == "Sentret" then
			self.pcScanned.Sentret = false
			self.pcFound.Sentret = false
		end
	end
end

return P3ViridianRequestsQuest
