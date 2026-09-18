# Changelog

## 2026-09-19 (Officer Jenny quest pickup)

- Require the Viridian requests quest to be accepted from Officer Jenny after
  the Viridian School hand-off before Gerrald is battled or Rattata is hunted.
- Persist the acceptance flag so the server-side Rattata Hair drop behavior
  remains enabled across script restarts.

## 2026-09-19 (persistent quest completion flags)

- QuestManager now records completed quest names in
  `quest_completed_flags.txt` and skips only quests whose `isDone()` state was
  observed, avoiding repeated checks after a restart.
- Throttled the post-Rainbow NPC interaction disable request so a delayed
  client state update does not repeat the debug message every tick.

## 2026-09-19 (Viridian movement API fix)

- Replaced the Viridian requests quest's obsolete moveToMap actions with
  moveToCell transitions using the existing Viridian, Route 1, and Route 2
  map-link coordinates.
- Added intermediate Route 2 Stop and Route 2_C handlers so Gerrald
  completion and PC returns can resume through the current movement API.

## 2026-09-19 (rod purchases disabled)

- Disabled automatic purchases of the Good Rod and Super Rod by setting
  BUY_RODS = false.

## 2026-09-19 (Gerrald completion handling)

- Mark Gerrald complete immediately after the actual battle-win message.
- Recognize Gerrald's post-battle “come back later” dialogue when the NPC
  remains visible, preventing the quest from attempting the battle again.
- Leave the completion flag unset when the battle is interrupted before it is
  won, allowing the story segment to resume safely after reconnecting.

## 2026-09-19 (Viridian side-story integration)

- Registered the Viridian Gerrald/Rattata/Sentret quest before Boulder Badge
  progression.
- Configured Bug Catcher Gerrald at `(61, 13)`.
- Persisted Gerrald and Officer Jenny progress through the existing
  `readLinesFromFile` and `logToFile` APIs.
- Added Route 2 recovery so the Viridian School quest can hand off cleanly to
  the Viridian Forest quest.

## 2026-09-18 (Viridian school order)

- Route the Viridian School quest to the school before the Viridian Maze and
  northern Route 2/Viridian Forest progression.

## 2026-09-18 (pre-Rainbow resource safety)

- Before the Rainbow Badge, run from ordinary wild Ground/Water encounters.
- Preserve explicit quest captures and shiny/event capture handling.
- Relog immediately before NPC encounters when Charmander-line HP is below
  8% or it has no usable offensive PP.
- Use an Escape Rope after Charmander-line PP exhaustion outside NPC battles.
- Limit pre-Rainbow Escape Rope purchases to five.
- Restore the existing post-Rainbow battle behavior and do not buy additional
  Escape Ropes after the Rainbow Badge.

## 2026-09-18 (Viridian requests)

- Added the reusable Viridian side-story quest after Viridian School.
- Added Bug Catcher Gerrald handling in Viridian Forest with an editable
  VIRIDIAN_GERRALD_CELL placeholder and active-battler fallback.
- Added Route 1 Rattata capture, Rattata Hair collection, and Officer Jenny
  turn-in handling at (50, 43).
- Added Route 1 Sentret capture and the second Officer Jenny turn-in.
- Reused existing Lua battle, capture, movement, PC, and pathfinder APIs;
  no C# or networking code was changed.

## 2026-09-18

- Kept `BetterQuesting.lua` as the single story entry point and retained the shared `QuestManager` architecture.
- Made Fast Story the only supported story configuration with its required behaviors enabled internally.
- Fixed Pokemart progression so the shared quest helper exits after reaching its Poké Ball target instead of repeating the shop branch.
- After the Rainbow Badge, skip `getActiveBattlers()` trainer scanning and disable active battle-NPC interaction.
- After the Rainbow Badge, wild-battle handling bypasses opponent evaluation and calls the existing Lua `run()` action.
- Added the corresponding Lua configuration and story-controller updates without changing C# or networking code.

### Verification

- Lua syntax checks passed with MoonSharp.
- Offline regression checks passed for Pokemart exit and Rainbow Badge wild-battle handling.
- Debug and Release solution builds passed.

## Repository layout

- Flattened the story package so `BetterQuesting.lua` is at the repository root.
- Moved `Libs/`, `Quests/`, `Classes/`, `Data/`, `Tests/`, and related files to the root.
- Removed the obsolete root Pathfinder module directory.
- Kept Lua module paths relative to the new root; story behavior is unchanged.

