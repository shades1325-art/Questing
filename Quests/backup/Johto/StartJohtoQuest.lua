-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"

local name		  = 'StartJohtoQuest'
local description = 'Get first Pokemon (Totodile)' --Totodile can Learn Surf and Cut, is perfect for questing
local level = 0

local StartJohtoQuest = Quest:new()

function StartJohtoQuest:new()
	local o = Quest.new(StartJohtoQuest, name, description, level)
	o.pokemonId = 1
	return o
end

function StartJohtoQuest:isDoable()
	if self:hasMap() and not hasItem("Zephyr Badge") then
		return true
	end
	return false
end

function StartJohtoQuest:isDone()
	return getMapName() == "Violet City"
end

function StartJohtoQuest:NewBarkTown()
	if getTeamSize() == 0 then
		sys.debug("quest", "Going to get starter Pokemon.")
		return moveToCell(19, 12)
	elseif getTeamSize() == 1 then
		--if hasItem("Rare Candy") then
			--if useItemOnPokemon("Rare Candy", 1) then
				--sys.debug("quest", "Used Rare Candy on " .. getPokemonName(1) .. ".")
			--end
		--else
			sys.debug("quest", "Going to Route 29.")
			return moveToCell(0, 19)
		--end
	end
end

function StartJohtoQuest:NewBarkTownPlayerHouseBedroom()
	sys.debug("quest", "Going to New Bark Town.")
	return moveToCell(1, 4)
end

function StartJohtoQuest:NewBarkTownPlayerHouse()
	sys.debug("quest", "Going to New Bark Town.")
	return moveToCell(3, 12)
end

function StartJohtoQuest:ProfessorElmsLab()
	if getTeamSize() == 0 then
		sys.debug("quest", "Going to get Totodile.")
		return talkToNpcOnCell(10, 6) --Totodile can Learn Surf and Cut, is perfect for questing
	else
		sys.debug("quest", "Going to New Bark Town.")
		return moveToCell(4, 14)
	end
end

function StartJohtoQuest:Route29()
	if not game.hasPokemonWithMove("Surf") then
		if self.pokemonId <= getTeamSize() then
			useItemOnPokemon("HM03 - Surf", self.pokemonId)
			log("Pokemon: " .. self.pokemonId .. " Try Learning: HM03 - Surf")
			self.pokemonId = self.pokemonId + 1
		else
			fatal("No pokemon in this team can learn Surf")
		end
	elseif not game.hasPokemonWithMove("Cut") then
			if self.pokemonId <= getTeamSize() then
				useItemOnPokemon("HM01 - Cut", self.pokemonId)
				log("Pokemon: " .. self.pokemonId .. " Try Learning: HM01 - Cut")
				self.pokemonId = self.pokemonId + 1
			else
				fatal("No pokemon in this team can learn Cut")
			end
	else
		sys.debug("quest", "Going to Cherrygrove City.")
		return moveToCell(0, 18)
	end
end

function StartJohtoQuest:CherrygroveCity()
	if isNpcOnCell(52, 7) then
		sys.debug("quest", "Going to get a few items from an NPC.")
		return talkToNpcOnCell(52, 7) --Get 5 Pokeballs + 5 Potions + 10000 Money
	elseif self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Cherrygrove City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(51, 6)
	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs..")
		return moveToCell(41, 6)
	else
		sys.debug("quest", "Going to Cherrygrove City.")
		return moveToCell(36, 0) --Route 30
	end
end

function StartJohtoQuest:PokecenterCherrygroveCity()
	self:pokecenter("Cherrygrove City")
end

function StartJohtoQuest:MartCherrygroveCity()
	self:pokemart()
end

function StartJohtoQuest:Route30()
	if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Cherrygrove City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(8, 96) --Cherrygrove City
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToRectangle(17, 82, 20, 88)
	elseif game.tryTeachMove("Cut","HM01 - Cut") == true then
		sys.debug("quest", "Going to Violet City.")
		return moveToCell(13, 0)
	end
end

function StartJohtoQuest:Route31()
	if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Cherrygrove City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(38, 30) --Cherrygrove City
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(38, 30)
	else
		sys.debug("quest", "Going to Violet City.")
		return moveToCell(4, 14)
	end
end

function StartJohtoQuest:VioletCityStopHouse()
	sys.debug("quest", "Going to Violet City.")
	return moveToCell(0, 6)
end

return StartJohtoQuest