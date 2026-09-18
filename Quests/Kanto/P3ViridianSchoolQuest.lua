-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.

local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local team   = require "Libs/teamlib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'Viridian School'
local description = 'from Route 1 to Route 2'
local level = 11

local dialogs = {
	jacksonDefeated = Dialog:new({
		"You will not take my spot!",
		"Sorry, the young boy there doesn't want to give his spot, I'm truly sorry..."
	})
}

local P3ViridianSchoolQuest = Quest:new()

function P3ViridianSchoolQuest:new()
local o = Quest.new(P3ViridianSchoolQuest, name, description, level, dialogs)
	o.pokemon = "Poliwag"
	o.pokemonId = 1
	o.forceCaught = false
	o.checkedViridianMaze = false
	o.hasDragonRage = false
	return o
end

function P3ViridianSchoolQuest:isDoable()
	if not hasItem("Boulder Badge") and self:hasMap() then
		return true
	end
	return false
end

function P3ViridianSchoolQuest:isDone()
	return getMapName() == "Route 2" and self.checkedViridianMaze
end

-- necessary, in case of black out we come back to the bedroom
function P3ViridianSchoolQuest:PlayerBedroomPallet()
	sys.debug("quest", "Going back to Route 1.")
	return moveToCell(12, 4)
end

function P3ViridianSchoolQuest:PlayerHousePallet()
	sys.debug("quest", "Going back to Route 1.")
	return moveToCell(4, 10)
end

function P3ViridianSchoolQuest:PalletTown()
	sys.debug("quest", "Going back to Route 1.")
	return moveToCell(14, 0)
end

function P3ViridianSchoolQuest:Route1()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(14, 4)
	else
		sys.debug("quest", "Going to Viridian City.")
		return moveToCell(14, 4)
	end
end

function P3ViridianSchoolQuest:Route1StopHouse()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(4, 2)
	else
		sys.debug("quest", "Going to Viridian City.")
		return moveToCell(4, 2)
	end
end

function P3ViridianSchoolQuest:isTrainingOver()
	-- More flexible training: at least one Pokémon at level 11 is enough
	-- This makes the quest faster
	if team.getHighestLvl() >= self.level then
		return true
	end
	return false
end

function P3ViridianSchoolQuest:ViridianCity()
	if not game.isTeamFullyHealed()
		or self.registeredPokecenter ~= "Pokecenter Viridian" then
		sys.debug("quest", "Going to heal Pokemon")
		return moveToCell(44, 43)

	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs")
		return moveToCell(54, 34)

	-- Visit the school before leaving Viridian City for the northern route.
	-- The previous order sent the quest to Viridian Maze first, which could
	-- leave the player at Route 1/Route 2 without completing the school step.
	elseif not self.dialogs.jacksonDefeated.state and self:isTrainingOver() then
		sys.debug("quest", "Going to Viridian City School before Viridian Forest")
		return moveToCell(48, 34)

	-- Check if we need to get Dragon Rage from Viridian Maze after school.
	elseif not self.checkedViridianMaze and self:isTrainingOver() then
		sys.debug("quest", "Going to Viridian Maze for Dragon Rage")
		return moveToCell(39, 0)

	elseif not self.forceCaught and getTeamSize() < 3 then
		-- Only force catch Poliwag if we have less than 3 Pokémon
		sys.debug("quest", "Going to catch " .. self.pokemon)
		return moveToCell(0, 47)

	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to train Pokemon until they all reached level " .. self.level .. ".")
		return moveToCell(0, 47)

	else
		sys.debug("quest", "Going to do next quest.")
		return moveToCell(39, 0)
	end
end

function P3ViridianSchoolQuest:needPokecenter()
	local lead = 1

	-- More efficient healing: only heal when really needed to save time
	if getPokemonHealthPercent(lead) < 20 then
		return true
	end

	local hasPP = false
	for i = 1, 4 do
		local moveName = getPokemonMoveName(lead, i)
		if moveName and getRemainingPowerPoints(lead, moveName) > 2 then
			hasPP = true
			break
		end
	end

	if not hasPP then
		return true
	end

	return Quest.needPokecenter(self)
end


function P3ViridianSchoolQuest:PokecenterViridian()
	if not game.isTeamFullyHealed() then
		sys.debug("quest", "Going to heal Pokemon.")
		return talkToNpcOnCell(9, 15)
	else
		self.registeredPokecenter = "Pokecenter Viridian"
		return moveToCell(9, 22)
	end
end

function P3ViridianSchoolQuest:ViridianPokemart()
	return self:pokemart("Viridian City")
end

function P3ViridianSchoolQuest:ViridianCitySchool()
	if self.dialogs.jacksonDefeated.state or not self:isTrainingOver() then
		sys.debug("quest", "Going to continue Quest.")
		return moveToCell(4, 13)
	else
		sys.debug("quest", "Going to fight Jackson.")
		return moveToCell(12, 3)
	end
end

function P3ViridianSchoolQuest:ViridianCitySchoolUnderground()
	if self.dialogs.jacksonDefeated.state or not self:isTrainingOver() then
		sys.debug("quest", "Jackson defeated, going to continue Questing.")
		return moveToCell(13, 3)
	elseif not isNpcVisible("Jackson") then
		self.dialogs.jacksonDefeated.state = true
	elseif isNpcOnCell(7, 6) then
		return talkToNpcOnCell(7, 6)
	else
		return talkToNpc("Jackson")
	end	
end

-- The route from Viridian City can arrive on Route 2 directly.  Keep a
-- handler here so the shared Quest:path() dispatcher can finish this quest
-- and let the next quest take over toward Viridian Forest.
function P3ViridianSchoolQuest:Route2()
	if not self.checkedViridianMaze then
		self.checkedViridianMaze = true
		sys.debug("quest", "Route 2 reached after Viridian School; continuing.")
	end
	return true
end

function P3ViridianSchoolQuest:Route22()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(60, 12)
	end

	if not self.forceCaught and getTeamSize() < 3 then
		sys.debug("quest", "Going to catch " .. self.pokemon)
		return moveToRectangle(50, 11, 50, 21)
	end

	if self:isTrainingOver() then
		sys.debug("quest", "Going to continue Quest.")
		return moveToCell(60, 12)
	else
		sys.debug("quest", "Going to train Pokemon until they all reached level " .. self.level .. ".")
		return moveToRectangle(50, 11, 50, 21)
	end
end

function P3ViridianSchoolQuest:ViridianMaze()
	if isNpcOnCell(186, 52) then
		sys.debug("quest", "Getting Dragon Rage from Viridian Maze.")
		self.hasDragonRage = true
		return talkToNpcOnCell(186, 52)
	else
		sys.debug("quest", "Dragon Rage obtained, returning to Viridian City.")
		self.checkedViridianMaze = true
		return moveToCell(16, 60)
	end
end

return P3ViridianSchoolQuest
