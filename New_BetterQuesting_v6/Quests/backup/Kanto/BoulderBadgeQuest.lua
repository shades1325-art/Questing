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

local BoulderBadgeQuest = Quest:new()
function BoulderBadgeQuest:new()
	local o = Quest.new(BoulderBadgeQuest, name, description, level)
	o.checkedForBestPokemon = false
	o.checkedViridianMazePokeball = false
	return o
end

function BoulderBadgeQuest:isDoable()
	if not hasItem("Cascade Badge") and self:hasMap()
	then
		return true
	end
	return false
end

function BoulderBadgeQuest:isDone()
	return getMapName() == "Pokecenter Route 3"
end

function BoulderBadgeQuest:isTrainingOver()
	if getTeamSize() >= 2 and team.getHighestLvl() >= self.level then
		return true
	end
	return false
end

function BoulderBadgeQuest:Route2()
	if game.inRectangle(0, 94, 45, 130) then
		sys.debug("quest", "Going to Viridian Forest.")
		return moveToCell(16, 96)
	elseif game.inRectangle(0, 0, 28, 42) then
		self:route2Up()
	end
end

function BoulderBadgeQuest:Route2Stop()
	sys.debug("quest", "Going to Viridian Forest.")
	return moveToCell(4, 2)
end

function BoulderBadgeQuest:ViridianForest()
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

function BoulderBadgeQuest:ViridianMaze()
	if isNpcOnCell(186, 52) then
		sys.debug("quest", "Going to get secret Pokemon.")
		return talkToNpcOnCell(186, 52)
	else
		sys.debug("quest", "Going to Pewter City.")
		self.checkedViridianMazePokeball = true
		return moveToCell(16, 60)
	end
end

function BoulderBadgeQuest:PokecenterViridian()
	self:pokecenter()
end

function BoulderBadgeQuest:ViridianCity()
	sys.debug("quest", "Going to Viridian Maze.")
	return moveToCell(39, 0)
end

function BoulderBadgeQuest:Route2Stop2()
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

function BoulderBadgeQuest:route2Up()
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

function BoulderBadgeQuest:needPokecenter()
	local lead = 1

	if getPokemonHealthPercent(lead) < 30 then
		return true
	end

	local hasPP = false
	for i = 1, 4 do
		local moveName = getPokemonMoveName(lead, i)
		if moveName and getRemainingPowerPoints(lead, moveName) > 0 then
			hasPP = true
			break
		end
	end

	if not hasPP then
		return true
	end

	return Quest.needPokecenter(self)
end

function BoulderBadgeQuest:PewterCity()
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
		or not game.isTeamFullyHealed()
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

function BoulderBadgeQuest:PewterGym()
	if hasItem("Boulder Badge") then
		sys.debug("quest", "Going to Mt. Moon.")
		return moveToCell(7,14)
	else
		return talkToNpcOnCell(7,5)
	end
end


function BoulderBadgeQuest:Route3()
	sys.debug("quest", "Going to Mt. Moon.")
	return moveToCell(79, 21)
end

function BoulderBadgeQuest:PokecenterPewter()
		self:pokecenter("Pewter City")
end

function BoulderBadgeQuest:PewterPokemart()
	self:pokemart("Pewter City")
end

return BoulderBadgeQuest