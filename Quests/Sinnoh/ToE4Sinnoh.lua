-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local team   = require "Libs/teamlib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'ToE4Sinnoh'
local description = 'Beat wife and live happy ever after'
local level       = 0

local dialogs = {
    FuckCynthia = Dialog:new({
        "yeu anh minh nhat",
    }),
    Aaron = Dialog:new({   
        "You may pass...",
        "You defeated me, you sure are a strong trainer.",
    }),
    Bertha = Dialog:new({   
        "rainer",
        "victory",
    }),
    xxx = Dialog:new({   
        "You may pass...",
        "victory",
    }),
    Flints = Dialog:new({   
        "rainer",
        "burning",
    }),  
    
}
local ToE4Sinnoh = Quest:new()
function ToE4Sinnoh:new()
	local o = Quest.new(ToE4Sinnoh, name, description, level, dialogs)
	o.pokemonId = 1
    o.ex = 0
    o.qnt_revive = 6
	o.qnt_hyperpot = 6
	return o
end
function ToE4Sinnoh:isDoable()
	if self:hasMap() and hasItem("Beacon Badge") and not dialogs.FuckCynthia.state then
		return true
	end
end

function ToE4Sinnoh:isDone()
	if hasItem("Beacon Badge") and getMapName() == "Canalave Pokecenter" then
		return true
	end
end

function ToE4Sinnoh:buyReviveItems() --return false if all items are on the bag (32x Revives 32x HyperPotions)
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

function ToE4Sinnoh:useReviveItems() --Return false if team don't need heal
	if not hasItem("Revive") or not hasItem("Hyper Potion") then
		return false
	end
	for pokemonId = 1, getTeamSize(), 1 do
		if getPokemonHealth(pokemonId) == 0 then
			return useItemOnPokemon("Revive", pokemonId)
		end
		if getPokemonHealthPercent(pokemonId) < 70 then
			return useItemOnPokemon("Hyper Potion", pokemonId)
		end		
	end
	return false
end

function ToE4Sinnoh:reviveItemCost()
	local bag_revive = getItemQuantity("Revive")
	local bag_hyperpot = getItemQuantity("Hyper Potion")
	local cost_revive = (self.qnt_revive - bag_revive) * 1500
	local cost_hyperpot = (self.qnt_hyperpot - bag_hyperpot) * 1200
	return cost_hyperpot + cost_revive
end
function ToE4Sinnoh:SunyShoreGym()
    sys.debug("quest", "Leave the gym.")
    return moveToCell(9, 14)
end
function ToE4Sinnoh:SunyShoreGym2()
    sys.debug("quest", "Leave the gym.")
    return moveToCell(8, 14)
end
function ToE4Sinnoh:SunyShoreGym3()
    sys.debug("quest", "Leave the gym.")
    return moveToCell(10, 25)
end
function ToE4Sinnoh:PokecenterSunyshore()
	if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 7)
	else
		self.registeredPokecenter = "Pokecenter Sunyshore" 
		return moveToCell(8, 15)
	end
end
function ToE4Sinnoh:SunyshoreCity()  
    if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Sunyshore" then
        sys.debug("quest", "Going to heal.")
        return moveToCell(29, 48)
    else
        sys.debug("quest", "Going to E4.")
        return moveToCell(25, 0)
    end
end
function ToE4Sinnoh:Route223()
    sys.debug("quest", "To E4.")
    return moveToCell(24, 0)
