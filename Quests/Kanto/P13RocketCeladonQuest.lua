local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local team   = require "Libs/teamlib"
local Quest  = require "Quests/Quest"
local pc = require "Libs/pclib"
local Dialog = require "Quests/Dialog"

local luaPokemonData = require "Data/luaPokemonData"

local name		  = 'Rocket Team'
local description = 'Celadon City Quest'
local level = 1

-- Giovanni is a required story battle.  Keep the recovery policy local to
-- this quest so the normal shared wild-battle policy is not changed for the
-- rest of the story.
local GIOVANNI_REVIVE_TARGET = 2
local GIOVANNI_LEMONADE_TARGET = 8
local GIOVANNI_LEMONADE_RESERVE = 1 -- keep one Lemonade for the Saffron guard
local GIOVANNI_RECOVERY_HP_PERCENT = 70

local dialogs = {
	guardQuestAccept = Dialog:new({ 
		"do not lose",
		"you may discover",
		"go back and find"
	}),
	elevator_B1 = Dialog:new({ 
		"arrived on b1",
	}),
	elevator_B2 = Dialog:new({ 
		"arrived on b2",
	}),
	elevator_B4 = Dialog:new({ 
		"arrived on b4",
	}),
	martElevatorFloor1 = Dialog:new({
		"the first floor"
	}),
	martElevatorFloor2 = Dialog:new({
		"the second floor"
	}),
	martElevatorFloor5 = Dialog:new({
		"the fifth floor"
	}),
	passwordNeeded = Dialog:new({ 
		"find someone with the password",
	}),
	releaseEeveeDone = Dialog:new({ 
		"of this project and to have them apprehended",
	}),
	receptorEmpty = Dialog:new({ 
		"there is nothing stored in this receptor",
	})
}

local P13RocketCeladonQuest = Quest:new()

function P13RocketCeladonQuest:new()
	local o =  Quest.new(P13RocketCeladonQuest, name, description, level, dialogs)
	o.pokemonId = 1
	o.needCutPokemonFromBoxes = false
	o.TrashBin_Iron = false
	o.Receptor1check = false
	o.Receptor2check = false
	o.Receptor3check = false
	o.Receptor4check = false
	o.Receptor5check = false
	o.Receptor6check = false
	o.Receptor7check = false
	o.Receptor8check = false
	o.Receptor9check = false
	o.Receptor10check = false
	o.b4f_ReceptorDone = false
	o.b3f_ReceptorDone = false

	o.checkedForBestPokemon = false
	o.giovanniBattlePending = false
	o.giovanniPreMissionSuppliesPending = false
	o.giovanniPostBattlePreparationPending = false
	o.giovanniPostBattlePreparationComplete = false
	o.giovanniSuppliesPurchased = false
	o.giovanniReviveBudget = GIOVANNI_REVIVE_TARGET
	return o
end

function P13RocketCeladonQuest:isDoable()
	if self:hasMap() then
		if getMapName() == "Celadon City" then 
			return isNpcOnCell(48,34)
				or self.giovanniPreMissionSuppliesPending
				or self:needsGiovanniPostBattlePreparation()
		else
			return true
		end
	end
	return false
end

function P13RocketCeladonQuest:isDone()
	if self.giovanniPreMissionSuppliesPending then
		return false
	end
	if self.giovanniBattlePending then
		return false
	end
	if getMapName() == "Celadon City" and not isNpcOnCell(48,34) then
		-- Recover the post-battle intent after a script reload if the Rocket
		-- NPC has already disappeared but the required supplies/recovery were
		-- not completed yet.
		if not self.giovanniPostBattlePreparationPending
			and not self.giovanniPostBattlePreparationComplete
			and self:needsGiovanniPostBattlePreparation()
		then
			self.giovanniPostBattlePreparationPending = true
			self.giovanniReviveBudget = GIOVANNI_REVIVE_TARGET
			return false
		end
		return not self.giovanniPostBattlePreparationPending
			or self.giovanniPostBattlePreparationComplete
	end
	return false
