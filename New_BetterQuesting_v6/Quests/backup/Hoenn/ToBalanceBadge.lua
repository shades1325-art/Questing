-- Copyright � 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @WiWi__33[NetPapa]

local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"

local name		  = 'To Balance Badge'
local description = 'Will earn the 4th and the 5th badge'
local level = 0

local ToBalanceBadge = Quest:new()

function ToBalanceBadge:new()
	local o = Quest.new(ToBalanceBadge, name, description, level, dialogs)
	o.relogged = false
	return o
end

function ToBalanceBadge:isDoable()
	if self:hasMap() and not hasItem("Balance Badge") and hasItem("Dynamo Badge") then
		return true
	end
	return false
end

function ToBalanceBadge:isDone()
	if getMapName() == "Petalburg City" and hasItem("Balance Badge") then
		return true
	else
		return false
	end
end

function ToBalanceBadge:LavaridgeTown()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Lavaridge Town" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(20, 12)

	elseif not hasItem("Heat Badge") then
		sys.debug("quest", "Going to get 4th badge.")
		return moveToCell(15, 24)

	else
		sys.debug("quest", "Going to Petalburg City.")
		return moveToCell(43, 16)
	end
end

function ToBalanceBadge:PokecenterLavaridgeTown()
	return self:pokecenter("Lavaridge Town")
end

function ToBalanceBadge:LavaridgeTownGym1F()
	if (game.inRectangle(21, 25, 23, 40) or game.inRectangle(21, 35, 33, 40)) and not hasItem("Heat Badge") then
		sys.debug("quest", "Going to get 4th badge.")
		return moveToCell(21, 26)

	elseif game.inRectangle(25, 24, 33, 33) and not hasItem("Heat Badge") then 
		sys.debug("quest", "Going to get 4th badge.")
		return talkToNpcOnCell(29, 26)

	elseif game.inRectangle(7, 25, 13, 40) or game.inRectangle(7, 37, 18, 40) then
		sys.debug("quest", "Going to get 4th badge.")
		return moveToCell(7, 28)

	elseif game.inRectangle(7, 4, 16, 13) then
		sys.debug("quest", "Going to get 4th badge.")
		return moveToCell(11, 7)

	elseif game.inRectangle(19, 4, 25, 13) then
		sys.debug("quest", "Going to get 4th badge.")
		return moveToCell(25, 13)

	else
		sys.debug("quest", "Going to Petalburg City.")
		return moveToCell(29, 41)
	end	
end


function ToBalanceBadge:LavaridgeTownGymB1F()
	if game.inRectangle(18, 12, 18, 39) or game.inRectangle(4, 31, 18, 40) then
		sys.debug("quest", "Going to get 4th badge.")
		return moveToCell(6, 35)

	elseif game.inRectangle(4, 12, 10, 31) then
		sys.debug("quest", "Going to get 4th badge.")
		return moveToCell(4, 13)

	elseif game.inRectangle(7, 4, 30, 7) then
		sys.debug("quest", "Going to get 4th badge.")
		return moveToCell(16, 5)

	elseif game.inRectangle(22, 12, 25, 36) then
		sys.debug("quest", "Going to get 4th badge.")
		return moveToCell(25, 33)

	end
end

function ToBalanceBadge:Route112()
	if hasItem("Heat Badge") then 
		sys.debug("quest", "Going to Petalburg City.")
		return moveToCell(45, 59)
	else
		sys.debug("quest", "Going to get 4th badge.")
		return moveToCell(0, 59)
	end
end

function ToBalanceBadge:Route111South()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(22, 97)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(20, 7)
	else
		sys.debug("quest", "Going to Mauvile City.")
		return moveToCell(22, 97)
	end
end

function ToBalanceBadge:Route111Desert()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(14, 57)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToRectangle(38, 58, 48, 80)
	else
		sys.debug("quest", "Going to Mauvile City.")
		return moveToCell(14, 57)
	end
end

function ToBalanceBadge:MauvilleCityStopHouse3()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(4, 12)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(4, 2)
	else
		sys.debug("quest", "Going to Petalburg City.")
		return moveToCell(4, 12)
	end
end

function ToBalanceBadge:MauvilleCity()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(28, 13)
	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(29, 23)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(22, 4)
	else
		sys.debug("quest", "Going to Petalburg City.")
		return moveToCell(2, 17)
	end
end

function ToBalanceBadge:PokecenterMauvilleCity()
	return self:pokecenter("Mauville City")
end

function ToBalanceBadge:MartMauvilleCity()
	return self:pokemart()
end

function ToBalanceBadge:MauvilleCityStopHouse2()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(10, 6)
	else
		sys.debug("quest", "Going to Petalburg City.")
		return moveToCell(0, 6)
	end
