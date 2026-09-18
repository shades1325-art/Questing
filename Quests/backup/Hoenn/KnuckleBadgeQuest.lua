-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @WiWi__33[NetPapa]


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'Knuckle Badge'
local description = 'Will meet Steven, earn 2nd badge and get back to Devon corp '

local level       = 0

local dialogs = {
	Steven = Dialog:new({ 
		"Steven",
	}),
}

local KnuckleBadgeQuest  = Quest:new()

function KnuckleBadgeQuest:new()
	return Quest.new(KnuckleBadgeQuest , name, description, level, dialogs)
end

function KnuckleBadgeQuest:isDoable()
	if hasItem("Stone Badge") and self:hasMap() and not hasItem("Devon Goods") and not hasItem("Dynamo Badge") then
		return true
	end
	return false
end

function KnuckleBadgeQuest:isDone()
	return hasItem("Knuckle Badge") and hasItem("Devon Goods")
end 

function KnuckleBadgeQuest:PetalburgWoods()
	if not hasItem("Knuckle Badge") then
		sys.debug("quest", "Going to get 2nd badge.")
		return moveToCell(24, 60)
	else
		sys.debug("quest", "Going back to Devon Corp.")
		return moveToCell(21, 0)
	end
end

function KnuckleBadgeQuest:Route104()
	if game.inRectangle(0, 0, 78, 54) then 
		if hasItem("Knuckle Badge") then 
			sys.debug("quest", "Going back to Devon Corp.")
			return moveToCell(41, 0)
		else
			sys.debug("quest", "Going to get 2nd badge.")
			return moveToCell(24, 51)
		end
	else
		if not hasItem("Knuckle Badge") then
			sys.debug("quest", "Going to get 2nd badge.")
			return moveToCell(45, 97)
		else
			sys.debug("quest", "Going back to Devon Corp.")
			return moveToCell(36,79)
		end
	end
end

function KnuckleBadgeQuest:Route104SailorHouse()
	sys.debug("quest", "Going to get 2nd badge.")
	return talkToNpcOnCell(11, 6)
end

function KnuckleBadgeQuest:DewfordTown()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Dewford Town" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(13, 14)
	elseif hasItem("SLetter") then 
		sys.debug("quest", "Going to deliver letter to Steven.")
		return moveToCell(20, 0)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(20, 0)
	elseif not hasItem("Knuckle Badge") then
		if isNpcOnCell(22, 23) then 
			sys.debug("quest", "Going to get 2nd badge.")
			return talkToNpcOnCell(22, 23)
		else
			sys.debug("quest", "Going to get 2nd badge.")
			return moveToCell(22, 22)
		end
	else
		sys.debug("quest", "Going back.")
		return talkToNpcOnCell(37, 9)
	end
end

function KnuckleBadgeQuest:PokecenterDewfordTown()
	return self:pokecenter("Dewford Town")
end

function KnuckleBadgeQuest:Route106()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(98, 42)
	elseif hasItem("SLetter") then 
		sys.debug("quest", "Going to deliver letter to Steven.")
		return moveToCell(75, 34)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(75, 34)
	else
		sys.debug("quest", "Going back.")
		return moveToCell(98, 42)
	end
end

function KnuckleBadgeQuest:GraniteCave1F()
	if game.inRectangle(15, 8, 37, 14) or game.inRectangle(31, 9, 42, 17) then
		if hasItem("SLetter") then
			sys.debug("quest", "Going to deliver letter to Steven.")
			return moveToCell(17, 13)
		elseif self:needPokecenter() then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(39, 15)
		elseif not self:isTrainingOver() then 
			sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
			moveToRectangle(18, 8, 40, 14)
		else
			sys.debug("quest", "Going back.")
			return moveToCell(39, 15)
		end
	else
		if hasItem("SLetter") then
			sys.debug("quest", "Going to deliver letter to Steven.")
			return moveToCell(7, 13)
		else
			sys.debug("quest", "Going back.")
			return moveToCell(38, 6)
		end
	end
end

function KnuckleBadgeQuest:GraniteCaveB1F()
	if game.inRectangle(27, 13, 32, 17) or game.inRectangle(30, 18, 32, 21) then
		if hasItem("SLetter") then
			sys.debug("quest", "Going to deliver letter to Steven.")
			return moveToCell(28, 15)
		else
			sys.debug("quest", "Going back.")
			return moveToCell(31, 15)
		end
	else
		if hasItem("SLetter") then
			sys.debug("quest", "Going to deliver letter to Steven.")
			return moveToCell(30, 24)
		else
			sys.debug("quest", "Going back.")
			return moveToCell(5, 23)
		end
	end
end
	
function KnuckleBadgeQuest:GraniteCaveB2F()
	if hasItem("SLetter") then 
		sys.debug("quest", "Going to deliver letter to Steven.")
		return moveToCell(30, 18)
	else
		sys.debug("quest", "Going back.")
		return moveToCell(29, 26)
	end
end

function KnuckleBadgeQuest:GraniteCave1F2()
	if isNpcOnCell(8, 9) then
		sys.debug("quest", "Going to deliver letter to Steven.")
		return talkToNpcOnCell(8, 9)
	else
		sys.debug("quest", "Going back.")
		return moveToCell(7, 3)
	end
end

function KnuckleBadgeQuest:DewfordTownGym()
	if not hasItem("Knuckle Badge") then 
		sys.debug("quest", "Going to get 2nd badge.")
		return talkToNpcOnCell(16,12)
	else
		sys.debug("quest", "Going back.")
		return moveToCell(16, 64)
	end
end

function KnuckleBadgeQuest:RustboroCity()
	sys.debug("quest", "Going to talk to Mr. Stone in Devon Corp.")
	return moveToCell(34, 11)
end

function KnuckleBadgeQuest:DevonCorporation1F()
	if not dialogs.Steven.state then
		sys.debug("quest", "Going to talk to Mr. Stone in Devon Corp.")
		return moveToCell(20, 3)
	end
end

function KnuckleBadgeQuest:DevonCorporation2F()
	if not dialogs.Steven.state then
		sys.debug("quest", "Going to talk to Mr. Stone in Devon Corp.")
		return moveToCell(6, 3)
	end
end

function KnuckleBadgeQuest:DevonCorporation3F()
	if not dialogs.Steven.state then
		sys.debug("quest", "Going to talk to Mr. Stone in Devon Corp.")
		return talkToNpcOnCell(25, 8)
	end
end

return KnuckleBadgeQuest