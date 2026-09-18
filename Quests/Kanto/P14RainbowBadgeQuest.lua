local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Rainbow Badge'
local description = 'Beat Erika + Get Lemonade for future quest'

local dialogs = {
	martElevatorFloor1 = Dialog:new({ 
		"the first floor"
	}),
	martElevatorFloor4 = Dialog:new({ 
		"the fourth floor"
	}),
	martElevatorFloor5 = Dialog:new({ 
		"the fifth floor"
	})
}

local P14RainbowBadgeQuest = Quest:new()

function P14RainbowBadgeQuest:new()
	local o = Quest.new(P14RainbowBadgeQuest, name, description, level, dialogs)
	--o.pokemonId = 1

	--stay on map until ditto catched, if a bike is wanted from user
	--o.pokemon = "Ditto"
	--if BUY_BIKE then
		--o.forceCaught = false
	--else
		--o.forceCaught = true
	--end
	return o
end

function P14RainbowBadgeQuest:isDoable()
	if self:hasMap() and not hasItem("Soul Badge") then
		return true
	end
	return false
end

function P14RainbowBadgeQuest:isDone()
	if hasItem("Rainbow Badge") and getMapName() == "Lavender Town" then
		return true
	else
		return false
	end
end

function P14RainbowBadgeQuest:CeladonCity()
	if self:needPokecenter() or self:needsTeamHealingForStory() or self.registeredPokecenter ~= "Pokecenter Celadon" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(52, 19)

	elseif not self:isTrainingOver() and not hasItem("Rainbow Badge") then
		sys.debug("quest", "Going to level Pokemon until level " .. self.level .. ".")
		return moveToCell(71, 23)

	elseif not game.hasPokemonWithMove("Cut") then
		if self.pokemonId <= getTeamSize() then					
			useItemOnPokemon("HM01 - Cut", self.pokemonId)
			log("Pokemon: " .. self.pokemonId .. " Try Learning: HM01 - Cut")
			self.pokemonId = self.pokemonId + 1
		else
			fatal("No pokemon in this team can learn - Cut")
		end

	elseif not hasItem("Rainbow Badge") then
		if isNpcOnCell(46, 49) then
			sys.debug("quest", "Going to talk to NPC in front of Gym.")
			return talkToNpcOnCell(46, 49)

		elseif isNpcOnCell(58, 51) then
			sys.debug("quest", "Going to talk to NPC in front of Gym.")
			return talkToNpcOnCell(58, 51)

		elseif isNpcOnCell(21, 51) then
			sys.debug("quest", "Going to talk to NPC in front of Gym.")
			return talkToNpcOnCell(21, 51)

		else
			sys.debug("quest", "Going to 4th Gym.")
			return moveToCell(21, 50)

		end
	elseif isNpcOnCell(14, 42) then --NPC: Remove the Guards
		sys.debug("quest", "Going to remove the guard NPCs.")
		return talkToNpcOnCell(14, 42)

	elseif not hasItem("Lemonade") then -- Buy Lemonade for Future Quest (Saffron Guard)
		sys.debug("quest", "Going to buy Lemonade for future quest.")
		return moveToCell(24, 20)

	else
		sys.debug("quest", "Going to Lavender Town.")
		return moveToCell(71, 23)

	end
end

function P14RainbowBadgeQuest:PokecenterCeladon()
	self:pokecenter("Celadon City")
end

function P14RainbowBadgeQuest:Route7()
	if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Celadon" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(0, 23)
	elseif hasItem("Rainbow Badge") and hasItem("Lemonade") then
		return moveToCell(10, 31)
	elseif not self:isTrainingOver() and not hasItem("Rainbow Badge") then
		if not game.inRectangle(12, 8, 21, 21) then
			return moveToCell(17, 17)
		else
			return moveToGrass()
		end
	else
		return moveToCell(0, 23)
	end
end

function P14RainbowBadgeQuest:CeladonGym()
	if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Celadon" or not self:isTrainingOver() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(8, 30)
	elseif not hasItem("Rainbow Badge") then
		sys.debug("quest", "Going to fight Erika.")
		talkToNpcOnCell(8, 4) -- Erika
	else
		sys.debug("quest", "Going to fight Red.")
		return moveToCell(8, 30)
	end
end

function P14RainbowBadgeQuest:CeladonMart1()
	if not hasItem("Lemonade") then
		return moveToCell(9, 2)
	else
		return moveToCell(8, 15)
	end
end

function P14RainbowBadgeQuest:CeladonMartElevator()
	if not hasItem("Lemonade") then
		if not dialogs.martElevatorFloor5.state then
			pushDialogAnswer(5)
			return talkToNpcOnCell(1, 1)
		else
			dialogs.martElevatorFloor5.state = false
			return moveToCell(2, 5)
		end
	elseif not hasItem("Water Stone") then
		if not dialogs.martElevatorFloor4.state then
			pushDialogAnswer(4)
			return talkToNpcOnCell(1, 1)
		else
			dialogs.martElevatorFloor4.state = false
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

function P14RainbowBadgeQuest:CeladonMart4()
	if not hasItem("Water Stone") then
		if not isShopOpen() then
			return talkToNpcOnCell(1, 13)
		else
			if getMoney() > 3500 then
				return buyItem("Water Stone", 1)
			end
		end
	else
		return moveToCell(9, 2)
	end
end

function P14RainbowBadgeQuest:CeladonMart5()
	if not hasItem("Lemonade") then
		return moveToCell(16, 4)
	else
		return moveToCell(9, 2)
	end
end

function P14RainbowBadgeQuest:CeladonMart6()
	if not hasItem("Lemonade") then
		if not isShopOpen() then
			return talkToNpcOnCell(12, 3)
		else
			if getMoney() > 1000 then
				return buyItem("Lemonade", 5)
			else
				return buyItem("Lemonade", (getMoney()/200))
			end
		end
	else
		return moveToCell(15, 8)
	end
end

function P14RainbowBadgeQuest:UndergroundHouse3()
	return moveToCell(9, 3)
end

function P14RainbowBadgeQuest:Underground1()
	return moveToCell(69, 5)
end

function P14RainbowBadgeQuest:UndergroundHouse4()
	return moveToCell(4, 10)
end

function P14RainbowBadgeQuest:Route8()
	--if not self.forceCaught then
		--sys.debug("quest", "Going to catch Ditto for Bike later.")
		--return moveToRectangle(37, 11, 42, 11)
	--else
		return moveToCell(72, 10)
	--end
end

return P14RainbowBadgeQuest
