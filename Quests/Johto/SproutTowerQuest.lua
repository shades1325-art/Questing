-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Sprout Tower'
local description = ' Violet City'

local dialogs = {
	masterDone = Dialog:new({ 
		"you have already won",
		"passed my test"
	})
}

local SproutTowerQuest = Quest:new()

function SproutTowerQuest:new()
	return Quest.new(SproutTowerQuest, name, description, level, dialogs)
end

function SproutTowerQuest:isDoable()
	return self:hasMap()
end

function SproutTowerQuest:isDone()
	if getMapName() == "Violet City" or getMapName() == "Pokecenter Violet City" then
		return true
	end
	return false
end

function SproutTowerQuest:SproutTowerF1()
	if game.inRectangle(1, 16, 26, 26) or game.inRectangle(6, 7, 20, 26) then		
		if dialogs.masterDone.state then
			sys.debug("quest", "Going back to Violet City.")
			return moveToCell(13, 26)
		else
			sys.debug("quest", "Going to top of Sprout Tower.")
			return moveToCell(8, 8)
		end		
	else
		if dialogs.masterDone.state then
			sys.debug("quest", "Going back to Violet City.")
			return moveToCell(24, 3)
		else
			sys.debug("quest", "Going to top of Sprout Tower.")
			return moveToCell(2, 11)
		end	
	end
end

function SproutTowerQuest:SproutTowerF2()
	if game.inRectangle(7, 3, 26, 15) then
		if dialogs.masterDone.state then
			sys.debug("quest", "Going back to Violet City.")
			return moveToCell(9, 9)
		else
			sys.debug("quest", "Going to top of Sprout Tower.")
			return moveToCell(23, 4)
		end
	else
		if dialogs.masterDone.state then
			sys.debug("quest", "Going back to Violet City.")
			return moveToCell(3, 12)
		else
			sys.debug("quest", "Going to top of Sprout Tower.")
			return moveToCell(13, 23)
		end
	end
end

function SproutTowerQuest:SproutTowerF3()
	if not isNpcOnCell(13, 4) then --Master NPC
		dialogs.masterDone.state = true
	end

	if dialogs.masterDone.state then
		sys.debug("quest", "Going back to Violet City.")
		return moveToCell(13, 24)
	else
		sys.debug("quest", "Going to talk to Master.")
		return talkToNpcOnCell(13, 4)
	end
end

return SproutTowerQuest