local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local pc   = require "Libs/pclib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"
local luaPokemonData = require "Data/luaPokemonData"

local name		  = 'Rock Tunnel'
local description = '(Route 9 to Lavander Town)'
local level = 1

local P12RockTunnelQuest = Quest:new()

function P12RockTunnelQuest:new()
	local o = Quest.new(P12RockTunnelQuest, name, description, level)
	o.checkedForBestPokemon = false

	return o
end

function P12RockTunnelQuest:isDoable()
	if self:hasMap() and not hasItem("Rainbow Badge") then
		return true
	end
	return false
end

function P12RockTunnelQuest:isDone()
	if getMapName() == "Celadon City" then --FIX Blackout if not Route10 or Lavander Pokecenter is Setup
		return true
	else
		return false
	end
end

function P12RockTunnelQuest:Route9()
	sys.debug("quest", "Going to Route 10.")
	return moveToCell(86, 33)
end

function P12RockTunnelQuest:Route10()
	if game.inRectangle(8, 0, 26, 12) then
		if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Route 10" then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(18, 4)
		elseif not self:isTrainingOver() then
			sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
			return moveToRectangle(13, 10, 20, 11)
		else
			sys.debug("quest", "Going to enter Rock Tunnel.")
			return moveToCell(11, 5)
		end
	else
		sys.debug("quest", "Going to Lavander Town.")
		return moveToCell(16, 71)
	end
end

function P12RockTunnelQuest:PokecenterRoute10()
		self:pokecenter("Route 10")
end

function P12RockTunnelQuest:RockTunnel1()
	if game.inRectangle(32, 4, 46, 19) or game.inRectangle(28, 17, 32, 19) then
		if self:needPokecenter() then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(43, 11)
		else
			sys.debug("quest", "Going to Rock Tunnel 2.")
			return moveToCell(35, 16)
		end
	elseif game.inRectangle(5, 5, 31, 17) then
		sys.debug("quest", "Going to Rock Tunnel 2.")
		return moveToCell(8, 15)
	else
		sys.debug("quest", "Going to Route 10 in front of Lavander Town.")
		return moveToCell(21, 32) -- Route 10 - 2nd Part
	end
end

function P12RockTunnelQuest:RockTunnel2()
	if game.inRectangle(35, 5, 45, 25) or game.inRectangle(6, 5, 34, 11) then
		sys.debug("quest", "Going to Rock Tunnel 1.")
		return moveToCell(7, 5)
	elseif game.inRectangle(6, 12, 27, 28) then
		sys.debug("quest", "Going to Rock Tunnel 1.")
		return moveToCell(8, 26)
	else
	end
end

function P12RockTunnelQuest:LavenderTown()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Lavender" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(9, 5)
	elseif self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(3, 5)
	else
		sys.debug("quest", "Going to Route 8.")
		return moveToCell(0, 10)
	end
end

function P12RockTunnelQuest:PokecenterVermilion()
	self:pokecenter("Vermilion City")
end

function P12RockTunnelQuest:VermilionPokemart()
	self:pokemart("Vermilion City")
end

function P12RockTunnelQuest:VermilionCity()
	if self:needPokemart() then
		sys.debug("quest", "Going to buy Pokeballs.")
		return moveToCell(47, 37)
	elseif hasItem("HM05 - Flash") then
		sys.debug("quest", "Going back to Route 9.")
		return moveToCell(43, 0)
	else
		sys.debug("quest", "Going to get HM05 - Flash.")
		return moveToCell(82, 41)
	end
end

function P12RockTunnelQuest:LavenderPokemart()
	self:pokemart("Lavender Town")
end

function P12RockTunnelQuest:PokecenterLavender()
	if not game.isTeamFullyHealed() then
		sys.debug("quest", "Going to heal Pokemon.")
		return talkToNpcOnCell(9, 15)
	else
		self.registeredPokecenter = "Pokecenter Lavender"
		return moveToCell(9, 22)
	end
end

function P12RockTunnelQuest:Route8()
	sys.debug("quest", "Going to Celadon City.")
	return moveToCell(12, 9)
end

function P12RockTunnelQuest:UndergroundHouse4()
	sys.debug("quest", "Going to Celadon City.")
	return moveToCell(1, 3)
end

function P12RockTunnelQuest:Underground1()
	sys.debug("quest", "Going to Celadon City.")
	return moveToCell(1, 5)
end

function P12RockTunnelQuest:UndergroundHouse3()
	sys.debug("quest", "Going to Celadon City.")
	return moveToCell(5, 10)
end

function P12RockTunnelQuest:Route7()
	sys.debug("quest", "Going to Celadon City.")
	return moveToCell(0, 24)
end

function P12RockTunnelQuest:Route6()
	sys.debug("quest", "Going back to Route 9.")
	return moveToCell(36, 18)
end

function P12RockTunnelQuest:UndergroundHouse2()
	sys.debug("quest", "Going back to Route 9.")
	return moveToCell(9, 3)
end

function P12RockTunnelQuest:Underground2()
	sys.debug("quest", "Going back to Route 9.")
	return moveToCell(3, 3)
end

function P12RockTunnelQuest:UndergroundHouse1()
	sys.debug("quest", "Going back to Route 9.")
	return moveToCell(5, 10)
end

function P12RockTunnelQuest:Route5()
	sys.debug("quest", "Going back to Route 9.")
	return moveToCell(27, 0)
end

function P12RockTunnelQuest:CeruleanCity()
	sys.debug("quest", "Going back to Route 9.")
	return moveToCell(58, 31)
end

return P12RockTunnelQuest