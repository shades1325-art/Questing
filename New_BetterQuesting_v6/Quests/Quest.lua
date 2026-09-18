

local sys  = require "Libs/syslib"
local game = require "Libs/gamelib"
local team = require "Libs/teamlib"

local blacklist = require "blacklist"

local Quest = {}
Quest.lastDebugMessage = nil
Quest.repeatCount = 0
-- the base class of all quests
function Quest:new(name, description, level, dialogs)
	local o = {}
	setmetatable(o, self)
	self.__index  = self
	o.name        = name
	o.description = description
	o.level       = level or 1
	o.dialogs     = dialogs
	o.training    = true
	o.canRun	  = true
	o.canSwitch   = true 
	o.blockedMove = false
	return o
end

function Quest:isDoable()
	sys.error("Quest:isDoable", "function is not overloaded in quest: " .. self.name)
	return nil
end

function Quest:isDone()
	return self:isDoable() == false
end
function Quest:debug(tag, message)
    local fullMsg = tag .. ": " .. message
    if self.lastDebugMessage == fullMsg then
        self.repeatCount = self.repeatCount + 1
    else
        self.repeatCount = 1
        self.lastDebugMessage = fullMsg
    end

    sys.debug(tag, message)

    -- nếu cùng message lặp >= 6 lần thì relog
    if self.repeatCount >= 6 then
        self.repeatCount = 0       --  reset counter
        self.lastDebugMessage = "" --  xóa để không dính lại ngay
        return relog(15, "Relogging (debug spam).")
    end
end
function Quest:mapToFunction()
	local mapName = getMapName()
	local mapFunction = sys.removeCharacter(mapName, ' ')
	mapFunction = sys.removeCharacter(mapFunction, '.')
	mapFunction = sys.removeCharacter(mapFunction, '-') -- Map "Fisherman House - Vermilion"
	return mapFunction
end

function Quest:hasMap()
	local mapFunction = self:mapToFunction()
	if self[mapFunction] then
		return true
	end
	return false
end

function Quest:pokecenter(exitMapName) -- idealy make it work without exitMapName

	local JohtoPokecenters = { -- moveToCell(10, 20) ?
		"Pokecenter Cherrygrove City",
		"Pokecenter Azalea",
		"Pokecenter Goldenrod",
		"Pokecenter Ecruteak",
		"Olivine Pokecenter",
		"Pokecenter Cianwood",
		"Pokecenter Blackthorn",
	}


	self.registeredPokecenter = getMapName()		
	if not game.isTeamFullyHealed() then
		if getMapName() == "Indigo Plateau Center" or getMapName() == "Indigo Plateau Center Johto" then
			return talkToNpcOnCell(4, 22)
		else
			return usePokecenter()
		end
	elseif sys.tableHasValue(JohtoPokecenters, getMapName()) then
		return moveToCell(10, 20)
	else
		return moveToCell(9,22)
	end
end