end
function ToE4Sinnoh:PokemonLeagueSinnoh()
    if not game.hasPokemonWithMove("Waterfall") then
		if self.pokemonId < getTeamSize() then
			useItemOnPokemon("HM07 - Waterfall", self.pokemonId)
			log("Pokemon: " .. self.pokemonId .. " Try Learning: HM07 - Waterfall")
			self.pokemonId = self.pokemonId + 1
		else
			fatal("No pokemon in this team can learn Waterfall")
		end
	end
	if game.inRectangle(6, 86, 36, 90) then
        sys.debug("quest", "Going up Waterfall.")
        return moveToCell(24, 72)
	elseif getPlayerX() == 29 and getPlayerY() == 56 then
        return moveToCell(19, 49)
    elseif not game.inRectangle(0, 12, 39, 86) and (self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter League Pokemon Sinnoh") then
        sys.debug("quest", "Going to heal.")
        return moveToCell(13, 73)
	elseif game.inRectangle(10, 72, 37, 80) and (self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter League Pokemon Sinnoh") then
        sys.debug("quest", "Going to heal.")
        return moveToCell(13, 73)
	elseif game.inRectangle(10, 72, 37, 80) and not (self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter League Pokemon Sinnoh") then
		sys.debug("quest", "Going to E4.")
		return moveToCell(24, 72)
	elseif game.inRectangle(6, 41, 32, 62) then
        sys.debug("quest", "Going to E4.")
        return moveToCell(19, 41)
	elseif game.inRectangle(1, 14, 39, 31) then
        sys.debug("quest", "Going to E4.")
        return moveToCell(20, 18)
	end
end
function ToE4Sinnoh:PokecenterLeaguePokemonSinnoh()
	if not game.isTeamFullyHealed() then
		return talkToNpcOnCell(8, 7)
	else
		self.registeredPokecenter = "Pokecenter League Pokemon Sinnoh" 
		return moveToCell(8, 15)
	end
end
function ToE4Sinnoh:SinnohVictoryRoad1F()
	sys.debug("quest", "To E4.")
    return moveToCell(33, 4)
end
function ToE4Sinnoh:SinnohPokemonLeagueGrandFloor()
	-- heal part
	if self:needPokecenter() or not game.isTeamFullyHealed() then
		sys.debug("quest", "Going to heal Pokemon.")
		return talkToNpcOnCell(4, 22)

	-- buying item part
	elseif self:buyReviveItems() ~= false then
		return

	-- E4 part
	else 
		sys.debug("quest", "Going to Sinnoh E4.")
		return moveToCell(10, 3)
	end
end
function ToE4Sinnoh:EliteFourAaronRoom()
	if self:useReviveItems() ~= false then
		return
	elseif self.ex == 0 then
		sys.debug("quest", "Going to fight #1 - Aaron.")
        self.ex = 1
		return talkToNpcOnCell(9, 11) 
    else
		sys.debug("quest", "Going to fight #2 - Bertha.")
        self.ex = 0
		return moveToCell(9, 3) 
	end
end
function ToE4Sinnoh:EliteFourBerthaRoom()
	if self:useReviveItems() ~= false then
		return
	elseif self.ex == 0 then
		sys.debug("quest", "Going to fight #2 - Bertha.")
        self.ex = 1
		return talkToNpcOnCell(9, 11) 
	else
		sys.debug("quest", "Going to fight #3 - Flints.")
        self.ex = 0
		return moveToCell(9, 3) 
	end
end
function ToE4Sinnoh:EliteFourFlintsRoom()
	if self:useReviveItems() ~= false then
		return
	elseif self.ex == 0 then
		sys.debug("quest", "Going to fight #3 - Flints.")
        self.ex = 1
		return talkToNpcOnCell(9, 11) 
	else
		sys.debug("quest", "Going to fight #4 - Lucian.")
        self.ex = 0
		return moveToCell(9, 3) 
	end
end
function ToE4Sinnoh:EliteFourLucianRoom()
	if self:useReviveItems() ~= false then
		return
	elseif self.ex == 0 then
		sys.debug("quest", "Going to fight #4 - Lucian.")
        self.ex = 1
		return talkToNpcOnCell(9, 11) 
	else
		sys.debug("quest", "Going to fight wife - Cynthia.")
        self.ex = 0
		return moveToCell(9, 3) 
	end
end
function ToE4Sinnoh:EliteFourChampionRoomSinnoh()
	if self:useReviveItems() ~= false then
		return
	elseif self.ex == 0 then
		sys.debug("quest", "Going to fight wife - Cynthia.")
        self.ex = 1
		return talkToNpcOnCell(6, 15) 
	else
		sys.debug("quest", "FREEDOM!!!")
        self.ex = 0
		return talkToNpcOnCell(6, 4) 
	end
end
function ToE4Sinnoh:TwinleafTownPlayerHouse2F()
	sys.debug("quest", "Going to Canalave City.")
    return moveToCell(8, 4)
end
function ToE4Sinnoh:TwinleafTownPlayerHouse()
	sys.debug("quest", "Going to Canalave City.")
    return moveToCell(4, 12)
end
function ToE4Sinnoh:TwinleafTown()
	sys.debug("quest", "Going to Canalave City.")
    return moveToCell(15, 0)
end
function ToE4Sinnoh:Route201()
	sys.debug("quest", "Going to Canalave City.")
    return moveToCell(100, 9)
end
function ToE4Sinnoh:Route202()
	sys.debug("quest", "Going to Canalave City.")
    return moveToCell(26, 0)
end
function ToE4Sinnoh:SandgemTown()
	sys.debug("quest", "Going to Canalave City.")
    return moveToCell(38, 0)
end
function ToE4Sinnoh:JubilifeCity()
	sys.debug("quest", "Going to Canalave City.")
    return moveToCell(1, 26)
end
function ToE4Sinnoh:Route218StopHouse1()
	sys.debug("quest", "Going to Canalave City.")
    return moveToCell(0, 7)
end
function ToE4Sinnoh:Route218StopHouse2()
	sys.debug("quest", "Going to Canalave City.")
    return moveToCell(0, 7)
end
function ToE4Sinnoh:Route218()
	sys.debug("quest", "Going to Canalave City.")
    return moveToCell(3, 19)
end
function ToE4Sinnoh:CanalaveCity()
	sys.debug("quest", "Going to Canalave City.")
    return moveToCell(40, 15)
end


return ToE4Sinnoh

