-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local team   = require "Libs/teamlib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'Start Sinnoh Quest'
local description = 'Get first Pokemon and go to Sandgem'
local level       = 0

local dialogs = {
	GrandmaCheck = Dialog:new({
		"Well, take care, sweetie!",
		"There you go, sweetie,",
	}),
	BarryCheck = Dialog:new({
		"million fine if you're late!",
	}),
	MeetProf = Dialog:new({
		"I'm sure your friend can be patient and wait",
	}),
	SandgemBarry = Dialog:new({
		"Anyway, smell ya later!",
	}),
	RowanLabCheck = Dialog:new({
		"to go on an adventure",
		"work on your Pokedex",
	}),
}

local StartSinnohQuest = Quest:new()

function StartSinnohQuest:new()
	local o = Quest.new(StartSinnohQuest, name, description, level, dialogs)
	o.pokemonId = 1
	return o
end

function StartSinnohQuest:isDoable()
	if self:hasMap() and not hasItem("Coal Badge") then
		return true
	end
	return false
end

function StartSinnohQuest:isDone()
	return getMapName() == "Sandgem Town"
end

function StartSinnohQuest:TwinleafTownPlayerHouse2F()
	if getTeamSize() == 0 then
		sys.debug("quest", "Going downstair.")
		return moveToCell(8, 4)
	end
end

function StartSinnohQuest:TwinleafTownPlayerHouse()
	if not dialogs.GrandmaCheck.state then
		sys.debug("quest", "Talk to grandma.")
		return talkToNpcOnCell(8, 9)
	else
		sys.debug("quest", "Going back to Twinleaf Town.")
		return moveToCell(4, 12)
	end
end

function StartSinnohQuest:TwinleafTown()
	if not dialogs.BarryCheck.state then 
		sys.debug("quest", "Going to talk to Barry.")
		return moveToCell(8, 14)
	else
		sys.debug("quest", "Going to Route201.")
		return moveToCell(15, 0)
	end
end

function StartSinnohQuest:TwinleafTownRivalHouse()
	if not dialogs.BarryCheck.state then
		sys.debug("quest", "Going to talk to Barry.")
		return moveToCell(3, 5)
	else
		sys.debug("quest", "leave his house.")
		return moveToCell(4, 12)
	end
end

function StartSinnohQuest:TwinleafTownRivalHouse2F()
	if isNpcOnCell(8, 4) then
		sys.debug("quest", "Going to talk to Barry.")
		return talkToNpcOnCell(8, 4)
	else
		sys.debug("quest", "leave his house.")
		dialogs.BarryCheck.state = true
		return moveToCell(1, 4)
	end
end

function StartSinnohQuest:Route201()
	if getTeamSize() == 0 and dialogs.MeetProf.state then
		sys.debug("quest", "Going to get Piplup.")
		return talkToNpcOnCell(47, 20) -- piplup
	else
		--if not game.hasPokemonWithMove("Surf") then
			--return useItemOnPokemon("HM03 - Surf", 1)
		--else
			sys.debug("quest", "Going to Sandgem Town.")
			return moveToCell(100, 8)
		--end
	end
	if not dialogs.MeetProf.state then
		sys.debug("quest", "Going to talk to Barry.")
		return talkToNpcOnCell(48, 19)
	end
end

return StartSinnohQuest
