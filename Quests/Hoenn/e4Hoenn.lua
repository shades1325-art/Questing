-- Copyright � 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @WiWi__33[NetPapa]


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local team	 = require "Libs/teamlib"
local pc	 = require "Libs/pclib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local luaPokemonData = require "Data/luaPokemonData"

local name		  = 'E4 Hoenn'
local description = 'Go to the Hoenn Pokemon League and beat the E4'
local level = 0

local dialogs = {
	sidney = Dialog:new({ 
		"It looks like You are stronger than I expected."
	}),
	glacia = Dialog:new({ 
		"You and your Pokemon... How hot your spirits burn!"
	}),
	drake = Dialog:new({ 
		"You indeed have what is needed as a Pokemon Trainer."
	}),
	phoebe = Dialog:new({ 
		"bond between you and your Pokemon"
	}),
	steven = Dialog:new({ 
		"Now you may go on and continue your journey, champ. I wish you luck!"
	})
}

local e4HoennQuest = Quest:new()

local checkedForBestPokemon = false

function e4HoennQuest:new()
	local o = Quest.new(e4HoennQuest, name, description, level, dialogs)
	o.qnt_revive = 6
	o.qnt_hyperpot = 6
	return o
end

function e4HoennQuest:isDoable()
	if self:hasMap() and hasItem("Rain Badge") then
		return true
	end
	return false
end

function e4HoennQuest:isDone()
	if hasItem("Rain Badge") and getMapName() == "Player Bedroom Littleroot Town" then
		return true
	else
		return false
	end
end

-- E4 preparation needs HP/PP restored, not every party slot to be
-- considered offensively usable.  The generic needPokecenter() check can
-- stay true for a healthy utility-only or PP-exhausted slot and loop between
-- Sootopolis City and its Pokecenter.
function e4HoennQuest:needsStoryHealing()
	if self:isHeroOnlyMode() then
		return self:needPokecenter()
	end
	return not game.isTeamFullyHealed()
end

function e4HoennQuest:buyReviveItems() --return false if all items are on the bag (32x Revives 32x HyperPotions)
	if getItemQuantity("Revive") < self.qnt_revive or getItemQuantity("Hyper Potion") < self.qnt_hyperpot then
		if not isShopOpen() then
			sys.debug("quest", "Going to buy items for E4.")
			return talkToNpcOnCell(16, 22)
		else
			if getItemQuantity("Revive") < self.qnt_revive then
				if buyItem("Revive", (self.qnt_revive - getItemQuantity("Revive"))) then
					sys.debug("pokemart", "Bought: " .. self.qnt_revive - getItemQuantity("Revive") .. " Revives.")
				end
			elseif getItemQuantity("Hyper Potion") < self.qnt_hyperpot then
				if buyItem("Hyper Potion", (self.qnt_hyperpot - getItemQuantity("Hyper Potion"))) then
					sys.debug("pokemart", "Bought: " .. self.qnt_hyperpot - getItemQuantity("Hyper Potion") .. " Hyper Potions.")
				end
			end
		end
	else
		return false
	end
end

function e4HoennQuest:useReviveItems() --Return false if team don't need heal
	if not hasItem("Revive") or not hasItem("Hyper Potion") then
		return false
	end
	for pokemonId = 1, getTeamSize(), 1 do
		if getPokemonHealth(pokemonId) == 0 then
			return useItemOnPokemon("Revive", pokemonId)
		end
		if getPokemonHealthPercent(pokemonId) < 70 then
			return useItemOnPokemon("Hyper Potion", pokemonId)
		end		
	end
	return false
end

function e4HoennQuest:SootopolisCityGymB1F()
    sys.debug("quest", "Going to Hoenn E4.")
    return useItem("Escape Rope")
end

function e4HoennQuest:SootopolisCityGym1F()
    if game.inCell(22, 39) then
        sys.debug("quest", "Going to Hoenn E4.")
        return useItem("Escape Rope")
    else 
        sys.debug("quest", "Going to Hoenn E4.")
        return useItem("Escape Rope")
    end
end