-- at a point in the game we'll always need to buy the same things
-- use this function then
function Quest:pokemart(exitMapName)
	local pokeballCount = getItemQuantity("Pokeball")
	local pokeballTarget = 20
	--local escapeRopeCount = getItemQuantity("Escape Rope")

	--pokeballs
	-- Keep this condition aligned with the amount bought below.  The old
	-- condition used 50 while the purchase logic stopped at 20, so after the
	-- first purchase the quest kept the mart branch active and never reached
	-- the exit branch.
	if (getMoney() >= 200 and pokeballCount < pokeballTarget) then
		--talk to shop owner - can it be they are always located at 3,5? Doesn't seem right

		local specialPokemartsNPCs1 = { -- NPC: 3, 4
			"Mart Cherrygrove City",
			"Blackthorn City Pokemart",
		}

		local specialPokemartsNPCs2 = { -- NPC: 12, 9
			"Mart Petalburg City",
			"Mart Rustboro City",
			"Mart Oldale Town",
		}

		local specialPokemartsNPCs3 = { -- NPC: 3, 6
			"Olivine Pokemart",
		}

		if not isShopOpen() then
			if sys.tableHasValue(specialPokemartsNPCs1, getMapName()) then
				return talkToNpcOnCell(3, 4)
			elseif sys.tableHasValue(specialPokemartsNPCs2, getMapName()) then
				return talkToNpcOnCell(12, 9)
			elseif sys.tableHasValue(specialPokemartsNPCs3, getMapName()) then
				return talkToNpcOnCell(3, 6)
			elseif getMapName() == "Celadon Mart 2" then
				return talkToNpcOnCell(4, 8)
			else
				return talkToNpcOnCell(3, 5)
			end
		end

		--else prepare buying
		
		--pokeballs
		-- Only buy up to 20 Poké Balls maximum to save money
		local pokeballToBuy = pokeballTarget - pokeballCount
		if pokeballToBuy > 0 then
			local maximumBuyablePokeballs = math.floor(getMoney() / 200)
			pokeballToBuy = math.min(pokeballToBuy, maximumBuyablePokeballs)
			
			if getItemQuantity("Pokeball") < pokeballTarget and getMoney() >= 200 and pokeballToBuy > 0 then
				if buyItem("Pokeball", pokeballToBuy) then
				end
			end
		end
	--if nothing to buy, leave mart




	else
		local specialPokemartsExits1 = { -- Exit: 4, 11
			"Viridian Pokemart",
			"Lavender Pokemart",
			"Blackthorn City Pokemart",
			"Mart Cherrygrove City",
			"Ecruteak Mart",
			"Cinnabar Pokemart",
			"Mart Mauville City",
			"Fortree Mart",
		}

		local specialPokemartsExits2 = { -- Exit: 3, 11
			"Mart Petalburg City",
			"Mart Rustboro City",
			"Mart Oldale Town",
		}

		if sys.tableHasValue(specialPokemartsExits1, getMapName()) then
			return moveToCell(4, 11)
		elseif sys.tableHasValue(specialPokemartsExits2, getMapName()) then
			return moveToCell(3, 11)
		elseif getMapName() == "Celadon Mart 2" then
			return moveToCell(1, 4)
		else
			return moveToCell(6, 12)
		end
	end
end




function Quest:isTrainingOver()
	local lowestLvl = team.getLowestLvl()
	if lowestLvl and lowestLvl >= self.level then
		if self.training then -- end the training
			self:stopTraining()
		end
		return true
	end
	return false
end
function Quest:giveLeftoversToAll()
    local ItemName = "Leftovers"
    local leftoversCount = getItemQuantity(ItemName)
    if leftoversCount == 0 then return false end

    -- Collect Pokémon indices and levels
    local teamList = {}
    for i = 1, getTeamSize() do
        table.insert(teamList, {index = i, level = getPokemonLevel(i)})
    end

    -- Sort by level descending
    table.sort(teamList, function(a, b) return a.level > b.level end)

    for _, p in ipairs(teamList) do
        if getPokemonHeldItem(p.index) ~= ItemName and hasItem(ItemName) then
            giveItemToPokemon(ItemName, p.index)
            return true -- Only one action per call!
        end
    end
    return false
