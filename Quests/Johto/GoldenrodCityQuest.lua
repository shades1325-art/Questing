-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local luaPokemonData = require "Data/luaPokemonData"

local name		  = 'Goldenrod City'
local description = " Complete Guard's Quest"
local level = 0

local dialogs = {
	martElevatorFloorB1F = Dialog:new({
		"on the underground"
	}),
	martElevatorFloor1 = Dialog:new({
		"the first floor"
	}),
	martElevatorFloor2 = Dialog:new({
		"the second floor"
	}),
	martElevatorFloor3 = Dialog:new({
		"the third floor"
	}),
	martElevatorFloor4 = Dialog:new({
		"the fourth floor"
	}),
	martElevatorFloor5 = Dialog:new({
		"the fifth floor"
	}),
	martElevatorFloor6 = Dialog:new({
		"the sixth floor"
	}),
	directorQuestPart1 = Dialog:new({
		"there is nothing to see here"
	}),
	guardQuestPart1 = Dialog:new({
		"any information on his whereabouts"
	}),
	guardQuestPart2 = Dialog:new({
		"where did you find him",
		"he might be able to help"
	})
}

local GoldenrodCityQuest = Quest:new()

function GoldenrodCityQuest:new()
	local o = Quest.new(GoldenrodCityQuest, name, description, level, dialogs)
	o.need_caterpie = false
	o.gavine_done = false
	o.checkCrate1 = false
	o.checkCrate2 = false
	o.checkCrate3 = false
	o.checkCrate4 = false
	o.checkCrate5 = false
	o.checkCrate6 = false
	o.checkCrate7 = false
	return o
end

function GoldenrodCityQuest:isDoable()
	if self:hasMap() and not hasItem("Rain Badge") then
		if getMapName() == "Goldenrod City" then
			return isNpcOnCell(48, 34)
		else
			return true
		end
	end
	return false
end

function GoldenrodCityQuest:isDone()
	if getMapName() == "Goldenrod City" and not isNpcOnCell(50, 34) or (getMapName() == "Ilex Forest") then
		return true
	end
	return false
end

function GoldenrodCityQuest:getWeakestTeamMember()
	local weakestPokemon = 1 -- assume first in team is weakest

	for i = 1, getTeamSize() do
		if luaPokemonData[getPokemonName(i)]["TotalStats"] < luaPokemonData[getPokemonName(weakestPokemon)]["TotalStats"] then
			weakestPokemon = i
		end
	end

	return weakestPokemon
end

function GoldenrodCityQuest:PokecenterGoldenrod()
	if self.need_caterpie then
		if hasPokemonInTeam("Caterpie") or hasPokemonInTeam("Metapod") or hasPokemonInTeam("Butterfree") then
			self.need_caterpie = false
		else
			log("Caterpie/Metapod/Butterfree with Johto Region NOT FOUND, Next quest: llexForestQuest.lua")
			return self:pokecenter("Goldenrod City")
		end
		
	-- Get Caterpie From PC
	elseif hasItem("Basement Key") and not hasItem("Squirt Bottle") and dialogs.guardQuestPart2.state then
		if not hasPokemonInTeam("Caterpie") or not hasPokemonInTeam("Metapod") or not hasPokemonInTeam("Butterfree") then
			if isPCOpen() then
				if isCurrentPCBoxRefreshed() then
					if getCurrentPCBoxSize() ~= 0 then
						for pokemon = 1, getCurrentPCBoxSize() do
							if getPokemonNameFromPC(getCurrentPCBoxId(), pokemon) == "Caterpie" and getPokemonRegionFromPC(getCurrentPCBoxId(), pokemon) == "Johto" then
								log(string.format("LOG: %s found in Box #%i. Swapping with Team Member %s", getPokemonNameFromPC(getCurrentPCBoxId(), pokemon), getCurrentPCBoxId(), getPokemonName(self:getWeakestTeamMember())))
								return swapPokemonFromPC(getCurrentPCBoxId(), pokemon, self:getWeakestTeamMember()) --swap the pokemon with the weakest pokemon in team
							end
						end
						return openPCBox(getCurrentPCBoxId() + 1)
					else
						self.need_caterpie = true
					end
				end
			else
				return usePC()
			end
	--END get Metapod or Butterfree
		else
			self:pokecenter("Goldenrod City")
		end
	else
		self:pokecenter("Goldenrod City")
	end
end

