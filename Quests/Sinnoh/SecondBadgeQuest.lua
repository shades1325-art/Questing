-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local team   = require "Libs/teamlib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'SecondBadgeQuest'
local description = 'Get the 2nd badge. Doing all related quest from Floaroma Town to end of Eterna City.'
local level       = 0

local dialogs = {
	SandyRequest = Dialog:new({
		"so please save my papa out of there!",
        "Please save my papa! I'm worried about him.",
        "save my papa",
	}),
    GalaticGrunt = Dialog:new({
		"password",
	}),
    RescueMission = Dialog:new({
		"Can you please look for them?",
        "still missing",
	}),
    meetLooker = Dialog:new({
		"I'll take one, you can take the other",
		"There you go, sweetie,",
	}),
    talkLooker = Dialog:new({
        "Hey, kid, can we talk for a second?",
    }),
    investGalatic = Dialog:new({
        "How was the investigation in that building?",
    }),
    GymQuest = Dialog:new({
        "Thanks for your help, Eterna Gym is open again since all things are settled.",
        "At my Gym, no one gets to battle with the Gym Leader - me - until they've beaten all the other Trainers.",
        "Good luck, challenger!"
    }),
    
}

local SecondBadgeQuest = Quest:new()

function SecondBadgeQuest:new()
	local o = Quest.new(SecondBadgeQuest, name, description, level, dialogs)
	o.pokemonId = 1
    --o.dialogs.GymQuest.state = false
    o.ex = 0
	return o
end

function SecondBadgeQuest:isDoable()
	if self:hasMap() and hasItem("Coal Badge") and not hasItem("Forest Badge") then
		return true
	end
	return false
end

function SecondBadgeQuest:isDone()
	if getMapName() == "Route 206" or getMapName() == "xxx" then --fix blackout
		return true
	end
end
function SecondBadgeQuest:PokecenterOreburghCity()
	if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 7)
	else
		self.registeredPokecenter = "Pokecenter Oreburgh City"
		return moveToCell(8, 15)
	end
end
function SecondBadgeQuest:OreburghCityGym()
        sys.debug("quest", "Going back to Oreburgh.")
        return moveToCell(5, 24)
end
function SecondBadgeQuest:OreburghCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Oreburgh City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(43, 17)
    elseif hasItem("Coal Badge") and not hasItem("TM114 - Rock Smash") then
        sys.debug("quest", "Going to buy Rock Smash.")
        return moveToCell(32, 12)
    else
        sys.debug("quest", "Going back to Jubilife City.")
        return moveToCell(1, 13)
	end
end
function SecondBadgeQuest:OreburghCityHouse2()
    if not hasItem("TM114 - Rock Smash") then
		sys.debug("quest", "Going to buy Rock Smash.")
		return talkToNpcOnCell(1, 9)
    else
        sys.debug("quest", "Going back to Oreburgh.")
        return moveToCell(2, 12)
    end
end
function SecondBadgeQuest:OreburghGate1F()
    sys.debug("quest", "Going back to Jubilife City.")
        return moveToCell(2, 19)
end

function SecondBadgeQuest:Route203()
    sys.debug("quest", "Going back to Jubilife City.")
        return moveToCell(0, 21)
end

function SecondBadgeQuest:Route204()
    if isNpcOnCell(10, 35) then
        sys.debug("quest", "talkToNpcOnCell(10, 35)")
        return talkToNpcOnCell(10, 35)
    elseif game.inRectangle(0, 33, 15, 47) then
        return moveToCell(10, 34)
    elseif game.inRectangle(0, 0, 34, 31) then
        return moveToCell(10, 0)
    end
end

function SecondBadgeQuest:RavagedPath()
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

function SecondBadgeQuest:JubilifeCity()
    if not self.dialogs.meetLooker.state then
        if isNpcOnCell(50, 6) then
            sys.debug("quest", "Going back to Route204.")
            self.dialogs.meetLooker.state = true
            return talkToNpcOnCell(50, 6)
        end
    elseif self.dialogs.meetLooker.state then
        if isNpcOnCell(51, 6) then
            return talkToNpcOnCell(51, 6)
        elseif isNpcOnCell(50, 6) then
            return talkToNpcOnCell(50, 6)
        else  
            sys.debug("quest", "Going back to Route204.")
            return moveToCell(50, 0)
        end
    end
end
function SecondBadgeQuest:FloaromaTown()
	if not game.isTeamFullyHealed() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(25, 34)
    elseif self.ex == 0 or self.ex == 0.5 then
        sys.debug("quest", "Going to Route 205.")
        return moveToCell(45, 28)
    elseif self.ex == 0.3 then
        sys.debug("quest", "Get the password.")
        return moveToCell(13, 4)
	end
end

