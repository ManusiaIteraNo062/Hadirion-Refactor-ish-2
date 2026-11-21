extends SceneTree
## Tests for the effect slots: Attack Vfx, Guard Vfx, a skill's Vfx Cast / Vfx Hit, and an item's Vfx.
##   godot --headless --path . --script res://tests/vfx_test.gd
## Open the project in the editor once first, so the PNGs in assets/vfx/ get imported.
## Prints PASS / FAIL for each check and ends with ALL PASSED.

var fails: int = 0

func check(name: String, ok: bool) -> void:
	if ok:
		print("PASS ", name)
	else:
		print("FAIL ", name)
		fails += 1

func wait(seconds: float) -> void:
	await create_timer(seconds).timeout

func _init() -> void:
	var state: GameState = GameState.new()
	state.ensure_defaults()
	var mission: Mission = MissionLibrary.build_all()[1]

	var holder: Node = Node.new()
	root.add_child(holder)
	var bm: BattleManager = BattleManager.new()
	bm.player_team = UnitFactory.make_player_team(state, mission.party_ids)
	var enemies: Array[BattleUnit] = []
	enemies.assign(mission.build_wave(0))
	bm.enemy_team = enemies
	bm.wave_count = mission.wave_count()
	holder.add_child(bm)
	for unit in bm.player_team + bm.enemy_team:
		holder.add_child(unit)
	var hero: BattleUnit = bm.player_team[0]
	var ally: BattleUnit = bm.player_team[1]
	var foe: BattleUnit = bm.enemy_team[0]

	var stage: BattleStage = BattleStage.new()
	stage.battle_manager = bm
	holder.add_child(stage)
	await process_frame
	await process_frame

	var hero_fig: UnitVisual = stage._figures[hero]

	# --- the demo effects are filled in for Helder
	check("Helder has an Attack Vfx and a Guard Vfx", hero_fig.attack_vfx != null and hero_fig.guard_vfx != null)
	var rejuvenate: Skill = load("res://data/skills/helder/h_rejuvenate.tres")
	check("Rejuvenate has a Vfx Hit", rejuvenate.vfx_hit != null)
	var rejuvenate_move: Move = rejuvenate.build_moves()[0]
	check("build_moves() gives the skill's effects to its moves", rejuvenate_move.vfx_hit == rejuvenate.vfx_hit)
	var potion: Item = load("res://data/items/med_njus.tres")
	check("Med-Njus has a Vfx", potion.vfx != null)

	# --- Guard: Guard Vfx on the character
	stage._on_action_announced(hero, "Guard")
	stage._on_action_landed(hero, [], null)
	check("Guard plays the Guard Vfx", VfxPlayer.playing_count() == 1)
	await wait(2.0)
	check("... and the effect removes itself", VfxPlayer.playing_count() == 0)

	# --- Basic attack: Attack Vfx on the target when the hit lands
	stage._on_action_announced(hero, hero.basic_moves[0].move_name)
	stage._on_hp_changed(foe, stage._last_hp[foe] - 5)
	check("a Basic attack plays the Attack Vfx on the target", VfxPlayer.playing_count() == 1)
	await wait(2.0)

	# --- Alteration: Vfx Hit on every target
	hero.alteration_moves.append(rejuvenate_move)
	stage._on_action_announced(hero, rejuvenate_move.move_name)
	check("an Alteration without Vfx Cast / Alter Vfx plays nothing when it starts", VfxPlayer.playing_count() == 0)
	stage._on_action_landed(hero, [hero, ally], rejuvenate_move)
	check("... and its Vfx Hit plays on every target", VfxPlayer.playing_count() == 2)
	await wait(2.0)

	# --- Alteration: Vfx Cast on the caster when it starts
	var cast_move: Move = rejuvenate_move.duplicate()
	cast_move.move_name = "Cast Test"
	cast_move.vfx_cast = load("res://scenes/vfx/hit_spark.tscn")
	hero.alteration_moves.append(cast_move)
	stage._on_action_announced(hero, "Cast Test")
	check("a skill's Vfx Cast plays when it starts", VfxPlayer.playing_count() == 1)
	await wait(2.0)

	# --- Item: Vfx on the target
	stage._on_action_announced(hero, potion.item_name)
	stage._on_action_landed(hero, [ally], potion)
	check("an item plays its Vfx on the target", VfxPlayer.playing_count() == 1)
	await wait(2.0)

	# --- enemies are not touched by the new slots
	stage._on_action_landed(foe, [hero], null)
	check("an enemy action plays none of the new effects", VfxPlayer.playing_count() == 0)

	print("")
	if fails == 0:
		print("ALL PASSED")
		quit(0)
	else:
		print("FAILED: %d" % fails)
		quit(1)
