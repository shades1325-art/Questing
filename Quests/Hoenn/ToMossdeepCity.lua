-- Copyright � 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @WiWi__33[NetPapa]


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local pc	 = require "Libs/pclib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local luaPokemonData = require "Data/luaPokemonData"

local name		  = 'To Mossdeep City'
local description = 'Clear the Aqua Hideout of Lilycove and earn the 7th badge'
local level = 0

local dialogs = {
	shelly = Dialog:new({
		"jiafajisf",
	}),
	finaqua = Dialog:new({ 
		"Route 128"
	}),
	liza = Dialog:new({ 
		"you must find and defeat Tate",
	}),
	tate = Dialog:new({
		"you must find and defeat Liza",
	})
}

local ToMossdeepCity = Quest:new()

function ToMossdeepCity:new()
	local o = Quest.new(ToMossdeepCity, name, description, level, dialogs)
	o.shellyBeaten = false
	o.checkedForBestPokemon = false
	return o
end

function ToMossdeepCity:isDoable()
	-- The orb can still be in the inventory when the account arrives in
	-- Lilycove.  The old `not Red orb` gate prevented this quest from ever
	-- becoming selectable in that state, leaving the account with no quest
	-- method for the city.  Blue/Red Orb possession is the story marker for
	-- this segment; Mind Badge still ends it.
	if self:hasMap()
		and (hasItem("Blue Orb") or hasItem("Red Orb"))
		and not hasItem("Mind Badge")
	then
		return true
	end
	return false
end

function ToMossdeepCity:isDone()
	if hasItem("Mind Badge") then
		return true
	else
		return false
	end
end

function ToMossdeepCity:MagmaHideout4F()
	sys.debug("quest", "Going to Mossdeep City.")
	return moveToCell(20, 32)
end

function ToMossdeepCity:MagmaHideout3F3R()
	sys.debug("quest", "Going to Mossdeep City.")
	return moveToCell(21, 31)
end

function ToMossdeepCity:MagmaHideout2F3R()
	sys.debug("quest", "Going to Mossdeep City.")
	return moveToCell(21, 20)
end

function ToMossdeepCity:MagmaHideout1F()
	sys.debug("quest", "Going to Mossdeep City.")
	return moveToCell(9, 28)
end

function ToMossdeepCity:JaggedPass()
	sys.debug("quest", "Going to Mossdeep City.")
	return moveToCell(20, 110)
end

function ToMossdeepCity:Route112()
	sys.debug("quest", "Going to Mossdeep City.")
	return moveToCell(45, 59)
end

function ToMossdeepCity:Route111South()
	sys.debug("quest", "Going to Mossdeep City.")
	return moveToCell(22, 97)
end

function ToMossdeepCity:MauvilleCityStopHouse3()
	sys.debug("quest", "Going to Mossdeep City.")
	return moveToCell(4, 12)
end

function ToMossdeepCity:MauvilleCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Mauville City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(28, 13)
	else
		sys.debug("quest", "Going to Mossdeep City.")
		return moveToCell(48, 18)
	end
end

function ToMossdeepCity:PokecenterMauvilleCity()
	return self:pokecenter("Mauville City")
end

function ToMossdeepCity:MauvilleCityStopHouse4()
	sys.debug("quest", "Going to Mossdeep City.")
	return moveToCell(10, 7)
end

function ToMossdeepCity:Route118()
	sys.debug("quest", "Going to Mossdeep City.")
	return moveToCell(59, 0)
end

function ToMossdeepCity:Route119B()
	sys.debug("quest", "Going to Mossdeep City.")
	return moveToCell(9, 0)
end

function ToMossdeepCity:Route119A()
	sys.debug("quest", "Going to Mossdeep City.")
	return moveToCell(55, 8)
end

function ToMossdeepCity:FortreeCity()
	sys.debug("quest", "Going to Mossdeep City.")
	return moveToCell(54, 14)
end

function ToMossdeepCity:Route120()
	sys.debug("quest", "Going to Mossdeep City.")
	return moveToCell(50, 100)
end

function ToMossdeepCity:Route121()
	sys.debug("quest", "Going to Mossdeep City.")
	return moveToCell(85, 7)
end

function ToMossdeepCity:LilycoveCity()
	if isNpcOnCell(3, 23) then
		sys.debug("quest", "Going to fight May.")
		return talkToNpcOnCell(3, 23)

	elseif self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Lilycove City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(26, 20)

	elseif not dialogs.finaqua.state then
		sys.debug("quest", "Going to fight Aqua Clearout.")
		return moveToCell(81, 8)

	else
		sys.debug("quest", "Going to Mosdeep City.")
		return moveToCell(95, 19)
	end
end

function ToMossdeepCity:PokecenterLilycoveCity()
	return self:pokecenter("Lilycove City")
end

function ToMossdeepCity:TeamAquaHideoutEntrance()
	sys.debug("quest", "Going to Mossdeep City.")
	return moveToCell(14, 7)
end

function ToMossdeepCity:TeamAquaHideout1F()
	if game.inRectangle(29, 24, 60, 31) or game.inRectangle(38, 32, 41, 46) or game.inRectangle(55, 4, 60, 31) then
		sys.debug("quest", "Going to fight Aqua Clearout.")
		return moveToCell(58, 5)

	elseif game.inRectangle(7, 20, 26, 31) then
		if isNpcOnCell(17, 20) then
			sys.debug("quest", "Going to fight Magma Admin Courtney.")
			return talkToNpcOnCell(17, 20)
		else
			sys.debug("quest", "Going to fight Aqua Clearout.")
			return moveToCell(10, 22)
		end
	end
