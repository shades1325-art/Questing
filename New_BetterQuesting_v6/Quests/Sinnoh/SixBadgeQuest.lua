-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local team   = require "Libs/teamlib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'SixBadgeQuest'
local description = 'Get the 6th badge. Doing all related quest until beat Canalave Gym.'
local level       = 0

local dialogs = {
	SandyRequest = Dialog:new({
		"xxx",
        "xxx",
        "xxx",
	}),
}
local SixBadgeQuest = Quest:new()
function SixBadgeQuest:new()
	local o = Quest.new(SixBadgeQuest, name, description, level, dialogs)
	o.pokemonId = 1
    --o.dialogs.SandyRequest.state = false
    o.ex = 0
	return o
end
function SixBadgeQuest:isDoable()
	if self:hasMap() and hasItem("Relic Badge") and not hasItem("Mine Badge") then
		return true
	end
	return false
end
function SixBadgeQuest:isDone()
	if hasItem("Mine Badge") then --fix blackout
		return true
	end
end
function SixBadgeQuest:HearthomeGymLeaderRoom()
    sys.debug("quest", "Going to Canalave City.")
    return moveToCell(16, 4)
end
function SixBadgeQuest:HearthomeGymEntrance()
    sys.debug("quest", "Going to Canalave City.")
    return moveToCell(3, 8)
end
function SixBadgeQuest:HearthomeCity()
    sys.debug("quest", "Going to Canalave City.")
    return moveToCell(5, 41)
end
function SixBadgeQuest:Route208StopHouse()
    sys.debug("quest", "Going to Canalave City.")
    return moveToCell(0, 6)
end
function SixBadgeQuest:Route208()
    sys.debug("quest", "Going to Canalave City.")
    return moveToCell(2, 25)
end
function SixBadgeQuest:MtCoronetSouth()
    sys.debug("quest", "Going to Canalave City.")
    return moveToCell(3, 9)
end
function SixBadgeQuest:Route207()
    sys.debug("quest", "Going to Canalave City.")
    return moveToCell(17, 0)
end
function SixBadgeQuest:Route206()
    if game.inRectangle(0, 112, 33, 130) then
        sys.debug("quest", "Going to Canalave City.")
        return moveToCell(18, 112)
    else
        sys.debug("quest", "Going to Canalave City.")
        return moveToCell(18, 3)
    end
end
function SixBadgeQuest:Route206StopHouse()
    sys.debug("quest", "Going to Canalave City.")
    return moveToCell(4, 2)
end
function SixBadgeQuest:EternaCityStopHouse()
    sys.debug("quest", "Going to Canalave City.")
    return moveToCell(3, 2)
end
function SixBadgeQuest:EternaCity()
    sys.debug("quest", "Going to Canalave City.")
    return moveToCell(0, 24)
end
function SixBadgeQuest:Route205()
    sys.debug("quest", "Going to Canalave City.")
    return moveToCell(0, 105)
end
function SixBadgeQuest:FloaromaTown()
    sys.debug("quest", "Going to Canalave City.")
    return moveToCell(22, 41)
end
function SixBadgeQuest:Route204()
    if game.inRectangle(0, 0, 34, 32) then
        sys.debug("quest", "Going to Canalave City.")
        return moveToCell(19, 26)
    else
        sys.debug("quest", "Going to Canalave City.")
        return moveToCell(13, 68)
    end
end
function SixBadgeQuest:RavagedPath()
    sys.debug("quest", "Going to Canalave City.")
    return moveToCell(21, 46)
end
function SixBadgeQuest:JubilifeCity()
    sys.debug("quest", "Going to Canalave City.")
    return moveToCell(1, 25)
end
function SixBadgeQuest:Route218StopHouse1()
    sys.debug("quest", "Going to Canalave City.")
    return moveToCell(0, 6)
end
function SixBadgeQuest:Route218()
    sys.debug("quest", "Going to Canalave City.")
    return moveToCell(3, 18)
end
function SixBadgeQuest:Route218StopHouse2()
    sys.debug("quest", "Going to Canalave City.")
    return moveToCell(0, 6)
end

function SixBadgeQuest:CanalaveCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Canalave Pokecenter" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(40, 15)
    end
    if isNpcOnCell(31, 19) then
        sys.debug("quest", "Talk to Barry.")
        return talkToNpcOnCell(31, 19)
    elseif not hasItem("Mine Badge") then
        return moveToCell(16, 24)
    end
end

function SixBadgeQuest:CanalavePokecenter()
	if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 7)
	else
		self.registeredPokecenter = "Canalave Pokecenter"
		return moveToCell(8, 15)
	end
end

function SixBadgeQuest:CanalaveGym()
    if game.inRectangle(5, 24, 17, 32) or game.inRectangle(17, 17, 25, 24)  then
        return moveToCell(23, 18)
    elseif game.inRectangle(19, 26, 29, 32) then
        return moveToCell(20, 27)
    elseif game.inRectangle(9, 13, 25, 15) then
        return moveToCell(15, 14)
    end
end

function SixBadgeQuest:CanalaveGym2F()
    if game.inRectangle(22, 17, 29, 20) or game.inRectangle(27, 21, 29, 28) then
        return moveToCell(28, 27)
    elseif game.inRectangle(15, 26, 21, 28) then
        return moveToCell(16, 27)
    elseif game.inRectangle(0, 25, 11, 33) then
        return moveToCell(4, 31)
    elseif game.inRectangle(22, 9, 29, 15) then
        return moveToCell(24, 14)
    end
end

function SixBadgeQuest:CanalaveGym3F()
    if game.inRectangle(0, 7, 11, 33) then
        return moveToCell(9, 9)
    elseif game.inRectangle(15, 8, 25, 22) then
        return moveToCell(24, 21)
    elseif game.inRectangle(23, 26, 28, 32) then
        return moveToCell(27, 27)
    elseif game.inRectangle(26, 13, 28, 22) then
        return moveToCell(27, 14)
    end
end

function SixBadgeQuest:CanalaveGym4F()
    if not hasItem("Mine Badge") then
        return talkToNpcOnCell(16, 8)
    else
        return moveToCell(19, 9)
    end
end

return SixBadgeQuest

