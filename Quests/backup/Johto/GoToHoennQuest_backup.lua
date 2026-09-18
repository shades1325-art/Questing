-- Copyright � 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Atem

local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"

local luaPokemonData = require "Data/luaPokemonData"

local name		  = 'Go to Hoenn'
local description = 'Catch a Rattata, level it to 80, fight Youngster Joey, go to Hoenn'
local level = 80

local GoToHoennQuest = Quest:new()

function GoToHoennQuest:new()
	local o = Quest.new(GoToHoennQuest, name, description, level, dialogs)
	o.pokemon = "Rattata"
	o.forceCaught = false

	return o
end

function GoToHoennQuest:isDoable()
	if self:hasMap() and not hasItem("Stone Badge") and hasItem("Rising Badge") then
		return true
	end
	return false
end

function GoToHoennQuest:isDone()
	if getMapName() == "Littleroot Town Truck" then
		return true
	else
		return false
	end
end

-- START special functions 

function GoToHoennQuest:hasLevel80Rattata()
	if game.hasPokemonWithName("Rattata") and getPokemonLevel(game.hasPokemonWithName("Rattata")) >= 80 then
		return true
	else
		return false
	end
end

function GoToHoennQuest:getWeakestPokemonInTeam()
	local weakestPokemon = 1 -- assume first in team is weakest

	for i = 1, getTeamSize() do
		if luaPokemonData[getPokemonName(i)]["TotalStats"] < luaPokemonData[getPokemonName(weakestPokemon)]["TotalStats"] then
			weakestPokemon = i
		end
	end

	return weakestPokemon
end

function GoToHoennQuest:canUseNurse()
	return getMoney() > 1500
end

-- END special functions 

function GoToHoennQuest:IndigoPlateauCenterJohto()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Indigo Plateau Center Johto" then
		sys.debug("quest", "Going to heal Pokemon.")
		self:pokecenter("Indigo Plateau Center")
	elseif self:hasLevel80Rattata() then
		sys.debug("quest", "Going to fight Youngster Joey with our Level 80 Rattata.")
		return moveToCell(10, 28)
	else
		sys.debug("quest", "Going to catch a Rattata and level it to Lv80.")
		return moveToCell(10, 28)
	end
end

function GoToHoennQuest:IndigoPlateau()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Indigo Plateau Center Johto" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(10, 12)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Team too weak, training until Level " .. self.level .. ".")
		return moveToCell(21, 31)
	elseif self:hasLevel80Rattata() then
		if isNpcOnCell(21, 10) then
			pushDialogAnswer(game.hasPokemonWithName("Rattata"))
			sys.debug("quest", "Going to fight Youngster Joey with our Level 80 Rattata.")
			return talkToNpcOnCell(21, 10)
		else
			sys.debug("quest", "Going to Hoenn!")
			return talkToNpcOnCell(21, 7)
		end
	else
		sys.debug("quest", "Going to catch a Rattata and level it to Lv80.")
		return moveToCell(21, 31)
	end
end

function GoToHoennQuest:VictoryRoadKanto3F()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(46, 13)
	if not self:isTrainingOver() then
		sys.debug("quest", "Team too weak, training until Level " .. self.level .. ".")
		return moveToRectangle(40, 14, 48, 26)
	if self:hasLevel80Rattata() then
		sys.debug("quest", "Going to fight Youngster Joey with our Level 80 Rattata.")
		return moveToCell(46, 13)
	else
		sys.debug("quest", "Going to catch a Rattata and level it to Lv80.")
		return moveToCell(29, 17)
	end
end

function GoToHoennQuest:VictoryRoadKanto2F()
	if self:hasLevel80Rattata() then
		sys.debug("quest", "Going to fight Youngster Joey with our Level 80 Rattata.")
		return moveToCell(14, 9)
	else
		sys.debug("quest", "Going to catch a Rattata and level it to Lv80.")
		return moveToCell(14, 20)
	end
