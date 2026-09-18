-- Copyright � 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Elite 4 - Kanto'
local description = 'Exp in Victory Road (4 Zones)'
local level = 0

local dialogs = {
	leagueKantoNotDone = Dialog:new({ 
		"you are not ready to go to johto yet"
	}),
	leagueKantoDone = Dialog:new({
		"I am already the champ"
	})
}

local ExpForElite4Kanto = Quest:new()

function ExpForElite4Kanto:new()
	local o = Quest.new(ExpForElite4Kanto, name, description, level, dialogs)
	o.checkedForBestPokemon = false
	o.qnt_revive = 32
	o.qnt_hyperpot = 32
	return o
end

function ExpForElite4Kanto:isDoable()
	if self:hasMap() and hasItem("Earth Badge") and not hasItem("Zephyr Badge") then
		return true
	end
	return false
end

function ExpForElite4Kanto:isDone()
	if getMapName() == "Route 26" or getMapName() == "Pokecenter Viridian" or getMapName() == "Elite Four Lorelei Room" then --Fix Blackout
		return true
	end
	return false
end

function ExpForElite4Kanto:buyReviveItems() --return false if all items are on the bag (32x Revives 32x HyperPotions)
	if getItemQuantity("Revive") < self.qnt_revive or getItemQuantity("Hyper Potion") < self.qnt_hyperpot then
		if not isShopOpen() then
			sys.debug("quest", "Going to buy items for E4.")
			return talkToNpcOnCell(16,22)
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

function ExpForElite4Kanto:canBuyReviveItems()
	local bag_revive = getItemQuantity("Revive")
	local bag_hyperpot = getItemQuantity("Hyper Potion")
	local cost_revive = (self.qnt_revive - bag_revive) * 1500
	local cost_hyperpot = (self.qnt_hyperpot - bag_hyperpot) * 1200
	return getMoney() > (cost_hyperpot + cost_revive)
end

function ExpForElite4Kanto:reviveItemCost()
	local bag_revive = getItemQuantity("Revive")
	local bag_hyperpot = getItemQuantity("Hyper Potion")
	local cost_revive = (self.qnt_revive - bag_revive) * 1500
	local cost_hyperpot = (self.qnt_hyperpot - bag_hyperpot) * 1200
	return cost_hyperpot + cost_revive
end

function ExpForElite4Kanto:Route22()
	if isNpcOnCell(16, 8) then	
		sys.debug("quest", "Going to talk to NPC.")
		return talkToNpcOnCell(16, 8)
	else
		sys.debug("quest", "Going to E4.")
		return moveToCell(9, 8)
	end
end

function ExpForElite4Kanto:PokemonLeagueReceptionGate()
	if isNpcOnCell(22, 3) then
		sys.debug("quest", "Going to fight Red.")
		return talkToNpcOnCell(22, 3)
	elseif isNpcOnCell(22, 23) then
		if dialogs.leagueKantoDone.state then
			sys.debug("quest", "Going to talk to NPC.")
			return talkToNpcOnCell(22, 23)
		if dialogs.leagueKantoNotDone.state then
			sys.debug("quest", "Going to E4.")
			return moveToCell(22, 2)
		else
			sys.debug("quest", "Going to talk to NPC.")
			return talkToNpcOnCell(22, 23)
		end
	else
		sys.debug("quest", "Going to Johto.")
		return moveToCell(22, 24)
	end
end

function ExpForElite4Kanto:VictoryRoadKanto1F()
	if dialogs.leagueKantoDone.state then
		sys.debug("quest", "Going to Johto.")
		return moveToCell(43, 52)
	elseif dialogs.leagueKantoNotDone.state then
		sys.debug("quest", "Going to E4.")
		return moveToCell(17, 11)
	else
		sys.debug("quest", "Going back to Pokemon League Reception Gate.")
		return moveToCell(43, 52)
	end
end

function ExpForElite4Kanto:VictoryRoadKanto2F()
	if dialogs.leagueKantoDone.state then
		sys.debug("quest", "Going to Johto.")
		return moveToCell(14, 20)
	elseif dialogs.leagueKantoNotDone.state then
		sys.debug("quest", "Going to E4.")
		return moveToCell(14, 9) --Road3F
	else
		sys.debug("quest", "Going back to Pokemon League Reception Gate.")
		return moveToCell(14, 20)
	end
end

function ExpForElite4Kanto:VictoryRoadKanto3F()
	if isNpcOnCell(46, 14) then --Moltres
		sys.debug("quest", "Going to fight Moltres.")
		return talkToNpcOnCell(46, 14)
	elseif dialogs.leagueKantoDone.state then
		sys.debug("quest", "Going to Johto.")
		return moveToCell(29, 17)
	elseif dialogs.leagueKantoNotDone.state then
		if self:needPokecenter() or self.registeredPokecenter ~= "Indigo Plateau Center" then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(46, 13)
		elseif not self:isTrainingOver() then
			sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
			return moveToRectangle(40, 14, 48, 22)
		elseif not self:canBuyReviveItems() then
			sys.debug("quest", "Going to farm $" .. self:reviveItemCost() - getMoney() .. " more money for Revives + Potions.")
			return moveToRectangle(40, 14, 48, 22)
		else
			sys.debug("quest", "Going to E4.")
			return moveToCell(46, 13)
		end
	else
		sys.debug("quest", "Going back to Pokemon League Reception Gate.")
		return moveToCell(29, 17) --Road2F
	end
end

function ExpForElite4Kanto:IndigoPlateau()
	if dialogs.leagueKantoDone.state then
		sys.debug("quest", "Going to Johto.")
		return moveToCell(21, 31)

	elseif dialogs.leagueKantoNotDone.state then
		if self:needPokecenter() or self.registeredPokecenter ~= "Indigo Plateau Center" then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(32, 12)

		elseif not self:isTrainingOver() then
			sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
			return moveToCell(21, 31) --Road2F

		elseif not self:canBuyReviveItems() then
			sys.debug("quest", "Going to farm $" .. self:reviveItemCost() - getMoney() .. " more money for Revives + Potions.")
			return moveToCell(21, 31) --Road2F

		else
			sys.debug("quest", "Going to E4.")
			return moveToCell(32, 12)

		end
	else
		sys.debug("quest", "Going back to Pokemon League Reception Gate.")
		return moveToCell(21, 31)
	end
end

function ExpForElite4Kanto:IndigoPlateauCenter()
	if dialogs.leagueKantoDone.state then
		sys.debug("quest", "Going to Johto.")
		return moveToCell(10, 28)

	elseif dialogs.leagueKantoNotDone.state then

		if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Indigo Plateau Center" then
			sys.debug("quest", "Going to heal Pokemon.")
			self:pokecenter("Indigo Plateau Center")

		elseif not self:isTrainingOver() then
			sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
			return moveToCell(10, 28) --Road2F

		elseif not self:canBuyReviveItems() then
			sys.debug("quest", "Going to farm $" .. self:reviveItemCost() - getMoney() .. " more money for Revives + Potions.")
			return moveToCell(10, 28) --Road2F

		elseif self:buyReviveItems() ~= false then
			return 

		else
			sys.debug("quest", "Going to E4.")
			return moveToCell(10,3) --Start E4

		end
	else

		sys.debug("quest", "Going back to Pokemon League Reception Gate.")
		return moveToCell(10, 28)
	end
end

return ExpForElite4Kanto