
local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local pc = require "Libs/pclib"
local luaPokemonData = require "Data/luaPokemonData"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'Thunder Badge Quest'
local description = 'From Route 5 to Route 6'
local level       = 1


local dialogs = {
	psychicWadePart2 = Dialog:new({
		"You see, that was Lance, the Pokemon League Champion.",
		"hurry up and tell him that"
	}),
	surgeVision = Dialog:new({
		"Take the cruise, become stronger, and after that, come at me and let's have a zapping match!"
	});
	switchWrong = Dialog:new({
		"wrong switch",
		"have been reset"
	}),
	switchTrigger = Dialog:new({
		"have triggered the first switch"
	})
}

local ThunderBadgeQuest = Quest:new()

function ThunderBadgeQuest:new()
	o = Quest.new(ThunderBadgeQuest, name, description, level, dialogs)
	o.pokemonId = 1
	o.checkedForBestPokemon = false
	o.puzzle = {}
	o.firstSwitchFound     = false
	o.firstSwitchActivated = false
	o.firstSwitchX = 0
	o.firstSwitchY = 0
	o.currentSwitchX = SWITCHES_START_X
	o.currentSwitchY = SWITCHES_START_Y
	return o
end

function ThunderBadgeQuest:isDoable()
	if not hasItem("Rainbow Badge") and self:hasMap() then
		return true
	end
	return false
end

function ThunderBadgeQuest:isDone()
	if getMapName() == "Vermilion City 2" or getMapName() == "SSAnne 1F" or getMapName() == "Route 11" then
		return true
	else
		return false
	end
end

function ThunderBadgeQuest:Route5()
	sys.debug("quest", "Going to Vermilion City.")
	return moveToCell(27,29)
end

function ThunderBadgeQuest:UndergroundHouse1()
	sys.debug("quest", "Going to Vermilion City.")
	return moveToCell(9,3)
end

function ThunderBadgeQuest:Underground2()
	sys.debug("quest", "Going to Vermilion City.")
	return moveToCell(3,43)
end

function ThunderBadgeQuest:UndergroundHouse2()
	sys.debug("quest", "Going to Vermilion City.")
	return moveToCell(5,10)
end

function ThunderBadgeQuest:Route6()
	if not isNpcOnCell(24, 54) then -- Psychic Wade done
		self.dialogs.psychicWadePart2.state = true
		self.dialogs.surgeVision.state = true
	end

	if not dialogs.psychicWadePart2.state then
		sys.debug("quest", "Going to talk to Psychic Wade.")
		return talkToNpcOnCell(24, 54) -- Psychic Wade

	elseif not self.dialogs.surgeVision.state then
		sys.debug("quest", "Going to talk to Surge in Vermilion City.")
		return moveToCell(23,61)

	elseif self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(23,61)

	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to train Pokemon until they are all level " .. self.level .. ".")

		if not picked_route then
			return moveToCell(24, 61)
		elseif picked_route == 1 then
			return moveToCell(0, 52)
		elseif picked_route == 2 then
			return moveToRectangle(25, 48, 27, 53)
		end

	else
 		return moveToCell(23,61)
 	end
end

function ThunderBadgeQuest:VermilionCityGraveyard()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(60, 32)

	elseif not self:isTrainingOver() then
		return moveToRectangle(45, 36, 52, 37)

	else
		return moveToCell(60, 32)
	end
end

function ThunderBadgeQuest:PokecenterVermilion()
	if not (game.inRectangle(0, 19, 25, 22) or game.inRectangle(4, 16, 25, 18) or game.inRectangle(4, 11, 18, 15)) then
		return moveToCell(21, 11)
	else
		self:pokecenter("Vermilion City")
	end
end

function ThunderBadgeQuest:PokecenterCerulean()
	self:pokecenter("Cerulean City")
end

function ThunderBadgeQuest:VermilionPokemart()
	self:pokemart("Vermilion City")
end

function ThunderBadgeQuest:CeruleanCity()
	sys.debug("quest", "Going back to Route 5 after blackout.")
	return moveToCell(16, 50)
end