end
function Quest:leftovers()
	if leftovers_disabled then return end
	ItemName = "Leftovers"
	local PokemonNeedLeftovers = team.getHighestPkmAlive() or team.getHighestUsablePkmToLvl(100)
	local PokemonWithLeftovers = game.getPokemonIdWithItem(ItemName)

	-- EXCEPTIONS FOR REMOVE LEFTOVERS FROM POKEMON
	if getMapName() == "Route 27" and not hasItem("Zephyr Badge") then --START JOHTO
		if PokemonWithLeftovers > 0 then
			takeItemFromPokemon(PokemonWithLeftovers)
			return true
		end
		return false
	end
	if getMapName() == "Pokemon League Hoenn" then --REMOVE LEFTOVERS FROM ODDISH - GoldenrodCityQuest.lua
		if PokemonWithLeftovers > 0 then
			takeItemFromPokemon(PokemonWithLeftovers)
			return true
		end
		return false
	end
	if getMapName() == "Indigo Plateau" and hasItem("Rising Badge") and self.name == "Go to Hoenn" then
		if PokemonWithLeftovers > 0 then
			takeItemFromPokemon(PokemonWithLeftovers)
			return true
		end
		return false
	end

	if getMapName() == "VermilionHouse2Bottom" then -- bike quest
		if PokemonWithLeftovers > 0 then
			takeItemFromPokemon(PokemonWithLeftovers)
			return true
		end
		return false
	end
	
	if string.match(getMapName(), "Indigo Plateau Center") then
		if PokemonWithLeftovers > 0 then
			takeItemFromPokemon(PokemonWithLeftovers)
			return true
		end
		return false
	end
	------
	
	if getTeamSize() > 0 then
		local ItemName = "Leftovers"
		local leftoversCount = getItemQuantity(ItemName)
		if leftoversCount == 0 then return false end

		-- Collect Pokémon indices and levels
		local teamList = {}
		for i = 1, getTeamSize() do
			table.insert(teamList, {index = i, level = getPokemonLevel(i)})
		end

		-- Sort by level descending
		table.sort(teamList, function(a, b) return a.level > b.level end)

		local given = 0
		for _, p in ipairs(teamList) do
			if getPokemonHeldItem(p.index) ~= ItemName and hasItem(ItemName) then
				giveItemToPokemon(ItemName, p.index)
				return true -- Only one action per call!
			end
		end
		return false
	else
		return false
	end
end

function Quest:startTraining()
	self.training = true
end

function Quest:stopTraining()
	self.training = false
	self.healPokemonOnceTrainingIsOver = true
end

function Quest:needPokemart()
	-- TODO: ItemManager
	-- Only buy Poké Balls if we have less than 20 and enough money
	-- This saves money early in the game
	if getItemQuantity("Pokeball") < 20 and getMoney() >= 200 then
		return true
	end
	return false
end

function Quest:needPokecenter()
	if getUsablePokemonCount() < getTeamSize() then
		return true
	end
	if getTeamSize() == 1 then
		-- to avoid blacking out
		if getPokemonHealthPercent(1) <= 50 then 
			return true 
		end
		

	-- else we would spend more time evolving the higher level ones
	elseif not self:isTrainingOver() then
		if team.getLowestUsablePkmToLvl(self.level) == nil then
			return true
		-- <= needed, if last pkm has no pp, it's also unusable therefor value = 0
		elseif getUsablePokemonCount() < 2
			or not team.getAlivePkmToLvl(self.level)
		then return true end

	elseif not game.isTeamFullyHealed() and self.healPokemonOnceTrainingIsOver then 
		return true

	-- the team is fully healed and training over
	else 
		self.healPokemonOnceTrainingIsOver = false 
	end

	return false
end

function Quest:message()
	return self.name .. ': ' .. self.description
end

-- I'll need a TeamManager class very soon
local moonStoneTargets = {
	"Clefairy",
	"Jigglypuff",
	"Munna",
	"Nidorino",
	"Nidorina",
	"Skitty"
}

function Quest:evolvePokemon()
	-- some buffer levels, to ensure every teammember is fully evolved when figthing e4
	-- some leeway for indiviudal quest caps: Kanto e4 is started with lv 95, so evolving could start at 93
	
	--local lowestLvl = team.getLowestLvl()
	--if lowestLvl >= 90 then enableAutoEvolve() end
	
	if self.name == "Go to Hoenn" then
		if getPokemonName(1) == "Rattata" then
			disableAutoEvolve()
		else
			enableAutoEvolve()
		end
	else
		enableAutoEvolve()
	end

	-- or team.getHighestLvl() >= 93 --not leveling mixed teams efficiently: lv 38, ...., lv 93

	return self:useMoonStones()
end

function Quest:useMoonStones()
	local hasMoonStone = hasItem("Moon Stone")
	for pokemonId=1, getTeamSize(), 1 do
		local pokemonName = getPokemonName(pokemonId)
		if hasMoonStone
			and sys.tableHasValue(moonStoneTargets, pokemonName)
		then
			return useItemOnPokemon("Moon Stone", pokemonId)
		end
	end
	return false
