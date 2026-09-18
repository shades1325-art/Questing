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
	o.pokemonId = 1
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
function GoToHoennQuest:getWeakestPokemonInTeam()
	local weakestPokemon = 1 -- assume first in team is weakest
	for i = 1, getTeamSize() do
		if luaPokemonData[getPokemonName(i)]["TotalStats"] < luaPokemonData[getPokemonName(weakestPokemon)]["TotalStats"] then
			weakestPokemon = i
		end
	end
	return weakestPokemon
end

-- END special functions 

function GoToHoennQuest:IndigoPlateauCenterJohto()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Indigo Plateau Center Johto" then
		sys.debug("quest", "Going to heal Pokemon.")
		self:pokecenter("Indigo Plateau Center")
	else
		sys.debug("quest", "Going to catch a Rattata and level it to Lv80.")
		return moveToCell(10, 28)
	end
end

function GoToHoennQuest:IndigoPlateau()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Indigo Plateau Center Johto" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(10, 12)
	else
		sys.debug("quest", "Going to Hoenn!")
		return talkToNpcOnCell(21, 7)
	end
end

function GoToHoennQuest:VictoryRoadKanto3F()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(46, 13)
	end
end

return GoToHoennQuest