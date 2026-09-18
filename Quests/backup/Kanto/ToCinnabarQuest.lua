-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex

local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local pc            = require "Libs/pclib"
local team          = require "Libs/teamlib"
local SurfTarget    = require "Data/surfTargets"

local name		  = 'ToCinnabar'
local description = 'Route 8 To Cinnabar Island'

local ToCinnabarQuest = Quest:new()

function ToCinnabarQuest:new()
	local o = Quest.new(ToCinnabarQuest, name, description, level)
	o.pokemonId = 1
	return o
end

function ToCinnabarQuest:isDoable()
	if self:hasMap() and hasItem("Marsh Badge") and not hasItem("Volcano Badge") then
		return true
	end
	return false
end

function ToCinnabarQuest:isDone()
	if getMapName() == "Cinnabar Island" or getMapName() == "Pokecenter Saffron" then --Fix Blackout
		return true
	end
	return false
end

function ToCinnabarQuest:isGoodRodObtainable()
	return BUY_RODS and hasItem("Old Rod") and not hasItem("Good Rod") and getMoney() >= 15000
end



function ToCinnabarQuest:LavenderTown()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Lavender" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(9, 5)
	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(3, 5)
	else
		sys.debug("quest", "Going to Cinnabar Island.")
		return moveToCell(14, 25)
	end
end

function ToCinnabarQuest:PokecenterLavender()
	self:pokecenter("Lavender Town")
end

function ToCinnabarQuest:LavenderPokemart()
	self:pokemart()
end

function ToCinnabarQuest:Route12()
	sys.debug("quest", "Going to Cinnabar Island.")
	return moveToCell(24, 92)
end

function ToCinnabarQuest:Route13()
	sys.debug("quest", "Going to Cinnabar Island.")
	return moveToCell(18, 34)
end

function ToCinnabarQuest:Route14()
	sys.debug("quest", "Going to Cinnabar Island.")
	return moveToCell(0, 53)
end

function ToCinnabarQuest:Route15()
	sys.debug("quest", "Going to Cinnabar Island.")
	return moveToCell(6, 16)
end

function ToCinnabarQuest:Route15StopHouse()
	sys.debug("quest", "Going to Cinnabar Island.")
	return moveToCell(0, 6)
end

function ToCinnabarQuest:FuchsiaCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Fuchsia" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(30, 39)

	elseif self:isGoodRodObtainable() then
		sys.debug("quest", "Going to get Good Rod.")
		return moveToCell(45, 36)

	else
		sys.debug("quest", "Going to Cinnabar Island.")
		return moveToCell(23, 44)
	end
end

function ToCinnabarQuest:PokecenterFuchsia()
		self:pokecenter("Fuchsia City")
end

function ToCinnabarQuest:FuchsiaHouse1()
	if self:isGoodRodObtainable() then
		sys.debug("quest", "Going to get Good Rod.")
		return talkToNpcOnCell(3, 6)
	else
		sys.debug("quest", "Going to Cinnabar Island.")
		return moveToCell(5, 11)
	end
end

function ToCinnabarQuest:FuchsiaCityStopHouse()	
	sys.debug("quest", "Going to Cinnabar Island.")
	return moveToCell(6, 20)
end

function ToCinnabarQuest:Route19()
	if not game.hasPokemonWithMove("Surf") then
		if self.pokemonId < getTeamSize() then
			useItemOnPokemon("HM03 - Surf", self.pokemonId)
			log("Pokemon: " .. self.pokemonId .. " Try Learning: HM03 - Surf")
			self.pokemonId = self.pokemonId + 1
		else
			fatal("No pokemon in this team can learn Surf")
		end
	else
		sys.debug("quest", "Going to Cinnabar Island.")
		return moveToCell(0, 44)
	end
end

function ToCinnabarQuest:Route20()
	if game.inRectangle(52, 20, 120, 39) then
		sys.debug("quest", "Going to Cinnabar Island.")
		return moveToCell(60, 32)
	elseif game.inRectangle(0, 40, 80, 45) or game.inRectangle(0, 17, 50, 40) then
		sys.debug("quest", "Going to Cinnabar Island.")
		return moveToCell(0, 30)
	end
end

function ToCinnabarQuest:Seafoam1F()
	if game.inRectangle(5, 5, 21, 17) then
		sys.debug("quest", "Going to Cinnabar Island.")
		return moveToCell(20, 8)
	elseif game.inRectangle(63, 5, 79, 16) then
		sys.debug("quest", "Going to Cinnabar Island.")
		return moveToCell(71, 15)
	end
end

function ToCinnabarQuest:SeafoamB1F()
	sys.debug("quest", "Going to Cinnabar Island.")
	return moveToCell(85, 22)
end

return ToCinnabarQuest