function GoldenrodCityQuest:GoldenrodCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Goldenrod" then
		sys.debug("Quest", "Going to heal Pokemon.")
		return moveToCell(64, 47)

	elseif self.need_caterpie then
		sys.debug("quest", "Going to catch Caterpie.")
		return moveToCell(68, 62)

	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to train Pokemon until Level " .. self.level .. ".")
		return moveToCell(67, 62)

	elseif not isNpcOnCell(48, 34) then
		sys.debug("quest", "Going to talk to Whitney..")
		return talkToNpcOnCell(50, 34)

	elseif hasItem("Basement Key") and not hasItem("Squirt Bottle") and dialogs.guardQuestPart2.state then --get Metapod on PC and start leveling
		if not game.hasPokemonWithMove("Sleep Powder") then
			if hasPokemonInTeam("Caterpie") or hasPokemonInTeam("Metapod") or hasPokemonInTeam("Butterfree") then
				if getPokemonLevel(game.hasPokemonWithName("Butterfree")) > 12 then
					sys.debug("quest", "Going to teach Butterfree Sleep Power with Move Relearner.")
					if isRelearningMoves() then
						return relearnMove("Sleep Powder")
					else
						pushDialogAnswer(1)
						pushDialogAnswer(game.hasPokemonWithName("Butterfree"))
						return talkToNpcOnCell(66, 40)
					end
				else
					sys.debug("quest", "Going to train Caterpie until Sleep Powder.")
					return moveToCell(67, 62) -- route 34
				end

			else
				sys.debug("quest", "Going to check if we have a Caterpie in box.")
				return moveToCell(64, 47) -- pokecenter goldenrod

			end
		else

			sys.debug("quest", "Going to Goldenrod Mart 1.")
			return moveToCell(75, 47)
		end

	elseif isNpcOnCell(48, 34) then
		if dialogs.guardQuestPart2.state then
			if hasItem("Basement Key") then
				-- ???

			else
				sys.debug("quest", "Going to talk to Michael.")
				return moveToCell(84, 42)

			end

		elseif dialogs.guardQuestPart1.state then
			sys.debug("quest", "Going to Goldenrod Underground Entrance Top.")
			return moveToCell(54, 16)

		else
			sys.debug("quest", "Going to talk to Sergeant Raul.")
			pushDialogAnswer(2)
			return talkToNpcOnCell(48, 34)

		end
	end
end

function GoldenrodCityQuest:Route34()
	if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Goldenrod" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(13, 0)

	elseif self.need_caterpie then
		sys.debug("quest", "Going to catch Caterpie.")
		return moveToCell(24, 64)

	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToGrass()

	else
		sys.debug("quest", "Going back to Goldenrod City.")
		return moveToCell(13, 0)

	end
end

function GoldenrodCityQuest:Route34StopHouse()
	if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Goldenrod" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(3, 2)
	elseif self.need_caterpie then
		sys.debug("quest", "Going to catch Caterpie.")
		return moveToCell(3, 12)
	else
		sys.debug("quest", "Going back to Goldenrod City.")
		return moveToCell(3, 2)
	end
end

function GoldenrodCityQuest:GoldenrodUndergroundEntranceTop()
	dialogs.guardQuestPart1.state = false
	if dialogs.directorQuestPart1.state or self.gavin_done then
		sys.debug("quest", "Going back to Goldenrod City.")
		return moveToCell(5, 10)
	else
		sys.debug("quest", "Going to Goldenrod Underground.")
		return moveToCell(9, 3)
	end

end

function GoldenrodCityQuest:GoldenrodUndergroundPath()
	if not isNpcOnCell(17,10) then
		if not self.gavin_done then
			sys.debug("quest", "Going to Goldenrod Underground Basement.")
			return moveToCell(17, 9)
		else
			sys.debug("quest", "Going to Goldenrod Underground Entrance Top.")
			return moveToCell(1, 3)
		end
	elseif dialogs.directorQuestPart1.state then
		sys.debug("quest", "Going to Goldenrod Underground Entrance Top.")
		return moveToCell(1, 3)
	else
		sys.debug("quest", "Going to talk to Radio Director Gavin.")
		return talkToNpcOnCell(17,10)
	end
end

function GoldenrodCityQuest:GoldenrodCityHouse2()
	if not hasItem("Basement Key") then
		sys.debug("quest", "Going to talk to Michael.")
		return talkToNpcOnCell(9,5)
	else
		sys.debug("quest", "Going back to Goldenrod City.")
		return moveToCell(5, 10)
	end
end

function GoldenrodCityQuest:GoldenrodMartElevator()
	if not hasItem("Fresh Water") then
		if not dialogs.martElevatorFloor6.state then
			pushDialogAnswer(5)
			pushDialogAnswer(3)
			return talkToNpcOnCell(1,6)
		else
			dialogs.martElevatorFloor6.state = false
			return moveToCell(3,6)
		end
	elseif hasItem("Basement Key") and not hasItem("Squirt Bottle") and game.hasPokemonWithMove("Sleep Powder") and dialogs.guardQuestPart2.state then
		if not dialogs.martElevatorFloorB1F.state then
			pushDialogAnswer(1)
			return talkToNpcOnCell(1,6)
		else
			dialogs.martElevatorFloorB1F.state = false
			return moveToCell(3,6)
		end
	else
		if not dialogs.martElevatorFloor1.state then
			pushDialogAnswer(2)
			return talkToNpcOnCell(1,6)
		else
			dialogs.martElevatorFloor1.state = false
			return moveToCell(3,6)
		end
	end
