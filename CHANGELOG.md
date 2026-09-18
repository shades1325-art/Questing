# Changelog

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

