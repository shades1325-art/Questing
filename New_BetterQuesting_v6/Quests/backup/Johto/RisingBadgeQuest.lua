-- Copyrright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @WiWi__33[NetPaPa]


local sys    = require "Libs/syslib"
local pc	 = require "Libs/pclib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"

local luaPokemonData = require "Data/luaPokemonData"


local name		  = 'Rising Badge Quest'
local description = 'Will exp to lv 80 and earn the 8th badge'
local level = 0

local RisingBadgeQuest = Quest:new()

function RisingBadgeQuest:new()
	local o = Quest.new(RisingBadgeQuest, name, description, level, dialogs)
	o.checkedForBestPokemon = false

	return o
end

function RisingBadgeQuest:isDoable()
	if self:hasMap() and not hasItem("Rising Badge") and hasItem("Glacier Badge") then
		return true
	end
	return false
end

function RisingBadgeQuest:isDone()
	if hasItem("Rising Badge") and getMapName() == "Blackthorn City Gym" then
		return true
	else
		return false
	end
end

function RisingBadgeQuest:MahoganyTownGym()
	if game.inRectangle(14, 49, 22, 67) then
		sys.debug("quest", "Going to Blackthorn City.")
		return moveToCell(18, 67)
	elseif game.inRectangle(11, 32, 23, 46) then  
		sys.debug("quest", "Going to Blackthorn City.")
		return moveToCell(17, 46)
	elseif game.inRectangle(12, 10, 22, 29) then 
		sys.debug("quest", "Going to Blackthorn City.")
		return moveToCell(17, 29)
	end
end

function RisingBadgeQuest:MahoganyTown()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Mahogany" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(25, 23)
	else
		sys.debug("quest", "Going to Blackthorn City.")
		return moveToCell(40, 17)
	end
end

function RisingBadgeQuest:PokecenterMahogany()
	return self:pokecenter("Mahogany Town")
end

function RisingBadgeQuest:Route44()
	sys.debug("quest", "Going to Blackthorn City.")
	return moveToCell(81, 9)
end

function RisingBadgeQuest:IcePath1F()
	if game.inRectangle(7, 11, 49, 63) or game.inRectangle(47, 13, 58, 20) then
		sys.debug("quest", "Going to Blackthorn City.")
		return moveToCell(57,15)
	else
		sys.debug("quest", "Going to Blackthorn City.")
		return moveToCell(57, 46)
	end
end

function RisingBadgeQuest:IcePathB1F()
	if game.inRectangle(11, 9, 42, 31) then
		sys.debug("quest", "Going to Blackthorn City.")
		return moveToCell(21, 25)
	else
		sys.debug("quest", "Going to Blackthorn City.")
		return moveToCell(18, 44)
	end
end

function RisingBadgeQuest:IcePathB2F()
	if game.inRectangle(47, 7, 67, 32) then
		sys.debug("quest", "Going to Blackthorn City.")
		return moveToCell(50, 27)
	else
		sys.debug("quest", "Going to Blackthorn City.")
		return moveToCell(23, 22)
	end
end

function RisingBadgeQuest:IcePathB3F()
	sys.debug("quest", "Going to Blackthorn City.")
	return moveToCell(32, 17)
end

function RisingBadgeQuest:BlackthornCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Blackthorn" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(29, 39)
	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(23, 39)
	elseif not self:isTrainingOver() then 
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(27, 5)
	else
		sys.debug("quest", "Going to get 8th badge.")
		return moveToCell(24, 20)
	end
end

function RisingBadgeQuest:PokecenterBlackthorn()
	if not self.checkedForBestPokemon then
		self.checkedForBestPokemon = true
	else
		self:pokecenter("Blackthorn City")
	end
end

function RisingBadgeQuest:BlackthornCityPokemart()
	self:pokemart("Blackthorn City")
end

function RisingBadgeQuest:DragonsDenEntrance()
	if self:needPokecenter() or self:isTrainingOver() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(14, 18)
	else
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(14, 14)
	end
end

function RisingBadgeQuest:DragonsDen()
	if self:needPokecenter() or self:isTrainingOver() then 
		self.checkedForBestPokemon = false
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(40, 16)
	else
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToRectangle(25, 20, 57, 24)
	end
end

function RisingBadgeQuest:BlackthornCityGym()
	sys.debug("quest", "Going to get 8th badge.")
	return talkToNpcOnCell(29, 12)
end

return RisingBadgeQuest