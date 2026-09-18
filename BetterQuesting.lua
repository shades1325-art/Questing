
name = "New_Better_Questing"
author = "g0ld, rympex, wiwi33, m1l4, dubscheckum, atem, yutowa"
description = [[MainQuesting until end of Sinnoh region.]]

dofile "config.lua"

local QuestManager
local questManager = nil
local StoryConfig = require "Libs/storyconfig"
local storyConfig = nil

-- GUI options are defined while the script is loaded so they are available
-- before the bot is started.  The selected values are read in onStart().
StoryConfig.configureGui()

local mountList = require "mountList"
local waterMountList = require "waterMountList"

local canBuyGreatballs = false
local canBuyUltraballs = false

function onStart()
	storyConfig = StoryConfig.read()
	log("Fast Story configuration loaded")

	for key, mount in ipairs(mountList) do
		if hasItem(mount) then
			setMount(mount)
			break
		end
	end
	
	for key, waterMount in ipairs(waterMountList) do
		if hasItem(waterMount) then
			setWaterMount(waterMount)
			break
		end
	end

	math.randomseed(os.time())
	QuestManager = require "Quests/QuestManager"
	log("all fine")
	questManager = QuestManager:new({storyConfig = storyConfig})

	--for longer botting runs
	if DISABLE_PM and isPrivateMessageEnabled() then
		log("Private messages disabled.")
		return disablePrivateMessage()
	end
end

function onPause()
	questManager:pause()
end

function onResume()
end

function onStop()
	if getOption(StoryConfig.gui.relogOnStop) then
		return relog(15, "Relogging.")
	end
end

function onPathAction()
	questManager:path()
	if questManager.isOver then
		return fatal("No more quests to do. Script terminated.")
	end
end

function onBattleAction()
	questManager:battle()
end

function onDialogMessage(message)
	questManager:dialog(message)
end

function onBattleMessage(message)
	questManager:battleMessage(message)
end

function onSystemMessage(message)
	questManager:systemMessage(message)
end

function onLearningMove(moveName, pokemonIndex)
	questManager:learningMove(moveName, pokemonIndex)
end
