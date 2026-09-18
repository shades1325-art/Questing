-- Copyright � 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @WiWi__33 & Melt


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local pc	 = require "Libs/pclib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local luaPokemonData = require "Data/luaPokemonData"

local name		  = 'Elite 4 Johto'
local description = 'Will beat the E4'
local level = 0

local dialogs = {
	leagueDefeated = Dialog:new({ 
		"I am already the Champ, don't need to go in there...",
		"you are the Champion of Johto"
	}),
	leagueNotDefeated = Dialog:new({
		"You are not ready to go to Mount Silver yet",
	}),
	leaderDone = Dialog:new({
		"I did not foresee that",
		"You may pass",
		"You defeated me",
		"your destiny awaits you",
	})
}

local Elite4Johto = Quest:new()

function Elite4Johto:new()
	local o = Quest.new(Elite4Johto, name, description, level, dialogs)
	o.qnt_revive = 6
	o.qnt_hyperpot = 6
	return o
end

function Elite4Johto:isDoable()
	if self:hasMap() and not hasItem("Stone Badge") and hasItem("Rising Badge") and not dialogs.leagueDefeated.state then
		return true
	end
	return false
end

function Elite4Johto:isDone()
	if dialogs.leagueDefeated.state == true then
		return true
	else
		return false
	end
end

function Elite4Johto:buyReviveItems() --return false if all items are on the bag (32x Revives 32x HyperPotions)
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

function Elite4Johto:canBuyReviveItems()
	local bag_revive = getItemQuantity("Revive")
	local bag_hyperpot = getItemQuantity("Hyper Potion")
	local cost_revive = (self.qnt_revive - bag_revive) * 1500
	local cost_hyperpot = (self.qnt_hyperpot - bag_hyperpot) * 1200
	return getMoney() > (cost_hyperpot + cost_revive)
end

function Elite4Johto:reviveItemCost()
	local bag_revive = getItemQuantity("Revive")
	local bag_hyperpot = getItemQuantity("Hyper Potion")
	local cost_revive = (self.qnt_revive - bag_revive) * 1500
	local cost_hyperpot = (self.qnt_hyperpot - bag_hyperpot) * 1200
	return cost_hyperpot + cost_revive
end

function Elite4Johto:BlackthornCityGym()
	if game.inRectangle(15, 9, 32, 24) then
		sys.debug("quest", "Going to do Johto E4.")
		return moveToCell(17, 22)
	else
		sys.debug("quest", "Going to do Johto E4.")
		return moveToCell(21, 115)
	end
end

function Elite4Johto:BlackthornCity()
	if not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Blackthorn" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(29, 39)
	elseif self.checkedForBestPokemon then
		if not game.hasPokemonWithMove("Surf") then
			if self.pokemonId < getTeamSize() then
				useItemOnPokemon("HM03 - Surf", self.pokemonId)
				log("Pokemon: " .. self.pokemonId .. " Try Learning: HM03 - Surf")
				self.pokemonId = self.pokemonId + 1
			else
				fatal("No pokemon in this team can learn Surf")
			end
		else
			sys.debug("quest", "Going to Johto E4.")
			return moveToCell(20, 50)
		end
	end
end

function Elite4Johto:PokecenterBlackthorn()
	self:pokecenter("Blackthorn City")
end

function Elite4Johto:Route45()
	sys.debug("quest", "Going to Johto E4.")
	return moveToCell(0, 162)
end

function Elite4Johto:Route46()
	sys.debug("quest", "Going to Johto E4.")
	return moveToCell(28, 51)
end

function Elite4Johto:Route29StopHouse()
	sys.debug("quest", "Going to Johto E4.")
	return moveToCell(4, 12)
end

function Elite4Johto:Route29()
	sys.debug("quest", "Going to Johto E4.")
	return moveToCell(99, 18)
end

function Elite4Johto:NewBarkTown()
	sys.debug("quest", "Going to Johto E4.")
	return moveToCell(47, 18)
end

function Elite4Johto:NewBarkTownPlayerHouseBedroom()
	dialogs.leagueDefeated.state = true
	if hasItem("Escape Rope") then
		sys.debug("quest", "Going to Johto E4.")
		return useItem("Escape Rope") -- tp Back to indigo plateau center
	else
		sys.debug("quest", "Going to Johto E4.")
		return moveToCell(1, 4)
	end
end

function Elite4Johto:NewBarkTownPlayerHouse()
	sys.debug("quest", "Going to Johto E4.")
	return moveToCell(3, 12)
end

function Elite4Johto:Route27()
	if game.inRectangle(15, 29, 90, 39) or game.inRectangle(63, 25, 86, 28) or game.inRectangle(0, 0, 62, 28) then
		sys.debug("quest", "Going to Johto E4.")
		return moveToCell(56, 16)
	else
		sys.debug("quest", "Going to Johto E4.")
		return moveToCell(217, 23)
	end
end

function Elite4Johto:TohjoFalls()
	sys.debug("quest", "Going to Johto E4.")
	return moveToCell(46, 32)
end

function Elite4Johto:Route26()
	sys.debug("quest", "Going to Johto E4.")
	return moveToCell(17, 7)
end

function Elite4Johto:PokemonLeagueReceptionGate()
	if dialogs.leagueNotDefeated.state then
		sys.debug("quest", "Going to Johto E4.")
		return moveToCell(22, 2)
	elseif isNpcOnCell(2, 11) then
		sys.debug("quest", "Talking to NPC.")
		return talkToNpcOnCell(2, 11)
	else
		dialogs.leagueDefeated.state = true
	end
end

