-- Run from the script root: lua Tests/test_hoenn_remote.lua
-- Exercises the real quest with offline host API stubs (also MoonSharp).
local Base = {}
function Base:new()
	self.__index = self
	return setmetatable({}, self)
end
function Base:debug() end
function Base:dialog() end
function Base:battleMessage() end
local modules = { ["Quests/Quest"] = Base, ["Libs/syslib"] = {}, ["Libs/teamlib"] = {} }
local originalRequire = require
require = function(name) return assert(modules[name], name) end
local Quest = dofile("Quests/Hoenn/HoennTransportQuest.lua")
require = originalRequire

local now, x, y, npcs, actions, saved, moveOK, talkOK
os.time = function() return now end
function getPlayerX() return x end
function getPlayerY() return y end
function getMapName() return "New Mauville" end
function getNpcData() return npcs end
function getAccountName() return "offline_test" end
function readLinesFromFile() return saved end
function logToFile(_, lines) saved = lines end
function isNpcOnCell(tx, ty)
	for _, n in ipairs(npcs) do if n.x == tx and n.y == ty then return true end end
	return false
end
function moveToCell(tx, ty)
	assert(not (tx == 7 and ty == 45), "walked onto blocked object")
	actions[#actions + 1] = "move:" .. tx .. ":" .. ty
	return moveOK
end
function talkToNpcOnCell(tx, ty)
	assert(tx == 7 and ty == 45, "unexpected pickup/grunt interaction")
	actions[#actions + 1] = "talk"
	return talkOK
end
function waitForState() actions[#actions + 1] = "wait"; return true end
function fatal(message) error(message) end
function getDiscoverableItems() error("optional discovery must stay disabled") end
function moveToRectangle() error("random search must not run") end
local anchor = {x = 21, y = 55, name = "Aqua Grunt"}
local barrier = {x = 21, y = 40, name = "@"}
local remote = {x = 7, y = 45, name = ""}
local function reset()
	now, x, y = 100, 31, 44
	npcs, actions, saved, moveOK, talkOK = {}, {}, {}, true, true
	local q = Quest:new()
	q.state.phase = "find_remote_key"
	q.state.southPassageStep = "done"
	q.state.southPassageComplete = true
	return q
end
local function blocked(q)
	local ok, message = pcall(function() q:handleRemoteControl() end)
	assert(not ok and string.find(message, "remote objective blocked", 1, true), tostring(message))
	assert(not q.state.keyFound)
end

-- Already-open gate repairs stale persisted state; no completed-flag guessing.
local q = reset()
npcs, moveOK = {anchor}, false
q:handleRemoteControl()
assert(not q.state.keyFound)
now = 102; moveOK = true
q:handleRemoteControl()
assert(q.state.keyFound and actions[#actions] == "move:21:39")
assert(q.state.phase == "find_remote_key", "queued path is not arrival")
q:battleMessage("You have run away from the wild Pokemon.")
q:handleRemoteControl()
assert(actions[#actions] == "move:21:39", "wild interruption lost destination")
x, y = 21, 39
q:handleRemoteControl()
assert(q.state.phase == "clear_remaining_trainers")
local reloaded = Quest:new()
assert(reloaded.state.keyFound and reloaded.state.phase == "clear_remaining_trainers")

-- Empty snapshot + unreachable approach must time out, not freeze forever.
q = reset(); moveOK = false
q:handleRemoteControl()
now = 109; blocked(q)

-- An old southPassageComplete flag or missing remote alone proves nothing.
q = reset(); npcs = {anchor, barrier}; x, y = 6, 45
q:handleRemoteControl()
now = 109; blocked(q)

-- One still-present gate half means closed; a transient clear resets evidence.
q = reset(); moveOK = false; npcs = {anchor}
q:handleRemoteControl()
now = 101; npcs = {anchor, {x=22, y=40, name="@"}}
q:handleRemoteControl()
now = 102; npcs = {anchor}; q:handleRemoteControl()
assert(not q.state.keyFound)

-- Stale optional pickup is discarded. Continue the same remote path after battle.
q = reset(); npcs = {anchor, barrier, remote}
q.state.keyAttempt, q.state.keyAttemptAt = "59:59", 99
q:handleRemoteControl()
assert(q.state.keyAttempt == "7:45" and q.state.keyAttemptAt == 0)
q:battleMessage("A wild Voltorb attacks!")
now = 200; q:handleRemoteControl()
assert(actions[#actions] == "talk" and not q.state.keyFound)

-- Adjacent interaction is followed by a bounded response wait.
x, y = 6, 45; q:handleRemoteControl()
assert(q.state.keyAttemptAt == 200)
now = 209; blocked(q)

-- Exact completion dialogue survives a reload and resumes the gate crossing.
q = reset(); npcs = {anchor, remote}
q:dialog("You have found the hidden remote control; using it, you have deactivated the nearby electro-barrier!")
assert(q.state.keyFound and q.state.phase == "find_remote_key")
q = Quest:new(); q:handleRemoteControl()
assert(actions[#actions] == "move:21:39")

-- Grunt hint about hiding keys is not remote completion.
q = reset(); q.state.keyAttempt = "7:45"
q:dialog("I fled and hid the remote-control keys for the electro-barrier.")
assert(not q.state.keyFound)

-- A visible but unreachable object cannot enter an indefinite wait either.
q = reset(); npcs = {anchor, barrier, remote}; talkOK = false
q:handleRemoteControl()
now = 109; blocked(q)
print("PASS Hoenn remote recovery: gate evidence, persistence, interrupted movement, bounded waits, no discovery")
