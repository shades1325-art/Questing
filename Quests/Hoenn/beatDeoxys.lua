-- Copyright © 2016 g0ld <g0ld@tuta.io>
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

local name		  = 'Beat Deoxys'
local description = 'Will earn the 8th Badge and beat Deoxys on the moon'
local level = 0

local dialogs = {
	goToSkyPillar = Dialog:new({ 
		"He is currently at Sky Pillar"
	}),
	firstGymLeaderDone = Dialog:new({ 
		"He is somewhere in this Gym..."
	})
}

local beatDeoxys = Quest:new()

function beatDeoxys:new()
	local o = Quest.new(beatDeoxys, name, description, level, dialogs)
	o.deoxysBeaten = false
	o.relogged = false
	return o
end

function beatDeoxys:isDoable()
	if self:hasMap() and not hasItem("Blue Orb") and not hasItem("Rain Badge") then
		return true
	end
	return false
end

function beatDeoxys:isDone()
	-- Wallace's badge is the objective.  Requiring a specific gym-floor map
	-- left the quest selected after the battle when the server kept the player
	-- on another gym tile, so its post-badge handler returned no action.
	return hasItem("Rain Badge")
end

-- This quest requires a fully restored team before the long Sky Pillar/Moon
-- route.  The generic needPokecenter() check is intentionally stricter and
-- can remain true when a healthy party member has no usable offensive move;
-- that caused a healthy team to bounce between Pacifidlog Town and its PC.
-- Preserve the pre-Rainbow hero-only policy when it is still active.
function beatDeoxys:needsStoryHealing()
	if self:isHeroOnlyMode() then
		return self:needPokecenter()
	end
	return not game.isTeamFullyHealed()
end

function beatDeoxys:Route128()
	if not dialogs.goToSkyPillar.state then
		sys.debug("quest", "Going to talk to Steve in Sootopolis City.")
		return moveToCell(32, 0)
	else
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(33, 59)
	end
end

function beatDeoxys:Route127()
	if not dialogs.goToSkyPillar.state then 
		sys.debug("quest", "Going to talk to Steve in Sootopolis City.")
		return moveToCell(0, 48)
	else
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(47, 93)
	end
end

function beatDeoxys:MossdeepCity()
	if self:needsStoryHealing() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(36, 21)
	else
		sys.debug("quest", "Going to continue Quest.")
		return moveToCell(31, 55)
	end
end

function beatDeoxys:PokecenterMossdeepCity()
	self:pokecenter("Mossdeep City")
end

function beatDeoxys:Route126()
	if not dialogs.goToSkyPillar.state then 
		local pokemonWithDive = team.getFirstPkmWithMove("Dive")
	
		pushDialogAnswer(1)
		pushDialogAnswer(pokemonWithDive)
	
		sys.debug("quest", "Going to dive and talk to Steve in Sootopolis City.")
		return moveToCell(15, 71)
	else
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(125, 71)
	end
end

function beatDeoxys:Route126Underwater()
	if isNpcOnCell(58, 97) then 
		sys.debug("quest", "Going to talk to Roxanne.")
		return talkToNpcOnCell(58, 97)
	elseif not dialogs.goToSkyPillar.state then 
		sys.debug("quest", "Going to talk to Steve in Sootopolis City.")
		return moveToCell(58, 96)
	else
		local pokemonWithDive = team.getFirstPkmWithMove("Dive")
	
		pushDialogAnswer(1)
		pushDialogAnswer(pokemonWithDive)
	
		sys.debug("quest", "Going to dive and fight Deoxys.")
		return moveToCell(15, 71)
	end
end

function beatDeoxys:SootopolisCityUnderwater()
	if dialogs.goToSkyPillar.state then 
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(17, 20)
	else 
		local pokemonWithDive = team.getFirstPkmWithMove("Dive")
	
		pushDialogAnswer(1)
		pushDialogAnswer(pokemonWithDive)
	
		sys.debug("quest", "Going to dive and talk to Steve in Sootopolis City.")
		return moveToCell(17, 11)
	end
end

