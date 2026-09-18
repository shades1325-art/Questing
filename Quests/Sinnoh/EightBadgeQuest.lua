-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local team   = require "Libs/teamlib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'EightBadgeQuest'
local description = 'Getting 8th Badge.Doing all related quest until beat Sunyshore Gym.'
local level       = 0

local dialogs = {
	FirstEncounter = Dialog:new({
        "That space suit guy looks suspicious.",
        "xxx",
	}),
    FirstPassword = Dialog:new({
        "It's supercalifragilisticexpialidocious.",
        "I'm not kidding!",
        "Supercalifragilisticexpialidocious!",
        "I'm not doing business today.",
	}),
    SecondPassword = Dialog:new({
        "Please burn the paper after reading.",
        "Galactic HQ Password... World is mine!",
        "Nothing inside it...",
	}),
    ToVeilstone = Dialog:new({
        " I have to be stronger...",
        "head to Veilstone City",
    }),
    ToSpearPillar = Dialog:new({
        "xxx",
        "xxx",
    }),
    ToTrio = Dialog:new({
        "Anyway, as I promised. Go ahead and release the three Pok?mon you so desperately want to save.",
        "I am off to Mt. Coronet to bring about a new beginning for everything...",
    }),
    
}
local EightBadgeQuest = Quest:new()
function EightBadgeQuest:new()
	local o = Quest.new(EightBadgeQuest, name, description, level, dialogs)
	o.pokemonId = 1
    o.dialogs.ToTrio.state = true
    o.ex = 0
	return o
end
function EightBadgeQuest:isDoable()
	if self:hasMap() and not hasItem("Beacon Badge") then
		return true
	end
	return false
end

function EightBadgeQuest:isDone()
	if hasItem("Beacon Badge") then --fix blackout
		return true
	end
