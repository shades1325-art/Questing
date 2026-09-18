-- Copyright � 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"

local name		  = 'Cinnabar mansion'
local description = 'Get Cinnabar Key + All Items'

local CinnabarKeyQuest = Quest:new()

function CinnabarKeyQuest:new()
	return Quest.new(CinnabarKeyQuest, name, description, level)
end

function CinnabarKeyQuest:isDoable()
	if self:hasMap() and not hasItem("Earth Badge") then
		return true
	end
	return false
end

function CinnabarKeyQuest:isDone()
	if getMapName() == "Pokecenter Cinnabar" or getMapName() == "Cinnabar Island" then
		return true
	end
	return false
end

function CinnabarKeyQuest:Cinnabarmansion1()
	if not hasItem("Cinnabar Key") then
		if game.inRectangle(0, 0, 19, 42) or game.inRectangle(15, 3, 33, 23)  or game.inRectangle(33, 3, 42, 5) then
			sys.debug("quest", "Going to Cinnabar mansion 2.")
			return moveToCell(12, 17)
		elseif game.inRectangle(20, 26, 41, 42) or game.inRectangle(35, 6, 41, 26) then
			return moveToCell(29, 35)
		end
	else
		if game.inRectangle(20, 26, 41, 42) or game.inRectangle(35, 6, 41, 26) then
			sys.debug("quest", "Going back to Cinnabar Island.")
			return moveToCell(39, 42)
		end
	end
end

function CinnabarKeyQuest:Cinnabarmansion2()
	if not hasItem("Cinnabar Key") then
		sys.debug("quest", "Going to Cinnabar mansion 3.")
		return moveToCell(9, 4) -- Cinnabar mansion 3
	else
		sys.debug("quest", "Going to Cinnabar mansion 1.")
		return moveToCell(14, 19) -- Cinnabar mansion 1
	end
end

function CinnabarKeyQuest:Cinnabarmansion3()
	if not hasItem("Cinnabar Key") then
		sys.debug("quest", "Going to Cinnabar mansion B1F.")
		return moveToCell(20, 19) -- Cinnabar mansion B1F
	else
		sys.debug("quest", "Going to Cinnabar mansion 2.")
		return moveToCell(6, 4) -- Cinnabar mansion 2
	end
end

function CinnabarKeyQuest:CinnabarmansionB1F()
	if isNpcOnCell(5, 15) then
		if game.inRectangle(1, 16, 9, 22) then
			sys.debug("quest", "Going to talk to NPC.")
			return talkToNpcOnCell(5, 15)
		else
			sys.debug("quest", "Getting into Secret Room.")
			return talkToNpcOnCell(5, 26) --Library Hidden Passage
		end
	else
		sys.debug("quest", "Going to Cinnabar mansion 1.")
		return moveToCell(36, 31) --Cinnabar mansion 1
	end
end

return CinnabarKeyQuest