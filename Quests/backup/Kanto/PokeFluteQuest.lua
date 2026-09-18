-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Poke Flute'
local description = 'Lavender Town (Pokemon Tower)'

local dialogs = {
	checkFujiHouse = Dialog:new({ 
		"i should check out",
		"I suggest you acquire"
	}),
	checkFujiNote = Dialog:new({
		"go into that tower to check",
		"already read this note"
	})
}

local PokeFluteQuest = Quest:new()

function PokeFluteQuest:new()
	return Quest.new(PokeFluteQuest, name, description, level, dialogs)
end

function PokeFluteQuest:isDoable()
	if self:hasMap() and not hasItem("Soul Badge") then
		return true
	end
	return false
end

function PokeFluteQuest:isDone()
	if (hasItem("Poke Flute") and getMapName() == "Route 12") or getMapName() == "Pokecenter Celadon" then --FIX Blackout 
		return true
	else
		return false
	end
end

function PokeFluteQuest:LavenderTown()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Lavender" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(9, 5)
	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(3, 5)
	elseif dialogs.checkFujiHouse.state and not dialogs.checkFujiNote.state then
		sys.debug("quest", "Going to Fuji's House.")
		return moveToCell(10, 12)
	elseif not hasItem("Poke Flute") then
		sys.debug("quest", "Going to Pokemon Tower.")
		return moveToCell(21, 5)
	else
		sys.debug("quest", "Going to Route 12 - Snorlax.")
		return moveToCell(15, 25)
	end
end

function PokeFluteQuest:PokecenterLavender()
	self:pokecenter("Lavender Town")
end

function PokeFluteQuest:LavenderPokemart()
	self:pokemart("Lavender Town")
end

function PokeFluteQuest:LavenderTownVolunteerHouse()
	if not dialogs.checkFujiNote.state then
		sys.debug("quest", "Checking Fuji's notes.")
		return talkToNpcOnCell(10, 10)
	else
		sys.debug("quest", "Going back to Lavender Town.")
		return moveToCell(5, 12)
	end
end

function PokeFluteQuest:PokemonTower1F()
	if hasItem("Poke Flute") then
		sys.debug("quest", "Going back to Lavender Town.")
		return moveToCell(9, 19)
	else
		sys.debug("quest", "Going to top floor to fight the ghost.")
		return moveToCell(17, 11)
	end
end

function PokeFluteQuest:PokemonTower2F()
	if isNpcOnCell(6, 6) then
		return talkToNpcOnCell(6, 6)
	elseif hasItem("Poke Flute") then
		sys.debug("quest", "Going back to Lavender Town.")
		return moveToCell(17, 13)
	else
		sys.debug("quest", "Going to top floor to fight the ghost.")
		return moveToCell(1, 13)
	end
end

function PokeFluteQuest:PokemonTower3F()
	if hasItem("Poke Flute") then
		sys.debug("quest", "Going back to Lavender Town.")
		return moveToCell(1,13)
	else
		sys.debug("quest", "Going to top floor to fight the ghost.")
		return moveToCell(17,13)
	end
end

function PokeFluteQuest:PokemonTower4F()
	if hasItem("Poke Flute") then
		sys.debug("quest", "Going back to Lavender Town.")
		return moveToCell(17,13)
	else
		sys.debug("quest", "Going to top floor to fight the ghost.")
		return moveToCell(1,13)
	end
end

function PokeFluteQuest:PokemonTower5F()
	if hasItem("Poke Flute") then
		sys.debug("quest", "Going back to Lavender Town.")
		return moveToCell(1,13)
	else
		sys.debug("quest", "Going to top floor to fight the ghost.")
		return moveToCell(17,13)
	end
end

function PokeFluteQuest:PokemonTower6F()
	if hasItem("Poke Flute") then
		sys.debug("quest", "Going back to Lavender Town.")
		return moveToCell(17,13)
	else
		if isNpcOnCell(9,19) then
			sys.debug("quest", "Going to fight the ghost.")
			return talkToNpcOnCell(9,19)
		else
			sys.debug("quest", "Going to top floor to talk to Fuji.")
			return moveToCell(8,19)
		end
	end
end

function PokeFluteQuest:PokemonTower7F()
	if hasItem("Poke Flute") then
		sys.debug("quest", "Going back to Lavender Town.")
		return moveToCell(8,19)
	else
		sys.debug("quest", "Going to talk to Fuji to get the PokeFlute.")
		return talkToNpcOnCell(9,5) -- Fuji NPC - Give PokeFlute
	end
end

return PokeFluteQuest