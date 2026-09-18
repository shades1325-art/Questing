

local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'Quest: HM05 - Flash'
local description = 'Route 11 to Route 9'

local HmFlashQuest = Quest:new()

function HmFlashQuest:new()
	return Quest.new(HmFlashQuest, name, description, level)
end

function HmFlashQuest:isDoable()
	if self:hasMap() and not hasItem("Rainbow Badge") then
		return true
	end
	return false
end

function HmFlashQuest:isDone()
	if getMapName() == "Route 9" and hasItem("HM05 - Flash")then
		return true
	else
		return false
	end
end

function HmFlashQuest:VermilionCity()
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(82,40)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(42,0)
	end
end

function HmFlashQuest:Route11()
	if isNpcOnCell(10, 13) then -- NPC Block Diglet's Entrance
		sys.debug("quest", "Going to talk to NPC in front of Diglet Cave.")
		return talkToNpcOnCell(10, 13) 
	elseif not hasItem("HM05 - Flash") then
		--if getPokedexOwned() < 10 then
			--error("To get [HM05 - Flash] you need 10 Pokemon registered in your Pokedex. You only have " .. (getPokedexOwned()) .. " registered.")
		--else	
			sys.debug("quest", "Going to get HM05 - Flash.")
			return moveToCell(10, 12)
		--end
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(0, 13)
	end
end

function HmFlashQuest:PokecenterVermilion() -- BlackOut FIX
	self:pokecenter("Vermilion City")
end

function HmFlashQuest:Route6()
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(23,61)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(36,18)
	end
end

function HmFlashQuest:UndergroundHouse2()
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(5,10)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(9,3)
	end
end

function HmFlashQuest:Underground2()
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(3,43)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(3,3)
	end
end

function HmFlashQuest:UndergroundHouse1()
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(9,3)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(5,10)
	end
end

function HmFlashQuest:Route5() 
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(27,29)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(28,0)
	end
end

function HmFlashQuest:CeruleanCity()
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(23,50)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(58,30)
	end
end

function HmFlashQuest:DiglettsCaveEntrance2()
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(20,14)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(20,28)
	end
end

function HmFlashQuest:DiglettsCave()
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(27,16)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(52,56)
	end
end

function HmFlashQuest:DiglettsCaveEntrance1()
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(15,28)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(24,19)
	end
end

function HmFlashQuest:Route2()
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(39,90)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(33,31)
	end
end

function HmFlashQuest:Route2Stop3()
	--if getPokedexOwned() < 10 then
		--fatal("To take [HM05 - Flash] need 10 pokemons, you still have to catch ".. (10 - getPokedexOwned()) .." pokemons")
	--elseif not hasItem("HM05 - Flash") then
	if not hasItem("HM05 - Flash") then
		return talkToNpcOnCell(6,5)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(3,2)
	end
end

return HmFlashQuest