-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.

local QuestManager = {}

local COMPLETED_QUESTS_FILE = "quest_completed_flags.txt"
local COMPLETED_QUEST_PREFIX = "completed:"

local function loadCompletedQuestFlags()
	local flags = {}
	if type(readLinesFromFile) ~= "function" then
		return flags
	end

	local lines = readLinesFromFile(COMPLETED_QUESTS_FILE)
	if type(lines) ~= "table" then
		return flags
	end

	for _, line in ipairs(lines) do
		if type(line) == "string" and line ~= "" then
			flags[line] = true
		end
	end
	return flags
end

local function completedQuestKey(quest)
	if quest == nil or type(quest.name) ~= "string" then
		return nil
	end
	return COMPLETED_QUEST_PREFIX .. quest.name
end

--Kanto
local P1StartKantoQuest				= require('Quests/Kanto/P1StartKantoQuest')
local P2PalletStartQuest			= require('Quests/Kanto/P2PalletStartQuest')
local P3ViridianSchoolQuest			= require('Quests/Kanto/P3ViridianSchoolQuest')
local P3ViridianRequestsQuest			= require('Quests/Kanto/P3ViridianRequestsQuest')
local P4BoulderBadgeQuest			= require('Quests/Kanto/P4BoulderBadgeQuest')
local P5MoonFossilQuest				= require('Quests/Kanto/P5MoonFossilQuest')
local P6CascadeBadgeQuest			= require('Quests/Kanto/P6CascadeBadgeQuest')
local P7ThunderBadgeQuest			= require('Quests/Kanto/P7ThunderBadgeQuest')
local P8LanceVermilionQuest			= require('Quests/Kanto/P8LanceVermilionQuest')
local P9SSAnneQuest					= require('Quests/Kanto/P9SSAnneQuest')
local P10HmFlashQuest				= require('Quests/Kanto/P10HmFlashQuest')
--local P11BuyBikeQuest				= require('Quests/Kanto/P11BuyBikeQuest')
local P12RockTunnelQuest			= require('Quests/Kanto/P12RockTunnelQuest')
local P13RocketCeladonQuest			= require('Quests/Kanto/P13RocketCeladonQuest')
local P14RainbowBadgeQuest			= require('Quests/Kanto/P14RainbowBadgeQuest')
local P15PokeFluteQuest				= require('Quests/Kanto/P15PokeFluteQuest')
local P16SnorlaxQuest				= require('Quests/Kanto/P16SnorlaxQuest')
local P17SoulBadgeQuest				= require('Quests/Kanto/P17SoulBadgeQuest')
local P18HmSurfQuest				= require('Quests/Kanto/P18HmSurfQuest')
local P19ExpForSaffronQuest			= require('Quests/Kanto/P19ExpForSaffronQuest')
local P20SaffronGuardQuest				= require('Quests/Kanto/P20SaffronGuardQuest')
local P21MarshBadgeQuest				= require('Quests/Kanto/P21MarshBadgeQuest')
local P22SilphCoQuest					= require('Quests/Kanto/P22SilphCoQuest')
local P23ToCinnabarQuest				= require('Quests/Kanto/P23ToCinnabarQuest')
local P24CinnabarKeyQuest				= require('Quests/Kanto/P24CinnabarKeyQuest')
local P25VolcanoBadgeQuest				= require('Quests/Kanto/P25VolcanoBadgeQuest')
local P26ReviveFossilQuest				= require('Quests/Kanto/P26ReviveFossilQuest')
local P27EarthBadgeQuest				= require('Quests/Kanto/P27EarthBadgeQuest')
local P28ExpForElite4Kanto				= require('Quests/Kanto/P28ExpForElite4Kanto')
local P29Elite4Kanto					= require('Quests/Kanto/P29Elite4Kanto')
local P30GoToJohtoQuest				= require('Quests/Kanto/P30GoToJohtoQuest')


--Johto
local StartJohtoQuest				= require('Quests/Johto/StartJohtoQuest')
local ZephyrBadgeQuest				= require('Quests/Johto/ZephyrBadgeQuest')
local SproutTowerQuest				= require('Quests/Johto/SproutTowerQuest')
local HiveBadgeQuest				= require('Quests/Johto/HiveBadgeQuest')
local IlexForestQuest				= require('Quests/Johto/IlexForestQuest')
local GoldenrodCityQuest			= require('Quests/Johto/GoldenrodCityQuest')
local PlainBadgeQuest				= require('Quests/Johto/PlainBadgeQuest')
local FogBadgeQuest					= require('Quests/Johto/FogBadgeQuest')
local StormBadgeQuest				= require('Quests/Johto/StormBadgeQuest')
local MineralBadgeQuest				= require('Quests/Johto/MineralBadgeQuest')
local GlacierBadgeQuest				= require('Quests/Johto/GlacierBadgeQuest')
local RisingBadgeQuest				= require('Quests/Johto/RisingBadgeQuest')
local Elite4Johto					= require('Quests/Johto/Elite4Johto')
--local GoToHoennQuest			    = require('Quests/Johto/GoToHoennQuest')

