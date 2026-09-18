-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local team   = require "Libs/teamlib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'SevenBadgeQuest'
local description = 'Getting 7nd Badge.Doing all related quest until beat Snowpoint City Gym.'
local level       = 0

local dialogs = {
	LakeVerity = Dialog:new({
		"I should look for Prof. Rowan and Dawn in Lake Verity too...",
        "xxx",
        "xxx",
	}),
    LakeAcuity = Dialog:new({
        "But what about lake Acuity? Is Barry safe?",
        "I need you to go to Lake Acuity right away. I worried about Barry.",
        "You need to pass through Mt. Coronet Center to reach there.",
    }),
    
}
local SevenBadgeQuest = Quest:new()
function SevenBadgeQuest:new()
	local o = Quest.new(SevenBadgeQuest, name, description, level, dialogs)
	o.pokemonId = 1
    --o.dialogs.LakeVerity.state = true
    --o.dialogs.LakeAcuity.state = true
    o.ex = 0
	return o
end
function SevenBadgeQuest:isDoable()
	if self:hasMap() and not hasItem("Glacial Badge") then
		return true
	end
	return false
end

function SevenBadgeQuest:isDone()
	if hasItem("Glacial Badge") and not isNpcOnCell(50, 34) then --fix blackout
		return true
	end
end
function SevenBadgeQuest:CanalaveCity()
    if isNpcOnCell(16, 25) then
        sys.debug("quest", "Talk to Barry.")
        self.ex = 0.1
        return talkToNpcOnCell(16, 25)
    elseif self.ex == 0.1 then
        return moveToCell(13, 13)
    elseif self.ex == 0 or self.ex == 0.3 then
        return moveToCell(46, 42)
    end
end

function SevenBadgeQuest:CanalaveLibrary()
    if self.ex == 0.1 then
        sys.debug("quest", "Talk to Barry.")
        self.ex = 0.2
        return talkToNpcOnCell(13, 3)
    elseif self.ex == 0.2 then
        sys.debug("quest", "Going to meet Prof.Rowan.")
        self.ex = 0.2
        return moveToCell(12, 3)
    else
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(12, 10)
    end
end

function SevenBadgeQuest:CanalaveLibrary1F()
    if self.ex == 0.2 then
        sys.debug("quest", "Going to meet Prof.Rowan.")
        self.ex = 0.2
        return moveToCell(12, 3)
    else
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(6, 3)
    end
end

function SevenBadgeQuest:CanalaveLibrary2F()
    if isNpcOnCell(8, 7) then
        sys.debug("quest", "Going to meet Prof.Rowan.")
        self.ex = 0.3
        return talkToNpcOnCell(8, 7)
    else
        sys.debug("quest", "Going to Valor Lakefront.")
        self.ex = 0.3
        return moveToCell(6, 3)
    end
end

function SevenBadgeQuest:CanalavePokecenter()
	if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 7)
	else
		self.registeredPokecenter = "Canalave Pokecenter"
		return moveToCell(8, 15)
	end
end

function SevenBadgeQuest:CanalaveGym()
    if hasItem("Mine Badge") then
        return moveToCell(14, 32)
    end
end

function SevenBadgeQuest:CanalaveGym4F()
    if not hasItem("Mine Badge") then
        return talkToNpcOnCell(16, 8)
    elseif game.inRectangle(13, 8, 20, 16) then
        return moveToCell(19, 9)
    elseif game.inRectangle(26, 8, 31, 13) then
        return moveToCell(30, 12)
    elseif game.inRectangle(26, 27, 31, 32) then
        return moveToCell(27, 31)
    elseif game.inRectangle(0, 27, 5, 32) then
        return moveToCell(1, 28)
    elseif game.inRectangle(0, 13, 7, 19) then
        return moveToCell(6, 14)
    end
end
function SevenBadgeQuest:Route218StopHouse1()
    sys.debug("quest", "Going to Valor Lakefront.")
    self.ex = 0
    return moveToCell(10, 6)
end
function SevenBadgeQuest:Route218StopHouse2()
    sys.debug("quest", "Going to Valor Lakefront.")
    return moveToCell(10, 6)