end

function GoToHoennQuest:VictoryRoadKanto1F()
	if self:hasLevel80Rattata() then
		sys.debug("quest", "Going to fight Youngster Joey with our Level 80 Rattata.")
		return moveToCell(17, 11)
	else
		sys.debug("quest", "Going to catch a Rattata and level it to Lv80.")
		return moveToCell(43, 52)
	end
end

function GoToHoennQuest:PokemonLeagueReceptionGate()
	if self:hasLevel80Rattata() then
		sys.debug("quest", "Going to fight Youngster Joey with our Level 80 Rattata.")
		return moveToCell(22, 2)
	else
		sys.debug("quest", "Going to catch a Rattata and level it to Lv80.")
		return moveToCell(43, 10)
	end
end

function GoToHoennQuest:Route22()
	if self:hasLevel80Rattata() then
		sys.debug("quest", "Going to fight Youngster Joey with our Level 80 Rattata.")
		return moveToCell(9, 8)
	else
		sys.debug("quest", "Going to catch a Rattata and level it to Lv80.")
		return moveToCell(60, 12)
	end
end

function GoToHoennQuest:ViridianCity()
	if self:hasLevel80Rattata() then
		sys.debug("quest", "Going to fight Youngster Joey with our Level 80 Rattata.")
		return moveToCell(0, 47)
	else
		sys.debug("quest", "Going to catch a Rattata and level it to Lv80.")
		return moveToCell(49, 61)
	end
end

function GoToHoennQuest:Route1StopHouse()
	if self:hasLevel80Rattata() then
		sys.debug("quest", "Going to fight Youngster Joey with our Level 80 Rattata.")
		return moveToCell(4, 2)
	else
		sys.debug("quest", "Going to catch a Rattata and level it to Lv80.")
		return moveToCell(4, 12)
	end
end

function GoToHoennQuest:Route1()
	if self:hasLevel80Rattata() then
		sys.debug("quest", "Going to fight Youngster Joey with our Level 80 Rattata.")
		return moveToCell(14, 4)
	else
		sys.debug("quest", "Going to catch a Rattata and level it to Lv80.")
		return moveToCell(17, 50)
	end
end

function GoToHoennQuest:PalletTown()
	if self:hasLevel80Rattata() then
		sys.debug("quest", "Going to fight Youngster Joey with our Level 80 Rattata.")
		return moveToCell(16, 0)
	else
		sys.debug("quest", "Going to catch a Rattata and level it to Lv80.")
		return moveToCell(14, 30)
	end
end

function GoToHoennQuest:Route21()
	if self:hasLevel80Rattata() then
		sys.debug("quest", "Going to fight Youngster Joey with our Level 80 Rattata.")
		return moveToCell(14, 0)
	else
		sys.debug("quest", "Going to catch a Rattata and level it to Lv80.")
		return moveToCell(8, 95)
	end
end

function GoToHoennQuest:CinnabarIsland()
	if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Cinnabar" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(19, 26)

	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(25, 24)

	elseif self:hasLevel80Rattata() then
		sys.debug("quest", "Going to fight Youngster Joey with our Level 80 Rattata.")
		return moveToCell(8, 0)

	elseif not self.forceCaught then
		sys.debug("quest", "Going to catch a Rattata and level it to Lv80.")
		return moveToCell(18, 14)

	elseif not game.hasPokemonWithName("Rattata") then
		sys.debug("quest", "Going to take Rattata from Box.")
		return moveToCell(19, 26)

	else
		sys.debug("quest", "Going to level Rattata to Level 80.")
		return moveToCell(45, 28)
	end
end

