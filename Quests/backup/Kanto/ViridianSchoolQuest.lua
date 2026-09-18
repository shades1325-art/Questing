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

local ViridianSchoolQuest = Quest:new()

function ViridianSchoolQuest:new()
local o = Quest.new(ViridianSchoolQuest, name, description, level, dialogs)
	o.pokemon = "Poliwag"
	o.pokemonId = 1
	o.forceCaught = false
	return o
end

function ViridianSchoolQuest:isDoable()
	if not hasItem("Boulder Badge") and self:hasMap() then
		return true
	end
	return false
end

function ViridianSchoolQuest:isDone()
	return getMapName() == "Route 2"
end

-- necessary, in case of black out we come back to the bedroom
function ViridianSchoolQuest:PlayerBedroomPallet()
	sys.debug("quest", "Going back to Route 1.")
	return moveToCell(12, 4)
end

function ViridianSchoolQuest:PlayerHousePallet()
	sys.debug("quest", "Going back to Route 1.")
	return moveToCell(4, 10)
end

function ViridianSchoolQuest:PalletTown()
	sys.debug("quest", "Going back to Route 1.")
	return moveToCell(14, 0)
end

function ViridianSchoolQuest:Route1()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(14, 4)
	else
		sys.debug("quest", "Going to Viridian City.")
		return moveToCell(14, 4)
	end
end

function ViridianSchoolQuest:Route1StopHouse()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(4, 2)
	else
		sys.debug("quest", "Going to Viridian City.")
		return moveToCell(4, 2)
	end
end

function ViridianSchoolQuest:isTrainingOver()
	if getTeamSize() >= 2 and team.getHighestLvl() >= self.level then
		return true
	end
	return false
end

function ViridianSchoolQuest:ViridianCity()
	if not game.isTeamFullyHealed()
		or self.registeredPokecenter ~= "Pokecenter Viridian" then
		sys.debug("quest", "Going to heal Pokemon")
		return moveToCell(44, 43)

	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs")
		return moveToCell(54, 34)

	elseif not self.dialogs.jacksonDefeated.state and self:isTrainingOver() then
		sys.debug("quest", "Going to fight Jackson")
		return moveToCell(48, 34)

	elseif not self.forceCaught then
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

function ViridianSchoolQuest:needPokecenter()
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


function ViridianSchoolQuest:PokecenterViridian()
	self:pokecenter("Viridian City")
end

function ViridianSchoolQuest:ViridianPokemart()
	return self:pokemart("Viridian City")
end

function ViridianSchoolQuest:ViridianCitySchool()
	if self.dialogs.jacksonDefeated.state or not self:isTrainingOver() then
		sys.debug("quest", "Going to continue Quest.")
		return moveToCell(4, 13)
	else
		sys.debug("quest", "Going to fight Jackson.")
		return moveToCell(12, 3)
	end
end

function ViridianSchoolQuest:ViridianCitySchoolUnderground()
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

function ViridianSchoolQuest:Route22()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(60, 12)
	end

	if not self.forceCaught then
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


return ViridianSchoolQuest