function SecondBadgeQuest:EternaCity()
    if not game.hasPokemonWithMove("Cut") then
        if not self.pokemonIdToTeach then
            self.pokemonIdToTeach = 1
        end

        if self.pokemonIdToTeach <= 6 then
            log("Trying to teach Rock Smash to Pokémon #" .. self.pokemonIdToTeach)
            local result = useItemOnPokemon("HM01 - Cut", self.pokemonIdToTeach)
            self.pokemonIdToTeach = self.pokemonIdToTeach + 1
            return result
        else
            fatal("None of Pokémon 1 to 6 can learn Cut.")
        end
    end
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Eterna City" then
		sys.debug("quest", "Going to heal Pokemon.")
        self.ex = 1
		return moveToCell(17, 20)
    elseif self.ex == 1 then
        if isNpcOnCell(26, 48) then
            self.ex = 1.1
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            return talkToNpcOnCell(26, 48)
        else
            self.ex = 2.2
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            return moveToCell(26, 47)
        end
    elseif dialogs.GymQuest.state then
        self.ex = 2.2
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(26, 47)
    elseif self.ex == 1.1 then
        self.ex = 1.11
        sys.debug("quest", "Current| Khong chat duoc cay, chat cay xong di vao galatic building de tiep tuc quest.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(19, 13)
    elseif self.ex == 1.11 then
        self.ex = 1.12
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(19, 11)
    elseif isNpcOnCell(19, 9) or self.ex == 1.12 then
        self.ex = 1.13
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return talkToNpcOnCell(19, 9)
    elseif self.ex == 1.13 then
        self.ex = 1.3
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(19, 8)
    elseif self.ex == 2 then
        self.ex = 2.1
        sys.debug("quest", "Current| Khong chat duoc cay, vao pokecenter de tiep tuc quest.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return talkToNpcOnCell(26, 48)
    elseif self.ex == 2.1 then
        self.ex = 2.2
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(26, 47)
    end
    if hasItem("Forest Badge") then
        return moveToCell(18, 56)
    end
end

function SecondBadgeQuest:EternaGym()
    if not hasItem("Forest Badge") then
        if self.ex == 2.2 then
            self.ex = 2.3
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            return talkToNpcOnCell(5, 32)
        elseif self.ex == 2.3 then
            self.ex = 2.4
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            return talkToNpcOnCell(22, 26)
        elseif self.ex == 2.4 then
            self.ex = 2.5
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            return talkToNpcOnCell(9, 14)
        elseif self.ex == 2.5 then
            self.ex = 2.6
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            return talkToNpcOnCell(24, 9)
        elseif self.ex == 2.6 then
            self.ex = 2.7
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            return talkToNpcOnCell(15, 4)
        end
    else
        moveToCell(17, 34)
	end
end

function SecondBadgeQuest:EternaGalacticBuilding1F()
    if isNpcOnCell(2, 7) then
        sys.debug("quest", "Pkm 1F 1/1 .Mission 2/3")
        self.ex = 1.4
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return talkToNpcOnCell(2, 7)
    end
    if self.ex == 1.4 then
        sys.debug("quest", "Mission 2/3")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(12, 8)
    end
    if self.ex == 0 then
        sys.debug("quest", "Mission 1/3")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(18, 8)
    if self.ex == 1.2 or self.ex == 1.5 then
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(18, 8)
    elseif self.ex == 2 then
        sys.debug("quest", "Mission Finished")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(10, 17)
	end
end

function SecondBadgeQuest:EternaGalacticBuilding2F()
    if game.inRectangle(0, 2, 4, 12) then 
        if isNpcOnCell(0, 12) then
            self.ex = 1.5
            sys.debug("quest", "Mission 2/3")
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            return talkToNpcOnCell(0, 12)
        else
            self.ex = 1.5
            sys.debug("quest", "Mission 2/3")
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            return moveToCell(3, 4)
        end
    end
    if self.ex == 1.2 then
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(18, 4)
    elseif self.ex == 0 or self.ex == 1.5 then
        sys.debug("quest", "Mission 1/3")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(12, 4)
    elseif self.ex == 1.3 then
        sys.debug("quest", "Mission 2/3")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(8, 4)
    elseif self.ex == 2 then
        sys.debug("quest", "Mission Finished")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(8, 4)
	end
end

function SecondBadgeQuest:EternaGalacticBuilding3F()
    if isNpcOnCell(21, 11) then 
        self.ex = 1.1
        sys.debug("quest", "Pkm 3F 1/3 .Mission 2/3")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return talkToNpcOnCell(21, 11)
    elseif isNpcOnCell(2, 13) then 
        self.ex = 1.1
        sys.debug("quest", "Pkm 3F 2/3 .Mission 2/3")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return talkToNpcOnCell(2, 13)
    elseif game.inRectangle(5, 2, 10, 11) then 
        if isNpcOnCell(8, 9) then
            self.ex = 1.3
            sys.debug("quest", "Pkm 3F 3/3 .Mission 2/3")
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            return talkToNpcOnCell(8, 9)
        else
            sys.debug("quest", "Pkm 3F 3/3 .Mission 2/3")
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            self.ex = 1.3
            return moveToCell(8, 4)
        end
    elseif self.ex == 0 or self.ex == 1.5 then
        sys.debug("quest", "Mission 1/3")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(12, 4)
    elseif self.ex == 1.1 then
        sys.debug("quest", "Mission 2/3")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(18, 4)
    elseif self.ex == 1.2 then
        sys.debug("quest", "Mission 2/3")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(3, 4)
    elseif self.ex == 1.8 then
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(18, 4)
    elseif self.ex == 2 then
        sys.debug("quest", "Mission Finished")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(3, 4)
	end
end

function SecondBadgeQuest:EternaGalacticBuilding4F()
    if self.ex == 0 or self.ex == 1 then
        if isNpcOnCell(21, 4) then
            self.ex = 1
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            return talkToNpcOnCell(21, 4)
        else
            if isNpcOnCell(18, 4) then
                self.ex = 1.1
                return talkToNpcOnCell(18, 4)
            end
        end
    elseif game.inRectangle(5, 2, 11, 7) then
        if isNpcOnCell(9, 5) then
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            self.ex = 1.2
            sys.debug("quest", "Pkm 4F 1/1 .Mission 2/3")
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            return talkToNpcOnCell(9, 5)
        else
            self.ex = 1.2
            sys.debug("quest", "Pkm 4F 1/1 .Mission 2/3")
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            return moveToCell(8, 3)
        end
    elseif self.ex == 1.5 then
        if isNpcOnCell(18, 4) then
            self.ex = 2
            return talkToNpcOnCell(18, 4)
        else
            self.ex = 2
            sys.debug("quest", "Mission Finished")
            return moveToCell(3, 3)
        end
    elseif self.ex == 1.1 then
        sys.debug("quest", "Doing Mission 2/3")
        return moveToCell(3, 3) 
    elseif self.ex == 2 then
        sys.debug("quest", "Mission Finished")
        return moveToCell(3, 3)
	end
end

function SecondBadgeQuest:Route205()
    if self.ex == 0 then
		sys.debug("quest", "Talk to Sandy.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 0.1
		return talkToNpcOnCell(21, 105)
    elseif self.ex == 0.1 then
        sys.debug("quest", "Going to Valley Windwork.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 0.2
        return moveToCell(39, 107)
    elseif self.ex == 0.5 then
        sys.debug("quest", "Going to Valley Windwork.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 0.5
        return moveToCell(39, 107)
    elseif self.ex == 0.3 then
        sys.debug("quest", "Get the password.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(0, 108)
    elseif self.ex == 1 and not game.inRectangle(21, 4, 64, 28) then
        sys.debug("quest", "Going to Eterna Forest.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(15, 28)
    end
    if game.inRectangle(21, 4, 64, 28) then
        self.ex = 1
        return moveToCell(64, 20)
    end
end

function SecondBadgeQuest:ValleyWindworks()
    if self.ex == 0.2 then
		sys.debug("quest", "Talk to Galatic Grunt.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 0.3
		return talkToNpcOnCell(19, 63)
    elseif self.ex == 0.3 then
        sys.debug("quest", "Going to Route 205")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 0.3
        return moveToCell(0, 72)
    elseif self.ex == 1 then
        sys.debug("quest", "Going to Route 205")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1
        return moveToCell(0, 72)
    elseif self.ex == 0.5 then
        sys.debug("quest", "Going to save Sandy papa")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 0.6
        return talkToNpcOnCell(19, 62)
    elseif self.ex == 0.6 then
        sys.debug("quest", "Going to save Sandy papa")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 0.7
        return moveToCell(19, 62)
    end
end

function SecondBadgeQuest:ValleyWindworksInterior()
    if isNpcOnCell(22, 6) then
		sys.debug("quest", "Fight Commander Mars.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1
		return talkToNpcOnCell(22, 6)
    else
        sys.debug("quest", "Leave Valley Winworks")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        self.ex = 1
        return moveToCell(12, 16)
    end
end

function SecondBadgeQuest:EternaCityStopHouse()
        return moveToCell(4, 12)
end

function SecondBadgeQuest:FloaromaMeadow()
    if self.ex == 0.3 then
        if isNpcOnCell(15, 36) then
            sys.debug("quest", "Talk to Galatic Grunt.")
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            self.ex = 0.4
            return talkToNpcOnCell(15, 36)
        else
            self.ex = 0.4
        end
    end

    if self.ex == 0.4 then
        if isNpcOnCell(16, 36) then
            sys.debug("quest", "Talk to Old Man.")
            sys.debug("quest", "Current| ex = " .. tostring(self.ex))
            self.ex = 0.5
            return talkToNpcOnCell(16, 36)
        else
            self.ex = 0.5
        end
    end

    if self.ex == 0.5 then
        sys.debug("quest", "Talk to grandma| ex = " .. tostring(self.ex))
        return moveToCell(16, 42)
    end
end
function SecondBadgeQuest:EternaForest()
        sys.debug("quest", "Going to Eterna City.")
        sys.debug("quest", "Current| ex = " .. tostring(self.ex))
        return moveToCell(78, 32)
end

function SecondBadgeQuest:PokecenterFloaroma()
	if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 7)
	else
		self.registeredPokecenter = "Pokecenter Floaroma"
		return moveToCell(8, 15)
	end
end

function SecondBadgeQuest:PokecenterEternaCity()
	if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 7)
	else
		self.registeredPokecenter = "Pokecenter Eterna City"
		return moveToCell(8, 15)
	end
end

return SecondBadgeQuest