function e4HoennQuest:SootopolisCity()
	if self:needsStoryHealing() or self.registeredPokecenter ~= "Pokecenter Sootopolis City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(79, 56)
	elseif not hasItem("HM07 - Waterfall") and hasItem("Rain Badge") then
		sys.debug("quest", "Going to get HM07 - Waterfall")
		return moveToCell(49, 16)
	elseif hasItem('HM07 - Waterfall') then
		local pokemonWithDive = team.getFirstPkmWithMove("Dive")
	
		pushDialogAnswer(1)
		pushDialogAnswer(pokemonWithDive)
	
		sys.debug("quest", "Going to Hoenn E4.")
		return moveToCell(50, 91)
	end
end

function e4HoennQuest:CaveofOriginEntrance()
	if not hasItem("HM07 - Waterfall") then
		sys.debug("quest", "Going to get HM07 - Waterfall")
		return moveToCell(13, 7)
	else
		sys.debug("quest", "Going back to Sootopolis City")
		return moveToCell(13, 24)
	end
end

function e4HoennQuest:CaveofOrigin1F()
	if not hasItem("HM07 - Waterfall") then
		sys.debug("quest", "Going to get HM07 - Waterfall")
		return moveToCell(21, 6)
	else
		sys.debug("quest", "Going back to Cave of Origin Entrance")
		return moveToCell(15, 24)
	end
end

function e4HoennQuest:CaveofOriginB1F()
	if not hasItem("HM07 - Waterfall") then
		sys.debug("quest", "Going to get HM07 - Waterfall")
		return moveToCell(7, 18)
	else
		sys.debug("quest", "Going back to Cave of Origin 1F")
		return moveToCell(20, 7)
	end
end

function e4HoennQuest:CaveofOriginB2F()
	if not hasItem("HM07 - Waterfall") then
		sys.debug("quest", "Going to get HM07 - Waterfall")
		return moveToCell(9, 19)
	else
		sys.debug("quest", "Going back to Cave of Origin B1F")
		return moveToCell(5, 12)
	end
end

function e4HoennQuest:CaveofOriginB3F()
	if hasItem("HM07 - Waterfall") then
		sys.debug("quest", "Going back to Cave of Origin B2F")
		return moveToCell(15, 11)
	end
end

function e4HoennQuest:PokecenterSootopolisCity()
	return self:pokecenter("Sootopolis City")
end

function e4HoennQuest:SootopolisCityUnderwater()
	sys.debug("quest", "Going to Hoenn E4.")
	return moveToCell(17, 20)
end

function e4HoennQuest:Route126Underwater()
	local pokemonWithDive = team.getFirstPkmWithMove("Dive")
	
	pushDialogAnswer(1)
	pushDialogAnswer(pokemonWithDive)
	
	sys.debug("quest", "Going to Hoenn E4.")
	return moveToCell(15, 71)
end

function e4HoennQuest:Route126()
	sys.debug("quest", "Going to Hoenn E4.")
	return moveToCell(125, 64)
end

function e4HoennQuest:Route127()
	sys.debug("quest", "Going to Hoenn E4.")
	return moveToCell(38, 93)
end

function e4HoennQuest:Route128()
	sys.debug("quest", "Going to Hoenn E4.")
	return moveToCell(123, 33)
end

function e4HoennQuest:EverGrandeCity()
	-- bottom part
	if game.inRectangle(0, 55, 56, 118) then
		if self:needsStoryHealing() or self.registeredPokecenter ~= "Pokecenter Ever Grande City" then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(45, 64)

		elseif isNpcOnCell(27, 57) then
			sys.debug("quest", "Going to talk to NPC.")
			return talkToNpcOnCell(27, 57)

		else 
			sys.debug("quest", "Going to Hoenn E4.")
			return moveToCell(27, 56)

		end

	-- top part
	else
		if isNpcOnCell(30, 35) then
			sys.debug("quest", "Going to fight Wally.")
			return talkToNpcOnCell(30, 35)

		elseif self:needsStoryHealing() or self.registeredPokecenter ~= "Pokemon League Hoenn" then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(31, 9)

		elseif not self:isTrainingOver() then
			sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
			return moveToCell(30, 34)

		else
			sys.debug("quest", "Going to Hoenn E4.")
			return moveToCell(31, 9)

		end
	end
end

function e4HoennQuest:PokecenterEverGrandeCity()
	return self:pokecenter("Ever Grande City")
end

