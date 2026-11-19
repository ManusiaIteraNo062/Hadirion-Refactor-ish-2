# Where things live

This copy keeps the readable code style, and moves **looks** and **numbers** out of code
into files you can open in the Godot editor.

## Data (.tres files, edit them in the Inspector)
| Folder | What | Read by |
|---|---|---|
| `data/characters/` | the 4 playable characters (stats + battle art + effects) | `Roster` |
| `data/items/` | craftable items | `ItemLibrary` |
| `data/skills/<character>/` | Alteration skills, each with its moves | `SkillLibrary` |
| `data/upgrades/<character>/` | character upgrades (tiers, bonuses, passives) | `GearLibrary` |
| `data/equipment/` | equipment pieces | `GearLibrary` |
| `data/enemies/` | enemy types (and their battle art) | `EnemyLibrary` |
| `data/missions/` | missions, waves, story text | `MissionLibrary` |

Order in lists comes from `sort_order` (items, skills) or `party_order` (characters).
Special "Saat ini: ..." preview texts for skills are in `scripts/data/skill_previews.gd`.

## Scenes (.tscn files, open them to see the layout)
- `scenes/main.tscn` - the game's main scene (just a Node with `game_flow.gd`).
- `scenes/ui/` - every screen, plus the small pieces that repeat
  (`mission_button`, `workshop_row`, `enemy_card`, `party_cell`, `gold_button`, ...).
- `scenes/battle/unit_visual.tscn` - one fighter. It has an empty `Sprite` and a
  `VfxAnchor`, ready for real art. `floating_text.tscn` is the damage / "Dodge!" number.

## Battle art (see ASSET_RULES.md)
`UnitVisual` (the fighter) shows a picture per pose when the character / enemy `.tres` has one,
otherwise the stick figure. `BattleStage` decides the pose from events the battle already
sends (`action_announced`, HP changes, defeat). `VfxPlayer` plays effect scenes.
Dialogue portraits are found by file name in `assets/portraits/`.

## The pattern in every screen script
1. `const LAYOUT_SCENE := preload(...)` loads the scene file.
2. `_init()` makes a copy and adds it.
3. `_ready()` finds the nodes with `get_node("%Name")` and connects the buttons.
4. Code that depends on data (rows, cards, lists) instantiates a small scene per item.

If you rename a node in the editor, update its `%Name` in the script.

## Three traps found (already fixed)
A script's `_init()` runs AFTER a scene's saved values load, so it can overwrite them.
`OrnatePanel`, `WorkshopIcon` and `StatBar` now only set their default size/style if the
scene didn't already set one.

## Checks
`godot --headless --path . --script res://tests/smoke_test.gd` and `.../art_test.gd` -> both end with ALL PASSED.
