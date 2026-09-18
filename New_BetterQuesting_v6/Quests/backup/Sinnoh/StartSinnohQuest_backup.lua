-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local team   = require "Libs/teamlib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'Start Sinnoh Quest'
local description = 'Get first Pokemon and go to Jubilife City'
local level       = 0

local dialogs = {
	aDialogInstance = Dialog:new({
		"This is a dialog you can see in game",
		"And another one. It works only with game dialogs, not chat or popup",
		"e" -- would match any dialog with a 'e' in it
	})
}

local StartSinnohQuest = Quest:new()
function StartSinnohQuest:new()
	local o = Quest.new(StartSinnohQuest, name, description, level, dialogs)
	o.pokemonId = 1
	return o
end

function StartSinnohQuest:isDoable()
	if self:hasMap() and not hasItem("Coal Badge") then
		return true
	end
	return false
end

function StartSinnohQuest:isDone()
	return getMapName() == "Jubilife city"
end

function StartSinnohQuest:TwinleafTownPlayerHouse2F()
	if getTeamSize() == 0 then
		sys.debug("quest", "Going to get starter Pokemon.")
		return moveToCell(8, 4)
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
--[[
	Adding Maps
	
	A Quest is divided by maps. Anytime the onPathAction is executed, the
	function matching the map name will be called.
	To write a function matching a map name, simply write the name of the map
	and remove the spaces and dots.
	For instance, the map "Player House Pallet" uses the function:
		function TemplateQuest:PlayerHousePallet() end
		
	This behaviour can be changed by overloading the Quest:path() function.
--]]

-- The following is an example of maps functions from ViridianSchoolQuest.lua

function TemplateQuest:PlayerBedroomPallet()
	return moveToMap("Player House Pallet")
end

function TemplateQuest:PlayerHousePallet()
	return moveToMap("Player Bedroom Pallet")
end

function TemplateQuest:PalletTown()
	return moveToMap("Route 1")
end

function TemplateQuest:Route1()
	if getTeamSize() == 1 and getPokemonHealthPercent(1) < 50 then
		if useItemOnPokemon("Potion", 1) then
			return true
		end
	end
	return moveToMap("Route 1 Stop House")
end

function TemplateQuest:Route1StopHouse()
	return moveToMap("Viridian City")
end

-- a simple method to divide our code and avoid duplication
function TemplateQuest:isReadyForJackson()
	if getTeamSize() >= 2 and team.getLowestLvl() >= 8 then
		return true
	end
	return false
end

function TemplateQuest:ViridianCity()
	if not game.isTeamFullyHealed()
		or self.registeredPokecenter ~= "Pokecenter Viridian" then
		return moveToMap("Pokecenter Viridian")
	elseif getItemQuantity("Pokeball") < 50 and getMoney() >= 200 then
		return moveToMap("Viridian Pokemart")
	elseif not self.dialogs.jacksonDefeated.state
		and self:isReadyForJackson() then
		return moveToMap("Viridian City School")
	elseif not self:isReadyForJackson() then
		return moveToMap("Route 22")
	else
		return moveToMap("Route 2")
	end
end


-- We call the pokecenter mehod of the Quest class that will heal the pokemon
-- if needed and leave the pokecenter
function TemplateQuest:PokecenterViridian()
	self:pokecenter("Viridian City") -- we still need to pass the exit map
end

-- Example of Pokemart script.
-- This will likely be improved in futur versions.
-- Currently there is no method to facilate the buy of items.
function TemplateQuest:ViridianPokemart()
	local pokeballCount = getItemQuantity("Pokeball")
	local money         = getMoney()
	if money >= 200 and pokeballCount < 50 then
		if not isShopOpen() then
			return talkToNpcOnCell(3,5)
		else
			local pokeballToBuy = 50 - pokeballCount
			local maximumBuyablePokeballs = money / 200
			if maximumBuyablePokeballs < pokeballToBuy then
				pokeballToBuy = maximumBuyablePokeballs
			end
			return buyItem("Pokeball", pokeballToBuy)
		end
	else
		return moveToMap("Viridian City")
	end
end

-- End of maps functions

-- This is necessary for the require keyword to catch a value
-- See QuestManager.lua
return TemplateQuest
