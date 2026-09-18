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

local name		  = 'Storm Badge Quest'
local description = 'Will exp to lv 49 and earn the 5th badge'
local level = 0

local dialogs = {
	phare = Dialog:new({ 
		"Please return fast!"
	})
}

local StormBadgeQuest = Quest:new()

function StormBadgeQuest:new()
	o = Quest.new(StormBadgeQuest, name, description, level, dialogs)
	o.checkedForBestPokemon = false
	o.pokemonId = 1
	return o
end

function StormBadgeQuest:isDoable()
	if self:hasMap() and not hasItem("Storm Badge") and hasItem("Fog Badge") then
		return true
	end
	return false
end

function StormBadgeQuest:isDone()
	if hasItem("Storm Badge") and getMapName() == "Cianwood City Gym" then
		return true
	else
		return false
	end
end

function StormBadgeQuest:EcruteakGym()
	sys.debug("quest", "Going back to Ecruteak City.")
	return moveToCell(13, 43)
end

function StormBadgeQuest:EcruteakCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Ecruteak" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(43, 39)
	else
		sys.debug("quest", "Going to Olivine City.")
		return moveToCell(3, 26)
	end
end

function StormBadgeQuest:PokecenterEcruteak()
	self:pokecenter("Ecruteak City")
end

function StormBadgeQuest:EcruteakStopHouse1()
	sys.debug("quest", "Going to Olivine City.")
	return moveToCell(0, 7)
end

function StormBadgeQuest:Route38()
	sys.debug("quest", "Going to Olivine City.")
	return moveToCell(0, 16)
end

function StormBadgeQuest:Route39()
	sys.debug("quest", "Going to Olivine City.")
	return moveToCell(28, 65)
end

function StormBadgeQuest:OlivineCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Olivine Pokecenter" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(13, 32)
	elseif not dialogs.phare.state then 
		sys.debug("quest", "Going to Lighthouse Top.")
		return moveToCell(42, 34)
	else
		sys.debug("quest", "Going to Cianwood City.")
		return moveToCell(0, 36)
	end
end

function StormBadgeQuest:OlivinePokecenter()
	if not self.checkedForBestPokemon then
		self.checkedForBestPokemon = true
	else
		self:pokecenter("Olivine City")
	end
end

function StormBadgeQuest:GlitterLighthouse1F()
	if dialogs.phare.state then 
		sys.debug("quest", "Going back to Olivine City.")
		return moveToCell(8,14)
	else
		sys.debug("quest", "Going to Lighthouse Top.")
		return moveToCell(9,5)
	end
end

function StormBadgeQuest:GlitterLighthouse2F()
	if dialogs.phare.state then 
		if game.inRectangle(10, 3, 15, 7) then
			sys.debug("quest", "Going back to Olivine City.")
			return moveToCell(13, 7)
		else
			sys.debug("quest", "Going back to Olivine City.")
			return moveToCell(9, 12)
		end
	else
		if game.inRectangle(10, 3, 15, 7) then
			sys.debug("quest", "Going to Lighthouse Top.")
			return moveToCell(12, 4)
		else
			sys.debug("quest", "Going to Lighthouse Top.")
			return moveToCell(3, 5)
		end
	end
end

function StormBadgeQuest:GlitterLighthouse3F()
	if dialogs.phare.state then 
		if game.inRectangle(9, 2, 15, 13) or game.inRectangle(1, 10, 15, 13) then
			sys.debug("quest", "Going back to Olivine City.")
			return moveToCell(12, 5)
		else
			sys.debug("quest", "Going back to Olivine City.")
			return moveToCell(3, 5)
		end
	else 
		if game.inRectangle(9, 2, 15, 13) or game.inRectangle(1, 10, 15, 13) then
			sys.debug("quest", "Going to Lighthouse Top.")
			return moveToCell(9, 12)
		else
			sys.debug("quest", "Going to Lighthouse Top.")
			return moveToCell(5, 4)
		end
	end
end

function StormBadgeQuest:GlitterLighthouse4F()
	if dialogs.phare.state then 
		sys.debug("quest", "Going back to Olivine City.")
		return moveToCell(5, 4)
	else
		sys.debug("quest", "Going to Lighthouse Top.")
		return moveToCell(11, 6)
	end
end

function StormBadgeQuest:GlitterLighthouse5F()
	if dialogs.phare.state then 
		sys.debug("quest", "Going back to Olivine City.")
		return moveToCell(11, 11)
	elseif isNpcOnCell(11, 9) then
		sys.debug("quest", "Going to talk to NPC.")
		return talkToNpcOnCell(11, 9)
	end
end

function StormBadgeQuest:Route40()
	if not game.hasPokemonWithMove("Surf") then
		if self.pokemonId < getTeamSize() then
			useItemOnPokemon("HM03 - Surf", self.pokemonId)
			log("Pokemon: " .. self.pokemonId .. " Try Learning: HM03 - Surf")
			self.pokemonId = self.pokemonId + 1
		else
			fatal("No pokemon in this team can learn Surf")
		end
	else
		sys.debug("quest", "Going to Cianwood City.")
		return moveToCell(16, 47)
	end
end

function StormBadgeQuest:Route41()
	sys.debug("quest", "Going to Cianwood City.")
	return moveToCell(0, 8)
end

function StormBadgeQuest:CianwoodCity()
	if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Cianwood" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(24, 47)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToRectangle(29, 9, 30, 52)
	else
		sys.debug("quest", "Going to get 5th badge.")
		return moveToCell(9, 37)
	end
end

function StormBadgeQuest:PokecenterCianwood()
	self:pokecenter("Cianwood City")
end

function StormBadgeQuest:CianwoodCityGym()
	sys.debug("quest", "Going to get 5th badge.")
	return talkToNpcOnCell(32, 15)
end

return StormBadgeQuest