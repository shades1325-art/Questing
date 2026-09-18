-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @WiWi__33[NetPapa]


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local team	 = require "Libs/teamlib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Meet Kyogre'
local description = 'Clear the underwater hideout'
local dive = nil 

local meetKyogre = Quest:new()

function meetKyogre:new()
	local o = Quest.new(meetKyogre, name, description, level, dialogs)
	o.pokemonId = 1
	return o
end

function meetKyogre:isDoable()
	if self:hasMap() and hasItem("Blue Orb") and hasItem("Mind Badge")then
		return true
	end
	return false
end

function meetKyogre:isDone()
	if not hasItem("Blue Orb") and getMapName() == "Route 128" then
		return true
	else
		return false
	end
end

function meetKyogre:MossdeepGym()
	if game.inRectangle(47, 6, 56, 12) then
		sys.debug("quest", "Going to meet Kyogre.")
		return moveToCell(47, 6)
	elseif game.inRectangle(2, 27, 17, 36) then
		sys.debug("quest", "Going to meet Kyogre.")
		return moveToCell(12, 27)
	elseif game.inRectangle(2, 3, 19, 16) then
		sys.debug("quest", "Going to meet Kyogre.")
		return moveToCell(15, 3)
	elseif game.inRectangle(45, 46, 59, 68) then
		sys.debug("quest", "Going to meet Kyogre.")
		return moveToCell(51, 48)
	elseif game.inRectangle(2, 52, 20, 68) then
		sys.debug("quest", "Going to meet Kyogre.")
		return moveToCell(18, 68)
	end
end

function meetKyogre:MossdeepCity()
	if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Mossdeep City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(36, 21)

	elseif isNpcOnCell(83, 22) then 
		sys.debug("quest", "Going to talk to NPC.")
		return talkToNpcOnCell(83, 22)


	elseif not hasItem("HM06 - Dive") then 
		sys.debug("quest", "Going to Mossdeep City Space Center to get HM06 - Dive.")
		return moveToCell(83, 21)

	elseif not game.hasPokemonWithMove("Dive") then
		if self.pokemonId < getTeamSize() then
			useItemOnPokemon("HM06 - Dive", self.pokemonId)
			log("Pokemon: " .. self.pokemonId .. " Try Learning: HM06 - Dive")
			self.pokemonId = self.pokemonId + 1
		else
			fatal("No pokemon in this team can learn Dive")
		end
	
	else
		sys.debug("quest", "Going to meet Kyogre.")
		return moveToCell(31, 55)
	
	end
end

function meetKyogre:PokecenterMossdeepCity()
	return self:pokecenter("Mossdeep City")
end

function meetKyogre:MossdeepCitySpaceCenter1F()
	if not hasItem("HM06 - Dive") then
		sys.debug("quest", "Going to talk to Steven to get HM06 - Dive.")
		return talkToNpcOnCell(12, 6)
	else
		sys.debug("quest", "Going back to Mossdeep City.")
		return moveToCell(10, 12)
	end
end

function meetKyogre:Route127()
	local pokemonWithDive = team.getFirstPkmWithMove("Dive")
	
	pushDialogAnswer(1)
	pushDialogAnswer(pokemonWithDive)
	
	sys.debug("quest", "Going to dive.")
	return moveToCell(37, 25)
end

function meetKyogre:Route127Underwater()
	sys.debug("quest", "Going to meet Kyogre.")
	return moveToCell(36, 70)
end

function meetKyogre:Route128Underwater()
	sys.debug("quest", "Going to meet Kyogre.")
	return moveToCell(26, 57)
end

function meetKyogre:SecretUnderwaterCavern()
	local pokemonWithDive = team.getFirstPkmWithMove("Dive")
	
	pushDialogAnswer(1)
	pushDialogAnswer(pokemonWithDive)
	
	sys.debug("quest", "Going to dive up again.")
	return moveToCell(8, 6)
end

function meetKyogre:SeafloorCavernEntrance()
	sys.debug("quest", "Going to meet Kyogre.")
	return moveToCell(9, 2)
end

function meetKyogre:SeafloorCavernR1()
	sys.debug("quest", "Going to meet Kyogre.")
	return moveToCell(14, 15)
end

function meetKyogre:SeafloorCavernR2()
	sys.debug("quest", "Going to meet Kyogre.")
	return moveToCell(15, 13)
end

function meetKyogre:SeafloorCavernR3()
	sys.debug("quest", "Going to meet Kyogre.")
	return moveToCell(13, 2)
end

function meetKyogre:SeafloorCavernR4()
	sys.debug("quest", "Going to meet Kyogre.")
	return moveToCell(16, 2)
end

function meetKyogre:SeafloorCavernR6() -- fucking hell
	if game.inRectangle(3, 18, 6, 20) then
		return moveToCell(4, 17)
	elseif game.inCell(4, 17) then
		return moveToCell(7, 18)
	elseif game.inCell(7, 18) then
		return moveToCell(10, 18)
	elseif game.inCell(13, 18) then
		return moveToCell(11, 18)
	elseif game.inCell(11, 18) then
		return moveToCell(11, 15)
	elseif game.inCell(11, 15) then
		return moveToCell(6, 15)
	elseif game.inCell(6, 15) then
		return moveToCell(6, 5)
	elseif game.inRectangle(2, 3, 12, 5) then
		return moveToCell(4, 2)
	end
end

function meetKyogre:SeafloorCavernR7()
	sys.debug("quest", "Going to meet Kyogre.")
	return moveToCell(12, 2)
end

function meetKyogre:SeafloorCavernR8()
	sys.debug("quest", "Going to meet Kyogre.")
	return moveToCell(9, 2)
end

function meetKyogre:SeafloorCavernR9()
	sys.debug("quest", "Going to fight Aqua Admin Matt.")
	return talkToNpcOnCell(16, 37)
end

return meetKyogre