end

function P13RocketCeladonQuest:isPersistentCompletionValid()
	-- Older flag files may already contain Rocket Team as completed before the
	-- Giovanni supply/recovery step existed.  Re-open that flag only while the
	-- player is still in the Celadon/Saffron part of Kanto and the objective is
	-- visibly incomplete.  Later story progression keeps the normal flag fast
	-- path.
	if getMapName() == "Celadon City" and not hasItem("Marsh Badge") and not hasItem("Soul Badge") then
		return not isNpcOnCell(48, 34)
			and not self:needsGiovanniPostBattlePreparation()
	end
	return true
end

-- The final Rocket Hideout encounter is an NPC/story battle and must not be
-- handled by the post-Rainbow wild-battle run policy.  The map guard also
-- keeps the battle required if the script is reloaded between the NPC dialog
-- and the battle callback.
function P13RocketCeladonQuest:isRequiredStoryBattle()
	if self.giovanniBattlePending then
		return true
	end
	return getMapName() == "Rocket Hideout B4F" and not isWildBattle()
end

function P13RocketCeladonQuest:talkToGiovanni()
	self.giovanniBattlePending = true
	self.giovanniPostBattlePreparationPending = false
	self.giovanniPostBattlePreparationComplete = false
	self.giovanniSuppliesPurchased = self:hasGiovanniSupplies()
	self.giovanniReviveBudget = GIOVANNI_REVIVE_TARGET
	return talkToNpcOnCell(18, 15)
end

-- Giovanni's superboss battle does not allow items. Attack with the current
-- Pokemon first, even when Charizard in slot 1 has fainted. Only rotate when
-- attack() cannot act; otherwise healthy backups switch back and forth.
-- The existing party fallbacks support any party size. Recovery items are
-- reserved for the overworld after the battle.
function P13RocketCeladonQuest:battle()
	if not self:isRequiredStoryBattle() then
		return Quest.battle(self)
	end

	return attack()
		or sendUsablePokemon()
		or sendAnyPokemon()
		or useAnyMove()
end

function P13RocketCeladonQuest:battleMessage(message)
	local result = Quest.battleMessage(self, message)
	if self.giovanniBattlePending and sys.stringContains(message, "won the battle") then
		self.giovanniBattlePending = false
		self.giovanniPostBattlePreparationPending = true
		self.giovanniPostBattlePreparationComplete = false
		self.giovanniSuppliesPurchased = self:hasGiovanniSupplies()
		self.giovanniReviveBudget = GIOVANNI_REVIVE_TARGET
		sys.debug("quest", "Giovanni defeated; preparing Revives and Lemonade for the party.")
	elseif self.giovanniBattlePending and sys.stringContains(message, "black out") then
		-- Let the normal quest path retry Giovanni after a failed battle.
		self.giovanniBattlePending = false
	end
	return result
end

function P13RocketCeladonQuest:partyNeedsGiovanniRecovery()
	for pokemonId = 1, math.min(getTeamSize(), 6) do
		if getPokemonHealth(pokemonId) <= 0
			or getPokemonHealthPercent(pokemonId) < GIOVANNI_RECOVERY_HP_PERCENT
		then
			return true
		end
	end
	return false
end

function P13RocketCeladonQuest:hasGiovanniSupplies()
	return getItemQuantity("Revive") >= GIOVANNI_REVIVE_TARGET
		and getItemQuantity("Lemonade") >= GIOVANNI_LEMONADE_TARGET
end

function P13RocketCeladonQuest:needsGiovanniPostBattlePreparation()
	return not self:hasGiovanniSupplies()
		or self:partyNeedsGiovanniRecovery()
end

function P13RocketCeladonQuest:needsGiovanniSupplies()
	if self.giovanniSuppliesPurchased then
		return false
	end
	if not self.giovanniPreMissionSuppliesPending
		and not self.giovanniPostBattlePreparationPending
	then
		return false
	end
	return not self:hasGiovanniSupplies()
end

