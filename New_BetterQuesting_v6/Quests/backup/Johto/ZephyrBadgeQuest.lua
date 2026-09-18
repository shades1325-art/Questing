-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"

local name		  = 'Violet City'
local description = 'Badge Quest'
local level = 0

local ZephyrBadgeQuest = Quest:new()

function ZephyrBadgeQuest:new()
	return Quest.new(ZephyrBadgeQuest, name, description, level)
end

function ZephyrBadgeQuest:isDoable()
	if self:hasMap() and not hasItem("Hive Badge") then
		return true
	end
	return false
end

function ZephyrBadgeQuest:isDone()
	if getMapName() == "Sprout Tower F1" or getMapName() == "Azalea Town" then
		return true
	end
	return false
end

function ZephyrBadgeQuest:PokecenterVioletCity()
	if isNpcOnCell(11, 21) then -- Guide BOB
		sys.debug("quest", "Going to talk to Guide Bob.")
		return talkToNpcOnCell(11, 21)
	else
		self:pokecenter("Violet City")
	end
end

function ZephyrBadgeQuest:PokecenterRoute32()
	self:pokecenter("Route 32")
end

function ZephyrBadgeQuest:VioletCityPokemart()
	self:pokemart("Violet City")	
end

function ZephyrBadgeQuest:VioletCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Violet City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(48, 57)

	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(18, 41)

	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(19, 72)

	elseif isNpcOnCell(27, 44) then	
		sys.debug("quest", "Going to Sprout Tower.")
		return moveToCell(37, 11)

	elseif not hasItem("Zephyr Badge") then
		sys.debug("quest", "Going to get 1st badge.")
		return moveToCell(27, 43)

	else
		sys.debug("quest", "Going to Azalea Town.")
		return moveToCell(19, 72)
	end
end


function ZephyrBadgeQuest:Route32()
	if not hasItem("Zephyr Badge") then
		if self:needPokecenter() or self:needPokemart() or self.registeredPokecenter ~= "Pokecenter Violet City" or self:isTrainingOver() then
			sys.debug("quest", "Going back to Violet City.")
			return moveToCell(24, 0)

		elseif not self:isTrainingOver() then
			sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
			return moveToRectangle(25, 9, 28, 15)
		end
	else
		if isNpcOnCell(26, 23) then
			sys.debug("quest", "Going to talk to Guard.")
			return talkToNpcOnCell(26, 23)

		elseif self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Route 32" then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(19, 128)

		else
			sys.debug("quest", "Going to Azalea Town.")
			return moveToCell(13, 137)

		end
	end
end

function ZephyrBadgeQuest:VioletCityGymEntrance()
	if not hasItem("Zephyr Badge") then
		sys.debug("quest", "Going to get 1st badge.")
		return moveToCell(7, 21)
	else
		sys.debug("quest", "Going back to Violet City.")
		return moveToCell(7, 32)
	end
end

function ZephyrBadgeQuest:VioletCityGym()
	if not hasItem("Zephyr Badge") then
		sys.debug("quest", "Going to get 1st badge.")
		return talkToNpcOnCell(7, 4)
	else
		sys.debug("quest", "Going back to Violet City.")
		return moveToCell(7, 20)
	end
end

function ZephyrBadgeQuest:UnionCave1F()
	sys.debug("quest", "Going to Azalea Town.")
	return moveToCell(42, 84)
end

function ZephyrBadgeQuest:Route33()
	sys.debug("quest", "Going to Azalea Town.")
	return moveToCell(0, 21)
end

return ZephyrBadgeQuest