end
--37, 36
function EightBadgeQuest:LakeTrioRoom()
    if game.inRectangle(29, 1, 45, 13) then
        if isNpcOnCell(37, 4) then
            sys.debug("quest", "Beat Saturn.")
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            self.ex = 1.2
            self.dialogs.ToTrio.state = false
            return talkToNpcOnCell(37, 4)
        elseif isNpcOnCell(31, 2) then
            sys.debug("quest", "Release Lake Trio.")
            return talkToNpcOnCell(37, 3)
        else
            sys.debug("quest", "Leave Galatic HQ.")
            self.ex = 1.3
            moveToCell(37, 12)
        end
    elseif self.ex == 1.3 then
        sys.debug("quest", "Leave Galatic HQ.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.3
        return moveToCell(2, 45)
    else
        sys.debug("quest", "Beat Saturn.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.2
        return moveToCell(37, 36)
    end
end
function EightBadgeQuest:TeamGalacticHQ4F()
    if game.inRectangle(22, 1, 22, 2) then
        sys.debug("quest", "Leave Galatic HQ.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.3
        return talkToNpcOnCell(19, 12)
    elseif game.inRectangle(17, 13, 22, 16) then
        sys.debug("quest", "Leave Galatic HQ.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.3
        return moveToCell(21, 15)
    end
    if isNpcOnCell(8, 12) then
        sys.debug("quest", "Keep going.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.2
        return talkToNpcOnCell(8, 12)
    elseif isNpcOnCell(8, 7) then
        sys.debug("quest", "Beat Cyrus.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.2
        return talkToNpcOnCell(8, 7)
    elseif ex == 1.2 or self.dialogs.ToTrio.state then
        sys.debug("quest", "Beat Saturn.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.2
        return moveToCell(22, 2)
    end
end
function EightBadgeQuest:TeamGalacticHQ3F()
    if (game.inRectangle(20, 2, 52, 6) or game.inRectangle(15, 7, 22, 14)) then
        sys.debug("quest", "Keep going.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.2
        return moveToCell(15, 11)
    elseif game.inRectangle(6, 9, 12, 14) then
        sys.debug("quest", "Keep going.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.2
        return moveToCell(11, 10)
    end
end
function EightBadgeQuest:TeamGalacticHQ2F()
    if game.inRectangle(0, 1, 15, 6) then
        sys.debug("quest", "Keep going.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 0.6
        return moveToCell(1, 2)
    elseif game.inRectangle(16, 1, 27, 6) then
        sys.debug("quest", "Keep going.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 0.6
        return moveToCell(25, 3)
    elseif (game.inRectangle(7, 10, 26, 14) or game.inRectangle(21, 11, 45, 21) or game.inRectangle(29, 2, 36, 14)) then
        sys.debug("quest", "Keep going.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.2
        return moveToCell(29, 12)
    elseif game.inRectangle(39, 2, 52, 6) then
        sys.debug("quest", "Keep going.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.2
        return moveToCell(49, 3)
    end
end
function EightBadgeQuest:TeamGalacticHQ1F()
    if game.inRectangle(38, 1, 52, 9) then
        sys.debug("quest", "Keep going.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 0.6
        return moveToCell(39, 2)
    elseif game.inRectangle(31, 1, 37, 9) then
        sys.debug("quest", "Keep going.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 0.6
        return moveToCell(36, 7)
    elseif game.inRectangle(0, 1, 7, 9) then
        sys.debug("quest", "Keep going.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 0.6
        return moveToCell(5, 3) 
    elseif game.inRectangle(9, 2, 29, 8) then
        sys.debug("quest", "Keep going.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 0.6
        return moveToCell(10, 3) 
    elseif game.inRectangle(1, 13, 36, 20) then
        if isNpcOnCell(22, 17) then
            sys.debug("quest", "Open the door.")
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            self.ex = 1.2
            return talkToNpcOnCell(22, 17)
        else
            sys.debug("quest", "Keep going.")
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            return moveToCell(18, 14) 
        end
    elseif game.inRectangle(39, 13, 44, 20) then
        sys.debug("quest", "Leave Galatic HQ.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.3
        return moveToCell(42, 20) 
	end
end
function EightBadgeQuest:GalacticWarehouseUnderpass2F()
    if self.ex == 0.5 then
        sys.debug("quest", "Keep going.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 0.6
        return moveToCell(18, 8)
    else
        sys.debug("quest", "Keep going.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(6, 11)
	end
end
function EightBadgeQuest:GalacticWarehouseUnderpass()
    if (game.inRectangle(18, 2, 53, 8) or game.inRectangle(13, 3, 30, 12)) then
        if not self.dialogs.SecondPassword.state then
            sys.debug("quest", "Searching trashcan.")
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            self.ex = 1
            self.dialogs.SecondPassword.state = true
            return talkToNpcOnCell(20, 3)
        else
            if isNpcOnCell(13, 8) then
                sys.debug("quest", "Open the door.")
                sys.debug("quest", "Current| ex = " .. tostring(self.ex))
                return talkToNpcOnCell(13, 8)
            else
                sys.debug("quest", "Going to Galatic HQ.")
                sys.debug("quest", "Current| ex = " .. tostring(self.ex))
                self.ex = 1
                return moveToCell(1, 17)
            end
        end
    elseif not (game.inRectangle(18, 2, 53, 8) or game.inRectangle(13, 3, 30, 12))  then
        sys.debug("quest", "Keep going.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 0.5
        return moveToCell(81, 4)
	end
end
function EightBadgeQuest:GalacticWarehouseEntrance()
    if isNpcOnCell(9, 7) then
        sys.debug("quest", "Open the door.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 0.4
        return talkToNpcOnCell(9, 7)
    else
        if not self.dialogs.SecondPassword.state then
            sys.debug("quest", "Going downstair.")
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            self.ex = 0.5
            return moveToCell(15, 4)
        else
            sys.debug("quest", "Going to Galatic HQ.")
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            self.ex = 1
            self.dialogs.FirstPassword.state = false
            return moveToCell(9, 13)
        end
	end
end
function EightBadgeQuest:VeilstoneCity()
	if not self.registeredPokecenter == "Veilstone Pokecenter" then
        sys.debug("quest", "Going to heal.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
		return moveToCell(46, 31)
    end
    if self.ex == 0 then
        sys.debug("quest", "Going to get 1st password.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 0.1
		return moveToCell(51, 19)
    elseif self.ex == 0.1 then
        sys.debug("quest", "Going to get 1st password.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 0.2
        return talkToNpcOnCell(49, 17)
    elseif dialogs.FirstPassword.state then
        sys.debug("quest", "Going to Galatic Warehouse.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 0.3
        return moveToCell(29, 15)
    elseif self.ex == 1 then
        sys.debug("quest", "Going to Galatic HQ.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.1
        return moveToCell(51, 18)
    elseif self.ex == 1.1 then
        sys.debug("quest", "Going to Galatic HQ.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.2
        return moveToCell(42, 13)
    elseif self.ex == 1.3 then
        sys.debug("quest", "Going to Mt.Coronet.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.3
        return moveToCell(5, 24)
	end
end
function EightBadgeQuest:VeilstonePokecenter()
	if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 5)
	else
		self.registeredPokecenter = "Veilstone Pokecenter"
		return moveToCell(8, 11)
	end
end
function EightBadgeQuest:Route215StopHouse()
    if self.ex == 1.3 then
        sys.debug("quest", "Going to Mt.Coronet.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.3
        return moveToCell(0, 7)
    else
        sys.debug("quest", "Going to Veilstone City.")
        return moveToCell(10, 6)
    end
end
function EightBadgeQuest:Route215()
    if self.ex == 1.3 then
        sys.debug("quest", "Going to Mt.Coronet.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.3
        return moveToCell(0, 22)
    else
        sys.debug("quest", "Going to Veilstone City.")
        return moveToCell(119, 24)
    end
end
function EightBadgeQuest:Route210()
    if self.ex == 1.3 then
        sys.debug("quest", "Going to Mt.Coronet.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.3
        return moveToCell(28, 0)
    else
        sys.debug("quest", "Going to Veilstone City.")
        return moveToCell(40, 42)
    end
end
function EightBadgeQuest:Route210North()
    if self.ex == 1.3 then
        sys.debug("quest", "Going to Mt.Coronet.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.3
        return moveToCell(0, 17)
    else
        sys.debug("quest", "Going to Veilstone City.")
        return moveToCell(100, 30)
    end
end
function EightBadgeQuest:CelesticTown()
    if self.ex == 1.3 then
        sys.debug("quest", "Going to Mt.Coronet.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.3
        return moveToCell(0, 20)
    else
        sys.debug("quest", "Going to Veilstone City.")
        return moveToCell(30, 22)
    end
end
function EightBadgeQuest:Route211()
    if self.ex == 1.3 then
        sys.debug("quest", "Going to Mt.Coronet.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.3
        return moveToCell(59, 21)
    else
        sys.debug("quest", "Going to Veilstone City.")
        return moveToCell(94, 23)
    end
end
function EightBadgeQuest:SunyShoreGym3()
    if self.ex == 0.9 then
        sys.debug("quest", "cbi danh npc 1 1/2.")
        self.ex = 1
        return moveToCell(4, 24) 
    elseif self.ex == 1 then
        sys.debug("quest", "cbi danh npc 1 2/2.")
        self.ex = 1.1
        return moveToCell(4, 18) 
    elseif self.ex == 1.1 then
        sys.debug("quest", "danh npc 1.")
        self.ex = 1.2
        return talkToNpcOnCell(6, 18) 
    if self.ex == 1.2 then
        sys.debug("quest", "cbi danh npc 2 1/4.")
        self.ex = 1.3
        return moveToCell(4, 18) 
    elseif self.ex == 1.3 then
        sys.debug("quest", "cbi danh npc 2 2/4.")
        self.ex = 1.4
        return moveToCell(4, 24) 
    elseif self.ex == 1.4 then
        sys.debug("quest", "cbi danh npc 2 3/4.")
        self.ex = 1.5
        return moveToCell(16, 24) 
    elseif self.ex == 1.5 then
        sys.debug("quest", "cbi danh npc 2 4/4.")
        self.ex = 1.6
        return moveToCell(16, 18)  
    elseif self.ex == 1.6 then
        sys.debug("quest", "danh npc 2.")
        self.ex = 2
        return talkToNpcOnCell(14, 18) 
    elseif self.ex == 2 then
        sys.debug("quest", "giai puzzle 1/25.")
        self.ex = 2.1
        return moveToCell(16, 18) 
    elseif self.ex == 2.1 then
        sys.debug("quest", "giai puzzle 2/25.")
        self.ex = 2.2
        return moveToCell(16, 24)
    elseif self.ex == 2.2 then
        sys.debug("quest", "giai puzzle 3/25.")
        self.ex = 2.3
        return moveToCell(4, 24)
    elseif self.ex == 2.3 then
        sys.debug("quest", "giai puzzle 4/25.")
        self.ex = 2.4
        return moveToCell(4, 19)
    elseif self.ex == 2.4 then
        sys.debug("quest", "giai puzzle 5/25.")
        self.ex = 2.5
        return moveToCell(6, 19)
    elseif self.ex == 2.5 then
        sys.debug("quest", "giai puzzle 6/25.")
        self.ex = 2.6
        return moveToCell(6, 21)
    elseif self.ex == 2.6 then
        sys.debug("quest", "giai puzzle 7/25.")
        self.ex = 2.7
        return talkToNpcOnCell(6, 22)
    elseif self.ex == 2.7 then
        sys.debug("quest", "giai puzzle 8/25.")
        self.ex = 2.8
        return talkToNpcOnCell(10, 21)
    elseif self.ex == 2.8 then
        sys.debug("quest", "giai puzzle 9/25.")
        self.ex = 2.9
        return moveToCell(6, 21)
    elseif self.ex == 2.9 then
        sys.debug("quest", "giai puzzle 10/25.")
        self.ex = 3
        return talkToNpcOnCell(6, 22)
    elseif self.ex == 3 then
        sys.debug("quest", "giai puzzle 11/25.")
        self.ex = 3.1
        return moveToCell(6, 19)
    elseif self.ex == 3.1 then
        sys.debug("quest", "giai puzzle 12/25.")
        self.ex = 3.2
        return moveToCell(4, 19)
    elseif self.ex == 3.2 then
        sys.debug("quest", "giai puzzle 13/25.")
        self.ex = 3.3
        return moveToCell(4, 24)
    elseif self.ex == 3.3 then
        sys.debug("quest", "giai puzzle 14/25.")
        self.ex = 3.4
        return moveToCell(13, 24)
    elseif self.ex == 3.4 then
        sys.debug("quest", "giai puzzle 15/25.")
        self.ex = 3.5
        return moveToCell(13, 22)
    elseif self.ex == 3.5 then
        sys.debug("quest", "giai puzzle 16/25.")
        self.ex = 3.6
        return talkToNpcOnCell(14, 22)
    elseif self.ex == 3.6 then
        sys.debug("quest", "giai puzzle 17/25.")
        self.ex = 3.7
        return moveToCell(13, 24)
    elseif self.ex == 3.7 then
        sys.debug("quest", "giai puzzle 18/25.")
        self.ex = 3.8
        return moveToCell(4, 24)
    elseif self.ex == 3.8 then
        sys.debug("quest", "giai puzzle 19/25.")
        self.ex = 3.9
        return moveToCell(4, 19)
    elseif self.ex == 3.9 then
        sys.debug("quest", "giai puzzle 21/25.")
        self.ex = 4
        return moveToCell(6, 19)
    elseif self.ex == 4 then
        sys.debug("quest", "giai puzzle 22/25.")
        self.ex = 4.1
        return talkToNpcOnCell(6, 22)
    elseif self.ex == 4.1 then
        sys.debug("quest", "giai puzzle 23/25.")
        self.ex = 4.2
        return moveToCell(9, 21)
    elseif self.ex == 4.2 then
        sys.debug("quest", "giai puzzle 24/25.")
        self.ex = 4.3
        return moveToCell(9, 18)
    elseif self.ex == 4.3 then
        sys.debug("quest", "giai puzzle 25/25.")
        self.ex = 4.4
        return talkToNpcOnCell(10, 18)
    elseif self.ex == 4.4 then
        sys.debug("quest", "giai puzzle 25/25.")
        self.ex = 4.5
        return talkToNpcOnCell(10, 5)
    else
        self.ex = 0.8
        return moveToCell(10, 25)
    end
end
function EightBadgeQuest:SunyShoreGym2()
	if self.ex == 0.1 then
        sys.debug("quest", "cbi danh npc 1.")
        self.ex = 0.2
        return moveToCell(5, 13) 
    elseif self.ex == 0.2 then
        sys.debug("quest", "danh npc 1.")
        self.ex = 0.3
        return talkToNpcOnCell(5, 9)
    elseif self.ex == 0.3 then
        sys.debug("quest", "cbi danh npc 2 1/4.")
        self.ex = 0.4
        return moveToCell(5, 12)
    elseif self.ex == 0.4 then
        sys.debug("quest", "cbi danh npc 2 2/4.")
        self.ex = 0.5
        return moveToCell(9, 12)
    elseif self.ex == 0.5 then
        sys.debug("quest", "cbi danh npc 2 3/4.")
        self.ex = 0.6
        return moveToCell(9, 7)
    elseif self.ex == 0.6 then
        sys.debug("quest", "cbi danh npc 2 4/4.")
        self.ex = 0.7
        return moveToCell(12, 7)
    elseif self.ex == 0.7 then
        sys.debug("quest", "danh npc 2.")
        self.ex = 0.8
        return moveToCell(12, 7)
    elseif self.ex == 0.8 then
        sys.debug("quest", "qua man.")
        self.ex = 0.9
        return moveToCell(9, 4)
    else
        self.ex = 0
        return moveToCell(9, 14)
    end
end
function EightBadgeQuest:SunyShoreGym()
	if not hasItem("Beacon Badge") then
        sys.debug("quest", "Going to beat Sunyshore City Gym.")
        self.ex = 0.1
        return moveToCell(9, 4)
    else
        return moveToCell(9, 14)
    end
end
function EightBadgeQuest:PokecenterSunyshore()
	if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 7)
	else
		self.registeredPokecenter = "Pokecenter Sunyshore" 
		return moveToCell(8, 15)
	end
end
function EightBadgeQuest:SunyshoreCity()  
    if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Sunyshore" then
        sys.debug("quest", "Going to heal.")
        return moveToCell(29, 48)
    elseif not hasItem("Beacon Badge") then
        sys.debug("quest", "Going to Sunyshore City Gym.")
        return moveToCell(14, 14)
    end
end
function EightBadgeQuest:Route222()
    sys.debug("quest", "Going to Sunyshore City.")
    sys.debug("quest", "Current| ex = " .. tostring(self.ex))
    return moveToCell(107, 24)
end
function EightBadgeQuest:Route222StopHouse() 
    sys.debug("quest", "Going to Sunyshore City.")
    sys.debug("quest", "Current| ex = " .. tostring(self.ex))
    return moveToCell(10, 6)
end
function EightBadgeQuest:ValorLakefront()  
    sys.debug("quest", "Going to Sunyshore City.")
    sys.debug("quest", "Current| ex = " .. tostring(self.ex))
    return moveToCell(61, 45)
end
function EightBadgeQuest:Route214()  
    sys.debug("quest", "Going to Sunyshore City.")
    sys.debug("quest", "Current| ex = " .. tostring(self.ex))
    return moveToCell(28, 96)
end
function EightBadgeQuest:SendoffSpring()  
    if isNpcOnCell(34, 18) then
        sys.debug("quest", "Talk to wife.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.6
        return talkToNpcOnCell(34, 18)
    end
end
function EightBadgeQuest:DistortionWorld()  
    if isNpcOnCell(72, 44) then
        sys.debug("quest", "Beat Cyrus.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.5
        return talkToNpcOnCell(72, 44)
    elseif isNpcOnCell(76, 41) then
        sys.debug("quest", "Beat Giratina.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.6
        return talkToNpcOnCell(76, 41)
    end
end
function EightBadgeQuest:SpearPillar()
    if isNpcOnCell(11, 13) then
        sys.debug("quest", "Talk to Cyrus.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.4
        return talkToNpcOnCell(11, 13)
    elseif isNpcOnCell(12, 13) then
        sys.debug("quest", "Talk to Cynthia.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.4
        return talkToNpcOnCell(12, 13)
    else
        sys.debug("quest", "Going to Veilstone City.")
        return moveToCell(11, 39)
    end
end
function EightBadgeQuest:MtCoronet7F()
    if self.ex == 1.3 then
        sys.debug("quest", "Going to the top of Mt.Coronet.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.3
        return moveToCell(18, 10)
    else
        sys.debug("quest", "Going to Veilstone City.")
        return moveToCell(22, 27)
    end
end
function EightBadgeQuest:MtCoronet6F()
    if self.ex == 1.3 then
        sys.debug("quest", "Going to the top of Mt.Coronet.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.3
        return moveToCell(5, 23)
    else
        sys.debug("quest", "Going to Veilstone City.")
        return moveToCell(11, 9)
    end
end
function EightBadgeQuest:MtCoronet5F()
    if self.ex == 1.3 and game.inRectangle(3, 4, 18, 12) then
        sys.debug("quest", "Going to the top of Mt.Coronet.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.3
        return moveToCell(16, 10)
    else
        sys.debug("quest", "Going to Veilstone City.")
        return moveToCell(4, 6)
    end
end
function EightBadgeQuest:MtCoronetSummit()
    if self.ex == 1.3 then
        sys.debug("quest", "Going to the top of Mt.Coronet.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.3
        return moveToCell(11, 9)
    else
        sys.debug("quest", "Going to Veilstone City.")
        return moveToCell(43, 16)
    end
end
function EightBadgeQuest:MtCoronetTunnel()
    if self.ex == 1.3 then
        sys.debug("quest", "Going to the top of Mt.Coronet.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.3
        return moveToCell(2, 49)
    else
        sys.debug("quest", "Going to Veilstone City.")
        return moveToCell(18, 14)
    end
end
function EightBadgeQuest:MtCoronetCenter()
    if self.ex == 1.3 then
        sys.debug("quest", "Going to the top of Mt.Coronet.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1.3
        return moveToCell(20, 47)
    else
        sys.debug("quest", "Going to Veilstone City.")
        return moveToCell(32, 23)
    end
end
function EightBadgeQuest:MtCoronetB1F()
    sys.debug("quest", "Going to Veilstone City.")
    return moveToCell(9, 54)
end
function EightBadgeQuest:MtCoronetNorth()
    sys.debug("quest", "Going to Veilstone City.")
    return moveToCell(10, 16)
end
function EightBadgeQuest:Route216()
        sys.debug("quest", "Going to Veilstone City.")
        return moveToCell(91, 18)
end
function EightBadgeQuest:Route217()
        sys.debug("quest", "Going to Veilstone City.")
        return moveToCell(19, 114)
end
function EightBadgeQuest:LakeAcuity()
    if isNpcOnCell(13, 41) then
        sys.debug("quest", "Talk to Barry.")
        self.dialogs.ToVeilstone.state = true
        return talkToNpcOnCell(13, 41)
    else
        sys.debug("quest", "Going to Veilstone City.")
        self.dialogs.ToVeilstone.state = true
        return moveToCell(11, 45)
    end
end
function EightBadgeQuest:AcuityLakefront()
    if isNpcOnCell(25, 19) then
        sys.debug("quest", "Going to Acuity Lake.")
        return talkToNpcOnCell(25, 19)
    elseif not self.dialogs.ToVeilstone.state then
        sys.debug("quest", "Going to Acuity Lake.")
        return moveToCell(25, 18)
    else
        sys.debug("quest", "Going to Veilstone City.")
        return moveToCell(22, 49)
    end
end
function EightBadgeQuest:SnowpointCity()
	if not game.isTeamFullyHealed() then
        self.ex = 0
		return moveToCell(30, 37)
    else
        self.ex = 0
		return moveToCell(0, 44)
	end
end
function EightBadgeQuest:PokecenterSnowpointCity()
	if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 7)
	else
		self.registeredPokecenter = "Pokecenter Snowpoint City"
		return moveToCell(8, 15)
	end
end
function EightBadgeQuest:SnowpointGym()
	return moveToCell(13, 29)
end

return EightBadgeQuest

