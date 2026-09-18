-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @WiWi__33[NetPapa]


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"

local name		  = 'The Magma HideOut'
local description = 'Clear the Magma Hideout and give the Red Orb'

local MagmaHideOut = Quest:new()

function MagmaHideOut:new()
	return Quest.new(MagmaHideOut, name, description, level, dialogs)
end

function MagmaHideOut:isDoable()
	if self:hasMap() and hasItem("Blue Orb") and hasItem("Red Orb") then
		return true
	end
	return false
end

function MagmaHideOut:isDone()
	if not hasItem("Red Orb") and getMapName() == "Magma Hideout 4F" then
		return true
	else
		return false
	end
end

function MagmaHideOut:MtPyreSummit()
	sys.debug("quest", "Going to Magma Hideout.")
	return moveToCell(25, 79)
end

function MagmaHideOut:MtPyreExterior()
	sys.debug("quest", "Going to Magma Hideout.")
	return moveToCell(8, 133)
end

function MagmaHideOut:MtPyre3F()
	sys.debug("quest", "Going to Magma Hideout.")
	return moveToCell(23, 4)
end

function MagmaHideOut:MtPyre2F()
	sys.debug("quest", "Going to Magma Hideout.")
	return moveToCell(2, 5)
end

function MagmaHideOut:MtPyre1F()
	sys.debug("quest", "Going to Magma Hideout.")
	return moveToCell(19, 27)
end

function MagmaHideOut:Route122()
	sys.debug("quest", "Going to Magma Hideout.")
	return moveToCell(64, 60)
end

function MagmaHideOut:Route123()
	sys.debug("quest", "Going to Magma Hideout.")
	return moveToCell(0, 12)
end

function MagmaHideOut:Route118()
	sys.debug("quest", "Going to Magma Hideout.")
	return moveToCell(3, 17)
end

function MagmaHideOut:MauvilleCityStopHouse4()
	sys.debug("quest", "Going to Magma Hideout.")
	return moveToCell(0, 7)
end

function MagmaHideOut:MauvilleCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Mauville City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(28, 13)
	else
		sys.debug("quest", "Going to Magma Hideout.")
		return moveToCell(22, 4)
	end
end

function MagmaHideOut:PokecenterMauvilleCity()
	return self:pokecenter("Mauville City")
end

function MagmaHideOut:MauvilleCityStopHouse3()
	sys.debug("quest", "Going to Magma Hideout.")
	return moveToCell(4, 2)
end

function MagmaHideOut:Route111South()
	sys.debug("quest", "Going to Magma Hideout.")
	return moveToCell(0, 23)
end

function MagmaHideOut:Route112()
	sys.debug("quest", "Going to Magma Hideout.")
	return moveToCell(29, 33)
end

function MagmaHideOut:CableCarStation1()
	sys.debug("quest", "Going to Magma Hideout.")
	return talkToNpcOnCell(10, 6)
end

function MagmaHideOut:CableCarStation2()
	sys.debug("quest", "Going to Magma Hideout.")
	return moveToCell(3, 9)
end

function MagmaHideOut:MtChimney()
	sys.debug("quest", "Going to Magma Hideout.")
	return moveToCell(32, 50)
end

function MagmaHideOut:JaggedPass()
	sys.debug("quest", "Going to Magma Hideout.")
	return talkToNpcOnCell(30, 35)
end

function MagmaHideOut:MagmaHideout1F()
	sys.debug("quest", "Going to Magma Hideout.")
	return moveToCell(23, 28)
end

function MagmaHideOut:MagmaHideout2F1R()
	sys.debug("quest", "Going to Magma Hideout.")
	return moveToCell(17, 37)
end

function MagmaHideOut:MagmaHideout3F1R()
	sys.debug("quest", "Going to Magma Hideout.")
	return moveToCell(11, 20)
end

function MagmaHideOut:MagmaHideout4F() -- groudon: 19, 29
	if isNpcOnCell(16, 31) then
		sys.debug("quest", "Going to talk to NPC.")
		return talkToNpcOnCell(16, 31)
	if isNpcOnCell(15, 31) then
		sys.debug("quest", "Going to talk to NPC.")
		return talkToNpcOnCell(15, 31)
	end
end

return MagmaHideOut