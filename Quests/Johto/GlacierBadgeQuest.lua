-- Copyright � 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @WiWi__33[NetPaPa]

local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Glacier Badge Quest'
local description = 'Will clear the Rocket Hideout, and earn the 7th Badge'
local level = 0

local dialogs = {
	goChangeComputerSettings = Dialog:new({
		"Please go back before you trigger something around here!",
	}),
	checkNextComputer = Dialog:new({ 
		"Rats, no sign of any picture with Christina on this desk!"
	}),
	foundComputer = Dialog:new({ 
		"I don't have anything to do with this now...",
		"Yes, this was the computer!"
	}),
	disabledAdminPC = Dialog:new({
		"I'm done with this PC now...",
	})
}

local GlacierBadgeQuest = Quest:new()

function GlacierBadgeQuest:new()
	local o = Quest.new(GlacierBadgeQuest, name, description, level, dialogs)
	o.talkedToChappyNPC = false
	o.N = 1
	o.checkedJessiePC = false
	o.checkedJamesPC = false
	o.foughtAdminChristina = false
	return o
end


function GlacierBadgeQuest:isDoable()
	if self:hasMap() and not hasItem("Glacier Badge") and hasItem("Mineral Badge") then
		return true
	end
	return false
end

function GlacierBadgeQuest:isDone()
	if hasItem("Glacier Badge") and getMapName() == "Mahogany Town Gym" then
		return true
	else
		return false
	end
end

function GlacierBadgeQuest:OlivineCityGym()
	sys.debug("quest", "Going to Mahogany Town.")
	return moveToCell(6, 25)
end

function GlacierBadgeQuest:OlivineCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Olivine Pokecenter" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(13, 32)
	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(27, 31)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(0, 36)
	else
		sys.debug("quest", "Going to Mahogany Town.")
		return moveToCell(20, 0)
	end
end

function GlacierBadgeQuest:OlivinePokecenter()
	self:pokecenter("Olivine City")
end

function GlacierBadgeQuest:OlivinePokemart()
	self:pokemart()
end

function GlacierBadgeQuest:Route40()
	if not self:isTrainingOver() and not self:needPokecenter() then 
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(12, 47)
	else
		sys.debug("quest", "Going back to Olivine City.")
		return moveToCell(30, 7)
	end
end

function GlacierBadgeQuest:Route41()
	if not self:isTrainingOver() and not self:needPokecenter() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToRectangle(1, 8, 2, 52)
	else
		sys.debug("quest", "Going back to Olivine City.")
		return moveToCell(52, 0)
	end
end

function GlacierBadgeQuest:Route39()
	if not self:isTrainingOver() and not self:needPokecenter() then 
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(28, 65)
	else
		sys.debug("quest", "Going to Mahogany Town.")
		return moveToCell(39, 17)
	end
end

function GlacierBadgeQuest:Route38()
	if not self:isTrainingOver() and not self:needPokecenter() then 
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(0, 15)
	else
		sys.debug("quest", "Going to Mahogany Town.")
		return moveToCell(63, 11)
	end
end

function GlacierBadgeQuest:EcruteakStopHouse1()
	if not self:isTrainingOver() and not self:needPokecenter() then 
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(0, 7)
	else
		sys.debug("quest", "Going to Mahogany Town.")
		return moveToCell(10, 6)
	end
end


function GlacierBadgeQuest:EcruteakCity()
	if not self:isTrainingOver() and not self:needPokecenter() then 
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(3, 26)
	else
		sys.debug("quest", "Going to Mahogany Town.")
		return moveToCell(62, 33)
	end
end


function GlacierBadgeQuest:EcruteakStopHouse2()
	if not self:isTrainingOver() and not self:needPokecenter() then 
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(0, 6)
	else
		sys.debug("quest", "Going to Mahogany Town.")
		return moveToCell(10, 6)
	end
end

