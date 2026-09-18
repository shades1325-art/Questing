-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.

local sys    = require "Libs/syslib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'Pallet Town'
local description = 'from PalletTown to Route 1'

local dialogs = {
	mom = Dialog:new({
		"Remember that I love you",
		"glad that you dropped by"
	}),
	oak = Dialog:new({
		"but you can have one",
		"which pokemon do you want"
	}),
	bulbasaur = Dialog:new({
		"grass type Pokemon Bulbasaur",
	}),
	charmander = Dialog:new({
		"fire type Pokemon Charmander",
	}),
	squirtle = Dialog:new({
		"water type Pokemon Squirtle",
	})
}

local P2PalletStartQuest = Quest:new()
function P2PalletStartQuest:new()
	--setting moon fossil, if no none defined
	if not KANTO_STARTER_ID then KANTO_STARTER_ID = math.random(1,4) end
	return Quest.new(P2PalletStartQuest, name, description, _, dialogs)
end

function P2PalletStartQuest:isDoable()
	return not hasItem("Boulder Badge") and self:hasMap() 
end

function P2PalletStartQuest:isDone()
	return getMapName() == "Route 1"
end

function P2PalletStartQuest:PlayerBedroomPallet()
	if getTeamSize() == 0 or hasItem("Pokeball") then
		sys.debug("quest", "Going to get Starter Pokemon.")
		return moveToCell(12, 4)
	else
		if isNpcOnCell(7, 3) then
			sys.debug("quest", "Going to collect item.")
			return talkToNpcOnCell(7, 3)
		elseif isNpcOnCell(6, 3) then
			sys.debug("quest", "Going to collect item.")
			return talkToNpcOnCell(6, 3)
		end
	end
end


function P2PalletStartQuest:PlayerHousePallet()
	if getTeamSize() == 0 or hasItem("Pokeball") then
		sys.debug("quest", "Going to get Starter Pokemon.")
		return moveToCell(4, 10)
	else
		if self.dialogs.mom.state == false then
			sys.debug("quest", "Going to talk to Mother.")
			return talkToNpcOnCell(7, 6)
		else
			sys.debug("quest", "Going to collect items.")
			return moveToCell(12, 3)
		end
	end
end

function P2PalletStartQuest:PalletTown()
	for i = 1, getTeamSize() do
		if getPokemonHeldItem(i) ~= nil then
			sys.debug("quest", "Taking item from " .. getPokemonName(i))
			return takeItemFromPokemon(i)
		end
	end
	if getTeamSize() == 0 then
		sys.debug("quest", "Going to get Starter Pokemon.")
		return moveToCell(22,21)

	elseif not hasItem("Pokeball") then
		sys.debug("quest", "Going to collect items.")
		return moveToCell(6, 12)
	
	else
		if isNpcOnCell(11, 12) then
			sys.debug("quest", "Going to talk to Eevee.")
			return talkToNpcOnCell(11, 12)
		elseif isNpcOnCell(14, 10) then
			sys.debug("quest", "Going to talk to Jackson.")
			return talkToNpcOnCell(14, 10)
		else
			sys.debug("quest", "Going to Route 1.")
			return moveToCell(14, 0)
		end
	end
end

function P2PalletStartQuest:OaksLab()
	if getTeamSize() == 0 then
		if self.dialogs.oak.state == false then
			sys.debug("quest", "Going to talk to Prof. Oak.")
			return talkToNpcOnCell(7, 4) -- Oak
		else
			if KANTO_STARTER_ID == 1 then
				sys.debug("quest", "Going to get Bulbasaur.")
				return talkToNpcOnCell(9, 6)  -- Bulbasaur
			elseif KANTO_STARTER_ID == 2 then
				sys.debug("quest", "Going to get Charmander.")
				return talkToNpcOnCell(10, 6) -- Charmander
			elseif KANTO_STARTER_ID == 3 then
				sys.debug("quest", "Going to get Squirtle.")
				return talkToNpcOnCell(11, 6) -- Squirtle
			elseif KANTO_STARTER_ID == 4 then
				sys.debug("quest", "Going to get Pikachu.")
				if not self.dialogs.bulbasaur.state then
					pushDialogAnswer(2)
					return talkToNpcOnCell(9, 6)  -- bulbasaur
				elseif not self.dialogs.charmander.state then
					pushDialogAnswer(2)
					return talkToNpcOnCell(10, 6) -- charmander
				elseif not self.dialogs.squirtle.state then
					pushDialogAnswer(2)
					return talkToNpcOnCell(11, 6) -- squirtle
				else
					return talkToNpcOnCell(9, 2) -- pikachu
				end
			else
				return fatal("undefined KANTO_STARTER_ID")
			end
		end
	else
		if not hasItem("Pokedex") then
			sys.debug("quest", "Going to talk to Prof. Oak to get the PokeDex.")
			return talkToNpcOnCell(7, 4) -- Oak
		else
			sys.debug("quest", "Going back outside.")
			return moveToCell(7, 12)
		end
	end
end

function P2PalletStartQuest:battle()
	if self:isHeroOnlyMode() then
		return self:battleHeroOnly()
	end

	--if getPokemonHealthPercent(1) < 50 then
		--if useItemOnPokemon("Potion", 1) then
			--return true
		--end
	--end
	return attack()
end

return P2PalletStartQuest
