-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @WiWi__33[NetPapa]


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'StoneBadgeQuestQuest'
local description = 'Will get the 1st badge'

local level       = 0

local dialogs = {
	firstBattleDone = Dialog:new({ 
		"I am your opponent",
		"Who are you"
	}),
}

local StoneBadgeQuest = Quest:new()


function StoneBadgeQuest:new()
	local o = Quest.new(StoneBadgeQuest, name, description, level, dialogs)
	o.pokemon = "Shroomish"
	o.forceCaught = true
	return o
end

function StoneBadgeQuest:isDoable()
	if not hasItem("Stone Badge") and self:hasMap() then
		return true
	end
	return false
end

function StoneBadgeQuest:isDone()
	if hasItem("Stone Badge") or getMapName() == "Pokecenter Petalburg City" then
		return true 
	else 
		return false
	end
end

function StoneBadgeQuest:PetalburgWoods()
	if isNpcOnCell(36, 30) and not dialogs.firstBattleDone.state then 
		sys.debug("quest", "Going to talk to NPC1.")
		return talkToNpcOnCell(36, 30)
	elseif isNpcOnCell(38, 30) and dialogs.firstBattleDone.state then
		sys.debug("quest", "Going to talk to NPC2.")
		return talkToNpcOnCell(38, 30)
	elseif isNpcOnCell(37, 29) then
		sys.debug("quest", "Going to talk to Scientist.")
		return talkToNpcOnCell(37, 29)
	elseif not self.forceCaught then
		sys.debug("quest", "Going to catch Shroomish for later quest.")
		return moveToGrass()
	else
		sys.debug("quest", "Going to Rustboro City.")
		return moveToCell(22, 0)
	end
end

function StoneBadgeQuest:Route104()
	if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Rustboro City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(38, 0)

	elseif isNpcOnCell(10, 21) then
		sys.debug("quest", "Going to get item.")
		return talkToNpcOnCell(10, 21)

	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToGrass()
	else
		sys.debug("quest", "Going to Rustboro City.")
		return moveToCell(38, 0)
	end
end	

function StoneBadgeQuest:RustboroCity()
	if isNpcOnCell(38, 39) then
		sys.debug("quest", "Going to talk to Guide Bob.")
		return talkToNpcOnCell(38, 39)

	elseif self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Rustboro City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(38, 38)

	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(38, 50)

	elseif not self:isTrainingOver() then 
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(38, 65)

	elseif self:isTrainingOver() and not hasItem("Stone Badge") then
		sys.debug("quest", "Going to get 1st badge.")
		return moveToCell(53, 19)
	end
end

function StoneBadgeQuest:PokecenterRustboroCity()
	return self:pokecenter("Rustboro City")
end

function StoneBadgeQuest:MartRustboroCity()
	return self:pokemart()
end

function StoneBadgeQuest:RustboroCityGym()
	if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Rustboro City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToMap("Rustboro City")
	elseif not hasItem("Stone Badge") then 
		sys.debug("quest", "Going to get 1st badge.")
		return talkToNpcOnCell(10, 3)
	end
end	

return StoneBadgeQuest