-- The Celadon mission-giver is the point at which the live story accepts the
-- Rocket mission (the account may display that NPC as Sergeant Rick).  Buy
-- the Giovanni recovery supplies before talking to that NPC so the account
-- does not enter the hideout without its required Revives and Lemonade.
function P13RocketCeladonQuest:handlePreMissionGiovanniSupplies()
	if self.giovanniSuppliesPurchased then
		return nil
	end

	if not self.giovanniPreMissionSuppliesPending then
		if not isNpcOnCell(48, 34)
			or dialogs.guardQuestAccept.state
		then
			return nil
		end

		if self:hasGiovanniSupplies() then
			self.giovanniSuppliesPurchased = true
			return nil
		end

		self.giovanniPreMissionSuppliesPending = true
		sys.debug("quest", "Buying Revives and Lemonade before accepting the Celadon mission.")
	end

	if not self:hasGiovanniSupplies() then
		return moveToCell(24, 20)
	end

	self.giovanniPreMissionSuppliesPending = false
	self.giovanniSuppliesPurchased = true
	sys.debug("quest", "Giovanni supplies ready before mission acceptance.")
	return moveToCell(52, 19)
end

function P13RocketCeladonQuest:buyGiovanniSupplies()
	if not isShopOpen() then
		return talkToNpcOnCell(4, 8)
	end

	local reviveCount = getItemQuantity("Revive")
	if reviveCount < GIOVANNI_REVIVE_TARGET then
		local quantity = GIOVANNI_REVIVE_TARGET - reviveCount
		return buyItem("Revive", quantity)
	end
	return false
end

function P13RocketCeladonQuest:buyGiovanniLemonade()
	if not isShopOpen() then
		return talkToNpcOnCell(12, 3)
	end

	local lemonadeCount = getItemQuantity("Lemonade")
	if lemonadeCount < GIOVANNI_LEMONADE_TARGET then
		local quantity = GIOVANNI_LEMONADE_TARGET - lemonadeCount
		return buyItem("Lemonade", quantity)
	end
	return false
end

function P13RocketCeladonQuest:giovanniRecoveryOrder()
	local order = {}
	local added = {}
	local lastPokemonId = math.min(getTeamSize(), 6)
	local heroPokemonId = self:getHeroPokemonIndex()

	local function addPokemon(pokemonId)
		if pokemonId ~= nil
			and pokemonId >= 1
			and pokemonId <= lastPokemonId
			and not added[pokemonId]
		then
			added[pokemonId] = true
			table.insert(order, pokemonId)
		end
	end

	-- Prioritize the hero, then the requested backup slots 2..6.  The final
	-- loop covers slot 1 if a borrowed team has Charizard in another position.
	addPokemon(heroPokemonId)
	for pokemonId = 2, lastPokemonId do
		addPokemon(pokemonId)
	end
	for pokemonId = 1, lastPokemonId do
		addPokemon(pokemonId)
	end
	return order
end

function P13RocketCeladonQuest:recoverGiovanniParty()
	for _, pokemonId in ipairs(self:giovanniRecoveryOrder()) do
		if getPokemonHealth(pokemonId) <= 0 then
			if self.giovanniReviveBudget > 0 and getItemQuantity("Revive") > 0 then
				if useItemOnPokemon("Revive", pokemonId) then
					self.giovanniReviveBudget = self.giovanniReviveBudget - 1
					return true
				end
			end
		elseif getPokemonHealthPercent(pokemonId) < GIOVANNI_RECOVERY_HP_PERCENT
			and getItemQuantity("Lemonade") > GIOVANNI_LEMONADE_RESERVE
		then
			return useItemOnPokemon("Lemonade", pokemonId)
		end
	end
	return false
end

