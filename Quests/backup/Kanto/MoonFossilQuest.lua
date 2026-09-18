

local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'Mt. Moon Fossil'
local description = 'from Route 3 to Cerulean City'
local level       = 28

local dialogs = {
	fossileGuyBeaten = Dialog:new({
		"Did you get the one you like?"--,
		--""
	})
}

local MoonFossilQuest = Quest:new()
function MoonFossilQuest:new()
	--setting moon fossil, if no none defined
	if not KANTO_FOSSIL_ID then KANTO_FOSSIL_ID = math.random(1,2) end
	return Quest.new(MoonFossilQuest, name, description, level, dialogs)
end

function MoonFossilQuest:isDoable()
	if not hasItem("Cascade Badge") and self:hasMap() then
		return true
	end
	return false
end

function MoonFossilQuest:isTrainingOver()
	if getTeamSize() >= 2 and team.getHighestLvl() >= self.level then
		return true
	end
	return false
end

function MoonFossilQuest:isDone()
	return getMapName() == "Cerulean City"
end

function MoonFossilQuest:PokecenterRoute3()
	return self:pokecenter("Route 3")
end

function MoonFossilQuest:Route3()
	if self:needPokecenter()
		or not game.isTeamFullyHealed()
		or self.registeredPokecenter ~= "Pokecenter Route 3"
	then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(79, 21)
	else
		sys.debug("quest", "Going to Mt. Moon.")
		return moveToCell(84, 16)
	end
end

function MoonFossilQuest:MtMoon1F()
	if self:needPokecenter() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(38, 63)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to train Pokemon until they are all level " .. self.level .. ".")
		return moveToRectangle(22, 53, 40, 53)
	else
		sys.debug("quest", "Going to Mt. Moon B1F.")
		return moveToCell(21, 20) -- Mt. Moon B1F
	end
end

function MoonFossilQuest:MtMoonB1F()
	if game.inRectangle(56, 18, 66, 21) then
		return moveToCell(65, 20) -- Mt. Moon B2F (wrong way)
	elseif game.inRectangle(73, 15, 78, 34)
		or game.inRectangle(53, 29, 78, 34)
	then
		sys.debug("quest", "Going to Mt. Moon B2F.")
		return moveToCell(56, 34) -- Mt. Moon B2F (right way)
	elseif game.inRectangle(32, 19, 42, 22) then
		sys.debug("quest", "Going to Mt. Moon Exit.")
		return moveToCell(41, 20) -- Mt. Moon Exit
	end
end

function MoonFossilQuest:MtMoonB2F()
	if game.inRectangle(10, 22, 63, 64) then
		if isNpcOnCell(25, 29) and isNpcOnCell(26, 29) then -- fossile on the way
			if dialogs.fossileGuyBeaten.state then
				if KANTO_FOSSIL_ID == 1 then
					sys.debug("quest", "Going to get Helix fossil.")
					return talkToNpcOnCell(25, 29)
				elseif KANTO_FOSSIL_ID == 2 then
					sys.debug("quest", "Going to get Dome fossil.")
					return talkToNpcOnCell(26, 29)
				end
			else
				sys.debug("quest", "Going to fight fossil NPC.")
				return talkToNpcOnCell(23, 31)
			end
		elseif isNpcOnCell(26, 23) then
			sys.debug("quest", "Going to fight Team Rocket.")
			return talkToNpcOnCell(26, 23) -- Team Rocket
		else
			sys.debug("quest", "Going to Mt. Moon B1F - Exit.")
			return moveToCell(17, 27) -- Mt. Moon B1F
		end
	end
end

function MoonFossilQuest:MtMoonExit()
	sys.debug("quest", "Going to Route 4.")
	return moveToCell(14,7)
end

function MoonFossilQuest:Route4()
	sys.debug("quest", "Going to Cerulean City.")
	return moveToCell(96, 21) -- Cerulean City (avoid water link)
end

return MoonFossilQuest