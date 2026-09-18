-- Copyright � 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Route 12 to Fuchsia City'
local description = 'Catch Snorlax, get all items, go to Fuchsia City.'

local P16SnorlaxQuest = Quest:new()

function P16SnorlaxQuest:new()
	return Quest.new(P16SnorlaxQuest, name, description, level)
end

function P16SnorlaxQuest:isDoable()
	if self:hasMap() and not hasItem("Soul Badge") then
		return true
	end
	return false
end

function P16SnorlaxQuest:isDone()
	if getMapName() == "Fuchsia City" or getMapName() == "Pokecenter Lavender" then --Fix Blackout
		return true
	end
	return false
end

function P16SnorlaxQuest:Route12()
	if isNpcOnCell(18, 47) then --NPC: Snorlax
		sys.debug("quest", "Going to fight and try to catch Snorlax.")
		return talkToNpcOnCell(18, 47)
	else
		sys.debug("quest", "Going to Route 13.")
		return moveToCell(25, 92)
	end
end

function P16SnorlaxQuest:Route13()
	sys.debug("quest", "Going to Route 14.")
	return moveToCell(18, 34)
end

function P16SnorlaxQuest:Route14()
	sys.debug("quest", "Going to Route 15.")
	return moveToCell(0, 46)
end

function P16SnorlaxQuest:Route15()
	sys.debug("quest", "Going to Fuchsia City.")
	return moveToCell(6, 16)
end

function P16SnorlaxQuest:Route15StopHouse()
	sys.debug("quest", "Going to Fuchsia City.")
	return moveToCell(0, 6)
end

return P16SnorlaxQuest