-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local team   = require "Libs/teamlib"
local pc	 = require "Libs/pclib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local luaPokemonData = require "Data/luaPokemonData"

local name		  = 'Volcano Badge'
local description = 'Revive Fossil + Cinnabar Key + Exp on Seafoam B4F'
local level = 1

local VolcanoBadgeQuest = Quest:new()

function VolcanoBadgeQuest:new()
	local o = Quest.new(VolcanoBadgeQuest, name, description, level)
	o.checkedForBestPokemon = false
	o.relogged = false
	return o
end

function VolcanoBadgeQuest:isDoable()
	if self:hasMap() and not hasItem("Earth Badge") then
		return true
	end
	return false
end

function VolcanoBadgeQuest:isDone()
	if getMapName() == "Cinnabar Lab" or getMapName() == "Cinnabar mansion 1" or getMapName() == "Route 21" then
		return true
	end
	return false
end

function VolcanoBadgeQuest:isTrainingOver()
	if getTeamSize() >= 2 and team.getHighestLvl() >= self.level then
		return true
	end
	return false
end

function VolcanoBadgeQuest:farmForBikeNeeded()
	if getMoney() < 100 then -- bike voucher is just 60k, but the 15k are for backup, in case we buy pokeballs
		return true
	else
		return false
	end
end

function VolcanoBadgeQuest:CinnabarIsland()
	if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Cinnabar" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(19, 26)

	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(25, 24)

	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(45, 28)

	elseif self:farmForBikeNeeded() then
		sys.debug("quest", "Going to farm $" .. 70000 - getMoney() .. " more Pokedollars for Bike Voucher.")
		return moveToCell(45, 28)
		

	elseif not hasItem("Cinnabar Key") and isNpcOnCell(28, 17) then
		if isNpcOnCell(18, 15) then
			sys.debug("quest", "Going to talk to NPC in front of Cinnabar Mansion.")
			return talkToNpcOnCell(18, 15)
		else
			sys.debug("quest", "Going to Cinnabar Mansion.")
			return moveToCell(18, 14)
		end

	elseif not hasItem("Volcano Badge") then
		if isNpcOnCell(28, 17) then
			sys.debug("quest", "Going to talk to NPC in front of the 7th Gym.")
			return talkToNpcOnCell(28, 17)
		else
			sys.debug("quest", "Going to the Gym for the 7th badge.")
			return moveToCell(28, 16)
		end

	elseif hasItem("Dome Fossil") or hasItem("Helix Fossil") or hasItem("Old Amber") or hasItem("Jaw Fossil") or hasItem("Sail Fossil") then
		sys.debug("quest", "Going to revive our Fossil.")
		return moveToCell(8, 26)

	else
		if game.tryTeachMove("Surf","HM03 - Surf") == true then
			sys.debug("quest", "Going to Route 21.")
			return moveToCell(10, 0)
		end

	end
end

function VolcanoBadgeQuest:PokecenterCinnabar()
		self:pokecenter("Cinnabar Island")
end

function VolcanoBadgeQuest:CinnabarPokemart()
	self:pokemart()
end

function VolcanoBadgeQuest:Route20()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(73, 40) --Seafoam 1F
	elseif self:farmForBikeNeeded() then
		sys.debug("quest", "Going to farm $" .. 70000 - getMoney() .. " more Pokedollars for Bike Voucher.")
		return moveToCell(73, 40) --Seafoam 1F
	else
		sys.debug("quest", "Going back to Cinnabar Island.")
		return moveToCell(0, 32)
	end
end

function VolcanoBadgeQuest:Seafoam1F()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(64, 8) --Seafoam B1F
	elseif self:farmForBikeNeeded() then
		sys.debug("quest", "Going to farm $" .. 70000 - getMoney() .. " more Pokedollars for Bike Voucher.")
		return moveToCell(64, 8) --Seafoam B1F
	else
		sys.debug("quest", "Going back to Cinnabar Island.")
		return moveToCell(71, 15)
	end
end

function VolcanoBadgeQuest:SeafoamB1F()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(64, 25) --Seafoam B2F
	elseif self:farmForBikeNeeded() then
		sys.debug("quest", "Going to farm $" .. 70000 - getMoney() .. " more Pokedollars for Bike Voucher.")
		return moveToCell(64, 25) --Seafoam B2F
	else
		sys.debug("quest", "Going back to Cinnabar Island.")
		return moveToCell(85, 22)
	end
end

function VolcanoBadgeQuest:SeafoamB2F()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(63, 19) --Seafoam B3F
	elseif self:farmForBikeNeeded() then
		sys.debug("quest", "Going to farm $" .. 70000 - getMoney() .. " more Pokedollars for Bike Voucher.")
		return moveToCell(63, 19) --Seafoam B3F
	else
		sys.debug("quest", "Going back to Cinnabar Island.")
		return moveToCell(51, 27)
	end
end

function VolcanoBadgeQuest:SeafoamB3F()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(57, 26) --Seafom B4F
	elseif self:farmForBikeNeeded() then
		sys.debug("quest", "Going to farm $" .. 70000 - getMoney() .. " more Pokedollars for Bike Voucher.")
		return moveToCell(57, 26) --Seafom B4F
	else
		sys.debug("quest", "Going back to Cinnabar Island.")
		return moveToCell(64, 16)
	end
end

function VolcanoBadgeQuest:SeafoamB4F()
	if self:needPokecenter() then
		if getMoney() > 1500 then -- if have 1500 money
			sys.debug("quest", "Going to heal Pokemon with NPC nurse.")
			return talkToNpcOnCell(59, 13)
		else
			sys.debug("quest", "Trying to get $" .. 1500 - getMoney() .. " more Pokedollars to heal Pokemon.")
			return moveToRectangle(50, 10, 62, 32)
		end
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToNormalGround()
	elseif self:farmForBikeNeeded() then
		sys.debug("quest", "Going to farm $" .. 70000 - getMoney() .. " more Pokedollars for Bike Voucher.")
		return moveToNormalGround()
	else
		sys.debug("quest", "Going back to Cinnabar Island.")
		return moveToCell(53, 28)
	end
end

function VolcanoBadgeQuest:CinnabarGym()
	if not hasItem("Volcano Badge") then
		if isNpcOnCell(5, 7) then
			sys.debug("quest", "Going to remove Mew from map.")
			return moveToCell(6, 11)
		elseif isNpcOnCell(6, 7) then
			if not self.relogged then
				self.relogged = true
				return relog(60, "Need to relog, because Blaine NPC cannot be talked to...")
			else
				sys.debug("quest", "Going to talk to Blaine.")
				return talkToNpcOnCell(6, 7) -- blaine moves here after prompting mew?
			end
		else
			sys.debug("quest", "Going to Cinnabar Gym B1F.")
			return moveToCell(6, 5)
		end
	else
		sys.debug("quest", "Going back to Cinnabar Island.")
		return moveToCell(27, 24)
	end
end

function VolcanoBadgeQuest:CinnabarGymB1F()
	if not hasItem("Volcano Badge") then
		sys.debug("quest", "Going to fight Blaine for 7th badge.")
		return talkToNpcOnCell(18, 16)
	else
		sys.debug("quest", "Going back to Cinnabar Island.")
		return moveToCell(7, 5)
	end
end

return VolcanoBadgeQuest