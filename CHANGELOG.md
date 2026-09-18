# Changelog

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