end

--prevents the sort algorithm being visualized - e.g. when gm inspects team
function Quest:sortInMemory()
	--setting lowest level pkm as starter
	local starter = team.getStarter() --getFirstPokemonAlive
	local lowestUsablePkmToLvl = team.getLowestUsablePkmToLvl(self.level)

	if self.level == nil or self.level == 1 then -- if level isn't set, assume this
		lowestUsablePkmToLvl = team.getLowestUsablePkmToLvl(100)
	end
		

	if lowestUsablePkmToLvl and	starter ~= lowestUsablePkmToLvl	then
		return swapPokemon(lowestUsablePkmToLvl, starter)
	end

	--setting highest level pkm, as last defense wall
	local highestAlivePkm = team.getHighestPkmAlive() --has to be found or you would have feinted
	local lastPkm = team.getLastPkmAlive()

	if highestAlivePkm ~= lastPkm and highestAlivePkm ~= lowestUsablePkmToLvl then
		return swapPokemon(highestAlivePkm, lastPkm)
	end
end 

function Quest:checkDiscoverables()
	if hasItem("Shovel") or (game.hasPokemonWithMove("Dig") and getPokemonHappiness(team.getFirstPkmWithMove("Dig")) >= 150) then
		for i,v in ipairs(getActiveDigSpots()) do
			if isNpcOnCell(v.x, v.y) then
				if talkToNpcOnCell(v.x, v.y) then
					sys.debug("Dig Spot Finder", "Going to DigSpot " .. i .. ": x(" .. v.x .. "), " .. "y(" .. v.y .. ")")
					return true 
				end
			end
		end
	end

	local blacklistHeadbuttMaps = {
		"Route 35",
		"Route 120",
		"Route 119A",
		"Fortree City",
		"Rustboro City",
		"Hearthome City",
		"Sendoff Spring",
	}

	if hasItem("Battering Ram") or (game.hasPokemonWithMove("Headbutt") and getPokemonHappiness(team.getFirstPkmWithMove("Headbutt")) >= 150) then
		for i,v in ipairs(getActiveHeadbuttTrees()) do
			if not sys.tableHasValue(blacklistHeadbuttMaps, getMapName()) then
				if isNpcOnCell(v.x, v.y) then
					if talkToNpcOnCell(v.x, v.y) then
						sys.debug("Headbutt Tree Finder", "Going to Headbutt Tree: x(" .. v.x .. "), " .. "y(" .. v.y .. ")")
						return true 
					end
				end
			end
		end
	end

	local blacklistBerryTreeMaps = {
		"Mahogany Town Rocket Hideout B3F",
		"Route 110",
		"Route 42",
	}

	--for i,v in ipairs(getActiveBerryTrees()) do
		--if not sys.tableHasValue(blacklistBerryTreeMaps, getMapName()) then
			--if isNpcOnCell(v.x, v.y) then
				--if talkToNpcOnCell(v.x, v.y) then
					--sys.debug("Berry Finder", "Going to Berry Tree: x(" .. v.x .. "), " .. "y(" .. v.y .. ")")
					--return true
				--end
			--end
		--end
	--end

	local blackListMapsForItems = {
		"Viridian Forest",
		"Mt. Moon 1F",
		--"Union Cave 1F",
		"Union Cave 1F",
		"Route 12",
		"Rocket Hideout B1F",
		"Rocket Hideout B2F",
		"Rocket Hideout B4F",
		"Player Bedroom Pallet",
		"Oaks Lab",
		"Professor Elms Lab",
		"Saffron Dojo",
		"Route 32", -- "Wow, the wrapping on this thing is quite nice, must belong to someone."
		"Underground Warehouse",
		"Route 35",
		"Lab Littleroot Town",
		"Route 42",
		"Route 110",
		"Route 117",
		"Route 119A",
		"Route 120",
		"Route 201", -- Pick Starter
		"Route 203", -- Barry Block
		"Route 205",
		"Route 206",
		"Route 213",
		"Route 215",
		"Route 223",
		"Jagged Pass",
		"Petalburg City",
		"New Mauville",
		"Hearthome City",
		"Route 40",
		"Rowan Lab",
		"Mt. Coronet Summit",
		"Sendoff Spring",
		"Mt. Coronet Center",
	}

	for i,v in ipairs(getDiscoverableItems()) do
		if not sys.tableHasValue(blackListMapsForItems, getMapName()) then
			if isNpcOnCell(v.x, v.y) then
				if talkToNpcOnCell(v.x, v.y) then
					--sys.debug("Item Finder", "Going to Item: x(" .. v.x .. "), " .. "y(" .. v.y .. ")")
					self:debug("Item Finder", "Going to Item: x(" .. v.x .. "), " .. "y(" .. v.y .. ")")
					return true
				end
			end
		end
	end

	local blacklistPokestopMaps = {
		"Route 35",
	}


 
	local abandonedPokemonMapBlacklist = {
		"Oaks Lab",
		"Olivine City",
		"Sprout Tower F1", -- Ghastly sucks for leveling
		"Tohjo Falls", -- else we will end up with 2x Crobat at the end
	}