function P13RocketCeladonQuest:handleGiovanniPostBattlePreparation()
	if not self.giovanniPostBattlePreparationPending then
		return nil
	end

	if not self.giovanniSuppliesPurchased then
		if self:needsGiovanniSupplies() then
			return moveToCell(24, 20)
		end
		self.giovanniSuppliesPurchased = true
	end

	if self:recoverGiovanniParty() then
		return true
	end

	self.giovanniPostBattlePreparationPending = false
	self.giovanniPostBattlePreparationComplete = true
	sys.debug("quest", "Giovanni party recovery complete; keeping one Lemonade for Saffron.")
	-- Return a real movement action.  QuestManager will see isDone() on the
	-- next tick and advance without restarting the region story.
	return moveToCell(52, 19)
end

function P13RocketCeladonQuest:CeladonCity()
	local preMissionSupplyAction = self:handlePreMissionGiovanniSupplies()
	if preMissionSupplyAction ~= nil then
		return preMissionSupplyAction
	end

	local giovanniAction = self:handleGiovanniPostBattlePreparation()
	if giovanniAction ~= nil then
		return giovanniAction
	end

	if self:needPokecenter() or self:needsTeamHealingForStory() or self.registeredPokecenter ~= "Pokecenter Celadon" or self.needCutPokemonFromBoxes then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(52, 19)

	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(24, 20)

	elseif not self:isTrainingOver() and not self:needPokecenter() then
		sys.debug("quest", "Going to train Pokemon until Level " .. self.level .. ".")
		return moveToCell(71, 24)

	elseif isNpcOnCell(48, 34) then 
		if not dialogs.guardQuestAccept.state then
			pushDialogAnswer(2)
			pushDialogAnswer(1)
			sys.debug("quest", "Going to talk to the guard.")
			return talkToNpcOnCell(48, 34)

		else
			dialogs.guardQuestAccept.state = false
			sys.debug("quest", "Going to Rocket Hideout.")
			return moveToCell(39, 30)

		end
	else
		return -- Quest Finish - Next
	end
end

function P13RocketCeladonQuest:PokecenterCeladon()
	return self:pokecenter("Celadon City")
end

function P13RocketCeladonQuest:Route7()
	if self.needCutPokemonFromBoxes then
		sys.debug("quest", "Going to get a Pokemon that can learn Cut from Boxes.")
		return moveToCell(0, 25)
	elseif not self.registeredPokecenter == "Pokecenter Celadon" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(0, 23)
	elseif not self:isTrainingOver() and not self:needPokecenter() then
		sys.debug("quest", "Going to train Pokemon until Level " .. self.level .. ".")
		return moveToCell(10, 31)
	else
		sys.debug("quest", "Going to Celadon City.")
		return moveToCell(0, 23)
	end
end

function P13RocketCeladonQuest:UndergroundHouse3()
	if self.needCutPokemonFromBoxes then
		sys.debug("quest", "Going to get a Pokemon that can learn Cut from Boxes.")
		return moveToCell(5, 10)
	elseif not self:isTrainingOver() and not self:needPokecenter() then
		sys.debug("quest", "Going to train Pokemon until Level " .. self.level .. ".")
		return moveToCell(9, 3)
	else
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(4, 10)
	end
end

function P13RocketCeladonQuest:Underground1()
	if self.needCutPokemonFromBoxes then
		sys.debug("quest", "Going to get a Pokemon that can learn Cut from Boxes.")
		return moveToCell(1, 5)
	elseif not self:isTrainingOver() and not self:needPokecenter() then
		sys.debug("quest", "Going to train Pokemon until Level " .. self.level .. ".")
		return moveToCell(69, 5)
	else
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(1, 5)
	end
end

function P13RocketCeladonQuest:UndergroundHouse4()
	if self.needCutPokemonFromBoxes then
		sys.debug("quest", "Going to get a Pokemon that can learn Cut from Boxes.")
		return moveToCell(1, 3)
	elseif not self:isTrainingOver() and not self:needPokecenter() then
		sys.debug("quest", "Going to train Pokemon until Level " .. self.level .. ".")
		return moveToCell(4, 10)
	else
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(1, 3)
	end
end