end

function ToMossdeepCity:TeamAquaHideoutB1F()
	if game.inRectangle(2, 20, 32, 30) or game.inRectangle(33, 26, 40, 30) then -- bottom part
		if isNpcOnCell(38, 18) then
			sys.debug("quest", "Going to fight Aqua Clearout.")
			return moveToCell(3, 29)
		else
			self.shellyBeaten = true
			return moveToCell(3, 29)
		end

	elseif game.inRectangle(33, 3, 40, 9) then
		sys.debug("quest", "Going to fight Aqua Clearout.")
		return moveToCell(35, 8)

	elseif game.inRectangle(33, 13, 40, 22) then
		if self.shellyBeaten then
			return moveToCell(35, 20)
		elseif isNpcOnCell(38, 18) then
			sys.debug("quest", "Going to fight Shelly.")
			return talkToNpcOnCell(38, 18)
		else
			self.shellyBeaten = true
		end
	end
end

function ToMossdeepCity:TeamAquaHideoutWarpHallway()
	if game.inRectangle(12, 32, 26, 32) then
		return moveToCell(19, 32)
	elseif not self.shellyBeaten then
		if game.inRectangle(12, 17, 26, 17) then
			return moveToCell(19, 17)
		elseif game.inRectangle(12, 24, 26, 24) then
			return moveToCell(14, 24)
		elseif game.inRectangle(23, 39, 40, 47) then
			return moveToCell(24, 41)
		end
	else
		if game.inRectangle(23, 39, 40, 47) then
			return moveToCell(39, 42)
		elseif game.inRectangle(12, 24, 26, 24) then
			return moveToCell(19, 24)
		elseif game.inRectangle(12, 17, 26, 17) then
			return moveToCell(24, 17)
		elseif game.inRectangle(12, 5, 26, 11) then
			return moveToCell(19, 5)
		end
	end
end

function ToMossdeepCity:TeamAquaHideoutB2F()
	if game.inRectangle(7, 3, 14, 11) then
		if not self.shellyBeaten then
			return moveToCell(12, 4)
		else
			return moveToCell(9, 10)
		end

	elseif game.inRectangle(16, 3, 40, 11) or game.inRectangle(21, 12, 40, 19) then
		return moveToCell(23, 17)

	elseif game.inRectangle(25, 24, 40, 35) then
		if isNpcOnCell(28, 30) then
			sys.debug("quest", "Going to fight Magma Grunt.")
			return talkToNpcOnCell(28, 30)
		end
	end
end

function ToMossdeepCity:Route124()
	sys.debug("quest", "Going to Mosdeep City.")
	return moveToCell(91, 32)
end

function ToMossdeepCity:MossdeepCity()
	if isNpcOnCell(36, 22) then
		sys.debug("quest", "Going to talk to NPC.")
		return talkToNpcOnCell(36, 22)

	elseif self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Mossdeep City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(36, 21)

	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(51, 21)

	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(25, 0)

	elseif not hasItem("Mind Badge") then
		sys.debug("quest", "Going to get 7th badge.")
		return moveToCell(53, 7)
	end
end

function ToMossdeepCity:PokecenterMossdeepCity()
	if not self.checkedForBestPokemon then
		self.checkedForBestPokemon = true
	else
		return self:pokecenter("Mossdeep City")
	end
end

function ToMossdeepCity:MossdeepPokemart()
	return self:pokemart()
end

function ToMossdeepCity:Route125()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(24, 40)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToCell(19, 16)
	else
		sys.debug("quest", "Going to get 7th badge.")
		return moveToCell(24, 40)
	end
end

function ToMossdeepCity:LowTideEntranceRoom()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(18, 26)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToRectangle(6, 22, 23, 22)
	else
		sys.debug("quest", "Going to get 7th badge.")
		return moveToCell(18, 26)
	end
end

function ToMossdeepCity:HighTideEntranceRoom()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(18, 26)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToRectangle(21, 3, 27, 3)
	else
		sys.debug("quest", "Going to get 7th badge.")
		return moveToCell(18, 26)
	end
end

function ToMossdeepCity:MossdeepGym() -- double check
	-- bottom left
	if game.inRectangle(0, 51, 21, 70) then
		sys.debug("quest", "Going to get 7th badge.")
		return moveToCell(5, 52)

	-- bottom right
	elseif game.inRectangle(44, 42, 60, 70) then
		sys.debug("quest", "Going to get 7th badge.")
		return moveToCell(54, 65)

	-- top left
	elseif game.inRectangle(0, 0, 20, 16) then
		sys.debug("quest", "Going to get 7th badge.")
			return moveToCell(7, 3)

	-- middle left
	elseif game.inRectangle(1, 27, 17, 37) then
		sys.debug("quest", "Going to get 7th badge.")
			return moveToCell(10, 34)

	-- top right
	elseif game.inRectangle(47, 6, 56, 12) then
		if not dialogs.liza.state then
			sys.debug("quest", "Going to fight Liza.")
			return talkToNpcOnCell(51, 8)
		elseif not dialogs.tate.state then
			sys.debug("quest", "Going to fight Tate.")
			return talkToNpcOnCell(52, 8)
		end
	end
end

return ToMossdeepCity