function beatDeoxys:SootopolisCity()
	if self:needsStoryHealing() or self.registeredPokecenter ~= "Pokecenter Sootopolis City" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(79, 56)
	elseif isNpcOnCell(48, 68) and not dialogs.goToSkyPillar.state then
		if self.relogged then
			sys.debug("quest", "Going to talk to Steven.")
			return talkToNpcOnCell(50, 17)
		else
			sys.debug("quest", "Going to relog -- can't talk to NPC after Rayquaza teleport (doesn't have to be the case here).")
			self.relogged = true
			return relog(60, "Relogging...")
		end
	elseif dialogs.goToSkyPillar.state then
		local pokemonWithDive = team.getFirstPkmWithMove("Dive")
	
		pushDialogAnswer(1)
		pushDialogAnswer(pokemonWithDive)
	
		sys.debug("quest", "Going to dive and fight Deoxys.")
		return moveToCell(50, 91)
	elseif not isNpcOnCell(48, 68) and not hasItem("Rain Badge") then
		sys.debug("quest", "Going to get 8th badge.")
		return moveToCell(48, 67)
	end
end

function beatDeoxys:PokecenterSootopolisCity()
	return self:pokecenter("Sootopolis City")
end

function beatDeoxys:Route129()
	sys.debug("quest", "Going to fight Deoxys.")
	return moveToCell(0, 24)
end

function beatDeoxys:Route130()
	sys.debug("quest", "Going to fight Deoxys.")
	return moveToCell(0, 38)
end

function beatDeoxys:Route131()
	if self:needsStoryHealing() or self.registeredPokecenter ~= "Pokecenter Pacifidlog Town" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(0, 30)
	else
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(40, 1)
	end
end

function beatDeoxys:PacifidlogTown()
	if self:needsStoryHealing() or self.registeredPokecenter ~= "Pokecenter Pacifidlog Town" then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(19, 12)
	else
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(40, 16) 
	end
end

function beatDeoxys:PokecenterPacifidlogTown()
	return self:pokecenter("Pacifidlog Town")
end

function beatDeoxys:SkyPillarEntrance()
	if game.inRectangle(9, 31, 47, 49) then
		if self:needsStoryHealing() then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(26, 49)
		else
			sys.debug("quest", "Going to fight Deoxys.")
			return moveToCell(26, 32)
		end
	else 
		if isNpcOnCell(27, 7) then	
			sys.debug("quest", "Going to talk to NPC.")
			return talkToNpcOnCell(27, 7)
		elseif self:needsStoryHealing() then
			sys.debug("quest", "Going to heal Pokemon.")
			return moveToCell(35, 23)
		else
			sys.debug("quest", "Going to fight Deoxys.")
			return moveToCell(27, 6)
		end
	end	
end

function beatDeoxys:SkyPillarEntranceCave1F()
	if self:needsStoryHealing() then
		sys.debug("quest", "Going to heal Pokemon.")
		return talkToNpcOnCell(7, 17)
	else
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(17,6)
	end
end

function beatDeoxys:SkyPillar1F()
	if self:needsStoryHealing() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(8, 13)
	else
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(13, 5)
	end
end

function beatDeoxys:SkyPillar2F()
	if self:needsStoryHealing() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(13, 7)
	else
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(7, 5)
	end
end

function beatDeoxys:SkyPillar3F()
	if self:needsStoryHealing() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(7, 6)
	else
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(3, 6)
	end
end

function beatDeoxys:SkyPillar4F()
	if self:needsStoryHealing() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(3, 7)
	else
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(8, 12)
	end
end

function beatDeoxys:SkyPillar5F()
	if self:needsStoryHealing() then
		sys.debug("quest", "Going to heal Pokemon.")
		return moveToCell(8, 13)
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until Level " .. self.level .. ".")
		return moveToRectangle(2, 5, 12, 5)
	else
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(13,12)
	end
end

function beatDeoxys:SkyPillar6F()
	sys.debug("quest", "Going to talk to Jackson to go to the Moon.")
	return talkToNpcOnCell(25, 19)
end