function P13RocketCeladonQuest:Route8()
	if not game.hasPokemonWithMove("Cut") then
		if self.pokemonId <= getTeamSize() then
			useItemOnPokemon("HM01 - Cut", self.pokemonId)
			log("Pokemon: " .. self.pokemonId .. " Try Learning: HM01 - Cut")
			self.pokemonId = self.pokemonId + 1
		else
			self.needCutPokemonFromBoxes = true
			self.pokemonId = 1
			sys.debug("quest", "Going to get a Pokemon that can learn Cut from Boxes.")
			return moveToCell(12, 9)
		end
	else
		if not self:isTrainingOver() and not self:needPokecenter() then
			sys.debug("quest", "Going to train Pokemon until Level " .. self.level .. ".")
			return moveToRectangle(38, 11, 42, 15)
		else
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(12, 9)
		end
	end
end

function P13RocketCeladonQuest:CeladonMart1()
	if self:needsGiovanniSupplies() or self:needPokemart() then
		return moveToCell(1, 4)
	else
		return moveToCell(8, 15)
	end
end

function P13RocketCeladonQuest:CeladonMart2()
	if self:needsGiovanniSupplies() and getItemQuantity("Revive") < GIOVANNI_REVIVE_TARGET then
		return self:buyGiovanniSupplies()
	elseif self:needsGiovanniSupplies() then
		-- Revives are sold on floor 2; Lemonade is sold on floor 6.
		return moveToCell(9, 2)
	end
	return self:pokemart()
end

function P13RocketCeladonQuest:CeladonMartElevator()
	if getItemQuantity("Revive") < GIOVANNI_REVIVE_TARGET then
		if not dialogs.martElevatorFloor2.state then
			pushDialogAnswer(2)
			return talkToNpcOnCell(1, 1)
		else
			dialogs.martElevatorFloor2.state = false
			return moveToCell(2, 5)
		end
	elseif getItemQuantity("Lemonade") < GIOVANNI_LEMONADE_TARGET then
		if not dialogs.martElevatorFloor5.state then
			pushDialogAnswer(5)
			return talkToNpcOnCell(1, 1)
		else
			dialogs.martElevatorFloor5.state = false
			return moveToCell(2, 5)
		end
	else
		if not dialogs.martElevatorFloor1.state then
			pushDialogAnswer(1)
			return talkToNpcOnCell(1, 1)
		else
			dialogs.martElevatorFloor1.state = false
			return moveToCell(2, 5)
		end
	end
end

function P13RocketCeladonQuest:CeladonMart5()
	if getItemQuantity("Lemonade") < GIOVANNI_LEMONADE_TARGET then
		return moveToCell(16, 4)
	else
		return moveToCell(9, 2)
	end
end

function P13RocketCeladonQuest:CeladonMart6()
	if getItemQuantity("Lemonade") < GIOVANNI_LEMONADE_TARGET then
		return self:buyGiovanniLemonade()
	else
		return moveToCell(15, 8)
	end
end

function P13RocketCeladonQuest:CeladonCityGameCorner()
	if not self:isTrainingOver() then
		return moveToCell(3, 11)
	elseif not hasItem("Card Key") then
		if isNpcOnCell(13, 3) then
			sys.debug("quest", "Going to talk to Scientist Greg.")
			return talkToNpcOnCell(13, 3)
		else
			sys.debug("quest", "Going to Rocket Hideout.")
			return moveToCell(14, 3)
		end
	else
		if dialogs.releaseEeveeDone.state or (self.b3f_ReceptorDone and self.b4f_ReceptorDone) then
			sys.debug("quest", "Going back to Celadon City.")
			return moveToCell(3, 11)
		else
			sys.debug("quest", "Going to Rocket Hideout.")
			return moveToCell(14, 3)
		end
	end
end

