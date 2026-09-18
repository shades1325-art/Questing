-- Copyright � 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Atem

-- Last battle is pretty difficult, so we need to catch these Pokemon (should be sorted like that before the last battle too)
-- 1. Luxray     --done and checked
-- 2. Exeggutor  --done and checked
-- 3. Heracross  --done and checked
-- 4. Swampert   --done and checked
-- 5. Flareon    --done and checked
-- 6. Breloom    --done


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'To Sinnoh Quest'
local description = 'Going to fight Galatic Grunts & Pluton, find the 3 starters, give them to Prof. Birch and go to Sinnoh.'
local level = 0

local dialogs = {
	Stanbeaten1 = Dialog:new({ 
		"He is currently at Sky Pillar"
	}),
	Stanbeaten2 = Dialog:new({ 
		"They will avenge me"
	})
}

local toSinnohQuest = Quest:new()

function toSinnohQuest:new()
	local o = Quest.new(toSinnohQuest, name, description, level, dialogs)
	return o
end

function toSinnohQuest:isDoable()
	if self:hasMap() and hasItem("Rain Badge") and not hasItem("Coal Badge") then
		return true
	end
	return false
end

function toSinnohQuest:isDone()
	if hasItem("xxx") and getMapName() == "xxx" or getMapName() == "Route 127" then
		return true
	else
		return false
	end
end

function toSinnohQuest:PlayerBedroomLittlerootTown()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(11, 5)
end

function toSinnohQuest:PlayerHouseLittlerootTown()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(11, 12)
end

function toSinnohQuest:LittlerootTown()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(23, 0)
end

function toSinnohQuest:Route101()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(22, 0)
end

function toSinnohQuest:OldaleTown()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Oldale Town" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(16, 26)
	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(28, 10)
	elseif isNpcOnCell(3, 17) then
		sys.debug("quest", "Going to talk to Stan.")
		return talkToNpcOnCell(3, 17)
	else
		sys.debug("quest", "Going to Lilycove City.")
		return moveToCell(23, 0)
	end
end

function toSinnohQuest:PokecenterOldaleTown() -- here i need to make sure to add all desired pokemon to the team
	return self:pokecenter("Oldale Town")
end

function toSinnohQuest:MartOldaleTown()
	return self:pokemart()
end

function toSinnohQuest:Route103()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(100, 20)
	if isNpcOnCell(35, 17) then
		if self:needPokecenter() then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(29, 35)
		else
			sys.debug("quest", "Going to fight Pluton.")
			return talkToNpcOnCell(35, 17)
		end
	elseif isNpcOnCell(36, 15) then
		sys.debug("quest", "Going to talk to Prof. Birch")
		return talkToNpcOnCell(36, 15)
	else
		sys.debug("quest", "Going to Lilycove City.")
		return moveToCell(100, 19)
	end
end

function toSinnohQuest:Route110()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(24, 3)
end

function toSinnohQuest:MauvilleCityStopHouse1()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(3, 2)
end

function toSinnohQuest:MauvilleCity()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(48, 17)
end

function toSinnohQuest:MauvilleCityStopHouse4()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(10, 6)
end

function toSinnohQuest:Route118()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(59, 0)
end

function toSinnohQuest:Route119B()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(9, 0)
end

function toSinnohQuest:Route119A()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(55, 8)
end

function toSinnohQuest:FortreeCity()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(54, 14)
end

function toSinnohQuest:Route120()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(50, 101)
end

function toSinnohQuest:Route121()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(85, 7)
end

function toSinnohQuest:LilycoveCity()
	if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Lilycove City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(26, 20)
	else
		if not self:isTrainingOver() then
			sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
			return moveToCell(95, 19)
		else
			sys.debug("quest", "Going to talk to Paul.")
			return talkToNpcOnCell(65, 33)
		end
	end
end

function toSinnohQuest:PokecenterLilycoveCity()
	return self:pokecenter("Lilycove City")
end

function toSinnohQuest:Route124()
	sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
	return moveToCell(91, 39)
end

function toSinnohQuest:MossdeepCity()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(31, 55)
	else
		sys.debug("quest", "Going back to Lilycove City.")
		return moveToCell(0, 15)
	end
end

return toSinnohQuest