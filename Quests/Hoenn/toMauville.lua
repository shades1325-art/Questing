-- Copyright � 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @WiWi__33[NetPapa]

local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'To Mauville City'
local description = 'Beat Museum, May and go to Mauville'

local level       = 0

local dialogs = {
	devonVic = Dialog:new({ 
		"I need to do some research on this"
	}),

	ingenieur = Dialog:new({ 
		"Oh, you need to see Devon",
		"Restaurants for cats?" --ARE THEY OUT OF THEIR MINDS ? 
	}),

	goingO = Dialog:new({ 
		"What is going on?"
	}),
}

local toMauville = Quest:new()

function toMauville:new()
	return Quest.new(toMauville , name, description, level, dialogs)
end

function toMauville:isDoable()
	if hasItem("Stone Badge") and self:hasMap() and not hasItem("Dynamo Badge") then
		return true
	end
	return false
end

function toMauville:isDone()
	if (hasItem("Knuckle Badge") and getMapName() == "Mauville City") then 
		return true
	end
	return false
end 
	
function toMauville:DevonCorporation3F()
	sys.debug("quest", "Going to Mauville City.")
	return moveToCell(6, 3)
end

function toMauville:DevonCorporation2F()
	sys.debug("quest", "Going to Mauville City.")
	return moveToCell(20, 3)
end

function toMauville:DevonCorporation1F()
	sys.debug("quest", "Going to Mauville City.")
	return moveToCell(8, 11)
end

function toMauville:RustboroCity()
	sys.debug("quest", "Going to Mauville City.")
	return moveToCell(41, 65)
end

function toMauville:Route104()
	if game.inRectangle(0, 0, 78, 55) then 
		sys.debug("quest", "Going to Mauville City.")
		return moveToCell(24, 51)
	else
		sys.debug("quest", "Going to Mauville City.")
		return moveToCell(45, 97)
	end
end

function toMauville:PetalburgWoods()
	sys.debug("quest", "Going to Mauville City.")
	return moveToCell(24, 60)
end

function toMauville:Route104SailorHouse()
	if isNpcOnCell(11, 6) then 
		sys.debug("quest", "Going to Mauville City.")
		return talkToNpcOnCell(11, 6)
	end
end

function toMauville:DewfordTown()
	pushDialogAnswer(2) -- Slateport
	sys.debug("quest", "Going to Mauville City.")
	return talkToNpcOnCell(37, 9)
end

function toMauville:Route109()
	sys.debug("quest", "Going to Mauville City.")
	moveToCell(33, 0)
end

function toMauville:SlateportCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Slateport" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(32, 25)
	elseif not hasItem("Devon Goods") then 
		sys.debug("quest", "Going to fight May.")
		return moveToCell(32, 0)
	elseif not dialogs.ingenieur.state and not dialogs.devonVic.state then 
		sys.debug("quest", "Going to deliver Devon Goods.")
		return moveToCell(39, 54)
	elseif dialogs.ingenieur.state then 
		sys.debug("quest", "Going to museum.")
		return moveToCell(55, 38)
	end
end

function toMauville:PokecenterSlateport()
	return self:pokecenter("Slateport City")
end

function toMauville:SlateportShipyard1F()
	if not dialogs.ingenieur.state then 
		sys.debug("quest", "Going to deliver Devon Goods.")
		return talkToNpcOnCell(5, 6)
	else
		sys.debug("quest", "Going to museum.")
		return moveToCell(3, 16)
	end
end

function toMauville:SlateportMuseum1F()
	if not dialogs.devonVic.state then 
		sys.debug("quest", "Going to deliver Devon Goods.")
		return moveToCell(4, 4)
	else
		sys.debug("quest", "Going to fight May.")
		return moveToCell(10, 22)
	end
end

function toMauville:SlateportMuseum2F()
    if isNpcOnCell(11, 14) and game.inRectangle(9, 12, 12, 17) then 
		sys.debug("quest", "Going to fight Jackson.")
        talkToNpcOnCell(11, 14)

    elseif isNpcOnCell(9, 14) and not dialogs.goingO.state then 
		sys.debug("quest", "Going to deliver Devon Goods.")
        return talkToNpcOnCell(9, 14)

    else
		dialogs.devonVic.state = true
        dialogs.ingenieur.state = false
		sys.debug("quest", "Going to fight May.")
        return moveToCell(7, 4)
    end
end 

function toMauville:Route110()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(23, 140)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToRectangle(8, 126, 18, 132)
	elseif isNpcOnCell(43, 78) then -- May
		sys.debug("quest", "Going to fight May.")
		return talkToNpcOnCell(43, 78)
	else
		sys.debug("quest", "Going to Mauville City.")
		return moveToCell(24, 3)
	end
end

function toMauville:MauvilleCityStopHouse1()
	sys.debug("quest", "Going to Mauville City.")
	return moveToCell(3, 2)
end
	
return toMauville