function P13RocketCeladonQuest:RocketHideoutB1F()
	if game.inRectangle(17, 15, 25, 32) then --right room
		if not hasItem("Lift Key") then
			if isNpcOnCell(24, 20) then
				sys.debug("quest", "Going to talk to Scientist Greg.")
				return talkToNpcOnCell(24, 20)
			elseif isNpcOnCell(23, 20) then
				sys.debug("quest", "Getting Item: Lift Key.")
				return talkToNpcOnCell(23, 20)
			end
		else
			return moveToRectangle(22, 29, 22, 30) -- AntiStuck Elevator
		end
	elseif game.inRectangle(1, 15, 7, 22) then -- intruder room
		sys.debug("quest", "Getting out of Intruder Room.")
		return talkToNpcOnCell(7, 18)
	elseif not self:isTrainingOver() then
		moveToCell(9, 4)
	elseif game.inRectangle(10, 37, 13, 39) then -- bottom stairs
		sys.debug("quest", "Going back to Rocket Hideout B2F.")
		return moveToCell(13, 38)
	elseif game.inRectangle(1, 3, 24, 14) or game.inRectangle(9, 15, 15, 22) then
		if dialogs.releaseEeveeDone.state then
			return moveToCell(9, 4)
		else
			if dialogs.releaseEeveeDone.state or (self.b3f_ReceptorDone and self.b4f_ReceptorDone) then
				return moveToCell(9, 4)
			else
				return moveToCell(16, 4)
			end
		end
	end 
end

function P13RocketCeladonQuest:RocketHideoutElevator()
	if not hasItem("Card Key") then
		if dialogs.elevator_B2.state then
			dialogs.elevator_B2.state = false
			return moveToCell(2, 5)
		else
			pushDialogAnswer(2)
			return talkToNpcOnCell(1, 1)
		end
	else
		if dialogs.passwordNeeded.state or (self.b3f_ReceptorDone and not self.b4f_ReceptorDone) then-- go b4f
			if dialogs.elevator_B4.state then
				dialogs.elevator_B4.state = false
				return moveToCell(2, 5)
			else
				pushDialogAnswer(3)
				return talkToNpcOnCell(1, 1)
			end
		else
			if dialogs.elevator_B2.state then
				dialogs.elevator_B2.state = false
				return moveToCell(2, 5)
			else
				pushDialogAnswer(2)
				return talkToNpcOnCell(1, 1)
			end
		end
	end
end

function P13RocketCeladonQuest:RocketHideoutB2F()
	if isNpcOnCell(28, 20) then
		return talkToNpcOnCell(28, 20)
	elseif isNpcOnCell(28, 21) and self.TrashBin_Iron == false then
		self.TrashBin_Iron = true
		return talkToNpcOnCell(28, 21)
	elseif not hasItem("Card Key") then
		return moveToCell(23, 4)
	elseif not dialogs.passwordNeeded.state and not dialogs.releaseEeveeDone.state and not self.b3f_ReceptorDone then
		return moveToCell(23, 4)--- 26,16 wenn nicht funktioniert
	elseif dialogs.passwordNeeded.state or (self.b3f_ReceptorDone and not self.b4f_ReceptorDone) then
		return moveToRectangle(31, 19, 31, 20) -- AntiStuck Elevator
	elseif dialogs.releaseEeveeDone.state or (self.b3f_ReceptorDone and self.b4f_ReceptorDone) then
		return moveToCell(31, 4) -- Rocket Hideout B1F
	else
		return talkToNpcOnCell(2, 3)
	end
end

function P13RocketCeladonQuest:RocketHideoutB3F()
	if isNpcOnCell(15, 22) then
		return talkToNpcOnCell(15, 22)
	elseif not hasItem("Card Key") then
		return moveToCell(14, 22)
	elseif isNpcOnCell(19, 6) then
		return talkToNpcOnCell(19, 6)
	elseif isNpcOnCell(18, 15) then
		return talkToNpcOnCell(18, 15)
	elseif dialogs.passwordNeeded.state or (dialogs.releaseEeveeDone.state or self.b3f_ReceptorDone) then
		return moveToCell(19, 4)
	else
		if not self.b3f_ReceptorDone and hasItem("Silph Scope") then
			if not dialogs.releaseEeveeDone.state then
				if not self.Receptor1check then -- Receptor1check
					if not dialogs.receptorEmpty.state then
						return talkToNpcOnCell(1, 3)
					else
						dialogs.receptorEmpty.state = false
						self.Receptor1check = true
						return
					end
				elseif not self.Receptor2check then -- Receptor2check
					if not dialogs.receptorEmpty.state then
						return talkToNpcOnCell(2, 3)
					else
						dialogs.receptorEmpty.state = false
						self.Receptor2check = true
						return
					end
				elseif not self.Receptor3check then -- Receptor3check
					if not dialogs.receptorEmpty.state then
						return talkToNpcOnCell(18, 14)
					else
						dialogs.receptorEmpty.state = false
						self.Receptor3check = true
						return
					end
				else
					self.b3f_ReceptorDone = true
				end
			end	
		else
			return talkToNpcOnCell(2, 3) -- 1 receptor only for get password dialog
		end
	end
