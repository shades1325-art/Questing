

local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Training for Saffron'
local description = 'Exp in Seafoam'
local level 	  = 75

local P19ExpForSaffronQuest = Quest:new()

function P19ExpForSaffronQuest:new()
	return Quest.new(P19ExpForSaffronQuest, name, description, level)
end

function P19ExpForSaffronQuest:isDoable()
	if self:hasMap() and not hasItem("Marsh Badge") then
		return true
	end
	return false
end

function P19ExpForSaffronQuest:isDone()
	if getMapName() == "Pokecenter Fuchsia" or getMapName() == "Route 19" then
		QuestManager.shared = QuestManager.shared or {}  -- Đảm bảo shared tồn tại
		QuestManager.shared.expForSaffronDone = true     -- Gán cờ hoàn thành
		return true
	end
	return false
end

function P19ExpForSaffronQuest:Route20()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to Seafoam 1F.")
		return moveToCell(60, 32) --Seafoam 1F
	else
		sys.debug("quest", "Going back to Fuchsia City.")
		return moveToCell(120, 29)
	end
end

function P19ExpForSaffronQuest:Route19()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to Seafoam 1F.")
		return moveToCell(60, 32) --Seafoam 1F
	else
		sys.debug("quest", "Going back to Fuchsia City.")
		return moveToCell(23, 3)
	end
end

function P19ExpForSaffronQuest:Route19()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to Seafoam 1F.")
		return moveToCell(60, 32) --Seafoam 1F
	else
		sys.debug("quest", "Going back to Fuchsia City.")
		return moveToCell(23, 3)
	end
end

function P19ExpForSaffronQuest:Seafoam1F()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to Seafoam B1F.")
		return moveToCell(20, 8) -- Seafoam B1F
	else
		sys.debug("quest", "Going back to Fuchsia City.")
		return moveToCell(13, 16)
	end
end

function P19ExpForSaffronQuest:SeafoamB1F()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to Seafoam B2F.")
		return moveToCell(64, 25) -- Seafoam B2F
	else
		sys.debug("quest", "Going back to Fuchsia City.")
		return moveToCell(15, 12)
	end
end

function P19ExpForSaffronQuest:SeafoamB2F()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to Seafoam B3F.")
		return moveToCell(63, 19) -- Seafoam B3F
	else
		sys.debug("quest", "Going back to Fuchsia City.")
		return moveToCell(51, 27)
	end
end

function P19ExpForSaffronQuest:SeafoamB3F()
	if not self:isTrainingOver() then
		sys.debug("quest", "Going to Seafoam B3F.")
		return moveToCell(57, 26) --Seafoam B4F
	else
		sys.debug("quest", "Going back to Fuchsia City.")
		return moveToCell(64, 16)
	end	
end

function P19ExpForSaffronQuest:SeafoamB4F()
	if self:isTrainingOver() then
		sys.debug("quest", "Going back to Fuchsia City.")
		return moveToCell(53, 28) 
	elseif self:needPokecenter() then
		if getMoney() > 1500 then
			sys.debug("quest", "Healing with NPC Nurse Joy.")
			return talkToNpcOnCell(59, 13)
		elseif hasItem("Escape Rope") and getMoney() * 0.05 > 550 then
			sys.debug("quest", "Using Escape Rope.")
			return useItem("Escape Rope")
		end
	elseif not self:isTrainingOver() then
		sys.debug("quest", "Going to level Pokemon until they are Level " .. self.level .. ".")
		return moveToNormalGround()
	end
end

return P19ExpForSaffronQuest