end
function SevenBadgeQuest:Route218()
    sys.debug("quest", "Going to Valor Lakefront.")
    return moveToCell(72, 22)
end
function SevenBadgeQuest:JubilifeCity()
    if self.dialogs.LakeAcuity.state then
        sys.debug("quest", "Going to Lake Acuity.")
        return moveToCell(49, 0)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(50, 63)
    else
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(49, 0)
    end
end
function SevenBadgeQuest:Route204()
    if self.dialogs.LakeAcuity.state then
        if game.inRectangle(0, 34, 34, 68) then
            sys.debug("quest", "Going to Lake Acuity.")
            return moveToCell(10, 34)
        elseif game.inRectangle(0, 0, 34, 31) then
            sys.debug("quest", "Going to Lake Acuity.")
            return moveToCell(11, 0)
        end
    elseif self.dialogs.LakeVerity.state then
        if game.inRectangle(0, 0, 34, 32) then
            sys.debug("quest", "Going to Lake Verity.")
            return moveToCell(19, 26)
        else
            sys.debug("quest", "Going to Lake Verity.")
            return moveToCell(13, 68)
        end
    else
        if game.inRectangle(0, 34, 34, 68) then
            sys.debug("quest", "Going to Valor Lakefront.")
            return moveToCell(10, 34)
        elseif game.inRectangle(0, 0, 34, 31) then
            sys.debug("quest", "Going to Valor Lakefront.")
            return moveToCell(11, 0)
        end
    end
end
function SevenBadgeQuest:RavagedPath()
    if self.dialogs.LakeAcuity.state then
        sys.debug("quest", "Going to Lake Acuity.")
        return moveToCell(30, 41)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(21, 46)
    else
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(30, 41)
    end
end
function SevenBadgeQuest:FloaromaTown()
    if self.dialogs.LakeAcuity.state then
        sys.debug("quest", "Going to Lake Acuity.")
        return moveToCell(45, 28)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(22, 41)
    else
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(45, 28)
    end
end
function SevenBadgeQuest:Route205()
    if self.dialogs.LakeAcuity.state then
        sys.debug("quest", "Going to Lake Acuity.")
        return moveToCell(64, 20)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(0, 105)
    else
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(64, 20)
    end
end
function SevenBadgeQuest:EternaCity()
    if self.dialogs.LakeAcuity.state then
        sys.debug("quest", "Going to Lake Acuity.")
        return moveToCell(66, 23)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(0, 24)
    else
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(18, 56)
    end
end
function SevenBadgeQuest:Route211()
    if self.dialogs.LakeAcuity.state then
        sys.debug("quest", "Going to Lake Acuity.")
        return moveToCell(37, 23)
    else
        sys.debug("quest", "Going to Eterna City.")
        return moveToCell(3, 2)
    end
end
function SevenBadgeQuest:EternaCityStopHouse()
    if not self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(4, 12)
    else
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(3, 2)
    end
end
function SevenBadgeQuest:Route206StopHouse()
    if not self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(4, 12)
    else
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(4, 2)
    end
end
function SevenBadgeQuest:Route206()
    if not self.dialogs.LakeVerity.state then
        if game.inRectangle(0, 0, 33, 107) then
            sys.debug("quest", "Going to Valor Lakefront.")
            return moveToCell(17, 107)
        elseif game.inRectangle(0, 112, 33, 130) then
            sys.debug("quest", "Going to Valor Lakefront.")
            return moveToCell(18, 130)
        end
    else
        if game.inRectangle(0, 112, 33, 130) then
            sys.debug("quest", "Going to Lake Verity.")
            return moveToCell(18, 112)
        else
            sys.debug("quest", "Going to Lake Verity.")
            return moveToCell(18, 3)
        end
    end
end
function SevenBadgeQuest:Route207()
    if not self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(56, 6)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(17, 0)
    end
end
function SevenBadgeQuest:MtCoronetSouth()
    if not self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(30, 18)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(3, 9)
    end
end
function SevenBadgeQuest:Route208()
    if not self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(67, 26)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(2, 25)
    end