--Hoenn
local FromLittlerootToWoodsQuest = require('Quests/Hoenn/FromLittlerootToWoodsQuest')
local StoneBadgeQuest 			 = require('Quests/Hoenn/StoneBadgeQuest')
local getSLetter 				 = require('Quests/Hoenn/getSLetter')
local KnuckleBadgeQuest 		 = require('Quests/Hoenn/KnuckleBadgeQuest')
local toMauville 				 = require('Quests/Hoenn/toMauville')
local DynamoBadge				 = require('Quests/Hoenn/DynamoBadge')
local ToLavaridgeTown	  		 = require('Quests/Hoenn/ToLavaridgeTown')
local ToBalanceBadge 		     = require('Quests/Hoenn/ToBalanceBadge')
local ToFortreeCity  		     = require('Quests/Hoenn/ToFortreeCity')
local GetTheOrbs 				 = require('Quests/Hoenn/GetTheOrbs')
local MagmaHideout			     = require('Quests/Hoenn/MagmaHideout') -- maybe needs a training part
local ToMossdeepCity			 = require('Quests/Hoenn/ToMossdeepCity')
local meetKyogre			     = require('Quests/Hoenn/meetKyogre')
local beatDeoxys				 = require('Quests/Hoenn/beatDeoxys')
local e4Hoenn					 = require('Quests/Hoenn/e4Hoenn')
local toSinnoh					 = require('Quests/Hoenn/toSinnoh')

--Sinnoh
local StartSinnohQuest = require('Quests/Sinnoh/StartSinnohQuest')
local OreburghCityQuest = require('Quests/Sinnoh/OreburghCityQuest')
local SecondBadgeQuest = require('Quests/Sinnoh/SecondBadgeQuest')
local ThirdBadgeQuest = require('Quests/Sinnoh/ThirdBadgeQuest')
local ForthBadgeQuest = require('Quests/Sinnoh/ForthBadgeQuest')
local FifthBadgeQuest = require('Quests/Sinnoh/FifthBadgeQuest')
local SixBadgeQuest = require('Quests/Sinnoh/SixBadgeQuest')
local SevenBadgeQuest = require('Quests/Sinnoh/SevenBadgeQuest')
local EightBadgeQuest = require('Quests/Sinnoh/EightBadgeQuest')
local ToE4Sinnoh = require('Quests/Sinnoh/ToE4Sinnoh')

local quests = {
	-- Kanto Quests
	P1StartKantoQuest:new(),
	P2PalletStartQuest:new(),
	P3ViridianSchoolQuest:new(),
	P3ViridianRequestsQuest:new(),
	P4BoulderBadgeQuest:new(),
	P5MoonFossilQuest:new(),
	P6CascadeBadgeQuest:new(),
	P7ThunderBadgeQuest:new(),
	P8LanceVermilionQuest:new(),
	P9SSAnneQuest:new(),
	P10HmFlashQuest:new(),
	--P11BuyBikeQuest:new(),
	P12RockTunnelQuest:new(),
	P13RocketCeladonQuest:new(),
	P14RainbowBadgeQuest:new(),
	P15PokeFluteQuest:new(),
	P16SnorlaxQuest:new(),
	P17SoulBadgeQuest:new(),
	P18HmSurfQuest:new(),
	P19ExpForSaffronQuest:new(),
	P20SaffronGuardQuest:new(),
	P21MarshBadgeQuest:new(),
	P22SilphCoQuest:new(),
	P23ToCinnabarQuest:new(),
	P24CinnabarKeyQuest:new(),
	P25VolcanoBadgeQuest:new(),
	P26ReviveFossilQuest:new(),
	P27EarthBadgeQuest:new(),
	P28ExpForElite4Kanto:new(),
	P29Elite4Kanto:new(),
	P30GoToJohtoQuest:new(),
	
	-- Johto Quests 
	StartJohtoQuest:new(),
	ZephyrBadgeQuest:new(),
	SproutTowerQuest:new(),
	HiveBadgeQuest:new(),
	IlexForestQuest:new(),
	GoldenrodCityQuest:new(),
	PlainBadgeQuest:new(),
	FogBadgeQuest:new(),
	StormBadgeQuest:new(),
	MineralBadgeQuest:new(),
	GlacierBadgeQuest:new(),
	RisingBadgeQuest:new(),
	Elite4Johto:new(),
	--GoToHoennQuest:new(),
	
	--HoennQuest
	FromLittlerootToWoodsQuest:new(),
	StoneBadgeQuest:new(),
	getSLetter:new(),
	KnuckleBadgeQuest:new(),
	toMauville:new(),
	DynamoBadge:new(),
	ToLavaridgeTown:new(),
	ToBalanceBadge:new(),
	ToFortreeCity:new(),
	GetTheOrbs:new(),
	MagmaHideout:new(),
	ToMossdeepCity:new(), -- i'll have to fix this up at some point, aqua hideout is a fucking mess...
	meetKyogre:new(),
	beatDeoxys:new(),
	e4Hoenn:new(),
	toSinnoh:new(),
	
	--SinnohQuest
	StartSinnohQuest:new(),
	OreburghCityQuest:new(),
	SecondBadgeQuest:new(),
	ThirdBadgeQuest:new(),
	ForthBadgeQuest:new(),
	FifthBadgeQuest:new(),
	SixBadgeQuest:new(),
	SevenBadgeQuest:new(),
	EightBadgeQuest:new(),
	ToE4Sinnoh:new(),
}

