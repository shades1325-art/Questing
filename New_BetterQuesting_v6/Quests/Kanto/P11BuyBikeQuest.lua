-- Copyright � 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local pc	 = require "Libs/pclib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Buy Bike'
local description = 'Go to Cerulean City to get Bike.'

local P11BuyBikeQuest = Quest:new()

function P11BuyBikeQuest:canBuyBike()
	return getMoney() > 60000 or hasItem("Bike Voucher")
end

function P11BuyBikeQuest:new()
	local o = Quest.new(P11BuyBikeQuest, name, description, level, dialogs)
	o.needCutPokemon = false
	return o
end

function P11BuyBikeQuest:isDoable()
	if self:hasMap() and hasItem("Volcano Badge") and not hasItem("Earth Badge") and not hasItem("Bicycle") then
		return true
	end
	return false
end

function P11BuyBikeQuest:isDone()
	if hasItem("Bicycle") or getMapName() == "Pokecenter Cinnabar" then
		return true
	end
	return false
end

function P11BuyBikeQuest:Route21()
	sys.debug("quest", "Going to get Bike.")
	return moveToCell(14, 0)
end

function P11BuyBikeQuest:PalletTown()
	sys.debug("quest", "Going to get Bike.")
	return moveToCell(14, 0)
end

function P11BuyBikeQuest:Route1()
	sys.debug("quest", "Going to get Bike.")
	return moveToCell(14, 4)
end

function P11BuyBikeQuest:Route1StopHouse()
	sys.debug("quest", "Going to get Bike.")
	return moveToCell(4, 2)
end

function P11BuyBikeQuest:ViridianCity()
	if self.needCutPokemon then
		sys.debug("quest", "Going to get Pokemon with Cut from Boxes.")
		return moveToCell(44, 43)
	if not game.hasPokemonWithMove("Cut") then
		self.needCutPokemon = true
	else
		sys.debug("quest", "Going to get Bike.")
		return moveToCell(39, 0)
	end
end

function P11BuyBikeQuest:PokecenterViridian()
		self:pokecenter("Viridian City")
end

function P11BuyBikeQuest:Route2()
	sys.debug("quest", "Going to get Bike.")
	if game.inRectangle(0, 93, 45, 130) then
		return moveToCell(39, 96)
	else
		return moveToCell(33, 31)
	end
end

function P11BuyBikeQuest:Route2Stop3()
	sys.debug("quest", "Going to get Bike.")
	return moveToCell(3, 2)
end

function P11BuyBikeQuest:DiglettsCaveEntrance1()
	sys.debug("quest", "Going to get Bike.")
	return moveToCell(24, 19)
end

function P11BuyBikeQuest:DiglettsCave()
	sys.debug("quest", "Going to get Bike.")
	return moveToCell(52, 56)
end

function P11BuyBikeQuest:DiglettsCaveEntrance2()
	sys.debug("quest", "Going to get Bike.")
	return moveToCell(20, 28)
end

function P11BuyBikeQuest:Route11()
	sys.debug("quest", "Going to get Bike.")
	return moveToCell(0, 14)
end

function P11BuyBikeQuest:VermilionCity()
	if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Vermilion" then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(27, 21)
	end
	if not hasItem("Bike Voucher") then
		if not self:canBuyBike() then
        	sys.debug("quest", "Farming $" .. 60000 - getMoney() .. " more money, so we can buy the bike.")
			return moveToRectangle(7, 29, 28, 29)
	
		elseif self:canBuyBike() then
			sys.debug("quest", "Earned enough money for Bike.")
			return moveToCell(32, 21)
		end
	end
	if hasItem("Bike Voucher") then
		sys.debug("quest", "Going to get Bike.")
		return moveToCell(42, 0)
	end
end

function P11BuyBikeQuest:PokecenterVermilion()
		self:pokecenter("Vermilion City")
end

function P11BuyBikeQuest:VermilionHouse2Bottom()
    if hasItem("Bike Voucher") then
        sys.debug("quest", "Going to get Bike.")
        return moveToCell(5, 10)
    end

    --if getDialogOptionsCount() >= 3 then
       --sys.debug("quest", "Selecting Buy Bike Voucher (Option 3)")
        --pushDialogAnswer(3)
        --return
    --end

    --return talkToNpcOnCell(6, 6)
end

function P11BuyBikeQuest:Route6()
	sys.debug("quest", "Going to get Bike.")
	return moveToCell(26, 5)
end

function P11BuyBikeQuest:Route6StopHouse()
	sys.debug("quest", "Going to get Bike.")
	return moveToCell(3, 2)
end

function P11BuyBikeQuest:SaffronCity()
	sys.debug("quest", "Going to get Bike.")
	return moveToCell(26, 5)
end

function P11BuyBikeQuest:Route5StopHouse()
	sys.debug("quest", "Going to get Bike.")
	return moveToCell(3, 2)
end

function P11BuyBikeQuest:Route5()
	sys.debug("quest", "Going to get Bike.")
	return moveToCell(27, 0)
end

function P11BuyBikeQuest:CeruleanCity()
	sys.debug("quest", "Going to get Bike.")
	return moveToCell(15, 38)
end

function P11BuyBikeQuest:CeruleanCityBikeShop()
	sys.debug("quest", "Going to get Bike.")
	return talkToNpcOnCell(11, 7)
end

return P11BuyBikeQuest