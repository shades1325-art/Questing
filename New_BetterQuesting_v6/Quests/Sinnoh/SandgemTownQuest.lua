-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local team   = require "Libs/teamlib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'OreburghCityQuest'
local description = 'Get the first badge.'
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
	BarryMom = Dialog:new({
		"Oh, Barry's mother looked quite worried, can you go pay her a visit?",
	}),
	RowanLabCheck = Dialog:new({
		"to go on an adventure",
		"work on your Pokedex",
	}),
}

local OreburghCityQuest = Quest:new()

function OreburghCityQuest:new()
	local o = Quest.new(SandgemTownQuest, name, description, level, dialogs)
	o.pokemonId = 1
	return o
end

function OreburghCityQuest:isDoable()
	if self:hasMap() and not hasItem("Coal Badge") then
		return true
	end
	return false
end

function OreburghCityQuest:isDone()
	if getMapName() == "xxx" or getMapName() == "xxx" then --fix blackout
		return true
	end
end

function OreburghCityQuest:OreburghCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Sandgem Town" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(43, 17)
	end
end

function OreburghCityQuest:PokecenterOreburghCity()
	self:pokecenter("Oreburgh City")
end

function OreburghCityQuest:RowanLab()
	if not dialogs.RowanLabCheck.state then
		sys.debug("quest", "Talk to Rowan")
		return talkToNpcOnCell(8, 5)
	else
		sys.debug("quest", "Leave Rowan Lab")
		dialogs.RowanLabCheck.state = true
		return moveToCell(8, 15)
	end
end

function OreburghCityQuest:PokecenterSandgemTown()
	if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 7)
	else
		self.registeredPokecenter = "Pokecenter Sandgem Town"
		return moveToCell(8, 15)
	end
end

function OreburghCityQuest:TwinleafTownPlayerHouse()
	if dialogs.RowanLabCheck.state then
		sys.debug("quest", "Going to tell grandma")
		return moveToCell(8, 9)
	else
		sys.debug("quest", "Going back to Twinleaf Town.")
		return moveToCell(4, 12)
	end
end

function OreburghCityQuest:TwinleafTown()
	if dialogs.RowanLabCheck.state then
		sys.debug("quest", "Going to tell grandma")
		return moveToCell(20, 25)
    elseif dialogs.BarryMom.state then
		sys.debug("quest", "Going to meet Barry Mom")
        return moveToCell(8, 14)
    else
        return moveToCell(15, 0)
    end
end

function OreburghCityQuest:TwinleafTownRivalHouse()
	if not dialogs.BarryCheck.state then
		sys.debug("quest", "Going to talk to Barry.")
		return moveToCell(3, 5)
	else
		sys.debug("quest", "leave his house.")
		return moveToCell(4, 12)
	end
end

function OreburghCityQuest:TwinleafTownRivalHouse2F()
	if isNpcOnCell(8, 4) then
		sys.debug("quest", "Going to talk to Barry.")
		return talkToNpcOnCell(8, 4)
	else
		sys.debug("quest", "leave his house.")
		dialogs.BarryCheck.state = true
		return moveToCell(1, 4)
	end
end

function OreburghCityQuest:Route201()
	if dialogs.RowanLabCheck.state then
		sys.debug("quest", "Going to tell grandma")
		return moveToCell(48, 30)
    else
        return moveToCell(100, 8)
    end
end

return OreburghCityQuest