function ThunderBadgeQuest:VermilionCity()
	if isNpcOnCell(38, 63) then
		self.dialogs.surgeVision.state = false -- security check, sometimes a NPC takes time to appear
	else
		self.dialogs.surgeVision.state = true
	end

	if not hasItem("Old Rod") then
		sys.debug("quest", "Going to get Old Rod.")
		return moveToCell(30,37)

	elseif self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Vermilion" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(27,21)

	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(47, 37)

	elseif not dialogs.psychicWadePart2.state then
		sys.debug("quest", "Going to talk to Psychic Wade.")
		return moveToCell(43,0)

	elseif not dialogs.surgeVision.state then
		sys.debug("quest", "Going to talk to Surge.")
		return talkToNpcOnCell(38, 63) -- Surge

	elseif not self:isTrainingOver() then
		picked_route = math.random(1,2) -- we pick it here, so the bot only randomizes it once

		sys.debug("quest", "Going to train Pokemon until they are all level " .. self.level .. ".")
		return moveToCell(43, 0)-- Go to Route 6 and level up Pokemon.

	elseif not hasItem("HM01 - Cut") then -- Need do SSanne Quest
		sys.debug("quest", "Going to enter SS Anne.")
		return moveToCell(40, 67) -- Enter on SSAnne

	elseif not hasItem("Thunder Badge") then
		if not game.hasPokemonWithMove("Cut") then
			if self.pokemonId < getTeamSize() then
				useItemOnPokemon("HM01 - Cut", self.pokemonId)
				log("Pokemon: " .. self.pokemonId .. " Try Learning: HM01 - Cut")
				self.pokemonId = self.pokemonId + 1
			else
				fatal("No pokemon in this team can learn Cut")
			end
		else
			sys.debug("quest", "Going to get 3rd badge.")
			return moveToCell(26, 51)
		end

	else
		sys.debug("quest", "Going to Route 11")
		return moveToCell(82, 40)
	end
end

function ThunderBadgeQuest:FishermanHouseVermilion()
	if not hasItem("Old Rod") then
		sys.debug("quest", "Going to get Old Rod.")
		return talkToNpcOnCell(0, 6)
	else
		sys.debug("quest", "Going back to Vermilion City.")
		return moveToCell(5, 11)
	end
end

function ThunderBadgeQuest:puzzleBinPosition(binId)
	local xCount = 5
	local yCount = 3
	local xPosition = 2
	local yPosition = 17
	local spaceBetweenBins = 2
	
	local line   = math.floor(binId / xCount + 1)
	local column = math.floor((binId - 1) % xCount + 1)
	
	local x = xPosition + (column - 1) * spaceBetweenBins
	local y = yPosition - (line   - 1) * spaceBetweenBins
	
	return x, y
end

function ThunderBadgeQuest:solvePuzzle()
	if not self.puzzle.bin then
		self.puzzle.bin = 1
	end
	if self.dialogs.switchWrong.state then
		self.dialogs.switchWrong.state = false
		self.dialogs.switchTrigger.state = false
		self.puzzle.bin = self.puzzle.bin + 1
	elseif self.dialogs.switchTrigger.state and not self.puzzle.firstBin then
		self.puzzle.firstBin = self.puzzle.bin
		self.puzzle.bin = 1 -- we know the first bin, let start again
	end
	
	if not self.dialogs.switchTrigger.state and self.puzzle.firstBin then
		local x, y = self:puzzleBinPosition(self.puzzle.firstBin)
		return talkToNpcOnCell(x, y)
	else
		local x, y = self:puzzleBinPosition(self.puzzle.bin)
		return talkToNpcOnCell(x, y)
	end
end

function ThunderBadgeQuest:VermilionGym()
	if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Vermilion" then
		sys.debug("quest", "Going to heal Pokemon.")
 		return moveToCell(6,21)
	elseif not self:isTrainingOver() and not hasItem("Thunder Badge") then
		sys.debug("quest", "Going to train Pokemon until they are all level " .. self.level .. ".")
		return moveToCell(6,21)-- Go to Route 6 and Leveling
	else
		if hasItem("Thunder Badge") then
			sys.debug("quest", "Going to go to Vermilion City.")
			return moveToCell(6,21)
		else
			if not isNpcOnCell(6, 10) then
				return talkToNpcOnCell(6,4)
			else
				return self:solvePuzzle()
			end
		end
	end
end

return ThunderBadgeQuest