function GlacierBadgeQuest:Route42()
	if not self:isTrainingOver() and not self:needPokecenter() then 
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(3, 18)
	else
		sys.debug("quest", "Going to Mahogany Town.")
		return moveToCell(95, 16)
	end
end

function GlacierBadgeQuest:MahoganyTown()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Mahogany" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(25, 23)
	elseif not self:isTrainingOver() and not self:needPokecenter() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(0, 17)
	elseif not isNpcOnCell(11, 24) then
		sys.debug("quest", "Going to get 7th badge.")
		return moveToCell(11, 23)
	elseif not self.talkedToChappyNPC then
		sys.debug("quest", "Going to talk to Chappy.")
		return moveToCell(12, 5)
	elseif self.talkedToChappyNPC then 
		sys.debug("quest", "Going to do Rocket quest.")
		return moveToCell(16, 14)
	end
end

function GlacierBadgeQuest:PokecenterMahogany()
	if isNpcOnCell(9, 22) then
		sys.debug("quest", "Going to talk to NPC.")
		return talkToNpcOnCell(9, 22)
	else
		return self:pokecenter("Mahogany Town")
	end
end

function GlacierBadgeQuest:Route43()
	if not self.talkedToChappyNPC then
		sys.debug("quest", "Going to talk to Chappy.")
		return moveToCell(22, 0)
	else
		sys.debug("quest", "Going to do Rocket quest.")
		return moveToCell(18, 64)
	end
end

function GlacierBadgeQuest:LakeofRage()
	if isNpcOnCell(50, 28) then
		sys.debug("quest", "Going to talk to Chappy.")
		return talkToNpcOnCell(50, 28)
	else
		self.talkedToChappyNPC = true
		sys.debug("quest", "Going to do Rocket quest.")
		return moveToCell(46, 60)
	end
end

function GlacierBadgeQuest:MahoganyTownShop()
	sys.debug("quest", "Going to do Rocket quest.")
	return moveToCell(6, 3)
end

function GlacierBadgeQuest:MahoganyTownRocketHideoutB1F()
	sys.debug("quest", "Going to do Rocket quest.")
	return moveToCell(4, 24)
end

function GlacierBadgeQuest:MahoganyTownRocketHideoutB2F()
	-- bottom part
	if game.inRectangle(0, 23, 50, 30) then
		if not isNpcOnCell(24, 22) then
			if isNpcOnCell(33, 13) then
				sys.debug("quest", "Going to fight Electrodes.")
				return moveToCell(23, 18)
			end
		elseif not dialogs.goChangeComputerSettings.state then 
			if isNpcOnCell(24, 22) then
				sys.debug("quest", "Going to talk to Lance.")
				if not game.inCell(24, 23) then
					return moveToCell(24, 23)
				else
					return talkToNpcOnCell(24, 22)
				end
			end
		else
			sys.debug("quest", "Going to change Computer Settings.")
			return moveToCell(49, 30)
		end



	-- middle part
	elseif game.inRectangle(12, 9, 37, 22) then
		if isNpcOnCell(33, 13) then
			if isNpcOnCell(15, 12) then
				sys.debug("quest", "Going to fight Pokemon 1/3.")
				return talkToNpcOnCell(15, 12)
			elseif isNpcOnCell(15, 13) then
				sys.debug("quest", "Going to fight Pokemon 2/3.")
				return talkToNpcOnCell(15, 13)
			elseif isNpcOnCell(15, 14) then
				sys.debug("quest", "Going to fight Pokemon 3/3.")
				return talkToNpcOnCell(15, 14)
			end
		else
			sys.debug("quest", "Going to talk to Lance.")
			return talkToNpcOnCell(24, 22)
		end


	-- top part
	elseif game.inRectangle(1, 2, 50, 6) or game.inRectangle(39, 6, 47, 20) then
		if not self.checkedJessiePC then
			sys.debug("quest", "Going to check Jessie's PC.")
			if not game.inCell(40, 18) then
				return moveToCell(40, 18)
			else
				if talkToNpcOnCell(40, 17) then
					self.checkedJessiePC = true
				end
			end
		elseif self.checkedJessiePC and self.checkedJamesPC then 
			sys.debug("quest", "Going to talk to Lance.")
			return moveToCell(49, 5)
		else
			sys.debug("quest", "Going to check James' PC.")
			return moveToCell(2, 5)
		end

	-- left part
	elseif game.inRectangle(2, 9, 9, 19) then
		if not self.checkedJamesPC then
			sys.debug("quest", "Going to check James' PC.")
			if not game.inCell(5, 18) then
				return moveToCell(5, 18)
			else
				if talkToNpcOnCell(5, 17) then
					self.checkedJamesPC = true
				end
			end
		else
			sys.debug("quest", "Going to talk to Lance.")
			return moveToCell(2, 10)
		end
	end
