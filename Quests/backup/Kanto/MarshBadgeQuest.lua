-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex

local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Marsh Badge'
local description = 'Get Badge + Dojo Pokemon'

local dialogs = {
    dojoSaffronDone = Dialog:new({
        "tomodachi"
    })
}

local MarshBadgeQuest = Quest:new()

function MarshBadgeQuest:new()
    if not KANTO_DOJO_POKEMON_ID then
        KANTO_DOJO_POKEMON_ID = math.random(1, 2)
    end
    local o = Quest.new(MarshBadgeQuest, name, description, level, dialogs)
    o.dojoState = false
    return o
end

function MarshBadgeQuest:isDoable()
    if self:hasMap() and not hasItem("Marsh Badge") then
        return true
    else
        return false
    end
end

function MarshBadgeQuest:isDone()
    if hasItem("Marsh Badge") and getMapName() == "Lavender Town"
    or getMapName() == "Silph Co 1F"
    or getMapName() == "Route 5" then
        return true
    else
        return false
    end
end

function MarshBadgeQuest:SaffronCity()
    if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Saffron" then
        sys.debug("quest", "Going to heal Pokemon.")
        return moveToCell(19, 45)

    elseif isNpcOnCell(49, 14) then -- Rocket on Saffron Gym Entrance
        sys.debug("quest", "Going to Silph Co.")
        return moveToCell(33, 34)

    elseif not dialogs.dojoSaffronDone.state then --Need Check dojo
        sys.debug("quest", "Going to Dojo.")
        return moveToCell(42, 13)

    elseif not hasItem("Marsh Badge") then
        sys.debug("quest", "Going to fight 6th Gym.")
        return moveToCell(49, 13)

    elseif hasItem("Marsh Badge") then
        sys.debug("quest", "Going to Lavender Town.")
        return moveToCell(60, 39)
    end
end

function MarshBadgeQuest:PokecenterSaffron()
    return self:pokecenter("Saffron City")
end

function MarshBadgeQuest:SaffronDojo()
    if isNpcOnCell(7, 5) then
        if dialogs.dojoSaffronDone.state then
            if isNpcOnCell(3, 4) and isNpcOnCell(10, 4) then
                if KANTO_DOJO_POKEMON_ID == 1 then
                    return talkToNpcOnCell(3, 4) -- Hitmonchan
                else
                    return talkToNpcOnCell(10, 4) -- Hitmonlee
                end
            else
                sys.debug("quest", "Going back to Saffron City.")
                return moveToCell(7, 15)
            end
        else
            sys.debug("quest", "Going to talk to Koichi.")
            return talkToNpcOnCell(7, 5)
        end
    else
        dialogs.dojoSaffronDone.state = true
        sys.debug("quest", "Going back to Saffron City.")
        return moveToCell(6, 15)
    end
end

function MarshBadgeQuest:SaffronGym()
    if not hasItem("Marsh Badge") then
        if game.inRectangle(9, 16, 15, 22) then -- Middle, Bottom
            sys.debug("quest", "Going to fight Sabrina.")
            return moveToCell(15, 17)
        elseif game.inRectangle(17, 16, 23, 20) then -- Right, Bottom
            sys.debug("quest", "Going to fight Sabrina.")
            return moveToCell(18, 20)
        elseif game.inRectangle(1, 16, 7, 20) then -- Left, Bottom
            sys.debug("quest", "Going to fight Sabrina.")
            return moveToCell(2, 17)
        elseif game.inRectangle(17, 2, 23, 6) then -- Right, Top
            sys.debug("quest", "Going to fight Sabrina.")
            return moveToCell(18, 6)
        elseif game.inRectangle(1, 2, 7, 6) then -- Left, Top
            sys.debug("quest", "Going to fight Sabrina.")
            return moveToCell(2, 6)
        elseif game.inRectangle(9, 9, 15, 13) then
            sys.debug("quest", "Going to fight Sabrina.")
            return talkToNpcOnCell(12, 10)
        end
    else
        if game.inRectangle(9, 9, 15, 13) then
            sys.debug("quest", "Going back to Saffron City.")
            return moveToCell(10, 13)
        elseif game.inRectangle(9, 16, 15, 22) then
            sys.debug("quest", "Going back to Saffron City.")
            return moveToCell(12, 22)
        end
    end
end

function MarshBadgeQuest:Route8StopHouse()
    if not hasItem("Marsh Badge") then
        sys.debug("quest", "Going to Saffron City.")
        return moveToCell(0, 6)
    else
        sys.debug("quest", "Going to Lavender Town.")
        return moveToCell(10, 6)
    end
end

function MarshBadgeQuest:Route8()
    if hasItem("Marsh Badge") then
        sys.debug("quest", "Going to Lavender Town.")
        return moveToCell(72, 10)
    else
        sys.debug("quest", "Going to Saffron City.")
        return moveToCell(3, 12)
    end
end

return MarshBadgeQuest