-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local team   = require "Libs/teamlib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'OreburghCityQuest'
local description = 'Get the first badge.'
local level       = 0

local dialogs = {
	meetRoark = Dialog:new({
		"come at the Gym",
	}),
    meetLooker = Dialog:new({
		"I'll take one, you can take the other",
	}),
    talkLooker = Dialog:new({
        "You are quite annoying, but we got all the info we need.",
        "Hey, kid, can we talk for a second?",
    }),
}

local OreburghCityQuest = Quest:new()

function OreburghCityQuest:new()
	local o = Quest.new(OreburghCityQuest, name, description, level, dialogs)
	o.pokemonId = 1
    self.ex = 0
    --o.dialogs.meetRoark.state = true
	return o
end

function OreburghCityQuest:isDoable()
	if self:hasMap() and not hasItem("Coal Badge") then
		return true
	end
	return false
end

function OreburghCityQuest:isDone()
	if getMapName() == "Floaroma Town" and hasItem("Coal Badge") then --fix blackout
		return true
	end
end

function OreburghCityQuest:OreburghCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Oreburgh City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(43, 17)
    elseif not self.dialogs.meetRoark.state and not hasItem("Coal Badge") then
		sys.debug("quest", "Going to challenge Roark.")
		return moveToCell(44, 46)
    elseif self.dialogs.meetRoark.state and not hasItem("Coal Badge") then
        sys.debug("quest", "Going to hit the gym.")
        return moveToCell(27, 18)
    elseif hasItem("Coal Badge") and not hasItem("TM114 - Rock Smash") then
        sys.debug("quest", "Going to buy Rock Smash.")
        return moveToCell(32, 12)
    else
        sys.debug("quest", "Going back to Jubilife City.")
        return moveToCell(1, 13)
	end
end

function OreburghCityQuest:OreburghCityHouse2()
    if not hasItem("TM114 - Rock Smash") then
		sys.debug("quest", "Going to buy Rock Smash.")
		return talkToNpcOnCell(1, 9)
    else
        sys.debug("quest", "Going back to Oreburgh.")
        return moveToCell(2, 12)
    end
end

function OreburghCityQuest:OreburghCityGym()
    if not hasItem("Coal Badge") then
		sys.debug("quest", "Going to challenge Roark.")
		return talkToNpcOnCell(6, 2)
    else
        sys.debug("quest", "Going back to Oreburgh.")
        return moveToCell(5, 24)
    end
end


function OreburghCityQuest:OreburghMineB1F()
    if not self.dialogs.meetRoark.state then
		sys.debug("quest", "Going to challenge Roark.")
		return moveToCell(11, 28)
    else
        sys.debug("quest", "Going to the Gym.")
        return moveToCell(13, 5)
    end
end

function OreburghCityQuest:OreburghMineB2F1R()
    if isNpcOnCell(18, 22) then
        sys.debug("quest", "Going to challenge Roark.")
        self.dialogs.meetRoark.state = true
        return talkToNpcOnCell(18, 22)
    else
        sys.debug("quest", "Going to the Gym.")
        self.dialogs.meetRoark.state = true
        return moveToCell(41, 2)
    end
end

function OreburghCityQuest:OreburghMineB2F2R()
    sys.debug("quest", "Going to the Gym.")
    self.dialogs.meetRoark.state = true
        return moveToCell(3, 1)
end

function OreburghCityQuest:PokecenterOreburghCity()
	if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 7)
	else
		self.registeredPokecenter = "Pokecenter Oreburgh City"
		return moveToCell(8, 15)
	end
end

function OreburghCityQuest:OreburghGate1F()
    sys.debug("quest", "Going back to Jubilife City.")
        return moveToCell(2, 19)
end

function OreburghCityQuest:Route203()
    sys.debug("quest", "Going back to Jubilife City.")
        return moveToCell(0, 21)
end

function OreburghCityQuest:Route204()
    if isNpcOnCell(10, 35) then
        sys.debug("quest", "talkToNpcOnCell(10, 35)")
        return talkToNpcOnCell(10, 35)
    elseif game.inRectangle(5, 33, 15, 41) then
        return moveToCell(10, 34)
    elseif game.inRectangle(0, 0, 34, 23) then
        return moveToCell(10, 0)
    end
end

function OreburghCityQuest:RavagedPath()
    if not game.hasPokemonWithMove("Rock Smash") then
        if not self.pokemonIdToTeachRockSmash then
            self.pokemonIdToTeachRockSmash = 1
        end

        if self.pokemonIdToTeachRockSmash <= 6 then
            log("Trying to teach Rock Smash to Pokémon #" .. self.pokemonIdToTeachRockSmash)
            local result = useItemOnPokemon("TM114 - Rock Smash", self.pokemonIdToTeachRockSmash)
            self.pokemonIdToTeachRockSmash = self.pokemonIdToTeachRockSmash + 1
            return result
        else
            fatal("None of Pokémon 1 to 6 can learn Rock Smash.")
        end
    else
        sys.debug("quest", "Going to Floaroma town.")
        return moveToCell(30, 41)
    end
end

function OreburghCityQuest:JubilifeCity()
    if not self.dialogs.meetLooker.state then
        if isNpcOnCell(50, 6) then
            sys.debug("quest", "Going back to Route204.")
            self.dialogs.meetLooker.state = true
            return talkToNpcOnCell(50, 6)
        end
    elseif self.dialogs.meetLooker.state then
        if isNpcOnCell(51, 6) then
            return talkToNpcOnCell(51, 6)
    elseif self.dialogs.talkLooker.state then
            sys.debug("quest", "Going back to Route204.")
            return moveToCell(50, 0)
        end
    end
end

return OreburghCityQuest