end

function GlacierBadgeQuest:talkToComputer(x, y)
	if not game.inCell(x, y + 1) then
		return moveToCell(x, y + 1)
	else
		return talkToNpcOnCell(x, y)
	end
end

function GlacierBadgeQuest:MahoganyTownRocketHideoutB3F()
	if game.inRectangle(25, 3, 50, 31) or game.inRectangle(5, 23, 25, 30) then
		if dialogs.checkNextComputer.state then
			dialogs.checkNextComputer.state = false
			self.N = self.N + 1
			return
		elseif dialogs.foundComputer.state then
			if not self.foughtAdminChristina then
				sys.debug("quest", "Going to check Admin PC.")
				return moveToCell(49, 5)
			else
				sys.debug("quest", "Going to talk to Lance.")
				dialogs.goChangeComputerSettings.state = false
				return moveToCell(49, 30)
			end
		else
			sys.debug("quest", string.format("Going to check computer #%i.", self.N))
			if self.N == 1 then
				return self:talkToComputer(40, 18)
			elseif self.N == 2 then
				return self:talkToComputer(37, 18)
			elseif self.N == 3 then
				return self:talkToComputer(34, 18)
			elseif self.N == 4 then
				return self:talkToComputer(31, 18)
			elseif self.N == 5 then
				return self:talkToComputer(40, 14)
			elseif self.N == 6 then
				return self:talkToComputer(37, 14)
			elseif self.N == 7 then
				return self:talkToComputer(34, 14)
			elseif self.N == 8 then
				return self:talkToComputer(31, 14)
			end
		end
	end
	if not self.checkedJamesPC then 
		sys.debug("quest", "Going to check James' PC.")
		return moveToCell(2, 10)
	elseif isNpcOnCell(18, 9) then
		sys.debug("quest", "Going to talk to Admin Christina.")
		return talkToNpcOnCell(18, 9)
	elseif self.foughtAdminChristina and not dialogs.disabledAdminPC.state then
		sys.debug("quest", "Going to check Admin Christina's PC.")
		return self:talkToComputer(16, 6)
	elseif self.foughtAdminChristina and dialogs.disabledAdminPC.state then
		sys.debug("quest", "Going to talk to Lance.")
		return moveToCell(2, 5)
	elseif not isNpcOnCell(18, 9) then
		self.foughtAdminChristina = true
	end
end

function GlacierBadgeQuest:MahoganyTownGym()
	if game.inRectangle(15, 49, 21, 67) then 
		sys.debug("quest", "Going to get 7th badge.")
		return moveToCell(17, 49)

	elseif game.inRectangle(12, 32, 22, 46) then  
		sys.debug("quest", "Going to get 7th badge.")
		return moveToCell(17, 32)

	elseif game.inRectangle(13, 12, 21, 29) then 
		sys.debug("quest", "Going to get 7th badge.")
		return talkToNpcOnCell(19, 12)
	end
end

return GlacierBadgeQuest