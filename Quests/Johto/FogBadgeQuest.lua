-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @WiWi__33[NetPaPa]

local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local pc	 = require "Libs/pclib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local luaPokemonData = require "Data/luaPokemonData"

local name		  = 'Fog Badge Quest'
local description = "Earn the 4th Badge"
local level = 0

local dialogs = {
	letter = Dialog:new({ 
		"Please hurry up"
	}),
	suicune = Dialog:new({ 
		"Nothing"
	})
}

local FogBadgeQuest = Quest:new()

function FogBadgeQuest:new()
	local o = Quest.new(FogBadgeQuest, name, description, level, dialogs)
	o.checkedForBestPokemon = false
	return o
end

function FogBadgeQuest:isDoable()
	if self:hasMap() and hasItem("Plain Badge") and not hasItem("Fog Badge") then
		return true
	end
	return false
end

function FogBadgeQuest:isDone()
	if hasItem("Fog Badge") and getMapName() == "Ecruteak Gym" then
		return true
	else
		return false
	end
end

function FogBadgeQuest:GoldenrodCityGym()
	sys.debug("quest", "Going back to Goldenrod City.")
	return moveToCell(4, 18)
end

function FogBadgeQuest:GoldenrodCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Goldenrod" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(64, 47)

	elseif not hasItem("Squirt Bottle") then 
		sys.debug("quest", "Going to get Squirt Bottle for later.")
		return moveToCell(80, 17)

	elseif dialogs.letter.state then 
		if isNpcOnCell(81, 56) then
			sys.debug("quest", "Doing letter quest.")
			return talkToNpcOnCell(81, 56)

		else
			dialogs.letter.state = false
			return moveToCell(69, 11)
		end
	else
		sys.debug("quest", "Going to Route 35 Stop House.")
		return moveToCell(69, 11)
	end
end

function FogBadgeQuest:PokecenterGoldenrod()
	self:pokecenter("Goldenrod City")
end

function FogBadgeQuest:GoldenrodCityFlowerShop()
	if not hasItem("Squirt Bottle") then 
		sys.debug("quest", "Going to get Squirt Bottle.")
		return talkToNpcOnCell(0, 9)
	else
		sys.debug("quest", "Going back to Goldenrod City.")
		return moveToCell(8, 15)
	end
end

function FogBadgeQuest:Route35StopHouse()
	if dialogs.letter.state then 
		sys.debug("Going back to Goldenrod City.")
		return moveToCell(4, 12)
	else
		sys.debug("quest", "Going to Route 35.")
		return moveToCell(4, 2)
	end
end

function FogBadgeQuest:Route35()
	if isNpcOnCell(11, 8) then
		if dialogs.letter.state then 
			sys.debug("quest", "Going back to Goldenrod City.")
			return moveToCell(5, 58)
		else
			sys.debug("quest", "Going to talk to letter NPC.")
			return talkToNpcOnCell(11, 8)
		end
	else
		sys.debug("quest", "Going to National Park.")
		return moveToCell(11, 6)
	end
end

function FogBadgeQuest:NationalParkStopHouse1()
	sys.debug("quest", "Going to National Park.")
	return moveToCell(4, 2)
end

function FogBadgeQuest:NationalPark()
	sys.debug("quest", "Going to Ecruteak City.")
	return moveToCell(62, 32)
end

function FogBadgeQuest:NationalParkStop()
	sys.debug("quest", "Going to Ecruteak City.")
	return moveToCell(10, 7)
end

function FogBadgeQuest:Route36()
	if isNpcOnCell(46, 25) then 
		sys.debug("quest", "Going to wake up Sudowoodo.")
		return talkToNpcOnCell(46, 25)
	else
		sys.debug("quest", "Going to Ecruteak City.")
		return moveToCell(19, 0)
	end
end

function FogBadgeQuest:Route37()
	if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Ecruteak" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(18, 4)
	elseif not self:isTrainingOver() then 
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToGrass()
	end