end
function SevenBadgeQuest:Route208StopHouse()
    if not self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(10, 45)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(0, 7)
    end
end
function SevenBadgeQuest:HearthomeCity()
    if not self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(67, 26)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(5, 42)
    end
end
function SevenBadgeQuest:HearthomeCityStopHouse2()
    if not self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(3, 12)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(4, 2)
    end
end
function SevenBadgeQuest:Route212North()
    if not self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(13, 98)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(11, 5)
    end
end
function SevenBadgeQuest:Route212South()
    if not self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(128, 13)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(12, 0)
    end
end
function SevenBadgeQuest:PastoriaCity()
    if not self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(60, 14)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(0, 47)
    end
end
function SevenBadgeQuest:PastoriaCityStopHouse()
    if not self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(10, 6)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(0, 7)
    end
end
function SevenBadgeQuest:Route213()
    if not self.dialogs.LakeVerity.state then
        if game.inRectangle(0, 13, 55, 55) or game.inRectangle(55, 13, 95, 55) then
            sys.debug("quest", "Going to Valor Lakefront.")
            return moveToCell(66, 22)
        elseif game.inRectangle(56, 0, 86, 19) then
            sys.debug("quest", "Going to Valor Lakefront.")
            return moveToCell(66, 0)
        end
    elseif self.dialogs.LakeVerity.state then
        if game.inRectangle(0, 13, 55, 55) or game.inRectangle(55, 13, 95, 55) then
            sys.debug("quest", "Going to Lake Verity.")
            return moveToCell(5, 18)
        elseif game.inRectangle(56, 0, 86, 19) then
            sys.debug("quest", "Going to Lake Verity.")
            return moveToCell(66, 18)
        end
    end
end
function SevenBadgeQuest:Route213House1()
    if not self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Valor Lakefront.")
        return moveToCell(8, 3)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(8, 12)
    end
end
function SevenBadgeQuest:ValorLakefront()
    if not self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Valor Cavern.")
        return moveToCell(40, 21)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(38, 49)
    end
end
function SevenBadgeQuest:LakeValorExploded()
    if not self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Valor Cavern.")
        return moveToCell(30, 28)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(60, 6)
    end
end
function SevenBadgeQuest:Route202()
    if self.dialogs.LakeAcuity.state then
        sys.debug("quest", "Going to Lake Acuity.")
        return moveToCell(27, 0)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(41, 32)
    else
        sys.debug("quest", "Going to Valor Cavern.")
        return moveToCell(27, 0)
    end
end
function SevenBadgeQuest:SandgemTown()
    if self.dialogs.LakeAcuity.state then
        sys.debug("quest", "Going to Lake Acuity.")
        return moveToCell(38, 0)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(0, 12)
    else
        sys.debug("quest", "Going to Valor Cavern.")
        return moveToCell(38, 0)
    end
end
function SevenBadgeQuest:Route201()
    if self.dialogs.LakeAcuity.state then
        sys.debug("quest", "Going to Lake Acuity.")
        return moveToCell(100, 9)
    elseif self.dialogs.LakeVerity.state then
        sys.debug("quest", "Going to Lake Verity.")
        return moveToCell(10, 0)
    else
        sys.debug("quest", "Going to Valor Cavern.")
        return moveToCell(100, 9)
    end
end
function SevenBadgeQuest:LakeVerity()
    if isNpcOnCell(50, 35) then
        sys.debug("quest", "Going to fight Mars.")
        return talkToNpcOnCell(50, 35)
    elseif isNpcOnCell(50, 34) then
        sys.debug("quest", "Talk to Prof.Rowan.")
        return talkToNpcOnCell(50, 34)
    else
        self.dialogs.LakeVerity.state = false
        self.dialogs.LakeAcuity.state = true
        return moveToCell(51, 50)
    end
end
function SevenBadgeQuest:ValorCavern()
    if isNpcOnCell(15, 20) then
        return talkToNpcOnCell(15, 20)
    else
        sys.debug("quest", "Going to Lake Verity.")
        self.ex = 2
        return moveToCell(15, 28)
    end
end

return SevenBadgeQuest

