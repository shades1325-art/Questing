-- Copyright � 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @WiWi__33[NetPapa]


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"

local name		  = 'To Fortree City'
local description = 'Will save the Weather Institute and get the Devon Scope'
local level = 0

local ToFortreeCity = Quest:new()

function ToFortreeCity:new()
	o = Quest.new(ToFortreeCity, name, description, level, dialogs)
	return o
end

function ToFortreeCity:isDoable()
	if self:hasMap() and not hasItem("Devon Scope") and hasItem("Balance Badge") then
		return true
	end
	return false
end

function ToFortreeCity:isDone()
	if hasItem("Devon Scope") and getMapName() == "Route 120" then
		return true
	else
		return false
	end
end

function ToFortreeCity:PetalburgCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Petalburg City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(27, 22)
	else
		sys.debug("quest", "Going to Fortree City.")
		return moveToCell(44, 22)
	end
end

function ToFortreeCity:PokecenterPetalburgCity()
	return self:pokecenter("Petalburg City")
end

function ToFortreeCity:Route102()
	sys.debug("quest", "Going to Fortree City.")
	return moveToCell(83, 17)
end

function ToFortreeCity:OldaleTown()
	sys.debug("quest", "Going to Fortree City.")
	return moveToCell(24, 0)
end

function ToFortreeCity:Route103()
	sys.debug("quest", "Going to Fortree City.")
	return moveToCell(100, 19)
end

function ToFortreeCity:Route110()
	sys.debug("quest", "Going to Fortree City.")
	return moveToCell(25, 3)
end

function ToFortreeCity:MauvilleCityStopHouse1()
	sys.debug("quest", "Going to Fortree City.")
	return moveToCell(4, 2)
end

function ToFortreeCity:MauvilleCity()
	sys.debug("quest", "Going to Fortree City.")
	return moveToCell(48, 17)
end

function ToFortreeCity:MauvilleCityStopHouse4()
	sys.debug("quest", "Going to Fortree City.")
	return moveToCell(10, 6)
end

function ToFortreeCity:Route118()
	sys.debug("quest", "Going to Fortree City.")
	return moveToCell(59, 0)
end

function ToFortreeCity:Route119B()
	sys.debug("quest", "Going to Fortree City.")
	return moveToCell(9, 0)
end

function ToFortreeCity:Route119A()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(9, 40)

	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToRectangle(8, 60, 16, 74)

	elseif isNpcOnCell(18, 43) then 
		sys.debug("quest", "Going to rescue Weather Institute.")
		return moveToCell(9, 40)

	elseif isNpcOnCell(41, 30) then 
		sys.debug("quest", "Going to fight May.")
		return talkToNpcOnCell(41, 30)

	else
		sys.debug("quest", "Going to Fortree City.")
		return moveToCell(55, 8)

	end
end

function ToFortreeCity:WeatherInstitute1F()
	if not game.isTeamFullyHealed() then
		sys.debug("quest", "Going to heal Pokemon.")
		talkToNpcOnCell(18, 24)

	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(18, 28)

	elseif isNpcOnCell(32, 9) then
		sys.debug("quest", "Going to fight Admin Aqua Shelly.")
		return talkToNpcOnCell(32, 9)

	elseif isNpcOnCell(24, 13) then
		sys.debug("quest", "Going to rescue Weather Institute.")
		return moveToCell(32, 9)

	else
		sys.debug("quest", "Going to Fortree City.")
		return moveToCell(18, 28)

	end
end

function ToFortreeCity:WeatherInstitute2F()
	if isNpcOnCell(16, 19) then
		sys.debug("quest", "Going to fight Magma Admin Tabitha.")
		return talkToNpcOnCell(16, 19)
	else
		sys.debug("quest", "Going to Fortree City.")
		return moveToCell(36, 12)
	end
end

function ToFortreeCity:FortreeCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Fortree City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(8, 11)
	elseif not hasItem("Devon Scope") then
		sys.debug("quest", "Going to talk to Steven.")
		return moveToCell(54, 14)
	end
end

function ToFortreeCity:PokecenterFortreeCity()
	return self:pokecenter("Fortree City")
end

function ToFortreeCity:Route120()
	if isNpcOnCell(45, 13) then 
		sys.debug("quest", "Going to talk to Steven.")
		return talkToNpcOnCell(45, 13)
	end
end

return ToFortreeCity