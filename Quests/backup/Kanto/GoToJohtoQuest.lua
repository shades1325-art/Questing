-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Start Johto Region'
local description = 'Route 26 to Bark Town'

local GoToJohtoQuest = Quest:new()

function GoToJohtoQuest:new()
	local o = Quest.new(GoToJohtoQuest, name, description, level)
	o.pokemonId = 1
	return o
end

function GoToJohtoQuest:isDoable()
	if self:hasMap() and not hasItem("Zephyr Badge") then
		return true
	end
	return false
end

function GoToJohtoQuest:isDone()
	if getMapName() == "New Bark Town" or getMapName() == "Indigo Plateau Center" or getMapName() == "Pokecenter Viridian" then
		return true
	end
	return false
end

function GoToJohtoQuest:Route26()
	sys.debug("quest", "Going to Johto.")
	return moveToCell(0, 105)
end

function GoToJohtoQuest:Route27()
	if not game.hasPokemonWithMove("Surf") then
		if self.pokemonId < getTeamSize() then
			useItemOnPokemon("HM03 - Surf", self.pokemonId)
			log("Pokemon: " .. self.pokemonId .. " Try Learning: HM03 - Surf")
			self.pokemonId = self.pokemonId + 1
		else
			fatal("No pokemon in this team can learn Surf")
		end
	else
		if game.inRectangle(63, 8, 217, 24) or game.inRectangle(108, 25, 217, 39) then
			sys.debug("quest", "Going to Johto.")
			return moveToCell(74, 14)
		else
			sys.debug("quest", "Going to Johto.")
			return moveToCell(0, 20)
		end
	end
end

function GoToJohtoQuest:TohjoFalls()
	sys.debug("quest", "Going to Johto.")
	return moveToCell(23,32)
end

return GoToJohtoQuest