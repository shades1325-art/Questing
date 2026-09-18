-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local Quest  = require "Quests/Quest"

local name		  = 'Revive Fossils'
local description = 'Dome Fossil, Helix Fossil, Old Amber, Jaw Fossil, Sail Fossil'

local ReviveFossilQuest = Quest:new()

function ReviveFossilQuest:new()
	return Quest.new(ReviveFossilQuest, name, description, level)
end

function ReviveFossilQuest:isDoable()
	return self:hasMap()
end

function ReviveFossilQuest:isDone()
	return getMapName() == "Cinnabar Island"
end

function ReviveFossilQuest:CinnabarLab()
	if not hasItem("Dome Fossil") and not hasItem("Helix Fossil") and not hasItem("Old Amber") and not hasItem("Jaw Fossil") and not hasItem("Sail Fossil") then
		sys.debug("quest", "Going back to Cinnabar Island.")
		return moveToCell(6, 15)
	else
		if isNpcOnCell(34, 10) then
			sys.debug("quest", "Going to talk to NPC in front of Cinnabar Lab Room 3.")
			return talkToNpcOnCell(34, 10)
		else
			sys.debug("quest", "Going to Cinnabar Lab Room 3.")
			return moveToCell(34, 9)
		end
	end
end

function ReviveFossilQuest:CinnabarLabRoom3()
	if hasItem("Dome Fossil") or hasItem("Helix Fossil") or hasItem("Old Amber") or hasItem("Jaw Fossil") or hasItem("Sail Fossil") then
		if hasItem("Dome Fossil") then
			sys.debug("quest", "Going to revive Dome Fossil.")
			pushDialogAnswer(1) --Choose Fossil
			pushDialogAnswer(1) --Confirm
			return talkToNpcOnCell(12, 5)

		elseif hasItem("Helix Fossil") then
			sys.debug("quest", "Going to revive Helix Fossil.")
			pushDialogAnswer(2) --Choose Fossil
			pushDialogAnswer(1) --Confirm
			return talkToNpcOnCell(12, 5)

		elseif hasItem("Old Amber") then
			sys.debug("quest", "Going to revive Old Amber.")
			pushDialogAnswer(3) --Choose Fossil
			pushDialogAnswer(1) --Confirm
			return talkToNpcOnCell(12, 5)

		elseif hasItem("Jaw Fossil") then
			sys.debug("quest", "Going to revive Jaw Fossil.")
			pushDialogAnswer(4) --Choose Fossil
			pushDialogAnswer(1) --Confirm
			return talkToNpcOnCell(12, 5)

		elseif hasItem("Sail Fossil") then
			sys.debug("quest", "Going to revive Sail Fossil.")
			pushDialogAnswer(5) --Choose Fossil
			pushDialogAnswer(1) --Confirm
			return talkToNpcOnCell(12, 5)

		end		
	else
		sys.debug("quest", "Going back to Cinnabar Island.")
		return moveToCell(8, 14)
	end	
end

return ReviveFossilQuest