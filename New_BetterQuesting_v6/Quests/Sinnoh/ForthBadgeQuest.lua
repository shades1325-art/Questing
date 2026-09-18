-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local team   = require "Libs/teamlib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'ForthBadgeQuest'
local description = 'Get the 4th badge. Doing all related quest to Hearthome City.'
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

local ForthBadgeQuest = Quest:new()

function ForthBadgeQuest:new()
	local o = Quest.new(ForthBadgeQuest, name, description, level, dialogs)
	o.pokemonId = 1
    --o.dialogs.SandyRequest.state = false
    o.ex = 0
	return o
end

function ForthBadgeQuest:isDoable()
	if hasItem("Cobble Badge") and not hasItem("Fen Badge") then
		return true
	end
	return false
end

function ForthBadgeQuest:isDone()
	if hasItem("Fen Badge") then --fix blackout
		return true
	end
end

function ForthBadgeQuest:VeilstoneGym()
	if hasItem("Cobble Badge") then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(12, 25)
    end
end

function ForthBadgeQuest:VeilstoneCity()
	if self.ex == 0 then
        sys.debug("quest", "Going to help Dawn.")
        self.ex = 0.1
        return talkToNpcOnCell(12, 32)
    elseif self.ex == 0.1 then
        sys.debug("quest", "Going to help Dawn.")
        self.ex = 0.2
        return talkToNpcOnCell(25, 20)
    elseif self.ex == 0.2 then
        sys.debug("quest", "Going to beat Galatic Grunt.")
        self.ex = 0.3
        return talkToNpcOnCell(26, 21)
    elseif self.ex == 0.3 then
        sys.debug("quest", "Going to talk to Dawn.")
        self.ex = 0.4
        return talkToNpcOnCell(25, 20)
    elseif self.ex == 0.4 then
        sys.debug("quest", "Going to Pastoria.")
        self.ex = 0
        return moveToCell(48, 51)
    end
end

function ForthBadgeQuest:VeilstonePokecenter()
	if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 5)
	else
		self.registeredPokecenter = "Veilstone Pokecenter"
		return moveToCell(8, 11)
	end
end

function ForthBadgeQuest:Route214StopHouse()
	return moveToCell(4, 12)
end

function ForthBadgeQuest:Route214()
	return moveToCell(25, 96)
end

function ForthBadgeQuest:ValorLakefront()
	return moveToCell(32, 49)
end

function ForthBadgeQuest:Route213()
    if game.inRectangle(46, 0, 86, 18) then
	    return moveToCell(66, 18)
    elseif game.inRectangle(86, 19, 0, 52) then
        return moveToCell(5, 17)
	elseif game.inRectangle(4, 12, 38, 27) then
		return moveToCell(5, 17)
    end
end

function ForthBadgeQuest:PastoriaCityStopHouse()
	return moveToCell(0, 6)
end


function ForthBadgeQuest:Route213House1()
	return moveToCell(8, 12)
end

function ForthBadgeQuest:PastoriaCity()
    if not hasItem("Fen Badge") then
		sys.debug("quest", "Going to get Fen Badge.")
        return moveToCell(13, 29)
	elseif self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Veilstone Pokecenter" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(24, 17)
    end
end

function ForthBadgeQuest:PastoriaGym()
	if not hasItem("Fen Badge") then
        if self.ex == 0 then
            self.ex = 0.1
			sys.debug("quest", "Current| ex = " .. tostring(self.ex))
		    return talkToNpcOnCell(4, 32)
        elseif self.ex == 0.1 then
			self.ex = 0.2
			sys.debug("quest", "Current| ex = " .. tostring(self.ex))
			return talkToNpcOnCell(4, 22)
		elseif self.ex == 0.2 then
			self.ex = 0.3
			sys.debug("quest", "Current| ex = " .. tostring(self.ex))
		    return talkToNpcOnCell(10, 22)
        elseif self.ex == 0.3 then
            self.ex = 0.4
			sys.debug("quest", "Current| ex = " .. tostring(self.ex))
			return moveToCell(21, 22)
		elseif self.ex == 0.4 then
            self.ex = 0.5
			sys.debug("quest", "Current| ex = " .. tostring(self.ex))
		    return talkToNpcOnCell(24, 16)
        elseif self.ex == 0.5 then
            self.ex = 0.6
			sys.debug("quest", "Current| ex = " .. tostring(self.ex))
		    return talkToNpcOnCell(20, 14)
        elseif self.ex == 0.6 then
            self.ex = 0.7
			sys.debug("quest", "Current| ex = " .. tostring(self.ex))
		    return talkToNpcOnCell(18, 11)
        elseif self.ex == 0.7 then
            self.ex = 0.8
			sys.debug("quest", "Current| ex = " .. tostring(self.ex))
		    return talkToNpcOnCell(12, 13)
        elseif self.ex == 0.8 then
            self.ex = 0.9
			sys.debug("quest", "Current| ex = " .. tostring(self.ex))
		    return talkToNpcOnCell(6, 8)
		elseif self.ex == 0.9 then
            self.ex = 1
			sys.debug("quest", "Current| ex = " .. tostring(self.ex))
		    return talkToNpcOnCell(4, 9)
		elseif self.ex == 1 then
            self.ex = 1.1
			sys.debug("quest", "Current| ex = " .. tostring(self.ex))
		    return talkToNpcOnCell(14, 6)
        end
	else
		return talkToNpcOnCell(16, 8)
	end
end

function ForthBadgeQuest:PastoriaPokecenter()
	if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 7)
	else
		self.registeredPokecenter = "Pastoria Pokecenter"
		return moveToCell(8, 15)
	end
end

return ForthBadgeQuest

