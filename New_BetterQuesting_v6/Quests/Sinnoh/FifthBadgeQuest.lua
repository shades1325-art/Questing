-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local team   = require "Libs/teamlib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'FifthBadgeQuest'
local description = 'Get the 5th badge. Doing all related quest to Hearthome City.'
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

local FifthBadgeQuest = Quest:new()

function FifthBadgeQuest:new()
	local o = Quest.new(FifthBadgeQuest, name, description, level, dialogs)
	o.pokemonId = 1
    --o.dialogs.SandyRequest.state = false
    o.ex = 0
	return o
end

function FifthBadgeQuest:isDoable()
	if hasItem("Fen Badge") and not hasItem("Relic Badge") then
		return true
	end
	return false
end

function FifthBadgeQuest:isDone()
	if hasItem("Relic Badge") then --fix blackout
		return true
	end
end

function FifthBadgeQuest:Route214StopHouse()
	return moveToCell(4, 2)
end

function FifthBadgeQuest:Route214()
	return moveToCell(13, 4)
end

function FifthBadgeQuest:ValorLakefront()
    if hasItem("Fen Badge") then
        if isNpcOnCell(46, 42) then
            return talkToNpcOnCell(46, 42)
        elseif isNpcOnCell(48, 27) then
            return talkToNpcOnCell(48, 27)
        elseif isNpcOnCell(45, 20) and not hasItem("Secret Potion") then
            self.ex = 0.1
            return talkToNpcOnCell(45, 20)
        end
    end
    return moveToCell(56, 0)
end

function FifthBadgeQuest:Route213()
    if (game.inRectangle(0, 13, 55, 55) or game.inRectangle(54, 19, 95, 55)) then
        if isNpcOnCell(52, 37) then 
            return talkToNpcOnCell(52, 37)
        else
            self.ex = 0
            return moveToCell(66, 22) 
        end
    elseif game.inRectangle(57, 0, 79, 18) then
        self.ex = 0
        return moveToCell(66, 0)
    end
end

function FifthBadgeQuest:PastoriaCityStopHouse()
    if hasItem("Fen Badge") then
	    return moveToCell(10, 7)
    else
        return moveToCell(0, 7)
    end
end

function FifthBadgeQuest:Route213House1()
    if hasItem("Fen Badge") then
	    return moveToCell(8, 3)
    end
end

function FifthBadgeQuest:PastoriaCity()
    if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pastoria Pokecenter" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(24, 17)
    elseif isNpcOnCell(39, 11) then
        return talkToNpcOnCell(39, 11)
    elseif isNpcOnCell(59, 13) then
        return talkToNpcOnCell(59, 13)
    else
        return moveToCell(60, 14)
    end
end

function FifthBadgeQuest:PastoriaGym()
	if game.inRectangle(2, 6, 19, 13) then
        return talkToNpcOnCell(16, 8)
    elseif game.inRectangle(9, 34, 19, 41) then
		return moveToCell(14, 40)
	end
end

function FifthBadgeQuest:PastoriaPokecenter()
	if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 7)
	else
		self.registeredPokecenter = "Pastoria Pokecenter"
		return moveToCell(8, 15)
	end
end

function FifthBadgeQuest:VeilstoneCity()
	sys.debug("quest", "Going to Rt210.")
	return moveToCell(5, 24)
end

function FifthBadgeQuest:Route215StopHouse()
	sys.debug("quest", "Going to Rt210.")
	return moveToCell(0, 7)
end
function FifthBadgeQuest:Route215()
	sys.debug("quest", "Going to Rt210.")
	return moveToCell(0, 22)
end
function FifthBadgeQuest:Route210()
    if isNpcOnCell(25, 37) then
	    sys.debug("quest", "Talk to Psyduck.")
	    return talkToNpcOnCell(25, 37)
    elseif self.ex == 0.5 then
        sys.debug("quest", "Going to Hearthome City.")
	    return moveToCell(19, 87)
    else
        return moveToCell(28, 0)
    end