end

function GoldenrodCityQuest:GoldenrodMart1()
	if not hasItem("Fresh Water") then
		sys.debug("quest", "Going to buy Fresh Water.")
		return moveToCell(18, 2)
	elseif hasItem("Basement Key") and not hasItem("Squirt Bottle") and game.hasPokemonWithMove("Sleep Powder") and dialogs.guardQuestPart2.state then
		sys.debug("quest", "Going to do quest.")
		return moveToCell(18, 2)
	else
		sys.debug("quest", "Going back to Goldenrod City.")
		return moveToCell(11, 11)
	end
end

function GoldenrodCityQuest:GoldenrodMart6()
	if not hasItem("Fresh Water") then
		if not isShopOpen() then
			return talkToNpcOnCell(11, 3)
		else
			if getMoney() > 1000 then
				return buyItem("Fresh Water", 5)
			else
				return buyItem("Fresh Water",(getMoney()/200))
			end
		end
	else
		return moveToCell(18, 2)
	end
end

function GoldenrodCityQuest:GoldenrodMartB1F()
	if hasItem("Basement Key") and not hasItem("Squirt Bottle") and dialogs.guardQuestPart2.state and game.hasPokemonWithMove("Sleep Powder") then
		if isNpcOnCell(13,8) then
			pushDialogAnswer(2)
			if game.hasPokemonWithName("Butterfree")  then
				pushDialogAnswer(game.hasPokemonWithName("Butterfree"))
			else
				fatal("Error . - No Metapod or Butterfree in this team")
			end
			sys.debug("quest", "Going to talk to Security Officer Eric.")
			return talkToNpcOnCell(13,8)
		else
			sys.debug("quest", "Going to Underground Warehouse.")
			return moveToCell(15, 4)
		end
	else
		sys.debug("quest", "Going back to Goldenrod City.")
		return moveToCell(8, 5)
	end
end

function GoldenrodCityQuest:UndergroundWarehouse()
	if not self.checkCrate1 then --Marill Crate
		if getPlayerX() == 23 and getPlayerY() == 12 then
			sys.debug("quest", "Checking on Marill.")
			talkToNpcOnCell(23,13)
			self.checkCrate1 = true
			return
		else
			return moveToCell(23,12)
		end
	elseif not self.checkCrate2 then --Miltank Crate
		if getPlayerX() == 20 and getPlayerY() == 9 then
			sys.debug("quest", "Checking on Miltank.")
			talkToNpcOnCell(20,8)
			self.checkCrate2 = true
			return
		else
			return moveToCell(20,9)
		end
	elseif not self.checkCrate3 then --Abra Crate
		if getPlayerX() == 16 and getPlayerY() == 12 then
			sys.debug("quest", "Checking on Abra.")
			talkToNpcOnCell(15,12)
			self.checkCrate3 = true
			return
		else
			return moveToCell(16,12)
		end
	elseif not self.checkCrate4 then --Meowth Crate
		if getPlayerX() == 19 and getPlayerY() == 17 then
			sys.debug("quest", "Checking on Meowth.")
			talkToNpcOnCell(19,16)
			self.checkCrate4 = true
			return
		else
			return moveToCell(19,17)
		end
	elseif not self.checkCrate5 then --Heracross Crate
		if getPlayerX() == 24 and getPlayerY() == 22 then
			sys.debug("quest", "Checking on Heracross.")
			talkToNpcOnCell(24,23)
			self.checkCrate5 = true
			return
		else
			return moveToCell(24,22)
		end
	elseif not self.checkCrate6 then --Snubbull Crate
		if getPlayerX() == 13 and getPlayerY() == 24 then
			sys.debug("quest", "Checking on Snubbull.")
			talkToNpcOnCell(12,24)
			self.checkCrate6 = true
			return
		else
			return moveToCell(13,24)
		end
	elseif not self.checkCrate7 then --Item: Great Balls
		if getPlayerX() == 5 and getPlayerY() == 8 then
			sys.debug("quest", "Checking on Great Balls.")
			talkToNpcOnCell(5,7)
			self.checkCrate7 = true
			return
		else
			return moveToCell(5,8)
		end
	else
		self.checkCrate1 = false
		self.checkCrate2 = false
		self.checkCrate3 = false
		self.checkCrate4 = false
		self.checkCrate5 = false
		self.checkCrate6 = false
		self.checkCrate7 = false
		return moveToCell(7,18)
	end
