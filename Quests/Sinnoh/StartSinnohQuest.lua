-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local team   = require "Libs/teamlib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'Start Sinnoh Quest'
local description = 'Get first Pokemon and go to Sandgem'
local level       = 0

local dialogs = {
}

local StartSinnohQuest = Quest:new()

local checkedForBestPokemon = false
function StartSinnohQuest:new()
	local o = Quest.new(StartSinnohQuest, name, description, level, dialogs)
	o.pokemonId = 1
	o.ex = 0
	return o
end

function StartSinnohQuest:isDoable()
	if self:hasMap() and not hasItem("Coal Badge") then
		return true
	end
	return false
end

function StartSinnohQuest:isDone()
	if getMapName() == "Oreburgh City" then
		return true
	end
end

function StartSinnohQuest:TwinleafTownPlayerHouse2F()
	if getTeamSize() == 0 then
		sys.debug("quest", "Going downstair| ex = " .. tostring(self.ex))
		return moveToCell(8, 4)
	end
end

function StartSinnohQuest:TwinleafTownPlayerHouse()
	if self.ex == 0 then
		sys.debug("quest", "Talk to grandma| ex = " .. tostring(self.ex))
		self.ex = 0.1
		return talkToNpcOnCell(8, 9)
	elseif self.ex == 2 then
		sys.debug("quest", "Talk to grandma| ex = " .. tostring(self.ex))
		self.ex = 2.1
		return talkToNpcOnCell(8, 9)
	elseif self.ex == 0.1 or self.ex == 0.2 then
		sys.debug("quest", "Going back to Twinleaf Town| ex = " .. tostring(self.ex))
		self.ex = 0.2
		return moveToCell(4, 12)
	elseif self.ex == 2.1 or self.ex == 2.2 then
		sys.debug("quest", "Going back to Twinleaf Town| ex = " .. tostring(self.ex))
		self.ex = 2.2
		return moveToCell(4, 12)
	end
end

function StartSinnohQuest:TwinleafTown()
	if self.ex == 0.2 then 
		sys.debug("quest", "Going to talk to Barry| ex = " .. tostring(self.ex))
		return moveToCell(8, 14)
	elseif self.ex == 2.2 then 
		sys.debug("quest", "Going to talk to Barry mom| ex = " .. tostring(self.ex))
		return moveToCell(8, 14)
	elseif self.ex == 0.3 then
		sys.debug("quest", "Going to Route201| ex = " .. tostring(self.ex))
		return moveToCell(15, 0)
	elseif self.ex == 2.3 then
		sys.debug("quest", "Going to Route201| ex = " .. tostring(self.ex))
		return moveToCell(15, 0)
	elseif self.ex == 2 then
		sys.debug("quest", "Going to tell grandma| ex = " .. tostring(self.ex))
		return moveToCell(20, 25)
	end
end

function StartSinnohQuest:TwinleafTownRivalHouse()
	if self.ex == 0.2 then
		sys.debug("quest", "Going to talk to Barry| ex = " .. tostring(self.ex))
		return moveToCell(3, 5)
	elseif self.ex == 2.2 then
		sys.debug("quest", "Going to talk to Barry mom| ex = " .. tostring(self.ex))
		self.ex = 2.3
		return talkToNpcOnCell(12, 9)
	elseif self.ex == 0.3 or self.ex == 2.3 then
		sys.debug("quest", "leave his house| ex = " .. tostring(self.ex))
		return moveToCell(4, 12)
	end
end

function StartSinnohQuest:TwinleafTownRivalHouse2F()
	if isNpcOnCell(8, 4) then
		sys.debug("quest", "Going to talk to Barry| ex = " .. tostring(self.ex))
		return talkToNpcOnCell(8, 4)
	else
		sys.debug("quest", "leave his house| ex = " .. tostring(self.ex))
		self.ex = 0.3
		return moveToCell(1, 4)
	end
end

