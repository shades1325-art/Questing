-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @WiWi__33[NetPapa]


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Dynamo Badge'
local description = 'Will earn Dynamo Badge'
local level = 0

local relogged = false

local DynamoBadge = Quest:new()

function DynamoBadge:new()
	o = Quest.new(DynamoBadge, name, description, level, dialogs)
	o.pokemonId = 1
	return o
end

function DynamoBadge:isDoable()
	if self:hasMap() and not  hasItem("Dynamo Badge") then
		return true
	end
	return false
end

function DynamoBadge:isDone()
	if  hasItem("Dynamo Badge") and getMapName() == "Mauville City Gym" then
		return true
	else
		return false
	end
end

function DynamoBadge:MauvilleCity()
	if not hasItem("TM114 - Rock Smash") and not game.hasPokemonWithMove("Rock Smash") then
		sys.debug("quest", "Going to get Rock Smash.")
		return moveToCell(39, 23)

	elseif not game.hasPokemonWithMove("Rock Smash") then
		if self.pokemonId < getTeamSize() then
			useItemOnPokemon("TM114 - Rock Smash", self.pokemonId)
			log("Pokemon: " .. self.pokemonId .. " Try Learning: TM114 - Rock Smash")
			self.pokemonId = self.pokemonId + 1
		else
			fatal("No pokemon in this team can learn Rock Smash")
		end

	elseif self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Mauville City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(28, 13)

	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(29, 23)

	elseif isNpcOnCell(12, 14) then
		sys.debug("quest", "Going to talk to NPC in front of the gym.")
		return talkToNpcOnCell(13, 14)

	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(2, 17)

	elseif not hasItem("Dynamo Badge") then 
		sys.debug("quest", "Going to get 3rd badge.")
		return moveToCell(13, 13)

	end
end

function DynamoBadge:MauvilleCityHouse2()
	if not hasItem("TM114 - Rock Smash") then
		sys.debug("quest", "Going to get Rock Smash.")
		return talkToNpcOnCell(2, 6)
	else	
		sys.debug("quest", "Going back.")
		return moveToCell(5, 11)
	end
end

function DynamoBadge:PokecenterMauvilleCity()
	return self:pokecenter("Mauville City")
end

function DynamoBadge:MartMauvilleCity()
	return self:pokemart()
end

function DynamoBadge:MauvilleCityStopHouse2()
	if not self:isTrainingOver() and not self:needPokecenter() then 
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(0, 6)
	else
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(10, 6)
	end
end

function DynamoBadge:Route117()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(101, 33)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToRectangle(86, 41, 94, 44)
	else
		sys.debug("quest", "Going back.")
		return moveToCell(101, 33)
	end
end


function DynamoBadge:MauvilleCityGym()
	-- for reference: https://i.imgur.com/OoElWvN.png
	local barrierA = isNpcOnCell(6, 17) and isNpcOnCell(7, 17) and isNpcOnCell(8, 17)
	local barrierB = isNpcOnCell(5, 16) and isNpcOnCell(5, 15) and isNpcOnCell(5, 14)
	local barrierC = isNpcOnCell(2, 13) and isNpcOnCell(3, 13) and isNpcOnCell(4, 13)
	local barrierD = isNpcOnCell(6, 13) and isNpcOnCell(7, 13) and isNpcOnCell(8, 13)
	local barrierE = isNpcOnCell(10, 13) and isNpcOnCell(11, 13) and isNpcOnCell(12, 13)
	local barrierF = isNpcOnCell(6, 9) and isNpcOnCell(7, 9) and isNpcOnCell(8, 9)
	local barrierG = isNpcOnCell(9, 14) and isNpcOnCell(9, 15) and isNpcOnCell(9, 16)
	local barrierH = isNpcOnCell(9, 10) and isNpcOnCell(9, 11) and isNpcOnCell(9, 12)

	if hasItem("Dynamo Badge") then
		return moveToCell(7, 25)

	else
		if barrierA and barrierB and barrierC and barrierD and barrierE and barrierF then
			sys.debug("quest", "Receptor a")
			return talkToNpcOnCell(1, 19)

		elseif barrierA and barrierB and barrierC and barrierD and barrierF then
			sys.debug("quest", "Fight trainer.")
			return talkToNpcOnCell(1, 17)

		elseif barrierA and barrierC and barrierD and barrierF and barrierG then
			sys.debug("quest", "Receptor b")
			return talkToNpcOnCell(7, 15)

		elseif barrierA and barrierC and barrierE and barrierF and barrierG then
			if game.inRectangle(5, 13, 9, 17) then
				return moveToCell(7, 12)
			else
				sys.debug("quest", "Receptor d")
				return talkToNpcOnCell(3, 11)
			end

		elseif barrierA and barrierF and barrierG then
			sys.debug("quest", "Receptor d")
			return talkToNpcOnCell(3, 11)

		elseif barrierA and barrierF and barrierE then
			sys.debug("quest", "Receptor b")
			return talkToNpcOnCell(7, 15)

		elseif barrierA and barrierD and barrierF then
			if game.inRectangle(5, 13, 9, 17) then
				return moveToCell(11, 16)
			else
				sys.debug("quest", "Receptor c")
				return talkToNpcOnCell(11, 11)
			end

		elseif barrierA and barrierD and barrierH then
			if game.inRectangle(10, 10, 13, 12) then
				return moveToCell(11, 15)
			elseif game.inRectangle(10, 14, 13, 16) then
				return moveToCell(3, 15)
			elseif game.inRectangle(1, 14, 4, 16) then
				sys.debug("quest", "Moving in front of Wattson, going to remove all barriers.")
				return moveToCell(7, 3)
			else
				-- The gym can briefly leave the player at (7,18) while the
				-- server publishes the next puzzle state. Treat that as an
				-- intentional bounded wait. The next puzzle-state branch will
				-- request movement and automatically resume stuck detection.
				return waitForState(2000)
			end

		else
			if not self.relogged then
				self.relogged = true
				return relog(60, "Can't talk to NPC -> relog")
			else
				sys.debug("quest", "Getting badge.")
				return talkToNpcOnCell(7, 1)
			end
		end
	end
end

return DynamoBadge