function Elite4Johto:VictoryRoadKanto1F()
	if dialogs.leagueNotDefeated.state then
		sys.debug("quest", "Going to Johto E4.")
		return moveToCell(17, 11)
	else
		sys.debug("quest", "Checking NPC in front of Mt. Silver.")
		return moveToCell(43, 52)
	end
end

function Elite4Johto:VictoryRoadKanto2F()
	if dialogs.leagueNotDefeated.state then
		sys.debug("quest", "Going to Johto E4.")
		return moveToCell(14, 9) 
	else
		sys.debug("quest", "Checking NPC in front of Mt. Silver.")
		return moveToCell(14, 20)
	end
end

function Elite4Johto:VictoryRoadKanto3F()
	if dialogs.leagueNotDefeated.state then
		if self:needPokecenter() or self.registeredPokecenter ~= "Indigo Plateau Center Johto" then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(46, 13)
		elseif not self:isTrainingOver() then
			sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
			return moveToRectangle(40, 14, 48, 22)
		elseif not self:canBuyReviveItems() then
			sys.debug("quest", "Going to farm $" .. self:reviveItemCost() - getMoney() .. " more money for Revives + Potions.")
			return moveToRectangle(40, 14, 48, 22)
		else
			sys.debug("quest", "Going to Johto E4.")
			return moveToCell(46, 13)
		end
	else
		sys.debug("quest", "Checking NPC in front of Mt. Silver.")
		return moveToCell(29, 17)
	end
end

function Elite4Johto:IndigoPlateau()
	if not isNpcOnCell(21, 10) then -- level 80 rattata quest done
		dialogs.leagueDefeated.state = true
	elseif isNpcOnCell(10,13) then
		sys.debug("quest", "Going to talk to NPC in front of Johto E4.")
		return talkToNpcOnCell(10,13)
	elseif dialogs.leagueNotDefeated.state then
		if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Indigo Plateau Center Johto" then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(10, 12)

		elseif not self:isTrainingOver() then
			sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
			return moveToCell(21, 31) --Road2F
			
		elseif not self:canBuyReviveItems() then
			sys.debug("quest", "Going to farm $" .. self:reviveItemCost() - getMoney() .. " more money for Revives + Potions.")
			return moveToCell(21, 31) --Road2F
		
		else
			sys.debug("quest", "Going to Johto E4.")
			return moveToCell(10, 12)
		end
	else
		sys.debug("quest", "Checking NPC in front of Mt. Silver.")
		return moveToCell(21, 31)
	end
end

function Elite4Johto:IndigoPlateauCenterJohto()
	if dialogs.leagueNotDefeated.state then
		if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Indigo Plateau Center Johto" then
			sys.debug("quest", "Going to heal Pokemon.")
			self:pokecenter("Indigo Plateau Center Johto")
		elseif not self:isTrainingOver() then
			sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
			return moveToCell(10, 28)

		elseif not self:canBuyReviveItems() then
			sys.debug("quest", "Going to farm $" .. self:reviveItemCost() - getMoney() .. " more money for Revives + Potions.")
			return moveToCell(10, 28) --Road2F

		elseif self:buyReviveItems() ~= false then
			return 

		else
			sys.debug("quest", "Going to Johto E4.")
			return moveToCell(10, 3)
		end
	else
		sys.debug("quest", "Checking NPC in front of Mt. Silver.")
		return moveToCell(10, 28)
	end
end

function Elite4Johto:useReviveItems() --Return false if team don't need heal
	if not hasItem("Revive") or not hasItem("Hyper Potion") then
		return false
	end
	for pokemonId=1, getTeamSize(), 1 do
		if getPokemonHealth(pokemonId) == 0 then
			if useItemOnPokemon("Revive", pokemonId) then
				sys.debug("quest", "Revived: " .. getPokemonName(pokemonId))
				return
			end
		end
		if getPokemonHealthPercent(pokemonId) < 80 then
			if useItemOnPokemon("Hyper Potion", pokemonId) then
				sys.debug("quest", "Used Hyper Potion on: " .. getPokemonName(pokemonId))
				return
			end
		end		
	end
	return false
end

function Elite4Johto:EliteFourWillRoom()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.leaderDone.state then
		sys.debug("quest", "Going to fight Lorelei.")
		return talkToNpcOnCell(6,12) 
	else
		sys.debug("quest", "Going to fight Koga.")
		dialogs.leaderDone.state = false
		return moveToCell(6,3)
	end
end

function Elite4Johto:EliteFourKogaRoom()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.leaderDone.state then
		sys.debug("quest", "Going to fight Koga.")
		return talkToNpcOnCell(20,24)
	else
		sys.debug("quest", "Going to fight Bruno.")
		dialogs.leaderDone.state = false
		return moveToCell(20,12)
	end
end

function Elite4Johto:EliteFourBrunoRoomJohto()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.leaderDone.state then
		sys.debug("quest", "Going to fight Bruno.")
		return talkToNpcOnCell(21,24) 
	else
		sys.debug("quest", "Going to fight Karen.")
		dialogs.leaderDone.state = false
		return moveToCell(21,14)
	end
end


function Elite4Johto:EliteFourKarenRoom()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.leaderDone.state then
		sys.debug("quest", "Going to fight Karen.")
		return talkToNpcOnCell(6,14)
	else
		sys.debug("quest", "Going to fight Champion.")
		dialogs.leaderDone.state = false
		return moveToCell(6,3)
	end
end

function Elite4Johto:EliteFourChampionRoomJohto()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.leaderDone.state then
		sys.debug("quest", "Going to fight Champion.")
		return talkToNpcOnCell(6,15) 
	else
		sys.debug("quest", "Going to talk to Prof. Elm.")
		return talkToNpcOnCell(6,4)
	end
end



return Elite4Johto