end

function FogBadgeQuest:EcruteakCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Ecruteak" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(43, 39)
	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(52, 31)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(38, 47)
	elseif isNpcOnCell(22, 40) then 
		sys.debug("quest", "Going to Burned Tower.")
		return moveToCell(22, 9)
	else
		sys.debug("quest", "Going to get Gym badge.")
		return moveToCell(22, 39)
	end
end

function FogBadgeQuest:PokecenterEcruteak()
	--if not self.checkedForBestPokemon then
		--if isPCOpen() then
			--if isCurrentPCBoxRefreshed() then
				--if getCurrentPCBoxSize() ~= 0 then
					--log("Current Box: " .. getCurrentPCBoxId())
					--log("Box Size: " .. getCurrentPCBoxSize())
					--for teamPokemonIndex = 1, getTeamSize() do
						--if pc.getBestPokemonIdFromCurrentBoxFromRegion("Johto") ~= nil then
							--if luaPokemonData[getPokemonName(teamPokemonIndex)]["TotalStats"] < luaPokemonData[getPokemonNameFromPC(getCurrentPCBoxId(), pc.getBestPokemonIdFromCurrentBoxFromRegion("Johto"))]["TotalStats"] then
								--log(string.format("Swapping Team Pokemon %s (Total Stats: %i) with Box %i Pokemon %s (Total Stats: %i)", getPokemonName(teamPokemonIndex), luaPokemonData[getPokemonName(teamPokemonIndex)]["TotalStats"], getCurrentPCBoxId(), getPokemonNameFromPC(getCurrentPCBoxId(), pc.getBestPokemonIdFromCurrentBoxFromRegion("Johto")), luaPokemonData[getPokemonNameFromPC(getCurrentPCBoxId(), pc.getBestPokemonIdFromCurrentBoxFromRegion("Johto"))]["TotalStats"]))
								--return swapPokemonFromPC(getCurrentPCBoxId(), pc.getBestPokemonIdFromCurrentBoxFromRegion("Johto"), teamPokemonIndex)
							--end
						--end
					--end
					--return openPCBox(getCurrentPCBoxId() + 1)
				--else
					--sys.debug("quest", "Checked for best Pokemon from PC.")
					self.checkedForBestPokemon = true
				--end
			--end
		--else
			--sys.debug("quest", "Going to check for better Pokemon in boxes.")
			--return usePC()
		--end
	--else
		self:pokecenter("Ecruteak City")
	--end
end

function FogBadgeQuest:EcruteakMart()
	self:pokemart()
end

function FogBadgeQuest:BurnedTowerTopFloor()
	if isNpcOnCell(17, 13) then 
		sys.debug("quest", "Going to fight Yellow.")
		return talkToNpcOnCell(17, 13)
	elseif not dialogs.suicune.state then 
		sys.debug("quest", "Going to see Suicune.")
		return moveToCell(18, 11)
	elseif game.inRectangle(18, 10, 18, 10) then
		sys.debug("quest", "Going back to Ecruteak City.")
		return moveToCell(17, 10)
	else
		sys.debug("quest", "Going back to Ecruteak City.")
		return moveToCell(11, 18)
	end
end

function FogBadgeQuest:BurnedTowerFloor2()
	if isNpcOnCell(15, 12) then
		sys.debug("quest", "Talking to NPC.")
		return talkToNpcOnCell(15, 12)
	elseif not isNpcOnCell(15, 12) and not dialogs.suicune.state then  
		dialogs.suicune.state = true 
		sys.debug("quest", "Going back to Ecruteak City.")
		return moveToCell(18, 10)
	end
end

function FogBadgeQuest:EcruteakGym()
	sys.debug("quest", "Going to fight Morty for 4th badge.")
	return talkToNpcOnCell(6, 4)
end

return FogBadgeQuest