end

function P13RocketCeladonQuest:RocketHideoutB4F()
	dialogs.passwordNeeded.state = false
	if game.inRectangle(1, 3, 12, 17) then
		if not hasItem("Card Key") then
			if isNpcOnCell(5, 6) then
				return talkToNpcOnCell(5, 6)
			else
				return talkToNpcOnCell(4, 6)
			end
		else
			return moveToCell(11, 16)
		end
	elseif game.inRectangle(16, 3, 22, 14) then -- After HiddenDoor
		if isNpcOnCell(19, 4) then
			return talkToNpcOnCell(19, 4)
		elseif isNpcOnCell(18, 6) then
			return talkToNpcOnCell(18, 6)
		elseif dialogs.releaseEeveeDone.state then
				return self:talkToGiovanni()
		elseif not self.b4f_ReceptorDone then
			if not self.Receptor5check then -- Receptor5check
				if not dialogs.receptorEmpty.state then
					return talkToNpcOnCell(17, 3)
				else
					dialogs.receptorEmpty.state = false
					self.Receptor5check = true
					return
				end
			elseif not self.Receptor6check then -- Receptor6check
				if not dialogs.receptorEmpty.state then
					return talkToNpcOnCell(18, 3)
				else
					dialogs.receptorEmpty.state = false
					self.Receptor6check = true
					return
				end
			elseif not self.Receptor7check then -- Receptor7check
				if not dialogs.receptorEmpty.state then
					return talkToNpcOnCell(20, 3)
				else
					dialogs.receptorEmpty.state = false
					self.Receptor7check = true
					return
				end
			elseif not self.Receptor8check then -- Receptor8check
				if not dialogs.receptorEmpty.state then
					return talkToNpcOnCell(21, 3)
				else
					dialogs.receptorEmpty.state = false
					self.Receptor8check = true
					return
				end
			else
				self.b4f_ReceptorDone = true
				return
			end
	else
			return self:talkToGiovanni()
		end
	elseif game.inRectangle(14, 16, 22, 26) or game.inRectangle(1, 21, 13, 26) then -- Before HiddenDoor
	if isNpcOnCell(19, 4) or isNpcOnCell(18, 6) then
			return self:talkToGiovanni()
		elseif not dialogs.releaseEeveeDone.state and not self.b4f_ReceptorDone then
			return self:talkToGiovanni()
		elseif self.b4f_ReceptorDone then
			if not self.Receptor9check and not dialogs.releaseEeveeDone.state then -- Receptor7check
				if not dialogs.receptorEmpty.state then
					return talkToNpcOnCell(1, 22)
				else
					dialogs.receptorEmpty.state = false
					self.Receptor9check = true
					return
				end
			elseif not self.Receptor10check then -- Receptor8check
				if not dialogs.receptorEmpty.state then
					return talkToNpcOnCell(2, 22)
				else
					dialogs.receptorEmpty.state = false
					self.Receptor10check = true
					return
				end
			else
				return moveToRectangle(20, 25, 20, 26) -- AntiStuck Elevator
			end
		else
			return moveToRectangle(20, 25, 20, 26) -- AntiStuck Elevator
		end
	else
	end
end

return P13RocketCeladonQuest