end

function Quest:fightTrainersOnMap()
	-- After the Rainbow Badge, Fast Story skips optional trainer battles.
	-- Keep this guard in the shared base quest so every region reuses it.
	if hasItem("Rainbow Badge") then
		return false
	end

	local trainerBlackList = {
		"[a0522d]Sailor Gordon[-]" -- @ Vermilion City, idk why he is marked as a trainer
	}
	local trainerBlackListMap = {
		"Route 7",
		"Route 12",
		"Route 21",
		"Route 26",
		"Route 27",
		"Route 32",
		"Route 40",
		"Route 110",
		"Route 111 South",
		"Route 119A",
		"Route 120",
		"Route 203",  -- Barry Block
		"Route 204", 
		"Route 205",
		"Route 206",
		"Route 213",
		"Valley Windworks",
		"Mauville City Gym",
		"Mt. Moon 1F",
		"Pokecenter Lavender",
		"Pokecenter Celadon",
		"Pokecenter Fuchsia",
		"Pokecenter Saffron",
		"Pokecenter Cinnabar",
		"Pokecenter Viridian",
		"Rocket Hideout B1F",
		"Rocket Hideout B2F",
		"Underground Warehouse",
		"Mahogany Town Rocket Hideout B2F",
		"Seafloor Cavern R7",
		"Sky Pillar Entrance Cave 1F",
		"Snowpoint Gym",
		"Jagged Pass",
		"Jubilife City",
		"Mauville City",
		"Mossdeep City",
		"Mauville City Stop House 3",
		"Mauville City Stop House 4",
		"Victory Road Hoenn 1F",
		"Victory Road Hoenn B1F",
		"Spear Pillar",
		"Oreburgh Mine B1F",
		"Oreburgh Mine B2F 1R",
		"Veilstone Gym",
		"Pastoria Gym",
		"Rocket Hideout B2F",
		"Rocket Hideout B2F",
		"Rocket Hideout B2F",
		"SunyShore Gym 2",
		"SunyShore Gym 3",

	}

	for trainer, position in pairs(getActiveBattlers()) do
		if not ((getMapName() == "Route 13" and ((position["x"] == 71 and position["y"] == 24) or (position["x"] == 72 and position["y"] == 24)))
		or (getMapName() == "Route 43" and (position["x"] == 24 and position["y"] == 3)))
		then -- manual fix for an info shield that has trainer tags...
			if not (sys.tableHasValue(trainerBlackList, trainer) or sys.tableHasValue(trainerBlackListMap, getMapName())) then
				if isNpcOnCell(position["x"], position["y"]) then
					if talkToNpcOnCell(position["x"], position["y"]) then
						sys.debug("trainer battle finder", "Going to fight Trainer: " .. trainer .. " - x(" .. position["x"] .. "), y(" .. position["y"] .. ")")
						return true
					end
				end
			end
		end
	end
end

