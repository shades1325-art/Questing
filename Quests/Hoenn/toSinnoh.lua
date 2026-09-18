-- Copyright � 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Atem

-- Last battle is pretty difficult, so we need to catch these Pokemon (should be sorted like that before the last battle too)
-- 1. Luxray     --done and checked
-- 2. Exeggutor  --done and checked
-- 3. Heracross  --done and checked
-- 4. Swampert   --done and checked
-- 5. Flareon    --done and checked
-- 6. Breloom    --done


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'To Sinnoh Quest'
local description = 'Going to fight Galatic Grunts & Pluton, find the 3 starters, give them to Prof. Birch and go to Sinnoh.'
local level = 0

local dialogs = {
	Stanbeaten1 = Dialog:new({ 
		"He is currently at Sky Pillar"
	}),
	Stanbeaten2 = Dialog:new({ 
		"They will avenge me"
	}),
	Charonbeaten = Dialog:new({ 
		"How can that be possible?!",
		"back to Sinnoh"
	}),
	Find3 = Dialog:new({ 
		"Can you please find them?",
		"You should check Route 101 and 102.",
		"Nice, can you bring me the other 2 Starters."
	}),
	FindLast = Dialog:new({ 
		"Treee.",
		"only 1"
	}),
	FindDone = Dialog:new({ 
		"Chiiiic.",
	}),
	ToLily = Dialog:new({ 
		"Alakazam if he can teleport you",
	}),
}

local toSinnohQuest = Quest:new()

function toSinnohQuest:new()
	local o = Quest.new(toSinnohQuest, name, description, level, dialogs)
	dialogs.Find3.state = true
	dialogs.FindLast.state = true
	dialogs.FindDone.state = true
	o.ex = 0
	return o
end

function toSinnohQuest:isDoable()
	if self:hasMap() and hasItem("Rain Badge") and not hasItem("Coal Badge") then
		return true
	end
	return false
end

function toSinnohQuest:isDone()
	if getMapName() == "Twinleaf Town Player House 2F" then
		return true
	else
		return false
	end
end

function toSinnohQuest:PlayerBedroomLittlerootTown()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(11, 5)
end

function toSinnohQuest:PlayerHouseLittlerootTown()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(11, 12)
end

function toSinnohQuest:LittlerootTown()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(23, 0)
end

function toSinnohQuest:Route101()
	if isNpcOnCell(8, 34) then
		sys.debug("quest", "Find Torchic.")
		dialogs.FindDone.state = true
		return talkToNpcOnCell(8, 34)
	else
		sys.debug("quest", "Going to Lilycove City.")
		return moveToCell(22, 0)
	end
end

function toSinnohQuest:Route102()
	if isNpcOnCell(55, 13) then
		sys.debug("quest", "Find Treecko.")
		dialogs.FindLast.state = true
		return talkToNpcOnCell(55, 13)
	else
		sys.debug("quest", "Going to Oldale Town.")
		return moveToCell(83, 18)
	end
end


function toSinnohQuest:OldaleTown()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Oldale Town" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(16, 26)
	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(28, 10)
	elseif isNpcOnCell(3, 17) then
		sys.debug("quest", "Going to talk to Stan.")
		return talkToNpcOnCell(3, 17)
	elseif dialogs.Find3.state and not dialogs.FindLast.state then
		sys.debug("quest", "Going to Rt102.")
		return moveToCell(0, 17)
	elseif dialogs.FindLast.state and not dialogs.FindDone.state then
		sys.debug("quest", "Going to Rt101.")
		return moveToCell(22, 33)
	elseif dialogs.FindDone.state then
		sys.debug("quest", "Going to Lilycove City.")
		return moveToCell(23, 0)
	else
		sys.debug("quest", "Going to Lilycove City.")
		return moveToCell(23, 0)
	end
end

function toSinnohQuest:PokecenterOldaleTown() -- here i need to make sure to add all desired pokemon to the team
	return self:pokecenter("Oldale Town")
end

function toSinnohQuest:MartOldaleTown()
	return self:pokemart()
end

function toSinnohQuest:Route103()
	if dialogs.ToLily.state then
		sys.debug("quest", "Going to Lilycove City.")
		return moveToCell(100, 19)
	end
	if isNpcOnCell(35, 17) then
		if self:needPokecenter() then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(29, 35)
		else
			sys.debug("quest", "Going to fight Pluton.")
			return talkToNpcOnCell(35, 17)
		end
	elseif isNpcOnCell(36, 15) and not (dialogs.Find3.state or dialogs.FindLast.state) then
		sys.debug("quest", "Going to talk to Prof. Birch")
		return talkToNpcOnCell(36, 15)
	end
	if (dialogs.Find3.state and dialogs.FindDone.state and dialogs.FindLast.state) then
		sys.debug("quest", "Finished. Going to talk to Prof. Birch")
		return talkToNpcOnCell(36, 15)
	end
	if dialogs.Find3.state and not dialogs.FindDone.state then
        sys.debug("quest", "Find3.state is TRUE")
        if isNpcOnCell(47, 27) then
            sys.debug("quest", "Find Mudkip.")
            return talkToNpcOnCell(47, 27)
        else
            sys.debug("quest", "Go to Oldale Town")
            return moveToCell(27, 35)
        end
    end
end


function toSinnohQuest:Route110()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(24, 3)
end

function toSinnohQuest:MauvilleCityStopHouse1()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(3, 2)
end

function toSinnohQuest:MauvilleCity()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(48, 17)
end

function toSinnohQuest:MauvilleCityStopHouse4()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(10, 6)
end

function toSinnohQuest:Route118()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(59, 0)
end

function toSinnohQuest:Route119B()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(9, 0)
end

function toSinnohQuest:Route119A()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(55, 8)
end

function toSinnohQuest:FortreeCity()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(54, 14)
end

function toSinnohQuest:Route120()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(50, 101)
end

function toSinnohQuest:Route121()
	sys.debug("quest", "Going to Lilycove City.")
	return moveToCell(85, 7)
end

function toSinnohQuest:LilycoveCity()
	if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Lilycove City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(26, 20)
	else
		if dialogs.ToLily.state then
			sys.debug("quest", "Going to Lilycove City.")
			return moveToCell(26, 38)
		else
			sys.debug("quest", "Going to talk to Paul.")
			return talkToNpcOnCell(65, 33)
		end
	end
end

function toSinnohQuest:LilycoveCityHarbor()
	sys.debug("quest", "Going to talk to Alakazam.")
	return talkToNpcOnCell(16, 6)
end 

function toSinnohQuest:PokecenterLilycoveCity()
	return self:pokecenter("Lilycove City")
end

function toSinnohQuest:Route124()
	sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
	return moveToCell(91, 39)
end

function toSinnohQuest:MossdeepCity()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(31, 55)
	else
		sys.debug("quest", "Going back to Lilycove City.")
		return moveToCell(0, 15)
	end
end

return toSinnohQuest