end
function FifthBadgeQuest:Route210North()
    if self.ex == 0.5 then
        sys.debug("quest", "Going to Hearthome City.")
        self.ex = 0.5
        return moveToCell(100, 30)
    else
	    sys.debug("quest", "Going to Rt210.")
	    return moveToCell(0, 17)
    end
end
function FifthBadgeQuest:CelesticTown()
    if not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Celestic Pokecenter" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(22, 29)
    elseif self.ex == 0 then
        sys.debug("quest", "Going to fight.")
        self.ex = 0.1
        return talkToNpcOnCell(14, 15)
    elseif self.ex == 0.1 then
        sys.debug("quest", "Going to Cynthia grandma.")
        self.ex = 0.2
        return talkToNpcOnCell(14, 17)
    elseif self.ex == 0.5 then
        sys.debug("quest", "Going to Hearthome City.")
        self.ex = 0.5
        return moveToCell(30, 22)
    elseif self.ex == 0.2 then
        sys.debug("quest", "Go inside the ruins.")
        self.ex = 0.2
        return moveToCell(14, 14)
    end
end
function FifthBadgeQuest:CelesticPokecenter()
    if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 7)
	else
		self.registeredPokecenter = "Celestic Pokecenter"
		return moveToCell(8, 15)
	end
end
function FifthBadgeQuest:CelesticRuins()
    if self.ex == 0.2 then
        self.ex = 0.3
    end
    if self.ex == 0.3 then
        sys.debug("quest", "interact the ruins.")
        self.ex = 0.5    
	    return talkToNpcOnCell(9, 7)
    end
    if isNpcOnCell(8, 10) then
        sys.debug("quest", "interact with Cyrus.")
        self.ex = 0.5    
	    return talkToNpcOnCell(8, 10)
    else 
        sys.debug("quest", "go outside the ruins.")
        self.ex = 0.5 
        return moveToCell(11, 18)
    end
end
function FifthBadgeQuest:SolaceonTown()
    if self.ex == 0.5 then
        sys.debug("quest", "Going to Hearthome City.")
        self.ex = 0.5    
	    return moveToCell(17, 35)
    end
end
function FifthBadgeQuest:Route209()
    if self.ex == 0.5 then
        sys.debug("quest", "Going to Hearthome City.")
        self.ex = 0.5    
	    return moveToCell(3, 65)
    end
end
function FifthBadgeQuest:Route209StopHouse()
    if self.ex == 0.5 then
        sys.debug("quest", "Going to Hearthome City.")
        self.ex = 0.5    
	    return moveToCell(0, 6)
    end
end
function FifthBadgeQuest:HearthomeCity()
    if not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Hearthome Pokecenter" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(18, 16)
    end
    if not hasItem("Relic Badge") then
        if isNpcOnCell(52, 17) then
            sys.debug("quest", "Going to Hearthome City Gym.")
            self.ex = 0.5    
	        return talkToNpcOnCell(52, 17)
        else
            return moveToCell(52, 16)
        end
    end
end
function FifthBadgeQuest:HearthomePokecenter()
    if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 7)
	else
		self.registeredPokecenter = "Hearthome Pokecenter"
		return moveToCell(8, 15)
	end
end
function FifthBadgeQuest:HearthomeGymEntrance()
    if not hasItem("Relic Badge") then
	    return moveToCell(3, 2)
    else
        return moveToCell(3, 8)
    end
end
function FifthBadgeQuest:HearthomeGymRoom1()
    if not hasItem("Relic Badge") then
	    return moveToCell(11, 2)
    else
        return moveToCell(7, 9)
    end
end
function FifthBadgeQuest:HearthomeGymRoom2()
    if not hasItem("Relic Badge") then
        if game.inRectangle(0, 0, 23, 19) then
	        return moveToCell(3, 6)
        elseif game.inRectangle(24, 0, 40, 19) then
            return moveToCell(25, 2)
        end
    else
        return moveToCell(20, 19)
    end
end
function FifthBadgeQuest:HearthomeGymLeaderRoom()
    if not hasItem("Relic Badge") then
	    return talkToNpcOnCell(4, 7)
    else
        return moveToCell(16, 4)
    end
end

return FifthBadgeQuest