function e4HoennQuest:VictoryRoadHoenn1F()
	-- top part
	if game.inRectangle(33, 5, 49, 14) then
		if self:needsStoryHealing() or self.registeredPokecenter ~= "Pokemon League Hoenn" then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(46, 10)

		elseif not self:isTrainingOver() then
			sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
			return moveToRectangle(33, 5, 44, 5)

		else
			sys.debug("quest", "Going to Hoenn E4.")
			return moveToCell(46, 10)
		end

	-- bottom part
	else
		sys.debug("quest", "Going to Hoenn E4.")
		return moveToCell(9, 17)
	end
end

function e4HoennQuest:VictoryRoadHoennB1F()
	sys.debug("quest", "Going to Hoenn E4.")
	return moveToCell(46, 7)
end

function e4HoennQuest:PokemonLeagueHoenn()
	-- team manager part
	--if not self.checkedForBestPokemon then
		--if isPCOpen() then
			--if isCurrentPCBoxRefreshed() then
				--if getCurrentPCBoxSize() ~= 0 then
					--log("Current Box: " .. getCurrentPCBoxId())
					--log("Box Size: " .. getCurrentPCBoxSize())
					--for teamPokemonIndex = 1, getTeamSize() do
						--local bestPkmFromBox = pc.getBestPokemonIdFromCurrentBox()
						--if bestPkmFromBox ~= nil then
							--if luaPokemonData[getPokemonName(teamPokemonIndex)]["TotalStats"] < luaPokemonData[getPokemonNameFromPC(getCurrentPCBoxId(), bestPkmFromBox)]["TotalStats"] then
								--log(string.format("Swapping Team Pokemon %s (Total Stats: %i) with Box %i Pokemon %s (Total Stats: %i)", getPokemonName(teamPokemonIndex), luaPokemonData[getPokemonName(teamPokemonIndex)]["TotalStats"], getCurrentPCBoxId(), getPokemonNameFromPC(getCurrentPCBoxId(), bestPkmFromBox), luaPokemonData[getPokemonNameFromPC(getCurrentPCBoxId(), bestPkmFromBox)]["TotalStats"]))
								--return swapPokemonFromPC(getCurrentPCBoxId(), bestPkmFromBox, teamPokemonIndex)
							--end
						--end
					--end
					--return openPCBox(getCurrentPCBoxId() + 1)
				--else
					--sys.debug("quest", "Checked for best Pokemon from PC.")
					--self.checkedForBestPokemon = true
				--end
			--end
		--else
			--return usePC()
		--end

	-- heal part
	if self:needsStoryHealing() then
		sys.debug("quest", "Going to heal Pokemon.")
		return talkToNpcOnCell(4, 22)

	-- buying item part
	elseif self:buyReviveItems() ~= false then
		return

	-- training part
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(10, 28)

	-- E4 part
	else 
		sys.debug("quest", "Going to Hoenn E4.")
		return moveToCell(10, 3)
	end
end

function e4HoennQuest:EliteFourSidneyRoom()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.sidney.state then
		sys.debug("quest", "Going to fight #1 - Sidney.")
		return talkToNpcOnCell(18, 17) 
	else
		sys.debug("quest", "Going to fight #2 - Phoebe.")
		return moveToCell(18, 3) 
	end
end

function e4HoennQuest:EliteFourPhoebeRoom()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.phoebe.state then
		sys.debug("quest", "Going to fight #2 - Phoebe.")
		return talkToNpcOnCell(17, 22) 
	else
		sys.debug("quest", "Going to fight #3 - Glacia.")
		return moveToCell(17, 12) 
	end
end

function e4HoennQuest:EliteFourGlaciaRoom()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.glacia.state then
		sys.debug("quest", "Going to fight #3 - Glacia.")
		return talkToNpcOnCell(15, 16) 
	else
		sys.debug("quest", "Going to fight #4 - Drake.")
		return moveToCell(15, 3) 
	end
end

function e4HoennQuest:EliteFourDrakeRoom()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.drake.state then
		sys.debug("quest", "Going to fight #4 - Drake.")
		return talkToNpcOnCell(17, 16) 
	else
		sys.debug("quest", "Going to fight #5 - Champion Steve.")
		return moveToCell(17, 2) 
	end
end

function e4HoennQuest:EliteFourChampionRoomHoenn()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.steven.state then
		sys.debug("quest", "Going to fight #5 - Champion Steve.")
		return talkToNpcOnCell(6, 16) 
	else
		sys.debug("quest", "Going to talk to Prof. Birch.")
		return talkToNpcOnCell(6, 4)
	end
end

return e4HoennQuest
