-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.

local sys    = require "Libs/syslib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'Start'
local description = 'Play the Start map'

local P1StartKantoQuest = Quest:new()
function P1StartKantoQuest:new()
	return Quest.new(P1StartKantoQuest, name, description, _, dialogs)
end

function P1StartKantoQuest:isDoable()
	-- a quest should never monopolize a map
	-- but Start is a special map
	return getMapName() == "Start"
end

function P1StartKantoQuest:Start()
	if isNpcOnCell(21, 38) then
		sys.debug("quest", "Going to talk to Prof. Oak.")
		return talkToNpcOnCell(21, 38)
	else
		sys.debug("quest", "Going to Pallet Town.")
		return moveToCell(26, 87)
	end
end

return P1StartKantoQuest
