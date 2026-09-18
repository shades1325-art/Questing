-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex

local sys    = require "Libs/syslib"
local Quest  = require "Quests/Quest"

local name		  = 'Saffron Guard'
local description = 'Route 15 to Saffron City'

local SaffronGuardQuest = Quest:new()

function SaffronGuardQuest:new()
	return Quest.new(SaffronGuardQuest, name, description, level)
end

function SaffronGuardQuest:isDoable()
	if self:hasMap() and not hasItem("Marsh Badge") then
		return true
	end
	return false
end

function SaffronGuardQuest:isDone()
	if getMapName() == "Saffron City" or getMapName() == "Pokecenter Fuchsia" then --Fix Blackout
		return true
	end
	return false
end

function SaffronGuardQuest:Route15()
	sys.debug("quest", "Going to Saffron City.")
	return moveToCell(94, 25)
end

function SaffronGuardQuest:Route14()
	sys.debug("quest", "Going to Saffron City.")
	return moveToCell(17, 0)
end

function SaffronGuardQuest:Route13()
	sys.debug("quest", "Going to Saffron City.")
	return moveToCell(94, 0)
end

function SaffronGuardQuest:Route12()
	sys.debug("quest", "Going to Saffron City.")
	return moveToCell(1, 47)
end

function SaffronGuardQuest:Route11StopHouse()
	sys.debug("quest", "Going to Saffron City.")
	return moveToCell(0, 6)
end

function SaffronGuardQuest:Route11()
	sys.debug("quest", "Going to Saffron City.")
	return moveToCell(0, 15)
end

function SaffronGuardQuest:VermilionCity()
	sys.debug("quest", "Going to Saffron City.")
	return moveToCell(42, 0)
end

function SaffronGuardQuest:PokecenterVermilion()
	self:pokecenter("Vermilion City")
end

function SaffronGuardQuest:Route6()
	sys.debug("quest", "Going to Saffron City.")
	return moveToCell(26, 5)
end

function SaffronGuardQuest:Route6StopHouse()
	sys.debug("quest", "Going to Saffron City.")
	return moveToCell(3, 2)
end

return SaffronGuardQuest