function GoToHoennQuest:PokecenterCinnabar()
	if self.forceCaught and not game.hasPokemonWithName("Rattata") then
		if isPCOpen() then
			if isCurrentPCBoxRefreshed() then
				if getCurrentPCBoxSize() > 0 then
					log("Current Box: " .. getCurrentPCBoxId())
					log("Box Size: " .. getCurrentPCBoxSize())
					for i = 1, getCurrentPCBoxSize() do
						if getPokemonLevelFromPC(getCurrentPCBoxId(), i) > 40 then
							if getPokemonNameFromPC(getCurrentPCBoxId(), i) == "Rattata" then
								log(string.format("Swapping Team Pokemon %s out with Rattata Lv %i from Boxes.", getPokemonName(self:getWeakestPokemonInTeam()), getPokemonLevelFromPC(getCurrentPCBoxId(), i)))
								return swapPokemonFromPC(getCurrentPCBoxId(), i, self:getWeakestPokemonInTeam())
							end
						end
					end
					return openPCBox(getCurrentPCBoxId() + 1)
				else
					if hasPokemonInTeam("Rattata") then
						sys.debug("quest", "Got Rattata with Level " .. getPokemonLevel(game.hasPokemonWithName("Rattata")) .. ".")
					else
						self.forceCaught = false
					end
				end
			end
		else
			return usePC()
		end
	else
		self:pokecenter("Pokecenter Cinnabar")
	end
end

function GoToHoennQuest:CinnabarPokemart()
	self:pokemart()
end

function GoToHoennQuest:Cinnabarmansion1()
	if not self.forceCaught then
		return moveToRectangle(8, 26, 12, 41)
	else
		return moveToCell(10, 42)
	end
end

function GoToHoennQuest:Route20()
	if self:hasLevel80Rattata() then
		sys.debug("quest", "Going to fight Youngster Joey with our Level 80 Rattata.")
		return moveToCell(0, 35)
	else
		sys.debug("quest", "Going to level Rattata to Level 80.")
		return moveToCell(73, 40)
	end
end

function GoToHoennQuest:Seafoam1F()
	if self:hasLevel80Rattata() then
		sys.debug("quest", "Going to fight Youngster Joey with our Level 80 Rattata.")
		return moveToCell(71, 15)
	else
		sys.debug("quest", "Going to level Rattata to Level 80.")
		return moveToCell(64, 8)
	end
end

function GoToHoennQuest:SeafoamB1F()
	if self:hasLevel80Rattata() then
		sys.debug("quest", "Going to fight Youngster Joey with our Level 80 Rattata.")
		return moveToCell(85, 22)
	else
		sys.debug("quest", "Going to level Rattata to Level 80.")
		return moveToCell(64, 25)
	end
end

function GoToHoennQuest:SeafoamB2F()
	if self:hasLevel80Rattata() then
		sys.debug("quest", "Going to fight Youngster Joey with our Level 80 Rattata.")
		return moveToCell(51, 27)
	else
		sys.debug("quest", "Going to level Rattata to Level 80.")
		return moveToCell(63, 19)
	end
end

function GoToHoennQuest:SeafoamB3F()
	if self:hasLevel80Rattata() then
		sys.debug("quest", "Going to fight Youngster Joey with our Level 80 Rattata.")
		return moveToCell(64, 16)
	else
		sys.debug("quest", "Going to level Rattata to Level 80.")
		return moveToCell(57, 26)
	end
end

function GoToHoennQuest:SeafoamB4F()
	if not self:hasLevel80Rattata() then
		if self:needPokecenter() then
			if self:canUseNurse() then -- if have 1500 money
				sys.debug("quest", "Going to heal Pokemon.")
				return talkToNpcOnCell(59, 13)
			end
		else
			sys.debug("quest", "Going to level Rattata to Level 80.")
			return moveToNormalGround() --moveToRectangle(50,10,62,32)
		end
	else
		sys.debug("quest", "Going to fight Youngster Joey with our Level 80 Rattata.")
		return moveToCell(53, 28) -- Link: Seafoam B3F
	end
end

return GoToHoennQuest