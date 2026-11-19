extends SceneTree
## Tests for the battle art system (poses, effects, defeat). It makes its own
## little test pictures, so no real art is needed.
##   godot --headless --path . --script res://tests/art_test.gd
## Prints PASS / FAIL for each check and ends with ALL PASSED.

var fails: int = 0

func check(name: String, ok: bool) -> void:
	if ok:
		print("PASS ", name)
	else:
		print("FAIL ", name)
		fails += 1

## A plain colored picture (256 x 384, transparent around it).
func make_picture(color: Color) -> Texture2D:
	var image: Image = Image.create(256, 384, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	image.fill_rect(Rect2i(64, 0, 128, 384), color)
	return ImageTexture.create_from_image(image)

## Tell the stage a unit lost `amount` HP (relative to what it saw last).
func hit(stage: BattleStage, unit: BattleUnit, amount: int) -> void:
	stage._on_hp_changed(unit, stage._last_hp[unit] - amount)

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

	# --- give the first party member and the first enemy pictures + effects
	var hero: BattleUnit = bm.player_team[0]
	var foe: BattleUnit = bm.enemy_team[0]
	var idle_pic: Texture2D = make_picture(Color.GRAY)
	var attack_pic: Texture2D = make_picture(Color.RED)
	var alter_pic: Texture2D = make_picture(Color.PURPLE)
	var hurt_pic: Texture2D = make_picture(Color.YELLOW)
	var hit_effect: PackedScene = load("res://scenes/vfx/hit_burst.tscn")
	var glow_effect: PackedScene = load("res://scenes/vfx/alter_glow.tscn")
	var template: CharacterTemplate = Roster.get_def("helder")
	template.sprite_frames = null   # this test is about single pictures (Helder has a sprite sheet: tests/anim_test.gd)
	template.idle_texture = idle_pic
	template.attack_texture = attack_pic
	template.alter_texture = alter_pic
	template.hurt_texture = hurt_pic
	template.attack_vfx = hit_effect
	template.alter_vfx = glow_effect
	var enemy_type: EnemyType = EnemyLibrary.type_for_id(foe.enemy_id)
	enemy_type.idle_texture = idle_pic
	enemy_type.attack_texture = attack_pic
	enemy_type.attack_vfx = hit_effect

	var stage: BattleStage = BattleStage.new()
	stage.battle_manager = bm
	holder.add_child(stage)
	await process_frame
	await process_frame

	var hero_fig: UnitVisual = stage._figures[hero]
	var foe_fig: UnitVisual = stage._figures[foe]
	var other_fig: UnitVisual = stage._figures[bm.player_team[1]]
	var hero_sprite: Sprite2D = hero_fig.get_node("Sprite")

	# --- art is picked up
	check("a character with art shows its picture", hero_fig.has_art() and hero_sprite.texture == idle_pic)
	check("a fighter without art keeps the stick figure", not other_fig.has_art())
	var shown_height: float = hero_sprite.texture.get_height() * hero_sprite.scale.y
	check("the picture is as tall as the stick figure", absf(shown_height - 122.0 * hero_fig.figure_scale) < 0.5)
	check("party pictures are not mirrored", not hero_sprite.flip_h)
	check("enemy pictures are mirrored", foe_fig.get_node("Sprite").flip_h)

	# --- poses
	var basic_name: String = hero.basic_moves[0].move_name
	stage._on_action_announced(hero, basic_name)
	check("a Basic attack shows the Attack pose", hero_sprite.texture == attack_pic)
	await wait(0.65)
	check("... and goes back to Idle", hero_sprite.texture == idle_pic)

	# an Alteration: use the character's first one, or add a test one if there is none
	if hero.alteration_moves.is_empty():
		var test_move: Move = Move.new()
		test_move.move_name = "Test Alteration"
		hero.alteration_moves.append(test_move)
	stage._on_action_announced(hero, hero.alteration_moves[0].move_name)
	check("an Alteration shows the Alter pose", hero_sprite.texture == alter_pic)
	check("an Alteration plays the character's effect", VfxPlayer.playing_count() == 1)
	await wait(0.9)
	check("... and goes back to Idle after the Alteration", hero_sprite.texture == idle_pic)

	stage._on_action_announced(hero, "Guard")
	check("Guard keeps the Idle pose", hero_sprite.texture == idle_pic)

	# --- hit effect + hurt pose
	await wait(3.3)   # let the earlier effects finish
	check("all effects clean themselves up", VfxPlayer.playing_count() == 0)
	stage._on_action_announced(hero, basic_name)
	hit(stage, foe, 5)
	check("a hit plays the attacker's effect on the target", VfxPlayer.playing_count() == 1)
	hit(stage, hero, 5)
	check("a party member that is hit shows the Hurt pose", hero_sprite.texture == hurt_pic)
	await wait(0.5)
	check("... and goes back to Idle", hero_sprite.texture == idle_pic)
	await wait(3.3)   # effects finish, and the "who attacked" memory is forgotten
	hit(stage, foe, 5)   # damage over time, for example: nobody is attacking
	check("damage when nobody is attacking plays no effect", VfxPlayer.playing_count() == 0)

	# --- an enemy attacking
	await wait(3.3)
	var foe_sprite: Sprite2D = foe_fig.get_node("Sprite")
	stage._on_action_announced(foe, "Anything")
	check("an enemy attack shows the enemy's Attack pose", foe_sprite.texture == attack_pic)
	hit(stage, hero, 5)
	check("an enemy hit plays the enemy's effect on the target", VfxPlayer.playing_count() == 1)
	await wait(0.6)
	check("... and the enemy goes back to Idle", foe_sprite.texture == idle_pic)

	# --- never too many effects at once
	await wait(3.3)
	for i in range(30):
		VfxPlayer.play(hit_effect, holder, Vector2(100, 100))
	check("at most %d effects play at once" % VfxPlayer.MAX_AT_ONCE, VfxPlayer.playing_count() == VfxPlayer.MAX_AT_ONCE)
	await wait(3.3)
	check("every effect is removed afterwards", VfxPlayer.playing_count() == 0)

	# --- defeat
	foe.kill()
	await wait(0.8)
	check("a defeated enemy fades out", foe_fig.modulate.a < 0.05)
	hero.kill()
	await wait(1.2)
	check("a defeated party member is dragged off to the left", hero_fig.position.x < 0.0)
	stage._apply_layout()
	check("a window resize doesn't bring them back", hero_fig.position.x < 0.0)
	var grey: BattleUnit = bm.player_team[1]
	grey.kill()
	check("a stick figure without art just turns grey", stage._figures[grey].modulate == BattleStage.DEFEATED_TINT)

	# --- dialogue portraits are found by name
	check("no portrait file = no portrait", SpeakerTable.portrait_for("Nobody Special") == null)

	print("")
	if fails == 0:
		print("ALL PASSED")
	else:
		print("FAILED: %d" % fails)
	quit()
