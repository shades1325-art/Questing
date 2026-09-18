

local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'Quest: HM05 - Flash'
local description = 'Route 11 to Route 9'

local P10HmFlashQuest = Quest:new()

local dialogs = {
	BikeVoucher = Dialog:new({
		"my poor Ditto",
		"Please leave.",
		"You did not help my Ditto.. he doesn't seem to be the same."
	})
}


function P10HmFlashQuest:new()
	return Quest.new(P10HmFlashQuest, name, description, level)
end

function P10HmFlashQuest:isDoable()
	if self:hasMap() and not hasItem("Rainbow Badge") then
		return true
	end
	return false
end

function P10HmFlashQuest:isDone()
	if getMapName() == "Route 9" and hasItem("HM05 - Flash") and hasItem("Bicycle")then
		return true
	else
		return false
	end
end

function P10HmFlashQuest:VermilionGym()
	sys.debug("quest", "Going to Route 11.")
	return moveToCell(6, 21)
end
function P10HmFlashQuest:VermilionCity()
	if hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(42, 0)
	end
	if self:needPokecenter() then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(27, 21)
	end
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(82,40)
	end
	if not self:canBuyBike() and not (hasItem("Bicycle") or hasItem("Bike Voucher"))  then
		sys.debug("quest", "Going to earn more money.")
		return moveToCell(82,40)
	end
	if self:canBuyBike() and not hasItem("Bike Voucher") then
		sys.debug("quest", "Earned enough money for Bike.")
		return moveToCell(32, 21)
	end
	if hasItem("Bike Voucher") then
		sys.debug("quest", "Going to get Bike.")
		return moveToCell(42, 0)
	end
end

function P10HmFlashQuest:VermilionHouse2Bottom()
    if not hasItem("Bike Voucher") and not hasItem("Bicycle") then
			pushDialogAnswer(3)
			return talkToNpcOnCell(6,6)
		else
			return moveToCell(5, 10)
		end

    --return talkToNpcOnCell(6, 6)
end

function P10HmFlashQuest:Route11()
	if hasItem("Bicycle") and hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(0, 13)
	end
	if isNpcOnCell(10, 13) then -- NPC Block Diglet's Entrance
		self:debug("quest", "Going to talk to NPC in front of Diglet Cave.")
		return talkToNpcOnCell(10, 13) 
	elseif not hasItem("HM05 - Flash") then
		--if getPokedexOwned() < 10 then
			--error("To get [HM05 - Flash] you need 10 Pokemon registered in your Pokedex. You only have " .. (getPokedexOwned()) .. " registered.")
		--else	
			sys.debug("quest", "Going to get HM05 - Flash.")
			return moveToCell(10, 12)
		--end
	end
	if self:needPokecenter() then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(0, 13)
	end
	if not hasItem("Bicycle") or not (hasItem("Bicycle") or hasItem("Bike Voucher")) then
		if not self:canBuyBike() and not hasItem("Bicycle") then
			return moveToRectangle(30, 25, 42, 26)
		elseif self:canBuyBike() and not hasItem("Bicycle") then
			sys.debug("quest", "Earned enough money for Bike.")
			return moveToCell(0, 13)
		end
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
	if hasItem("Bicycle") and hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(36, 18)
	end
	if hasItem("Bike Voucher") and not hasItem("Bicycle") then
		sys.debug("quest", "Going to get Bike.")
		return moveToCell(36, 18)
	elseif not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(23, 61)
	end
end

function P10HmFlashQuest:UndergroundHouse2()
	if hasItem("Bike Voucher") and not hasItem("Bicycle") then
		sys.debug("quest", "Going to get Bike.")
		return moveToCell(9, 3)
	elseif hasItem("Bicycle") and hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(9, 3)
	else
		sys.debug("quest", "Going to Route 11.")
		return moveToCell(5, 10)
	end
end

function P10HmFlashQuest:Underground2()
	if hasItem("Bike Voucher") and not hasItem("Bicycle") then
		sys.debug("quest", "Going to get Bike.")
		return moveToCell(3,3)
	elseif hasItem("Bicycle") and hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(3,3)
	else
		sys.debug("quest", "Going to Route 11.")
		return moveToCell(3,43)
	end
end

function P10HmFlashQuest:UndergroundHouse1()
	if hasItem("Bike Voucher") and not hasItem("Bicycle") then
		sys.debug("quest", "Going to get Bike.")
		return moveToCell(5,10)
	elseif hasItem("Bicycle") and hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(5,10)
	else
		sys.debug("quest", "Going to Route 11.")
		return moveToCell(9,3)
	end
end

function P10HmFlashQuest:Route5() 
	if hasItem("Bike Voucher") and not hasItem("Bicycle") then
		sys.debug("quest", "Going to get Bike.")
		return moveToCell(28,0)
	elseif hasItem("Bicycle") and hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(28,0)
	else
		sys.debug("quest", "Going to Route 11.")
		return moveToCell(27,29)
	end
end

function P10HmFlashQuest:CeruleanCity()
	if hasItem("Bike Voucher") and not hasItem("Bicycle") then
		sys.debug("quest", "Going to get Bike.")
		return moveToCell(15, 38)
	elseif hasItem("Bicycle") and hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(58, 31)
	else
		if not isMounted() and hasItem("Bicycle") then
			return useItem("Bicycle")
		end
		sys.debug("quest", "Going to Route 11.")
		return moveToCell(23, 50)
	end
end

function P10HmFlashQuest:CeruleanCityBikeShop()
	if not hasItem("Bicycle") then
		sys.debug("quest", "Going to get Bike.")
		return talkToNpcOnCell(11, 7)
	else
		sys.debug("quest", "Going to Route 11.")
		return moveToCell(6, 15)
	end
end

function P10HmFlashQuest:DiglettsCaveEntrance2()
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(20,14)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(20,28)
	end
end

function P10HmFlashQuest:DiglettsCave()
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(27,16)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(52,56)
	end
end

function P10HmFlashQuest:DiglettsCaveEntrance1()
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(15,28)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(24,19)
	end
end

function P10HmFlashQuest:Route2()
	if not hasItem("HM05 - Flash") then
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(39,90)
	else
		sys.debug("quest", "Going to Route 9.")
		return moveToCell(33,31)
	end
end

function P10HmFlashQuest:Route2Stop3()
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

return P10HmFlashQuest