function Quest:checkNPCInteractions()
	-- Keep automatic battles from active battle NPCs disabled after the
	-- Rainbow Badge.  Without this guard the normal branch below would enable
	-- NPC interactions again on the next path-action frame.
	if hasItem("Rainbow Badge") then
		if isNpcInteractionsEnabled() then
			sys.debug("NPC INTERACTIONS", "disabled after Rainbow Badge.")
			return disableNpcInteractions()
		end
		return false
	end

	local mapBlacklistForNPCInteractions = {
		"Underground Warehouse",
		"Mahogany Town Rocket Hideout B2F",
		"Seafloor Cavern R7",
		"Mauville City Stop House 4",
	}

	if sys.tableHasValue(mapBlacklistForNPCInteractions, getMapName()) then
		if isNpcInteractionsEnabled() then
			sys.debug("NPC INTERACTIONS", "disabled.")
			return disableNpcInteractions()
		end
	else
		if not isNpcInteractionsEnabled() then
			sys.debug("NPC INTERACTIONS", "enabled.")
			return enableNpcInteractions()
		end
	end
end

--function Quest:checkForDeadPokemonBug()
	--if getTeamSize() > 1 and getUsablePokemonCount() == 0 then
		--if hasItem("Revive") then
			--useItemOnPokemon("Revive", 1)
		--else
			--fatal("All pokemon are dead, likely to a bug and you have no revives.")
		--end
	--end
	--return false
--end

function Quest:path()
	if self.forceRelog then
		self.forceRelog = false
		return relog(15, "Relogging.")
	end
	--if self:checkForDeadPokemonBug() then   return true end
	if self:evolvePokemon() then 			return true end
	if self:leftovers() then 				return true end
	if self:checkNPCInteractions() then		return true end
	if self:checkDiscoverables() then		return true	end
	if self:fightTrainersOnMap() then		return true end



	local mapFunction = self:mapToFunction()
	assert(self[mapFunction] ~= nil, self.name .. " quest has no method for map: " .. getMapName())
	self[mapFunction](self)
end

function Quest:isPokemonBlacklisted(pokemonName)
	if getTeamSize() < 6 then
		if sys.tableHasValue(blacklist, pokemonName) then
			sys.debug("blacklist", "Wild Pokemon " .. pokemonName .. " is in blacklist. Not catching.")
			return true
		else
			return false
		end
	else
		return false -- we don't want to catch bad pokemon in the beginning,
	end				 -- but later in the game for pokedex we do.
end