function StartSinnohQuest:Route201()
	if getTeamSize() == 0 and self.ex == 0.4 then
		sys.debug("quest", "Going to get Piplup| ex = " .. tostring(self.ex))
		self.ex = 0.5
		return talkToNpcOnCell(47, 20) -- piplup
	else
		if self.ex == 0.5 then
			sys.debug("quest", "Going to Sandgem Town| ex = " .. tostring(self.ex))
			self.ex = 0.5
			return moveToCell(100, 8)
		elseif self.ex == 2.3 then
			sys.debug("quest", "Going to Sandgem Town| ex = " .. tostring(self.ex))
			return moveToCell(100, 8)
		end
	end
	if getTeamSize() == 1 and self.ex == 0 then
		sys.debug("quest", "Going to Sandgem Town| ex = " .. tostring(self.ex))
		self.ex = 0.5
		return moveToCell(100, 8)
	end
	if not game.hasPokemonWithMove("Surf") then
        for i = 1, getTeamSize() do
            if useItemOnPokemon("HM03 - Surf", i) then
                log("Pokemon: " .. i .. " Try Learning: HM03 - Surf")
                break
            end
            if i == getTeamSize() then
                fatal("No pokemon in this team can learn Surf")
            end
        end
    elseif not game.hasPokemonWithMove("Cut") then
        for i = 1, getTeamSize() do
            if useItemOnPokemon("HM01 - Cut", i) then
                log("Pokemon: " .. i .. " Try Learning: HM01 - Cut")
                break
            end
            if i == getTeamSize() then
                fatal("No pokemon in this team can learn Cut")
            end
        end
    elseif not game.hasPokemonWithMove("Waterfall") then
        for i = 1, getTeamSize() do
            if useItemOnPokemon("HM07 - Waterfall", i) then
                log("Pokemon: " .. i .. " Try Learning: HM07 - Waterfall")
                break
            end
            if i == getTeamSize() then
                fatal("No pokemon in this team can learn Waterfall")
            end
        end
	end
	if isNpcOnCell(48, 19) and self.ex == 0.3 then
		sys.debug("quest", "Going to talk to Barry| ex = " .. tostring(self.ex))
		self.ex = 0.4 
		return talkToNpcOnCell(48, 19)
	end
	if self.ex == 2 then
		sys.debug("quest", "Going to tell grandma| ex = " .. tostring(self.ex))
		return moveToCell(48, 30)
	end
end

function StartSinnohQuest:PokecenterSandgemTown()
	if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 7)
	else
		self.registeredPokecenter = "Pokecenter Sandgem Town"
		self.ex = 1
		sys.debug("quest", "Current| ex = " .. tostring(self.ex))
		return moveToCell(8, 15)
	end
end

function StartSinnohQuest:SandgemTown()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Sandgem Town" then
		sys.debug("quest", "Going to heal Pokemon| ex = " .. tostring(self.ex))
		self.ex = 1
		return moveToCell(24, 8)
	elseif self.ex == 1 then
		sys.debug("quest", "Talk to Barry| ex = " .. tostring(self.ex))
		self.ex = 1.1
		return talkToNpcOnCell(14, 10)
	elseif self.ex == 1.1 then
		sys.debug("quest", "Talk to Barry| ex = " .. tostring(self.ex))
		self.ex = 1.2
		return talkToNpcOnCell(14, 10)
	elseif self.ex == 1.2 then
        sys.debug("quest", "Going to Rowan Lab| ex = " .. tostring(self.ex))
		self.ex = 1.3
		return moveToCell(14, 9)
    elseif self.ex == 2 then
		sys.debug("quest", "Going to tell grandma| ex = " .. tostring(self.ex))
		return moveToCell(0, 12)
	elseif self.ex == 2.3 then
		sys.debug("quest", "Going to Route 202| ex = " .. tostring(self.ex))
		return moveToCell(39, 0)
	end
end

function StartSinnohQuest:RowanLab()
	if self.ex == 1.3 then
		sys.debug("quest", "Talk to Rowan| ex = " .. tostring(self.ex))
		self.ex = 2
		return talkToNpcOnCell(8, 5)
	else
		sys.debug("quest", "Leave Rowan Lab| ex = " .. tostring(self.ex))
		return moveToCell(8, 15)
	end
end

function StartSinnohQuest:Route202()
	sys.debug("quest", "Going to Jubilife| ex = " .. tostring(self.ex))
	self.ex = 2.5
	return moveToCell(27, 0)
end

