-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local team   = require "Libs/teamlib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'ThirdBadgeQuest'
local description = 'Get the 3rd badge. Doing all related quest from Rt206 to end of VeilStone City.'
local level       = 0

local dialogs = {
	SandyRequest = Dialog:new({
		"xxx",
        "xxx",
        "xxx",
	}),
    GalaticGrunt = Dialog:new({
		"xxx",
	}),
    RescueMission = Dialog:new({
		"xxx",
        "xxx",
	}),
}

local ThirdBadgeQuest = Quest:new()

function ThirdBadgeQuest:new()
	local o = Quest.new(ThirdBadgeQuest, name, description, level, dialogs)
	o.pokemonId = 1
    --o.dialogs.SandyRequest.state = false
    o.ex = 0
	return o
end

function ThirdBadgeQuest:isDoable()
	if self:hasMap() and not hasItem("Cobble Badge") then
		return true
	end
	return false
end

function ThirdBadgeQuest:isDone()
	if hasItem("Cobble Badge") and getMapName("Pastoria City") then --fix blackout
		return true
	end
end

function ThirdBadgeQuest:Route206()
    if game.inRectangle(0, 0, 33, 107) then
        sys.debug("quest", "Going to Route 205.")
        return moveToCell(16, 107)
    elseif game.inRectangle(0, 112, 33, 130) then
        sys.debug("quest", "Going to Route 205.")
        return moveToCell(17, 130)
    end
end

function ThirdBadgeQuest:Route206StopHouse()
    return moveToCell(3, 12)
end

function ThirdBadgeQuest:Route207()
    return moveToCell(56, 6)
end

function ThirdBadgeQuest:Route208StopHouse()
    return moveToCell(10, 6)
end

function ThirdBadgeQuest:Route209StopHouse()
    return moveToCell(10, 6)
end

function ThirdBadgeQuest:Route208()
    return moveToCell(67, 26)
end

function ThirdBadgeQuest:Route209()
    return moveToCell(78, 0)
end

function ThirdBadgeQuest:SolaceonTown()
    return moveToCell(18, 0)
end

function ThirdBadgeQuest:Route210()
    return moveToCell(40, 45)
end

function ThirdBadgeQuest:Route215()
    return moveToCell(119, 24)
end

function ThirdBadgeQuest:Route215StopHouse()
    return moveToCell(10, 6)
end

function ThirdBadgeQuest:HearthomeCity()
    if isNpcOnCell(57, 42) then
        return talkToNpcOnCell(57, 42)
    else
        return moveToCell(58, 42)
    end
end

function ThirdBadgeQuest:MtCoronetSouth()
    if isNpcOnCell(12, 20) then
        return talkToNpcOnCell(12, 20)
    else
        return moveToCell(30, 18)
    end
end

function ThirdBadgeQuest:VeilstoneCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Veilstone Pokecenter" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(46, 31)
    end
    if self.ex == 0 then
        sys.debug("quest", "Going to get 3rd Badge.")
        self.ex = 0.1
        return talkToNpcOnCell(12, 32)
    elseif self.ex == 0.1 then
        self.ex = 0.2
        return moveToCell(12, 31)
    end
end

function ThirdBadgeQuest:VeilstoneGym()
    if self.ex == 0.2 then
        self.ex = 0.3
        return talkToNpcOnCell(12, 23)
    elseif self.ex == 0.3 then
        self.ex = 0.4
        return talkToNpcOnCell(13, 19)
    elseif self.ex == 0.4 then
        self.ex = 0.5
        return talkToNpcOnCell(11, 12)
    elseif self.ex == 0.5 then
        self.ex = 0.6
        return talkToNpcOnCell(6, 12)
    elseif self.ex == 0.6 then
        self.ex = 0.7
        return talkToNpcOnCell(5, 19)
    elseif self.ex == 0.7 then
        self.ex = 0.8
        return talkToNpcOnCell(18, 12)
    elseif self.ex == 0.8 then
        self.ex = 0.9
        return talkToNpcOnCell(18, 19)
    elseif self.ex == 0.9 then
        self.ex = 1
        return talkToNpcOnCell(12, 7)
    elseif self.ex == 1 then
        self.ex = 1.1
        return talkToNpcOnCell(12, 3)
    end
end


function ThirdBadgeQuest:VeilstonePokecenter()
	if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 5)
	else
		self.registeredPokecenter = "Veilstone Pokecenter"
		return moveToCell(8, 11)
	end
end

function ThirdBadgeQuest:PokecenterEternaCity()
	if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 7)
	else
		self.registeredPokecenter = "Pokecenter Eterna City"
		return moveToCell(8, 11)
	end
end

return ThirdBadgeQuest