function Quest:battle()
	-- Once the Rainbow Badge is obtained, do not inspect the active
	-- opponent/party state for wild encounters.  The battle callback can go
	-- straight to the existing Lua run action instead.
	if hasItem("Rainbow Badge") and isWildBattle() then
		sys.debug("fighting team", "Rainbow Badge complete: running from wild battle.")
		return run()
	end

	-- catching
	local isEventPkm = getOpponentForm() ~= 0
	if isWildBattle() 													--if it's a wild battle:
		and (isOpponentShiny() 											--catch special pkm
			or isEventPkm
			or ((isAlreadyCaught() == false and self:isPokemonBlacklisted(getOpponentName()) == false and getOpponentLevel() >= 5))
			or (self.pokemon 											--catch quest related pkm
				and getOpponentName() == self.pokemon
				and self.forceCaught ~= nil
				and self.forceCaught == false))
	then 
		if useItem("Ultra Ball") or useItem("Great Ball") or useItem("Pokeball") then 
			return true 
		end 
	end

	-- 8th badge Mewtwo fight
	if getOpponentName() == "Mewtwo" then
		sys.debug("fighting team", "Special Quest: Don't Switch Pokemon, just attack.")
		return attack() or sendUsablePokemon() or sendAnyPokemon() or useAnyMove()
	-- special rattata Quest
	elseif self.name == "Go to Hoenn" and getOpponentLevel() == 120 then
		sys.debug("fighting team", "Special Quest: Don't Switch Pokemon, just attack.")
		return attack() or sendUsablePokemon() or sendAnyPokemon() or useAnyMove()
	-- deoxys story quest
	elseif self.name == "Beat Deoxys" and getOpponentLevel() == 110 then
		sys.debug("fighting team", "Special Quest: Don't Switch Pokemon, just attack.")
		return attack() or sendUsablePokemon() or sendAnyPokemon() or useAnyMove()
	-- to Sinnoh quest
	elseif self.name == "To Sinnoh Quest" and getOpponentLevel() == 100 then
		sys.debug("fighting team", "Special Quest: Don't Switch Pokemon, just attack.")
		return attack() or sendUsablePokemon() or sendAnyPokemon() or useAnyMove()
	elseif getOpponentName() == "Eevee" and getOpponentLevel() == 3 then
		sys.debug("fighting team", "Special Quest: Don't Switch Pokemon, just attack.")
		return attack() or sendUsablePokemon() or sendAnyPokemon() or useAnyMove()
	end

	--fighting
	local isTeamUsable = getTeamSize() == 1 --if it's our starter, it has to atk
		or getUsablePokemonCount() > 1		--otherwise we atk, as long as we have 2 usable pkm
	if isTeamUsable then
		--level low leveled pkm | switching
		local opponentLevel = getOpponentLevel()
		local myPokemonLvl  = getPokemonLevel(getActivePokemonNumber())
		if opponentLevel >= myPokemonLvl
			and self.canSwitch
		then
			local requestedId, requestedLevel = game.getMaxLevelUsablePokemon()
			if requestedLevel > myPokemonLvl and requestedId ~= nil	then 
				return sendPokemon(requestedId) 
			end
		end

		--actual battle
		if self.blockedMove == true then
			if isWildBattle() then
				if run() or sendAnyPokemon() then
					self.blockedMove = false
					return sys.debug("fighting team", "unstuck from battle")
				else
					sys.error("quest.battle", "stuck in battle")
				end
			else
				if sendUsablePokemon() or sendAnyPokemon() or useAnyMove() then
					self.blockedMove = false
					return sys.debug("fighting team", "unstuck from battle")
				else
					sys.error("quest.battle", "stuck in battle")
				end
			end
		elseif attack() 									--atk
			or self.canSwitch and sendUsablePokemon()	--switch in battle ready pkm if able
			or self.canSwitch and sendAnyPokemon()		--switch in any alive pkm if able
			or useAnyMove()								--use none damaging moves, to progress battle round
			or self.canRun and run()					--run if able
		then 
			return sys.debug("fighting team", "battle action performed")
		else 
			return sys.error("quest.battle", "no battle action for a fighting team") 
		end
	end

	-- running
	if 	self.canRun and run()           			--1. we try to run
		or attack()                                 --2. we try to attack
		or self.canSwitch and sendUsablePokemon()  	--3. we try to switch pokemon that has pp
		or self.canSwitch and sendAnyPokemon()     	--4. we try to switch to any pokemon alive
		or useAnyMove()			                  	--5. we try to use non-damaging attack
		--or BattleManager.useAnyAction()             --6. we try to use garbage items
	then 
		return 
	end 
	sys.debug("running team", "battle action performed")
	sys.error("quest.battle", "no battle action for a running team")

end

function Quest:dialog(message)
	if self.dialogs == nil then
		return false
	end
	for _, dialog in pairs(self.dialogs) do
		if dialog:messageMatch(message) then
			dialog.state = true
			return true
		end
	end
	return false
end

