local sys   = require "Libs/syslib"
local Quest = require "Quests/Quest"

local name        = 'Quest: HM05 - Flash'
local description = 'Route 11 to Route 9'

local P10HmFlashQuest = Quest:new()

function P10HmFlashQuest:new()
	return Quest.new(P10HmFlashQuest, name, description, level)
end

function P10HmFlashQuest:isDoable()
	-- HM05/Route 9 must remain behind Surge.  This also lets the
	-- shared quest ordering reactivate the existing Thunder Badge quest
	-- when an old completion flag skipped it.
	if self:hasMap() and hasItem("Thunder Badge") and not hasItem("Rainbow Badge") then
		return true
	end
	return false
end

function P10HmFlashQuest:isPersistentCompletionValid()
	return hasItem("Thunder Badge") and hasItem("HM05 - Flash")
end

function P10HmFlashQuest:isDone()
	return getMapName() == "Route 9" and hasItem("HM05 - Flash")
end

function P10HmFlashQuest:VermilionGym()
	sys.debug("quest", "Going to Route 11.")
	return moveToCell(6, 21)
end

function P10HmFlashQuest:VermilionCity()
	if hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(42, 0)
	elseif self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(27, 21)
	else
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(82, 40)
	end
end

function P10HmFlashQuest:VermilionHouse2Bottom()
	-- Leave the house; the optional purchase flow is not part of this quest.
	return moveToCell(5, 10)
end

function P10HmFlashQuest:Route11()
	if isNpcOnCell(10, 13) then -- NPC blocks Diglett's Cave
		self:debug("quest", "Going to talk to NPC in front of Diglett's Cave.")
		return talkToNpcOnCell(10, 13)
	elseif not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(10, 12)
	elseif self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(0, 13)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(0, 13)
	end
end

function P10HmFlashQuest:PokecenterVermilion() -- BlackOut FIX
	if self:shouldHealAtPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return talkToNpcOnCell(8, 15)
	else
		self.heroHealRequested = false
		self.registeredPokecenter = "Pokecenter Vermilion"
		return moveToCell(8, 22)
	end
end

function P10HmFlashQuest:Route6()
	if hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(36, 18)
	else
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(23, 61)
	end
end

function P10HmFlashQuest:UndergroundHouse2()
	if hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(9, 3)
	else
		sys.debug("quest", "Going to Route 11.")
		return moveToCell(5, 10)
	end
end

function P10HmFlashQuest:Underground2()
	if hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(3, 3)
	else
		sys.debug("quest", "Going to Route 11.")
		return moveToCell(3, 43)
	end
end

function P10HmFlashQuest:UndergroundHouse1()
	if hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(5, 10)
	else
		sys.debug("quest", "Going to Route 11.")
		return moveToCell(9, 3)
	end
end

function P10HmFlashQuest:Route5()
	if hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(28, 0)
	else
		sys.debug("quest", "Going to Route 11.")
		return moveToCell(27, 29)
	end
end

function P10HmFlashQuest:CeruleanCity()
	if hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(58, 31)
	else
		sys.debug("quest", "Going to Route 11.")
		return moveToCell(23, 50)
	end
end

function P10HmFlashQuest:CeruleanCityBikeShop()
	-- Keep the map handler for compatibility, but never talk to the clerk.
	return moveToCell(6, 15)
end

function P10HmFlashQuest:DiglettsCaveEntrance2()
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(20, 14)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(20, 28)
	end
end

function P10HmFlashQuest:DiglettsCave()
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(27, 16)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(52, 56)
	end
end

function P10HmFlashQuest:DiglettsCaveEntrance1()
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(15, 28)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(24, 19)
	end
end

function P10HmFlashQuest:Route2()
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(39, 90)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(33, 31)
	end
end

function P10HmFlashQuest:Route2Stop3()
	if not hasItem("HM05 - Flash") then
		return talkToNpcOnCell(6, 5)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(3, 2)
	end
end

return P10HmFlashQuest
