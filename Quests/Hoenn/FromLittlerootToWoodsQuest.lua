-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @WiWi__33[NetPapa]

local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'From Littleroot To Woods Quest'
local description = 'Pick Mudkip as start, and stop at Petalburg Woods'
local level       = 0

local dialogs = {
	profCheck = Dialog:new({ 
		"i gave her a task"
	}),
	jirachiCheck = Dialog:new({
		"JIRACHI"
	}),
	mayCheck = Dialog:new({ 
		"I heard much",
	})
}

local FromLittlerootToWoodsQuest = Quest:new()

function FromLittlerootToWoodsQuest:new()
	return Quest.new(FromLittlerootToWoodsQuest, name, description, level, dialogs)
end

-- The Birch rescue encounter is exposed as a wild battle by the client, but
-- it is required to advance this story quest.
function FromLittlerootToWoodsQuest:isRequiredStoryBattle()
	return getMapName() == "Lab Littleroot Town" and isWildBattle()
end

function FromLittlerootToWoodsQuest:isDoable()
	if getMapName() == "Route 104" and game.inRectangle(2, 0, 74, 54) then
		return false
	elseif not hasItem("Stone Badge") and self:hasMap() then
		return true
	end
	return false
end

function FromLittlerootToWoodsQuest:isDone()
	return getMapName() == "Petalburg Woods" or getMapName() == "Rustboro City" or (getMapName() == "Route 104" and game.inRectangle(2, 0, 74, 54))
end

function FromLittlerootToWoodsQuest:LittlerootTownTruck()
	sys.debug("quest", "Going to Littleroot Town.")
	return moveToCell(5, 8)
end

function FromLittlerootToWoodsQuest:LittlerootTown()
	if getTeamSize() == 0 and not dialogs.profCheck.state then
		sys.debug("quest", "Going to Prof. Birch's House.")
		return moveToCell(27, 17)
	elseif getTeamSize() == 0 and dialogs.profCheck.state then
		sys.debug("quest", "Going to get starter Pokemon.")
		return moveToCell(18, 29)
	else
		sys.debug("quest", "Going to Route 101.")
		return moveToCell(23, 0)
	end
end

function FromLittlerootToWoodsQuest:PlayerHouseLittlerootTown()
	if not dialogs.jirachiCheck.state then 
		sys.debug("quest", "Checking on Jirachi.")
		return moveToCell(11, 5)
	else
		sys.debug("quest", "Going back to Littleroot Town.")
		return moveToCell(11, 12)
	end
end

function FromLittlerootToWoodsQuest:PlayerBedroomLittlerootTown()
	if dialogs.jirachiCheck.state then
		return moveToCell(11, 5)
	elseif isNpcOnCell(6, 8) then 
		return talkToNpcOnCell(6, 8)
	else
		dialogs.jirachiCheck.state = true
	end	
end

function FromLittlerootToWoodsQuest:ProfBirchHouse()
	if isNpcOnCell(10, 8) then 
		sys.debug("quest", "Going to talk to Prof. Birch.")
		return talkToNpcOnCell(10, 8)
	else
		sys.debug("quest", "Going back to Littleroot Town.")
		dialogs.profCheck.state = true
		return moveToCell(11, 12)
	end
end

function FromLittlerootToWoodsQuest:LabLittlerootTown()
	if getTeamSize() == 0 then
		sys.debug("quest", "Going to get Mudkip.")
		return talkToNpcOnCell(10,4) -- mudkip
	else
		--if hasItem("Rare Candy") then
			--return useItemOnPokemon("Rare Candy", 1)
		if not game.hasPokemonWithMove("Surf") then
			return useItemOnPokemon("HM03 - Surf", 1)
		elseif isNpcOnCell(2, 6) then 
			sys.debug("quest", "Going to fight Fiffyen.")
			return talkToNpcOnCell(2, 6)
		else
			sys.debug("quest", "Going back to Littleroot Town.")
			return moveToCell(7, 17)
		end
	end
end

function FromLittlerootToWoodsQuest:Route101()
	sys.debug("quest", "Going to Oldale Town.")
	return moveToCell(23, 0)
end

function FromLittlerootToWoodsQuest:OldaleTown()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Oldale Town" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(16, 26)
	elseif dialogs.mayCheck.state then 
		sys.debug("quest", "Going to Petalburg City.")
		return moveToCell(0, 16)
	else
		sys.debug("quest", "Going to talk to May.")
		return moveToCell(24, 0)
	end
end

function FromLittlerootToWoodsQuest:PokecenterOldaleTown()
	return self:pokecenter("Oldale Town")
end

function FromLittlerootToWoodsQuest:Route103()
	if isNpcOnCell(30, 11) then
		sys.debug("quest", "Going to talk to May.")
		return talkToNpcOnCell(30, 11)
	else
		sys.debug("quest", "Going to Oldale Town.")
		dialogs.mayCheck.state = true
		return moveToCell(29, 35)
	end
end

function FromLittlerootToWoodsQuest:Route102()
	if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Oldale Town" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(83, 17)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToRectangle(61, 5, 66, 7)
	else
		sys.debug("quest", "Going to Petalburg City.")
		return moveToCell(0, 14)
	end
end

function FromLittlerootToWoodsQuest:PetalburgCity()
	if isNpcOnCell(38, 22) then
		sys.debug("quest", "Going to talk to Wally.")
		return talkToNpcOnCell (38, 22)

	elseif self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Petalburg City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(27, 22)

	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(34, 16)

	elseif not self:isTrainingOver() then 
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(0, 18)

	else
		sys.debug("quest", "Going to Route 104.")
		return moveToCell(0, 17)
	end
end

function FromLittlerootToWoodsQuest:PokecenterPetalburgCity()
	return self:pokecenter("Petalburg City")
end

function FromLittlerootToWoodsQuest:MartPetalburgCity()
	self:pokemart()
end

function FromLittlerootToWoodsQuest:Route104()
	if game.inRectangle(0, 76, 78, 148) then
		if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Petalburg City" then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(78, 112)
		else
			if not self:isTrainingOver() then
				sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
				return moveToRectangle(30, 91, 42, 93)
			else
				sys.debug("quest", "Going to Petalburg Woods.")
				return moveToCell(35, 79)
			end
		end
	end
end	

return FromLittlerootToWoodsQuest
