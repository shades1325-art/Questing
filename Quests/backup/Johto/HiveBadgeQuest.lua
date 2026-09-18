-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"

local name		  = 'Azalea Town'
local description = 'Hive Badge'
local level = 0

local HiveBadgeQuest = Quest:new()

function HiveBadgeQuest:new()
	local o = Quest.new(HiveBadgeQuest, name, description, level)
	o.pokemon = "Shinx"
	o.forceCaught = false
	return o
end

function HiveBadgeQuest:isDoable()
	if self:hasMap() and not hasItem("Plain Badge") then
		return true
	end
	return false
end

function HiveBadgeQuest:isDone()
	if getMapName() == "Ilex Forest" or getMapName() == "Pokecenter Route 32" then --fix blackout
		return true
	end
end

function HiveBadgeQuest:PokecenterAzalea()
	self:pokecenter("Azalea Town")
end

function HiveBadgeQuest:AzaleaPokemart()
	self:pokemart("Azalea Town")	
end

function HiveBadgeQuest:AzaleaTown()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Azalea" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(25, 14)

	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(34, 13)

	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(60, 27)

	elseif isNpcOnCell(19, 28) then	
		sys.debug("quest", "Going to Slowpoke Well.")
		return moveToCell(46, 10)

	elseif not hasItem("Hive Badge") then
		sys.debug("quest", "Going to get 2nd badge.")
		return moveToCell(19, 27)

	elseif isNpcOnCell(5, 12) then	
		sys.debug("quest", "Going to talk to Trainer Yellow.")
		return talkToNpcOnCell(5, 12)

	else
		sys.debug("quest", "Going to Ilex Forest.")
		return moveToCell(4, 12)
	end	
end

function HiveBadgeQuest:Route33()
	if self:needPokecenter() or self:needPokemart() or self.registeredPokecenter ~= "Pokecenter Azalea" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(0, 21)
	--elseif not self.forceCaught then
		--sys.debug("quest", "Going to catch Shinx for later quest.")
		--return moveToRectangle(6, 23, 21, 27)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToRectangle(6, 23, 21, 27)
	else
		sys.debug("quest", "Going back to Azalea Town.")
		return moveToCell(0, 21)
	end
end

function HiveBadgeQuest:IlexForestStopHouse()
	sys.debug("quest", "Going to Ilex Forest.")
	return moveToCell(0, 6)
end

function HiveBadgeQuest:SlowpokeWell()
	if isNpcOnCell(12, 26) then
		sys.debug("quest", "Going to talk to the NPC.")
		return talkToNpcOnCell(12, 26)
	else
		sys.debug("quest", "Going back to Azalea Town.")
		return moveToCell(41, 39)
	end
end

function HiveBadgeQuest:AzaleaTownGym()
	if not hasItem("Hive Badge") then
		sys.debug("quest", "Going to get 2nd badge.")
		return talkToNpcOnCell(15, 3)
	else
		sys.debug("quest", "Going back to Azalea Town.")
		return moveToCell(14, 32)
	end
end

return HiveBadgeQuest