function StartSinnohQuest:JubilifeCity()
	if isNpcOnCell(55, 43) and self.registeredPokecenter ~= "Pokecenter Jubilife City" then
		sys.debug("quest", "Going to meet Bob| ex = " .. tostring(self.ex))
		self.ex = 2.6
		return talkToNpcOnCell(55, 43)  -- nói chuyện với Bob trước
	elseif not isNpcOnCell(55, 43) and self.registeredPokecenter ~= "Pokecenter Jubilife City" then
		sys.debug("quest", "Going to heal Pokemon| ex = " .. tostring(self.ex))
		self.ex = 3
		return moveToCell(55, 42)
	end

	-- Sau khi xử lý Bob xong, mới kiểm tra heal
	if not isNpcOnCell(55, 43) and self.ex == 2.6 then
		sys.debug("quest", "Going to heal Pokemon.")
		self.ex = 3
		return moveToCell(55, 42)
	end
	if self.ex == 3 then
		sys.debug("quest", "Going to meet School teacher| ex = " .. tostring(self.ex))
		self.ex = 3
		return moveToCell(44, 41)
	elseif self.ex == 3.1 or self.ex == 3.2 then
			if isNpcOnCell(13, 13) then
				sys.debug("quest", "Current| ex = " .. tostring(self.ex))
				talkToNpcOnCell(13, 13)
			elseif isNpcOnCell(38, 31) then
				sys.debug("quest", "Current| ex = " .. tostring(self.ex))
				talkToNpcOnCell(38, 31)
			elseif isNpcOnCell(18, 35) then
				sys.debug("quest", "Current| ex = " .. tostring(self.ex))
				talkToNpcOnCell(18, 35)	
			elseif isNpcOnCell(64, 54) then
				sys.debug("quest", "Current| ex = " .. tostring(self.ex))
				talkToNpcOnCell(64, 54)
			else
				sys.debug("quest", "Going to meet School teacher| ex = " .. tostring(self.ex))
				self.ex = 3.2
			return moveToCell(44, 41)
		end
	elseif self.ex == 3.3 then
		if isNpcOnCell(2, 25) then
			sys.debug("quest", "Current| ex = " .. tostring(self.ex))
			return talkToNpcOnCell(2, 25)
		else
			sys.debug("quest", "Current| ex = " .. tostring(self.ex))
			moveToCell(1, 25)
		end
	elseif self.ex == 3.4 then
		sys.debug("quest", "Going to Route203| ex = " .. tostring(self.ex))
		moveToCell(74, 25)
	end
end

function StartSinnohQuest:PokecenterJubilifeCity() -- here i need to make sure to add all desired pokemon to the team
	if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 7)
	else
		self.registeredPokecenter = "Pokecenter Jubilife City"
		return moveToCell(8, 15)
	end
end

function StartSinnohQuest:JubilifeTrainersSchool()
	if self.ex == 3 then
		sys.debug("quest", "Talk to Teacher| ex = " .. tostring(self.ex))
		self.ex = 3.1
		return talkToNpcOnCell(1, 8)
	elseif self.ex == 3.2 then
		sys.debug("quest", "Talk to Teacher| ex = " .. tostring(self.ex))
		self.ex = 3.3
		return talkToNpcOnCell(1, 8)
	elseif self.ex == 3.1 or self.ex == 3.3 then
		sys.debug("quest", "Going to Jubilife| ex = " .. tostring(self.ex))
		return moveToCell(7, 10)
	end
end

function StartSinnohQuest:Route218StopHouse1()
	if self.ex == 3.3 then
		sys.debug("quest", "Going to Route 218| ex = " .. tostring(self.ex))
		return moveToCell(0, 6)
	else
		sys.debug("quest", "Going to Jubilife| ex = " .. tostring(self.ex))
		return moveToCell(10, 6)
	end
end

function StartSinnohQuest:Route218()
	if self.ex == 3.3 then
		if  isNpcOnCell(52, 16) then
		sys.debug("quest", "Going to Route 218| ex = " .. tostring(self.ex))
		self.ex = 3.4
		return talkToNpcOnCell(52, 16)
		end
	else
		sys.debug("quest", "Going to Jubilife| ex = " .. tostring(self.ex))
		return moveToCell(72, 22)
	end
end

function StartSinnohQuest:Route203()
	if isNpcOnCell(4, 21) then
		sys.debug("quest", "Danh chetcondime Barry| ex = " .. tostring(self.ex))
		return talkToNpcOnCell(4, 21)
	else
		sys.debug("quest", "Going to Oreburgh| ex = " .. tostring(self.ex))
		return moveToCell(57, 9)
	end
end

function StartSinnohQuest:OreburghGate1F()
	sys.debug("quest", "Going to Oreburgh| ex = " .. tostring(self.ex))
	return moveToCell(27, 19)
end


return StartSinnohQuest