function Quest:battleMessage(message)
	--reset after successful round progression
	if sys.stringContains(message, "Attacks") then
		self.canRun = true
		self.canSwitch = true

	--reset after ended fight | feinting
	elseif sys.stringContains(message, "black out") then
		self.canRun = true
		self.canSwitch = true

		--feinting
		if self.level < 100
			and self:isTrainingOver()
		then
			self.level = math.max(team:getLowestLvl(), self.level) + 1
			self:startTraining()
			log("Increasing " .. self.name .. " quest level to " .. self.level .. ". Training time!")
		end

	--reset after ended fight | win
	elseif sys.stringContains(message, "won the battle") then
		self.canRun = true
		self.canSwitch = true
		if not self:isTrainingOver() then
			sys.debug("quest", "Going to train Pokemon until level " .. self.level .. ".")
		end
		if hasItem("Thunder Badge") and not hasItem("Bicycle")  then
        	sys.debug("quest", "Need $" .. 60000 - getMoney() .. " more money, so we can buy the bike.")
		end
	--restrain running
	elseif sys.stringContains(message, "$CantRun")				--in case resource folder was missing
		or sys.stringContains(message, "You can not run away!")
	then
		self.canRun = false

	--restrain switching
	elseif sys.stringContains(message, "$NoSwitch")
		or sys.stringContains(message, "You can not switch this Pokemon!")
	then
		self.canSwitch = false

	--blocked move
	elseif sys.stringContains(message, "This move is disabled")
		or sys.stringContains(message, "Completely Ineffective")
		or sys.stringContains(message, "locked due to Encore")
	then
		self.blockedMove = true

	--force caught the specified pokemon on quest 1time
	elseif self.pokemon ~= nil
		and self.forceCaught ~= nil
		and sys.stringContains(message, "caught")
		and sys.stringContains(message, self.pokemon)
	then
		log("Selected Pokemon: " .. self.pokemon .. " is Caught")
		self.forceCaught = true
	end
end

function Quest:systemMessage(message)
	if sys.stringContains(message, "No XP gained. Try battling a higher level.") then	
		self.forceRelog = true
	end
	return false
end

local hmMoves = {
	"cut",
	"surf",
	"flash"
}

function Quest:chooseForgetMove(moveName, pokemonIndex) -- Calc the WrostAbility ((Power x PP)*(Accuract/100))
	local ForgetMoveName
	local ForgetMoveTP = 9999
	for moveId=1, 4, 1 do
		local MoveName = getPokemonMoveName(pokemonIndex, moveId)
		if MoveName == nil 
			or MoveName == "Cut" 
			or MoveName == "Dig" 
			or MoveName == "Headbutt" 
			or MoveName == "Surf" 
			or MoveName == "Rock Smash" 
			or MoveName == "Dive" 
			or (MoveName == "Sleep Powder" and hasItem("Earth Badge") and not hasItem("Plain Badge"))
			
			-- good moves below
			or MoveName == "Air Slash"
			or MoveName == "Crunch"
			or MoveName == "Earthquake"
			or MoveName == "Extrasensory"
			or MoveName == "Dragon Breath"
			or MoveName == "Flamethrower"
			or MoveName == "Flash Cannon"
			or MoveName == "Flare Blitz"
			or MoveName == "Ice Beam"
			or MoveName == "Ice Fang"
			or MoveName == "Leaf Blade"
			or MoveName == "Play Rough"
			or MoveName == "Rapid Spin"
			or MoveName == "Shadow Claw"
			or MoveName == "Thunder Fang"
			or MoveName == "Water Pulse"
			or MoveName == "Thrash"
			or MoveName == "Stomping Tantrum"
			or MoveName == "Outrage"
			or MoveName == "Waterfall"
			or MoveName == "Karate Chop"
			or MoveName == "Double Shock"
			or MoveName == "Stone Edge"
			or MoveName == "Dragon Dance"

			-- good moves end
		then
			sys.debug("Learing Move", "Don't forget the move \"" .. MoveName .. "\".")
		else
			local CalcMoveTP = math.modf((getPokemonMaxPowerPoints(pokemonIndex,moveId) * getPokemonMovePower(pokemonIndex,moveId))*(math.abs(getPokemonMoveAccuracy(pokemonIndex,moveId)) / 100))
			if CalcMoveTP < ForgetMoveTP then
				ForgetMoveTP = CalcMoveTP
				ForgetMoveName = MoveName
			end
		end
	end
	if ForgetMoveName ~= nil then
		sys.log("[Learning Move: " .. moveName .. "  -->  Forget Move: " .. ForgetMoveName .. "]")
	end
	return ForgetMoveName
end

function Quest:learningMove(moveName, pokemonIndex)
	if self:chooseForgetMove(moveName, pokemonIndex) ~= nil then
		return forgetMove(self:chooseForgetMove(moveName, pokemonIndex))
	end
end

return Quest