end

function ToBalanceBadge:Route117()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(101, 32)
	else
		sys.debug("quest", "Going to Petalburg City.")
		return moveToCell(0, 29)
	end
end

function ToBalanceBadge:VerdanturfTown()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(35, 13)
	else
		sys.debug("quest", "Going to Petalburg City.")
		return moveToCell(11, 2)
	end
end

function ToBalanceBadge:RusturfTunnel()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(35, 26)
	else
		sys.debug("quest", "Going to Petalburg City.")
		return moveToCell(11, 19)
	end
end

function ToBalanceBadge:Route116()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(62, 19)
	else
		sys.debug("quest", "Going to Petalburg City.")
		return moveToCell(0, 23)
	end
end

function ToBalanceBadge:RustboroCity()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(78, 12)
	else
		sys.debug("quest", "Going to Petalburg City.")
		return moveToCell(41, 65)
	end
end

function ToBalanceBadge:Route104()
	if game.inRectangle(0, 0, 78, 55) then --top
		if not self:isTrainingOver() then
			sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
			return moveToCell(41, 0)
		else
			sys.debug("quest", "Going to Petalburg City.")
			return moveToCell(24, 51)
		end
	else
		if not self:isTrainingOver() then
			sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
			return moveToCell(36, 79)
		else
			sys.debug("quest", "Going to Petalburg City.")
			return moveToCell(78, 110)
		end
	end
end

function ToBalanceBadge:PetalburgWoods()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(21, 0)
	else
		sys.debug("quest", "Going to Petalburg City.")
		return moveToCell(24, 60)
	end
end

function ToBalanceBadge:PetalburgCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Petalburg City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(27, 22)
	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(34, 16)
	elseif not self:isTrainingOver() then 
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(0, 16)
	elseif isNpcOnCell(19, 12) then
		if self.relogged then
			return talkToNpcOnCell(19, 12)
		else
			self.relogged = true
			return relog(60, "Can't talk to NPC - relogging...")
		end
	else
		sys.debug("quest", "Going to get 5th badge.")
		return moveToCell(19, 11)
	end
end

function ToBalanceBadge:PokecenterPetalburgCity()
	return self:pokecenter("Petalburg City")
end

function ToBalanceBadge:MartPetalburgCity()
	return self:pokemart()
end

function ToBalanceBadge:PetalburgCityGym()
	if isNpcOnCell(73, 104) then -- Norman beginning
		sys.debug("quest", "Going to talk to Norman.")
		talkToNpcOnCell(73, 104)

	elseif game.inRectangle(67, 98, 80, 110) then -- 1st room
		if not hasItem("Balance Badge") then
			sys.debug("quest", "Going to get 5th badge.")
			return moveToCell(77, 100)
		else
			sys.debug("quest", "Going back to Petalburg City.")
			return moveToCell(74, 109)
		end

	elseif game.inRectangle(35, 79, 48, 91) then -- Joey room
		if not hasItem("Balance Badge") then
			if isNpcOnCell(45, 81) then
				sys.debug("quest", "Going to get 5th badge.")
				return talkToNpcOnCell(41, 86)
			else
				sys.debug("quest", "Going to get 5th badge.")
				return moveToCell(45, 81)
			end
		else
			sys.debug("quest", "Going back to Petalburg City.")
			return moveToCell(38, 90)
		end

	elseif game.inRectangle(63, 52, 76, 64) then -- Peter Room
		if not hasItem("Balance Badge") then
			if isNpcOnCell(66, 54) then
				sys.debug("quest", "Going to get 5th badge.")
				return talkToNpcOnCell(70, 58)
			else
				sys.debug("quest", "Going to get 5th badge.")
				return moveToCell(66, 54)
			end
		else
			sys.debug("quest", "Going back to Petalburg City.")
			return moveToCell(66, 63)
		end

	elseif game.inRectangle(34, 25, 47, 37) then -- Stanly Room
		if not hasItem("Balance Badge") then
			if isNpcOnCell(37, 27) then
				sys.debug("quest", "Going to get 5th badge.")
				return talkToNpcOnCell(40, 31)
			else
				sys.debug("quest", "Going to get 5th badge.")
				return moveToCell(37, 27)
			end
		else
			sys.debug("quest", "Going back to Petalburg City.")
			return moveToCell(44, 36)
		end

	elseif game.inRectangle(17, 0, 30, 12) then -- Norman Leader Room
		if not hasItem("Balance Badge") then
			sys.debug("quest", "Going to get 5th badge.")
			return talkToNpcOnCell(23, 4)
		else
			sys.debug("quest", "Going back to Petalburg City.")
			return moveToCell(27, 11)
		end
	end
end

return ToBalanceBadge