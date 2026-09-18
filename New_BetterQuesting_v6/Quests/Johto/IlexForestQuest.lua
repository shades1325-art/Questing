-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Ilex Forest'
local description = ' Farfetch Quest'

local dialogs = {
	farfetchQuestAccept = Dialog:new({ 
		"have you found it yet"
	})
}

local IlexForestQuest = Quest:new()

function IlexForestQuest:new()
	local o = Quest.new(IlexForestQuest, name, description, level, dialogs)
	o.pokemon = "Butterfree"
	o.pokemonId = 6
	o.forceCaught = false
	return o
end

function IlexForestQuest:isDoable()
	if self:hasMap() and not hasItem("Plain Badge") then
		return true
	end
	return false
end

function IlexForestQuest:isDone()
	if getMapName() == "Goldenrod City" or getMapName() == "Pokecenter Azalea" or getMapName() == "Pokecenter Goldenrod"  or getMapName() == "Azalea Town" then
		return true
	end
	return false
end

function IlexForestQuest:IlexForestStopHouse()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(10, 6)
	else
		sys.debug("quest", "Going to Ilex Forest.")
		return moveToCell(0, 6)
	end
end

function IlexForestQuest:IlexForest()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(10, 74)

	elseif isNpcOnCell(12, 58) then
		if not dialogs.farfetchQuestAccept.state then
			sys.debug("quest", "Going to talk to NPC.")
			return talkToNpcOnCell(12, 58)

		else
			if isNpcOnCell(47, 42) then
				sys.debug("quest", "Going to talk to Farfetch'd.")
				return talkToNpcOnCell(47, 42)

			else
				sys.debug("quest", "Going to talk to NPC.")
				return talkToNpcOnCell(12, 58)

			end
		end
	--elseif not self.forceCaught then
		--sys.debug("quest", "Going to catch " .. self.pokemon)
		--return moveToRectangle(16, 43, 48, 63)

	else
		if not game.hasPokemonWithMove("Cut") then
			if self.pokemonId < getTeamSize() then
				useItemOnPokemon("HM01 - Cut", self.pokemonId)
				log("Pokemon: " .. self.pokemonId .. " Try Learning: HM01 - Cut")
				self.pokemonId = self.pokemonId + 1
			else
				fatal("No pokemon in this team can learn Cut")
			end
		else
			sys.debug("quest", "Going to Goldenrod City.")
			return moveToCell(8, 7)
		end
	end
end

function IlexForestQuest:Route34StopHouse()
	sys.debug("quest", "Going to Goldenrod City.")
	return moveToCell(4, 2)
end

function IlexForestQuest:Route34()
	sys.debug("quest", "Going to Goldenrod City.")
	return moveToCell(13, 0)
end

return IlexForestQuest