-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.

local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local pc	 = require "Libs/pclib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local luaPokemonData = require "Data/luaPokemonData"

local name        = 'Boulder Badge'
local description = 'from route 2 to route 3'
local level = 16

local P4BoulderBadgeQuest = Quest:new()
function P4BoulderBadgeQuest:new()
	local o = Quest.new(P4BoulderBadgeQuest, name, description, level)
	o.checkedForBestPokemon = false
	o.checkedViridianMazePokeball = false
	return o
end

function P4BoulderBadgeQuest:isDoable()
	if not hasItem("Cascade Badge") and self:hasMap()
	then
		return true
	end
	return false
end

function P4BoulderBadgeQuest:isDone()
	return getMapName() == "Pokecenter Route 3"
end

function P4BoulderBadgeQuest:isTrainingOver()
	local heroTrainingIsOver = self:heroTrainingOver()
	if heroTrainingIsOver ~= nil then
		return heroTrainingIsOver
	end

	return getTeamSize() >= 2 and team.getHighestLvl() >= self.level
end

function P4BoulderBadgeQuest:Route2()
	if game.inRectangle(0, 94, 45, 130) then
		sys.debug("quest", "Going to Viridian Forest.")
		return moveToCell(16, 96)
	elseif game.inRectangle(0, 0, 28, 42) then
		self:route2Up()
	end
end

function P4BoulderBadgeQuest:Route2Stop()
	sys.debug("quest", "Going to Viridian Forest.")
	return moveToCell(4, 2)
end

function P4BoulderBadgeQuest:ViridianForest()
	if not self.checkedViridianMazePokeball then
		sys.debug("quest", "Going to get secret Pokemon from Viridian Maze.")
		return moveToCell(19, 38)
	elseif picked_route == 2 then
		if self:needPokecenter() then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(12, 15)
		elseif not self:isTrainingOver() then
			sys.debug("quest", "Going to train Pokemon until they are level " .. self.level .. ".")
			return moveToRectangle(10, 17, 15, 29)
		else
			sys.debug("quest", "Going to Pewter City.")
			return moveToCell(12, 15)
		end
	else
		sys.debug("quest", "Going to Pewter City.")
		return moveToCell(12, 15)
	end
end

function P4BoulderBadgeQuest:ViridianMaze()
	if isNpcOnCell(186, 52) then
		sys.debug("quest", "Going to get secret Pokemon.")
		return talkToNpcOnCell(186, 52)
	else
		sys.debug("quest", "Going to Pewter City.")
		self.checkedViridianMazePokeball = true
		return moveToCell(16, 60)
	end
end

function P4BoulderBadgeQuest:PokecenterViridian()
	if self:shouldHealAtPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return talkToNpcOnCell(9, 15)
	else
		self.heroHealRequested = false
		self.registeredPokecenter = "Pokecenter Viridian"
		return moveToCell(9, 22)
	end
end

function P4BoulderBadgeQuest:ViridianCity()
	sys.debug("quest", "Going to Viridian Maze.")
	return moveToCell(39, 0)
end

function P4BoulderBadgeQuest:Route2Stop2()
	if picked_route == 2 then
		if self:needPokecenter() then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(4, 2)
		elseif not self:isTrainingOver() then
			sys.debug("quest", "Going to train Pokemon until they are level " .. self.level .. ".")
			return moveToCell(4, 12)
		else
			sys.debug("quest", "Going to Pewter City.")
			return moveToCell(4, 2)
		end
	else
		sys.debug("quest", "Going to Pewter City.")
		return moveToCell(4, 2)
	end
end

function P4BoulderBadgeQuest:route2Up()
	if self.registeredPokecenter ~= "Pokecenter Pewter" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(25,0)
	elseif not self:needPokecenter() and not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		if picked_route == 1 then
			return moveToRectangle(10, 12, 16, 12)
		elseif picked_route == 2 then
			return moveToCell(10, 42)
		end
	else
		sys.debug("quest", "Going to Pewter City.")
		return moveToCell(25,0)
	end
end

function P4BoulderBadgeQuest:PewterCity()
	if isNpcOnCell(23, 22) then
		sys.debug("quest", "Going to talk/fight Red blocking the way.")
		return talkToNpcOnCell(23, 22)
	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(37, 26)
	elseif hasItem("Boulder Badge") then
		sys.debug("quest", "Going to Route 3")
		return moveToCell(65, 34)
	elseif self.registeredPokecenter ~= "Pokecenter Pewter"
		or self:needPokecenter()
	then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(24, 35)
	elseif self:isTrainingOver() then
		sys.debug("quest", "Going to fight Brock.")
		return moveToCell(23, 21) --Pewter Gym
	else
		picked_route = math.random(1, 2)
		sys.debug("quest", "Going to train Pokemon until they are level " .. self.level .. ".")
		return moveToCell(16, 55)
	end
end

function P4BoulderBadgeQuest:PewterGym()
	if hasItem("Boulder Badge") then
		sys.debug("quest", "Going to Mt. Moon.")
		return moveToCell(7,14)
	else
		return talkToNpcOnCell(7,5)
	end
end


function P4BoulderBadgeQuest:Route3()
	sys.debug("quest", "Going to Mt. Moon.")
	return moveToCell(79, 21)
end

function P4BoulderBadgeQuest:PokecenterPewter()
	if self:shouldHealAtPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return talkToNpcOnCell(9, 15)
	else
		self.heroHealRequested = false
		self.registeredPokecenter = "Pokecenter Pewter"
		return moveToCell(9, 22)
	end
end

function P4BoulderBadgeQuest:PewterPokemart()
	self:pokemart("Pewter City")
end

return P4BoulderBadgeQuest
