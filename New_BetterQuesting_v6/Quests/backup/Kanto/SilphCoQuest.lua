-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Silph Co'
local description = 'Rocket Team Quest'

local dialogs = {
	silphCoDone = Dialog:new({ 
		"saving this building"
	})
}

local SilphCoQuest = Quest:new()

function SilphCoQuest:new()
	return Quest.new(SilphCoQuest, name, description, level, dialogs)
end

function SilphCoQuest:isDoable()
	if self:hasMap() and not hasItem("Volcano Badge") then
		return true
	end
	return false
end

function SilphCoQuest:isDone()
	if getMapName() == "Saffron City" or getMapName() == "Pokecenter Saffron" then
		return true
	else
		return false
	end
end

function SilphCoQuest:SilphCo1F()
	if isNpcOnCell(19, 7) or dialogs.silphCoDone.state then
		sys.debug("quest", "Going to Saffron City.")
		return moveToCell(10, 28)
	else
		sys.debug("quest", "Going to Silph Co 2F.")
		return moveToCell(30, 3)
	end
end

function SilphCoQuest:SilphCo2F()
	if not dialogs.silphCoDone.state then
		sys.debug("quest", "Going to Silph Co 3F.")
		return moveToCell(34, 3)
	else
		sys.debug("quest", "Going to Silph Co 1F.")
		return moveToCell(30, 4)
	end
end

function SilphCoQuest:SilphCo3F()
	if not dialogs.silphCoDone.state then
		sys.debug("quest", "Going to Silph Co 7F.")
		return moveToCell(16, 18) -- Teleporter: Silph Co 7F
	else
		sys.debug("quest", "Going to Silph Co 2F.")
		return moveToCell(29, 5)
	end
end

function SilphCoQuest:SilphCo7F()
	if not dialogs.silphCoDone.state then
		sys.debug("quest", "Going to Silph Co 11F.")
		return moveToCell(6, 11) -- Teleporter: Silph Co 11F
	else
		sys.debug("quest", "Going to Silph Co 3F.")
		return moveToCell(6, 6) -- Teleporter: Silph Co 3F
	end
end

function SilphCoQuest:SilphCo11F()
	if isNpcOnCell(3, 13) then
		sys.debug("quest", "Going to fight Green.")
		return talkToNpcOnCell(3, 13)
	elseif isNpcOnCell(6, 15) then
		sys.debug("quest", "Going to fight Giovanni.")
		return talkToNpcOnCell(6, 15)
	elseif not dialogs.silphCoDone.state then
		sys.debug("quest", "Going to take Rare Candies.")
		return talkToNpcOnCell(9, 11)
	else
		sys.debug("quest", "Going to Silph Co 7F.")
		return moveToCell(3, 7) --Silph Co 7F
	end
end

return SilphCoQuest