end

function GoldenrodCityQuest:GoldenrodUndergroundBasement()
	-- BASEMENT LEVELRS PUZZLE
	if not isNpcOnCell(5,4) then
		dialogs.guardQuestPart2.state = false
		self.gavin_done = true
		if isNpcOnCell(9,18) then
			return talkToNpcOnCell(8,19)
		elseif isNpcOnCell(18,12) then
			return talkToNpcOnCell(17,13)
		else
			sys.debug("quest", "Going to Goldenrod Underground Path.")
			return moveToCell(38, 4)
		end
	elseif isNpcOnCell(18,12) and isNpcOnCell(22,16) and isNpcOnCell(18,18) and isNpcOnCell(13,16) and isNpcOnCell(9,12) and isNpcOnCell(9,18) and isNpcOnCell(4,16) and isNpcOnCell(4,10) then --Lever A
		return talkToNpcOnCell(26,13)
	elseif not isNpcOnCell(18,12) and isNpcOnCell(22,16) and isNpcOnCell(18,18) and isNpcOnCell(13,16) and isNpcOnCell(9,12) and not isNpcOnCell(9,18) and isNpcOnCell(4,16) and isNpcOnCell(4,10) then --Lever C
		return talkToNpcOnCell(17,13)
	elseif isNpcOnCell(18,12) and isNpcOnCell(22,16) and isNpcOnCell(18,18) and not isNpcOnCell(13,16) and isNpcOnCell(9,12) and not isNpcOnCell(9,18) and isNpcOnCell(4,16) and isNpcOnCell(4,10) then --Lever D
		return talkToNpcOnCell(17,17)
	elseif isNpcOnCell(18,12) and not isNpcOnCell(22,16) and isNpcOnCell(18,18) and not isNpcOnCell(13,16) and not isNpcOnCell(9,12) and not isNpcOnCell(9,18) and isNpcOnCell(4,16) and isNpcOnCell(4,10) then --Lever C
		return talkToNpcOnCell(17,13)
	elseif not isNpcOnCell(18,12) and not isNpcOnCell(22,16) and isNpcOnCell(18,18) and isNpcOnCell(13,16) and not isNpcOnCell(9,12) and not isNpcOnCell(9,18) and isNpcOnCell(4,16) and isNpcOnCell(4,10) then --Lever B
		return talkToNpcOnCell(26,17)
	elseif not isNpcOnCell(18,12) and not isNpcOnCell(22,16) and isNpcOnCell(18,18) and isNpcOnCell(13,16) and isNpcOnCell(9,12) and not isNpcOnCell(9,18) and not isNpcOnCell(4,16) and isNpcOnCell(4,10) then --Lever C
		return talkToNpcOnCell(17,13)
	elseif isNpcOnCell(18,12) and not isNpcOnCell(22,16) and isNpcOnCell(18,18) and not isNpcOnCell(13,16) and isNpcOnCell(9,12) and not isNpcOnCell(9,18) and not isNpcOnCell(4,16) and isNpcOnCell(4,10) then --Lever C
		return talkToNpcOnCell(8,19)
	elseif isNpcOnCell(18,12) and not isNpcOnCell(22,16) and isNpcOnCell(18,18) and not isNpcOnCell(13,16) and isNpcOnCell(9,12) and isNpcOnCell(9,18) and not isNpcOnCell(4,16) and not isNpcOnCell(4,10) then	--Lever C
		if game.inRectangle(19,0,40,20) then
			return talkToNpcOnCell(26,13) --Leveler A
		else
			if isNpcOnCell(8,8) then --TM62 - Taunt
				return talkToNpcOnCell(8,8)
			elseif isNpcOnCell(5,4) then --Galvin Director
				return talkToNpcOnCell(5,4)
			else
				fatal("Error GoldenrodCityQuest:GoldenrodUndergroundBasement()")
			end
		end
	elseif not isNpcOnCell(18,12) and not isNpcOnCell(22,16) and isNpcOnCell(18,18) and not isNpcOnCell(13,16) and isNpcOnCell(9,12) and not isNpcOnCell(9,18) and not isNpcOnCell(4,16) and not isNpcOnCell(4,10) then	--Lever C
		if isNpcOnCell(5,4) then --Galvin Director
			return talkToNpcOnCell(5,4)
		else
			fatal("Error GoldenrodCityQuest:GoldenrodUndergroundBasement()")
		end
	else
		fatal("Error ON PUZZLE RESOLUTION  GoldenrodCityQuest:GoldenrodUndergroundBasement()")
	end
end

return GoldenrodCityQuest