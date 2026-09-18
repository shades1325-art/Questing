-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Elite 4 - Kanto'
local description = 'Beat the League'

local dialogs = {
	leaderDone = Dialog:new({ 
		"you defeated me",
		"you may pass",
		"you are amazing",
		"you are strong"
	})
}

local Elite4Kanto = Quest:new()

function Elite4Kanto:new()
	return Quest.new(Elite4Kanto, name, description, level, dialogs)
end

function Elite4Kanto:isDoable()
	return self:hasMap()
end

function Elite4Kanto:isDone()
	if getMapName() == "Indigo Plateau Center" or getMapName() == "Player Bedroom Pallet" then
		return true
	end
	return false
end

function Elite4Kanto:useReviveItems() --Return false if team don't need heal
	if not hasItem("Revive") or not hasItem("Hyper Potion") then
		return false
	end
	for pokemonId=1, getTeamSize(), 1 do
		if getPokemonHealth(pokemonId) == 0 then
			if useItemOnPokemon("Revive", pokemonId) then
				sys.debug("quest", "Revived: " .. getPokemonName(pokemonId))
				return
			end
		end
		if getPokemonHealthPercent(pokemonId) < 80 then
			if useItemOnPokemon("Hyper Potion", pokemonId) then
				sys.debug("quest", "Used Hyper Potion on: " .. getPokemonName(pokemonId))
				return
			end
		end		
	end
	return false
end

function Elite4Kanto:EliteFourLoreleiRoom()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.leaderDone.state then
		sys.debug("quest", "Going to fight Lorelei.")
		return talkToNpcOnCell(20,23) --Lorelei
	else
		sys.debug("quest", "Going to fight Bruno.")
		dialogs.leaderDone.state = false
		return moveToCell(20,13) -- Bruno Room
	end
end

function Elite4Kanto:EliteFourBrunoRoom()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.leaderDone.state then
		sys.debug("quest", "Going to fight Bruno.")
		return talkToNpcOnCell(21,25) --Bruno
	else
		sys.debug("quest", "Going to fight Agatha.")
		dialogs.leaderDone.state = false
		return moveToCell(21,14) -- Agatha Room
	end
end


function Elite4Kanto:EliteFourAgathaRoom()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.leaderDone.state then
		sys.debug("quest", "Going to fight Agatha.")
		return talkToNpcOnCell(20,25) --Agatha
	else
		sys.debug("quest", "Going to fight Lance.")
		dialogs.leaderDone.state = false
		return moveToCell(20,14) -- Lance Room
	end
end

function Elite4Kanto:EliteFourLanceRoom()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.leaderDone.state then
		sys.debug("quest", "Going to fight Lance.")
		return talkToNpcOnCell(21,26) --Lance
	else
		sys.debug("quest", "Going to fight Gary.")
		dialogs.leaderDone.state = false
		return moveToCell(21,15) -- Gary Room
	end
end

function Elite4Kanto:EliteFourChampionRoom()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.leaderDone.state then
		sys.debug("quest", "Going to fight Gary.")
		return talkToNpcOnCell(6,15) --Gary
	else
		sys.debug("quest", "Going to talk to Prof. Oak.")
		return talkToNpcOnCell(6,4) -- Exit Prof.Oak
	end
end

return Elite4Kanto