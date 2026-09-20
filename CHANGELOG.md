# Changelog

## 2026-09-20 (Celadon Giovanni recovery)

- Treat the Celadon Rocket Hideout Giovanni encounter as a required story
  battle and rotate through available party slots when Charizard faints.
- After victory, buy up to 2 Revives and 8 Lemonades, using the existing
  Celadon Mart floors while preserving one Lemonade for Saffron.
- Recover the party to at least 70% HP without assuming a six-Pokémon team.

## 2026-09-20 (Story recovery and progression fixes)

- Allow the Hoenn Mossdeep quest to resume in Lilycove while an orb remains
  in the inventory.
- Treat the Vermilion Lance event as a required story battle; rotate to the
  existing party fallback instead of relogging when Charizard faints.
- Add a reconnect delay to hero recovery relogs and fix the Bill's House exit
  transition.

## 2026-09-19 (Hoenn Littleroot rescue battle)

- Fight the required Birch rescue encounter at Lab Littleroot Town even
  though the client reports Poochyena as a wild battle.
- Keep the normal Rainbow Badge wild-battle run behavior for optional
  encounters.

## 2026-09-19 (Charmander hero progression)

- Use only Charmander, Charmeleon, or Charizard for battle and level-cap
  training before the Rainbow Badge.
- Send the hero to a Pokecenter when its HP is below 8% or it has no usable
  offensive PP; wild battles run away and NPC battles relog instead of using
  another party member.
- Run immediately from wild Ground/Water encounters before the Rainbow Badge.
- Move Mt. Moon 1F training to Route 3 at the configured Route 3 rectangle.

## 2026-09-19 (Boulder training heal loop)

- Make the Pewter City step honor the quest's recovery check before sending
  the team back to Route 2, preventing the loop when no usable PP remains.
- Return to the Pokecenter immediately when the lead starter is knocked out,
  even if another party member can still battle.
- Keep training after partial PP consumption and heal only when the whole
  party has no usable offensive Pokémon left, avoiding both route and
  Pokecenter loops.

## 2026-09-19 (account-specific quest flags)

- Quest completion flags now use `getAccountName()` and are stored separately
  under `Logs/flag/quest_completed_flags_<account>.txt`.
- Multiple accounts no longer share or overwrite the same completion state.

## 2026-09-19 (restore standard Kanto quest flow)

- Removed the Officer Jenny/Gerrald/Rattata/Sentret side quest from the active
  QuestManager so progression continues normally after Viridian School.
- Removed its unused Gerrald cell configuration.

## 2026-09-19 (Johto E4 Blackthorn hand-off)

- Fixed the Elite 4 Johto quest returning no action in Blackthorn City after
  healing; it now uses the existing Route 45 `moveToCell(20, 50)` link.
- Returned the Pokecenter action so healing does not depend on a stale queued
  movement command.

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