function QuestManager:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.quests = quests
	o.selected = nil
	o.isOver = false
	o.lastRelog = os.time()
	o.completedQuestFlags = loadCompletedQuestFlags()
	return o
end

function QuestManager:isQuestPersistentlyCompleted(quest)
	local key = completedQuestKey(quest)
	return key ~= nil and self.completedQuestFlags[key] == true
end

function QuestManager:markQuestCompleted(quest)
	local key = completedQuestKey(quest)
	if key == nil or self.completedQuestFlags[key] then
		return false
	end

	self.completedQuestFlags[key] = true
	if type(logToFile) ~= "function" then
		return true
	end

	local flags = {}
	for flag, completed in pairs(self.completedQuestFlags) do
		if completed then
			table.insert(flags, flag)
		end
	end
	table.sort(flags)
	logToFile(COMPLETED_QUESTS_FILE, flags, true)
	return true
end

function QuestManager:message()
	if self.selected then
		return self.selected:message()
	end
	return nil
end

function QuestManager:pause()
	if self.selected then
		log("Pause Quest: " .. self:message())
	end
end

function QuestManager:next()
	local previousQuest = self.selected
	for _, quest in pairs(self.quests) do
		if quest ~= previousQuest
			and not self:isQuestPersistentlyCompleted(quest)
			and quest:isDoable() == true
		then
			self.selected = quest
			return quest
		end
	end
	self.selected = nil
	return nil
end

function QuestManager:isQuestOver()
	if not self.selected then
		return true
	end
	if self.selected:isDone() then
		self:markQuestCompleted(self.selected)
		return true
	end
	return false
end

function QuestManager:updateQuest()
	if getMapName() == "" then
		return false
	end
	if self:isQuestOver() then
		if self.selected then
			log("QUESTING INFO: Quest '" .. self.selected.name .. "' is over")
		end
		if not self:next() then
			self.isOver = true
			return false
		end
		log("QUESTING INFO: Starting new quest: '" .. self.selected:message() .. "'")
	end
	return true
end

function QuestManager:path()

	if not self:updateQuest() then
		return false
	end
	-- only relog during training sessions to avoid
	-- weird continuity errors that might occur
	if not self.selected:isTrainingOver() 
		and os.difftime(os.time(), self.lastRelog) > 15*RELOG_TIME
	then
		relog(15, "Relogging...")
		self.lastRelog = os.time()
	end
	return self.selected:path()
end

function QuestManager:battle()
	if not self:updateQuest() then
		return false
	end
	return self.selected:battle()
end

function QuestManager:dialog(message)
	if not self.selected then
		return false
	end
	return self.selected:dialog(message)
end

function QuestManager:battleMessage(message)
	if not self:updateQuest() then
		return false
	end
	return self.selected:battleMessage(message)
end

function QuestManager:systemMessage(message)
	if not self.selected then
		return false
	end
	return self.selected:systemMessage(message)
end

function QuestManager:learningMove(moveName, pokemonIndex)
	if not self:updateQuest() then
		return false
	end
	return self.selected:learningMove(moveName, pokemonIndex)
end

return QuestManager
