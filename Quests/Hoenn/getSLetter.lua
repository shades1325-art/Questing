-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @WiWi__33[NetPapa]


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'Get S Letter'
local description = 'We will save Peeko ♥, and get the SLetter from Devon Corp'

local level       = 0

local dialogs = {
	devCheck = Dialog:new({ 
		"Did you get the Devon Goods yet?"
	}),
	Peeko = Dialog:new({
		"I'm so happy that you're alive"
	}),
	Steven = Dialog:new({ 
		"Steven",
	}),
	magmaCheck = Dialog:new({
		"What have we done to you"
	})
}

local getSLetter = Quest:new()

function getSLetter:new()
	return Quest.new(getSLetter, name, description, level, dialogs)
end

function getSLetter:isDoable()
	if getMapName() == "Route 104" and game.inRectangle(0, 74, 78, 148) then
		return false
	elseif hasItem("Stone Badge") and not hasItem("Knuckle Badge") and self:hasMap() then
		return true
	else
		return false
	end
end

function getSLetter:isDone()
	return getMapName() == "Petalburg Woods"
	or (getMapName() == "Route 104" and game.inRectangle(0, 74, 78, 148))
end 

function getSLetter:RustboroCityGym()
	sys.debug("quest", "Going back to Rustboro City.")
	return moveToCell(9, 39)
end	

function getSLetter:RustboroCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Rustboro City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(38, 38)

	elseif isNpcOnCell(52, 20) and not dialogs.devCheck.state then
		sys.debug("quest", "Going to talk to scientist.")
		return talkToNpcOnCell(52, 20) 

	elseif isNpcOnCell(52,20) and  dialogs.devCheck.state and not dialogs.Peeko.state then 
		sys.debug("quest", "Going to Route 116.")
		return moveToCell(78, 11)

	elseif dialogs.Peeko.state and isNpcOnCell(52, 20) then
		sys.debug("quest", "Going to talk to scientist.")
		return talkToNpcOnCell(52, 20)

	elseif not isNpcOnCell(52,20) and not dialogs.Steven.state then
		sys.debug("quest", "Going to Devon Corporation.")
		return moveToCell(34, 11)

	else
		sys.debug("quest", "Going to Route 104.")
		return moveToCell(39, 65)
	end
end

function getSLetter:PokecenterRustboroCity()
	return self:pokecenter("Rustboro City")
end

function getSLetter:Route116()
	if self:needPokecenter() or not dialogs.devCheck.state then 
		sys.debug("quest", "Going to Rustboro City.")
		return moveToCell(0, 20)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToGrass()
	elseif not dialogs.Peeko.state then
		sys.debug("quest", "Going to Rusturf Tunnel.")
		return moveToCell(62, 19)
	else
		sys.debug("quest", "Going to Rustboro City.")
		return moveToCell(0, 20)
	end
end

function getSLetter:RusturfTunnel()
	if isNpcOnCell(18, 8) and not dialogs.magmaCheck.state then
		sys.debug("quest", "Going to fight Magma grunt #1.")
		return talkToNpcOnCell(18, 8)
	elseif isNpcOnCell(19, 9) then 
		sys.debug("quest", "Going to fight Magma grunt #2.")
		return talkToNpcOnCell(19, 9)
	else
		sys.debug("quest", "Going to Rustboro City.")
		return moveToCell(11, 19)
	end
end

function getSLetter:DevonCorporation1F()
	if not dialogs.Steven.state then
		sys.debug("quest", "Going to deliver letter.")
		return moveToCell(20, 3)
	else
		sys.debug("quest", "Going to Rustboro City.")
		return moveToCell(8, 11)
	end
end

function getSLetter:DevonCorporation2F()
	if not dialogs.Steven.state then
		sys.debug("quest", "Going to deliver letter.")
		return moveToCell(6, 3)
	else
		sys.debug("quest", "Going to Rustboro City.")
		return moveToCell(20, 3)
	end
end

function getSLetter:DevonCorporation3F()
	if not dialogs.Steven.state then
		sys.debug("quest", "Going to deliver letter.")
		return talkToNpcOnCell(25, 8)
	else
		sys.debug("quest", "Going to Rustboro City.")
		return moveToCell(6, 3)
	end
end

function getSLetter:Route104()
	if game.inRectangle(0, 0, 78, 56) then
		sys.debug("quest", "Going to Petalburg Woods.")
		return moveToCell(24, 51)
	end		
end	

return getSLetter