function beatDeoxys:Moon()
	if game.inRectangle(7, 34, 26, 49) or game.inRectangle(12, 32, 16, 33) then -- bottom left
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(7, 40)

	elseif game.inRectangle(6, 19, 26, 21) or game.inRectangle(8, 10, 20, 18) or game.inRectangle(10, 22, 24, 31) or game.inRectangle(17, 31, 22, 32) then -- top left
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(15, 10)

	elseif game.inRectangle(37, 8, 53, 29) or game.inRectangle(35, 19, 36, 26) or game.inRectangle(34, 19, 35, 22) then -- top right
		if self.deoxysBeaten then
			sys.debug("quest", "Deoxys beaten, going to find Rayquaza in B1F.")
			return moveToCell(53, 19)
		else
			sys.debug("quest", "Going to fight Deoxys.")
			return moveToCell(53, 40)
		end

	elseif game.inRectangle(28, 37, 53, 48) or game.inRectangle(37, 35, 50, 36) or game.inRectangle(39, 30, 49, 34) then
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(53, 40)

	elseif isNpcOnCell(30, 28) then 
		sys.debug("quest", "Going to fight Deoxys.")
		talkToNpcOnCell(30, 28)

	else
		self.deoxysBeaten = true 
		sys.debug("quest", "Deoxys beaten, going to find Rayquaza in B1F.")
		return moveToCell(30, 18)
		
	end
end

function beatDeoxys:Moon1F()
	if game.inRectangle(1, 22, 15, 48) then
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(8, 24)

	elseif game.inRectangle(14, 1, 50, 17) then
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(47, 15)

	elseif game.inRectangle(54, 41, 63, 50) then
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(59, 45)

	elseif game.inRectangle(55, 20, 63, 29) then
		sys.debug("quest", "Deoxys beaten, going to find Rayquaza in B1F.")
		return moveToCell(59, 24)

	end
end

function beatDeoxys:MoonB1F()
	if game.inRectangle(52, 12, 64, 26) then
		dialogs.goToSkyPillar.state = false
		self.relogged = false
		sys.debug("quest", "Going to talk to Rayquaza and get teleported back to Sootopolis City.")
		return talkToNpcOnCell(60, 23)

	elseif not self.deoxysBeaten then
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(32, 19)

	else
		sys.debug("quest", "Deoxys beaten, going to find Rayquaza in B1F.")
		return moveToCell(5, 32)

	end
end

function beatDeoxys:Moon2F()
	if not self.deoxysBeaten then
		sys.debug("quest", "Going to fight Deoxys.")
		return moveToCell(6, 8)
	else
		sys.debug("quest", "Deoxys beaten, going to find Rayquaza in B1F.")
		return moveToCell(6, 4)
	end
end

function beatDeoxys:SootopolisCityGym1F()
	sys.debug("quest", "Going to get 8th gym badge.")
	if game.inCell(22, 38) then
		return moveToCell(22,47)

	elseif game.inRectangle(21, 38, 23, 47) then
		return moveToCell(22, 38)

	elseif game.inCell(22, 38) then
		return moveToCell(22, 47)

	elseif game.inRectangle(19, 27, 25, 34) then
		return moveToCell(22, 29)

	elseif game.inRectangle(17, 5, 25, 23) and not dialogs.firstGymLeaderDone.state then
		return talkToNpcOnCell(22, 6)

	elseif game.inRectangle(17, 4, 27, 23) and dialogs.firstGymLeaderDone.state then
		return moveToCell(22, 17)

	end
end

function beatDeoxys:SootopolisCityGymB1F()
	sys.debug("quest", "Going to get 8th gym badge.")
	if game.inRectangle(4, 21, 8, 31) or game.inRectangle(4, 29, 17, 31) or game.inRectangle(8, 32, 18, 45) then
		return moveToCell(13, 34)
	elseif game.inRectangle(13, 21, 22, 28) then
		return moveToCell(13, 21)
	elseif game.inRectangle(10, 5, 16, 14) then
		return talkToNpcOnCell(13, 6)
	end
end

return beatDeoxys
