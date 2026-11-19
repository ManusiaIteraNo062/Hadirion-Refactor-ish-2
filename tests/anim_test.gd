extends SceneTree
## Tests for Helder's animated sprite sheet: combat idle, jump + club swing, spellcast, flinch, defeat.
##   godot --headless --path . --script res://tests/anim_test.gd
## Open the project in the editor once first, so the PNGs in assets/characters/helder/ get imported.
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
	var foe: BattleUnit = bm.enemy_team[0]

	var stage: BattleStage = BattleStage.new()
	stage.battle_manager = bm
	holder.add_child(stage)
	await process_frame
	await process_frame

	var hero_fig: UnitVisual = stage._figures[hero]
	var foe_fig: UnitVisual = stage._figures[foe]
	var other_fig: UnitVisual = stage._figures[bm.player_team[1]]
	var anim: AnimatedSprite2D = hero_fig.get_node("AnimSprite")

	# --- the sprite sheet is picked up
	check("Helder uses the animated sprite sheet", hero_fig.is_animated() and anim.visible)
	check("... so the stick figure is not drawn", hero_fig.has_art())
	check("other fighters keep their stick figure", not other_fig.is_animated() and not other_fig.has_art())
	check("an enemy has no sprite sheet", not foe_fig.is_animated())
	for anim_name in ["idle", "attack", "alter", "hurt", "defeat", "jump", "guard"]:
		check("Helder has the '%s' animation" % anim_name, anim.sprite_frames.has_animation(anim_name))
	check("it starts on the combat idle, looping",
		anim.animation == &"idle" and anim.is_playing() and anim.sprite_frames.get_animation_loop("idle"))
	var frame_height: float = anim.sprite_frames.get_frame_texture("idle", 0).get_height()
	check("the character is as tall as the stick figure x Anim Size",
		absf(frame_height * anim.scale.y - 122.0 * hero_fig.figure_scale * hero_fig.anim_size) < 0.5)
	check("party sprites are not mirrored", not anim.flip_h)

	# --- Guard
	stage._on_action_announced(hero, "Guard")
	check("Guard plays the guard animation", anim.animation == &"guard")
	await wait(0.85)
	check("... and goes back to idle", anim.animation == &"idle")

	# --- being hit
	stage._on_hp_changed(hero, stage._last_hp[hero] - 5)
	check("losing HP plays the flinch", anim.animation == &"hurt")
	await wait(0.6)
	check("... and goes back to idle", anim.animation == &"idle")

	# --- an Alteration = spellcast (skipped if Helder has no Alteration equipped)
	if hero.alteration_moves.is_empty():
		print("SKIP the spellcast checks (Helder has no Alteration equipped)")
	else:
		stage._on_action_announced(hero, hero.alteration_moves[0].move_name)
		check("an Alteration plays the spellcast", anim.animation == &"alter")
		stage._on_action_targeted(hero, [foe])
		check("... and the manager is asked to wait until the spell leaves the hands",
			bm.visual_lead_in > 0.0 and absf(bm.visual_lead_in - hero_fig.alter_impact_seconds()) < 0.001)
		bm.visual_lead_in = 0.0
		bm.visual_follow_through = 0.0
		await wait(0.9)
		check("... and the spellcast ends back on idle", anim.animation == &"idle")

	# --- a Basic attack = jump to the enemy, swing the club, jump back
	var home: Vector2 = hero_fig.position
	var stand_off: float = hero_fig.lunge_distance * hero_fig.figure_scale / 0.65
	var spot: Vector2 = foe_fig.position - Vector2(stand_off, 0.0)
	stage._on_action_announced(hero, hero.basic_moves[0].move_name)
	stage._on_action_targeted(hero, [foe])
	check("a Basic attack asks the manager to wait until the club hits",
		absf(bm.visual_lead_in - hero_fig.lunge_impact_seconds()) < 0.001 and bm.visual_follow_through > 0.3)
	check("the whole lunge takes about a second",
		hero_fig.lunge_total_seconds() > 0.8 and hero_fig.lunge_total_seconds() < 1.6)
	bm.visual_lead_in = 0.0
	bm.visual_follow_through = 0.0
	await wait(0.1)
	check("it starts with the jump, in front of the enemies", anim.animation == &"jump" and hero_fig.z_index == 1)
	await wait(0.3)
	check("it lands next to the enemy and swings the club",
		anim.animation == &"attack" and hero_fig.position.distance_to(spot) < 4.0)
	await wait(hero_fig.lunge_total_seconds())
	check("it ends back home, on idle", hero_fig.position.distance_to(home) < 1.0 and anim.animation == &"idle")
	check("... and behind the others again", hero_fig.z_index == 0)

	# --- the BattleManager really waits (Guard has no target, so the stage leaves the numbers alone)
	bm.visual_lead_in = 0.2
	bm.visual_follow_through = 0.2
	var started: int = Time.get_ticks_msec()
	await bm._execute_action(hero, {"type": "guard", "targets": []})
	var elapsed: float = (Time.get_ticks_msec() - started) / 1000.0
	check("the manager waits for the lead-in and the follow-through", elapsed >= 0.38 and elapsed < 1.0)
	check("... and resets both numbers to 0", bm.visual_lead_in == 0.0 and bm.visual_follow_through == 0.0)

	# --- defeated
	stage._on_unit_defeated(hero)
	check("a defeated party member plays the defeat animation", anim.animation == &"defeat" and hero_fig.gone)
	await wait(1.2)
	check("... and stays down", anim.animation == &"defeat")

	print("")
	if fails == 0:
		print("ALL PASSED")
		quit(0)
	else:
		print("FAILED: %d" % fails)
		quit(1)
