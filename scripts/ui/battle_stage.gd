extends Node2D
class_name BattleStage
## Placeholder battlefield visuals: one stick figure per unit, in a 2x2 grid
## per side (party left, enemies right), placed from the actual viewport size
## so it follows window resizes and wider screens. Purely visual;
## BattleManager/BattleUnit logic doesn't know this exists. Swap
## CharacterPlaceholder's drawing for real art later without touching this.
##
## Also draws: a white marker over the unit whose turn it is, gold markers over
## whatever the Target menu is hovering, and floating damage / heal numbers.
##
## One exception to "purely visual": a party member with an animated sprite sheet jumps next to its
## target before a Basic attack lands. For that the stage asks the BattleManager to wait a moment
## (visual_lead_in / visual_follow_through), so the damage shows up when the club hits.

@export var battle_manager: BattleManager

# The fighter and the floating number are scenes (scenes/battle/).
# UnitVisual has an empty Sprite and VfxAnchor, ready for real art.
const UNIT_VISUAL_SCENE := preload("res://scenes/battle/unit_visual.tscn")
const FLOATING_TEXT_SCENE := preload("res://scenes/battle/floating_text.tscn")

# How long a pose stays on screen before the fighter goes back to Idle.
const ATTACK_POSE_SECONDS := 0.45
const ALTER_POSE_SECONDS := 0.7
const HURT_POSE_SECONDS := 0.35
const GUARD_POSE_SECONDS := 0.7

const PLAYER_COLOR := Color.WHITE
const ENEMY_COLOR := Color(0.85, 0.2, 0.2) # red, matches the reference art
const DEFEATED_TINT := Color(0.3, 0.3, 0.3, 0.5)

## Must match the space BattleUI uses at the bottom/top (see BattleUI).
const TOP_RESERVED := 150.0     # TURN/WAVE panels + enemy list live above this
const BOTTOM_RESERVED := 258.0  # party bar + action panel + margins

var _figures: Dictionary = {}   # BattleUnit -> UnitVisual
var _slots: Dictionary = {}     # BattleUnit -> { "party": bool, "index": int, "count": int }
var _enemy_units: Array = []    # enemies currently on stage (replaced each wave)
var _last_hp: Dictionary = {}   # BattleUnit -> HP last time we looked (for floating numbers)
var _markers: Dictionary = {}   # BattleUnit -> FieldMarker
var _active_unit: BattleUnit
var _acting: BattleUnit         # who attacked just now (hits that land in the same moment show its effect)
var _announced_kind: String = ""   # "attack" or "alter": what a party member just announced (for action_targeted)
var _holding_attacker: bool = false   # a jump is on its way: keep remembering who attacks until the hit lands

func _ready() -> void:
	position = Vector2.ZERO # layout is in screen space now; ignore any old offset
	z_index = -1            # UI panels draw on top of the field
	if not battle_manager:
		push_warning("BattleStage: battle_manager not set, no figures spawned.")
		return
	_spawn_team(battle_manager.player_team, true)
	_spawn_team(battle_manager.enemy_team, false)
	_enemy_units = battle_manager.enemy_team.duplicate()
	_apply_layout()
	get_viewport().size_changed.connect(_apply_layout)
	battle_manager.wave_started.connect(_on_wave_started)
	battle_manager.attack_dodged.connect(_on_dodged)
	battle_manager.action_announced.connect(_on_action_announced)
	battle_manager.action_targeted.connect(_on_action_targeted)
	battle_manager.action_landed.connect(_on_action_landed)
	battle_manager.player_turn_started.connect(_on_player_turn_started)
	battle_manager.enemy_turn_started.connect(_on_enemy_turn_started)
	battle_manager.battle_ended.connect(_on_battle_ended)
	# Hook up to the BattleUI next to us (if any) so the Target menu shows markers.
	for sibling in get_parent().get_children():
		if sibling is BattleUI:
			sibling.target_focused.connect(show_target_markers)

func _on_player_turn_started(unit: BattleUnit, _actions) -> void:
	_set_active(unit)

func _on_enemy_turn_started(_unit) -> void:
	_set_active(null)

func _on_battle_ended(_won) -> void:
	_set_active(null)

func _spawn_team(team: Array, party: bool) -> void:
	for i in range(team.size()):
		var unit: BattleUnit = team[i]
		var figure: UnitVisual = UNIT_VISUAL_SCENE.instantiate()
		if party:
			figure.color = PLAYER_COLOR
		else:
			figure.color = ENEMY_COLOR
		add_child(figure)

		var label: Label = figure.get_node("NameLabel")
		label.text = unit.stats.character_name
		_load_art(unit, figure, party)

		_figures[unit] = figure
		_slots[unit] = {"party": party, "index": i, "count": team.size()}
		_last_hp[unit] = unit.current_health
		unit.defeated.connect(_on_unit_defeated)
		unit.hp_changed.connect(_on_hp_changed)
		unit.stun_immunity_gained.connect(_on_stun_immunity)

# ---- layout -------------------------------------------------------------

func _apply_layout() -> void:
	var size: Vector2 = get_viewport_rect().size
	var fs: float = 0.65 * clampf(size.y / 648.0, 1.0, 1.6)   # figure scale
	var field_top: float = TOP_RESERVED
	var field_bottom: float = size.y - BOTTOM_RESERVED
	var row1: float = field_top + 52.0 * fs / 0.65             # top row of figures
	var row2: float = field_bottom - 58.0 * fs / 0.65          # bottom row of figures
	var mid: float = (row1 + row2) * 0.5
	var party_x: Array = [size.x * 0.20, size.x * 0.35]
	var enemy_x: Array = [size.x * 0.62, size.x * 0.77]

	for unit in _figures:
		var fig: UnitVisual = _figures[unit]
		if not is_instance_valid(fig):
			continue
		var slot: Dictionary = _slots[unit]
		var i: int = slot["index"]
		var n: int = slot["count"]
		var xs: Array = enemy_x
		if slot["party"]:
			xs = party_x
		var pos: Vector2
		var scale_mult: float = 1.0
		if slot["party"] and n <= 2:
			pos = Vector2(xs[i], mid) # a small party (e.g. mission 1) stands in the middle row
		elif slot["party"]:
			# Helder, Radik on top; Dean, WYG-01 below (slightly staggered like the sketch).
			var col: int = i % 2
			var row: int = i / 2
			pos = _grid_position(xs[col], row, row1, row2, size.x)
		elif n == 1:
			pos = Vector2((xs[0] + xs[1]) * 0.5, mid)
			if unit.is_boss:
				scale_mult = 1.45
		elif n == 2:
			pos = Vector2(xs[i], mid)
		else:
			# A B / C D, the same order as the 2x2 target buttons.
			var col2: int = i % 2
			var row2i: int = i / 2
			pos = _grid_position(xs[col2], row2i, row1, row2, size.x)
		fig.figure_scale = fs * scale_mult
		if not fig.gone:   # a fighter that was dragged off / faded out stays gone
			fig.position = pos
		fig.update_layout()
		var feet: float = 50.0 * fig.figure_scale
		fig.get_node("NameLabel").position = Vector2(-65, feet + 8)
	for unit in _markers:
		_place_marker(unit)

## Position in a 2x2 grid: row 0 is the top row, row 1 the bottom row (shifted a little right).
func _grid_position(x: float, row: int, row1: float, row2: float, screen_width: float) -> Vector2:
	if row == 0:
		return Vector2(x, row1)
	return Vector2(x + screen_width * 0.02, row2)

# ---- waves / defeat -------------------------------------------------------

## A new wave arrived: remove the old enemy figures and place the new ones.
func _on_wave_started(units: Array) -> void:
	for u in _enemy_units:
		if _figures.has(u):
			_figures[u].queue_free()
			_figures.erase(u)
		_slots.erase(u)
		_last_hp.erase(u)
		if _markers.has(u):
			_markers[u].queue_free()
			_markers.erase(u)
	_enemy_units = units.duplicate()
	_spawn_team(units, false)
	_apply_layout()

func _on_unit_defeated(unit: BattleUnit) -> void:
	if _figures.has(unit):
		var fig: UnitVisual = _figures[unit]
		if not fig.has_art():
			fig.modulate = DEFEATED_TINT          # stick figures just go grey
		elif _is_party(unit):
			fig.play_drag_off()                   # party members are dragged off to the left
		else:
			fig.play_fade_out()                   # enemies fade out
	_clear_marker(unit)

# ---- poses and effects -------------------------------------------------------

## Somebody used an action ("Strike", "Guard", an item name...). Show the right pose.
func _on_action_announced(user: BattleUnit, action_name: String) -> void:
	_acting = null
	_announced_kind = ""
	if not _figures.has(user):
		return
	var fig: UnitVisual = _figures[user]
	if not _is_party(user):
		if not user.is_dummy:
			fig.show_pose("attack", ATTACK_POSE_SECONDS)
			_acting = user
	elif _has_move_named(user.alteration_moves, action_name):
		fig.show_pose("alter", ALTER_POSE_SECONDS)
		fig.flicker()
		# This skill's own cast effect, or else the character's general Alter Vfx.
		var cast_move: Move = _move_named(user.alteration_moves, action_name)
		var cast_fx: PackedScene = fig.alter_vfx
		if cast_move != null and cast_move.vfx_cast != null:
			cast_fx = cast_move.vfx_cast
		VfxPlayer.play(cast_fx, self, fig.vfx_position())
		_announced_kind = "alter"
	elif _has_move_named(user.basic_moves, action_name):
		fig.show_pose("attack", ATTACK_POSE_SECONDS)
		_acting = user
		_announced_kind = "attack"
	elif action_name == "Guard":
		fig.show_pose("guard", GUARD_POSE_SECONDS)
	# The damage from this action lands in the same moment; after that, forget who acted.
	get_tree().create_timer(0.1).timeout.connect(_forget_acting)

## The action is aimed at `targets` (emitted right after action_announced).
## A party member with an animated sprite sheet moves here: a Basic attack jumps next to the first
## target and swings the club; an Alteration plays its spellcast. Then the stage asks the
## BattleManager to wait (visual_lead_in, visual_follow_through), so the damage shows up when the
## club hits and the next turn only starts when the animation is over.
func _on_action_targeted(user: BattleUnit, targets: Array) -> void:
	if _announced_kind == "" or not _figures.has(user) or not _is_party(user):
		return
	var fig: UnitVisual = _figures[user]
	if not fig.is_animated():
		return
	var lead_in: float = 0.0          # seconds until the hit lands
	var follow_through: float = 0.0   # seconds after it, until the animation is over
	if _announced_kind == "attack" and fig.can_lunge() and not targets.is_empty() and _figures.has(targets[0]):
		var target_fig: UnitVisual = _figures[targets[0]]
		var stand_off: float = fig.lunge_distance * fig.figure_scale / 0.65
		fig.play_lunge(target_fig.position - Vector2(stand_off, 0.0))
		lead_in = fig.lunge_impact_seconds()
		follow_through = fig.lunge_total_seconds() - lead_in
	elif _announced_kind == "alter":
		lead_in = fig.alter_impact_seconds()
		follow_through = maxf(0.0, fig.anim_seconds("alter") - lead_in)
	if lead_in <= 0.0:
		return
	battle_manager.visual_lead_in = lead_in
	battle_manager.visual_follow_through = follow_through
	_set_active(null)           # the white marker would hang over the empty spot
	_holding_attacker = true    # keep remembering who attacks until the hit has landed
	get_tree().create_timer(lead_in + 0.1).timeout.connect(_release_attacker)

func _forget_acting() -> void:
	if _holding_attacker:
		return   # a jump is on its way: stay remembered until the hit lands (see _release_attacker)
	_acting = null

func _release_attacker() -> void:
	_holding_attacker = false
	_acting = null

## The action takes effect now (the BattleManager emits this after any lead-in).
## Plays the effects that belong to it (see PANDUAN_VFX.md):
##   Alteration -> the skill's "Vfx Hit" on every target (its "Vfx Cast" played when it started)
##   Item       -> the item's "Vfx" on every target
##   Guard      -> the character's "Guard Vfx", on the character
## Basic attacks are not handled here: their "Attack Vfx" plays when the hit lands (_show_hit).
func _on_action_landed(user: BattleUnit, targets: Array, source: Resource) -> void:
	if not _is_party(user) or not _figures.has(user):
		return
	if source == null:   # Guard
		var user_fig: UnitVisual = _figures[user]
		VfxPlayer.play(user_fig.guard_vfx, self, user_fig.vfx_position())
		return
	var move: Move = source as Move
	var item: Item = source as Item
	var effect: PackedScene = null
	if move != null and _has_move_named(user.alteration_moves, move.move_name):
		effect = move.vfx_hit
	elif item != null:
		effect = item.vfx
	if effect == null:
		return
	for target in targets:
		if _figures.has(target) and is_instance_valid(_figures[target]):
			VfxPlayer.play(effect, self, _figures[target].vfx_position())

## The move with this name in the list, or null.
func _move_named(moves: Array, action_name: String) -> Move:
	for move in moves:
		if move.move_name == action_name:
			return move
	return null

## True for party members, false for enemies. (BattleUnit.is_player_controlled is
## never set to false for enemies, so it can't be used for this.)
func _is_party(unit: BattleUnit) -> bool:
	return _slots.get(unit, {}).get("party", true)

func _has_move_named(moves: Array, action_name: String) -> bool:
	for move in moves:
		if move.move_name == action_name:
			return true
	return false

## Looks up this unit's pictures and effects (characters: data/characters, enemies:
## data/enemies). No Idle picture = the stick figure stays.
func _load_art(unit: BattleUnit, figure: UnitVisual, party: bool) -> void:
	var textures: Dictionary = {}
	if party:
		var template: CharacterTemplate = _template_for(unit)
		if template == null:
			return
		figure.attack_vfx = template.attack_vfx
		figure.alter_vfx = template.alter_vfx
		figure.guard_vfx = template.guard_vfx
		# An animated sprite sheet wins over the single pictures.
		if template.sprite_frames != null:
			figure.set_animated_art(template.sprite_frames, false)
			if figure.is_animated():
				return
		_add_texture(textures, "idle", template.idle_texture)
		_add_texture(textures, "attack", template.attack_texture)
		_add_texture(textures, "alter", template.alter_texture)
		_add_texture(textures, "hurt", template.hurt_texture)
	else:
		var enemy_type: EnemyType = EnemyLibrary.type_for_id(unit.enemy_id)
		if enemy_type == null:
			return
		_add_texture(textures, "idle", enemy_type.idle_texture)
		_add_texture(textures, "attack", enemy_type.attack_texture)
		figure.attack_vfx = enemy_type.attack_vfx
	if textures.has("idle"):
		# art is drawn facing right, so enemies (on the right side) are mirrored
		figure.set_art(textures, not party)

func _add_texture(textures: Dictionary, pose: String, texture: Texture2D) -> void:
	if texture != null:
		textures[pose] = texture

## The party member's data file, found by name (the unit only knows its display name).
func _template_for(unit: BattleUnit) -> CharacterTemplate:
	for template in Roster.all():
		if template.display_name == unit.stats.character_name:
			return template
	return null

# ---- floating numbers -----------------------------------------------------

func _on_hp_changed(unit: BattleUnit, new_hp: int) -> void:
	var old: int = _last_hp.get(unit, new_hp)
	_last_hp[unit] = new_hp
	var delta: int = new_hp - old
	if delta == 0 or not _figures.has(unit) or not is_instance_valid(_figures[unit]):
		return
	var text: String = str(delta)
	var color: Color = Color(1.0, 0.45, 0.4)
	if delta > 0:
		text = "+%d" % delta
		color = Color(0.4, 0.95, 0.5)
	_float_text(_figures[unit], text, 24, color, Vector2(randf_range(-26.0, 6.0), -10.0), 44.0, 0.9, 0.9, 0.4)
	if delta < 0:
		_show_hit(unit)

## The unit lost HP: play the attacker's hit effect on it, and show its Hurt pose.
func _show_hit(unit: BattleUnit) -> void:
	var fig: UnitVisual = _figures[unit]
	if _acting != null and _acting != unit and _figures.has(_acting):
		var attacker: UnitVisual = _figures[_acting]
		VfxPlayer.play(attacker.attack_vfx, self, fig.vfx_position())
	if unit.is_alive():
		fig.show_pose("hurt", HURT_POSE_SECONDS)

## A boss reached 60% HP: "Stun Immunity!" floats over it.
func _on_stun_immunity(unit: BattleUnit) -> void:
	if not _figures.has(unit) or not is_instance_valid(_figures[unit]):
		return
	_float_text(_figures[unit], "Stun Immunity!", 22, Color(1.0, 0.82, 0.3), Vector2(-60.0, -34.0), 30.0, 1.4, 1.0, 0.9)

## "Dodge!" over the target (any attack, even one that deals no damage) plus a
## quick side-step away from the attacker's side.
func _on_dodged(target: BattleUnit, _attacker: BattleUnit) -> void:
	if not _figures.has(target) or not is_instance_valid(_figures[target]):
		return
	var fig: UnitVisual = _figures[target]
	_float_text(fig, "Dodge!", 22, Color(0.75, 0.95, 1.0), Vector2(-30.0, -10.0), 36.0, 0.9, 0.9, 0.4)
	# side-step: party steps left, enemies step right (away from the other side)
	var dir: float = 1.0
	if _slots.get(target, {}).get("party", true):
		dir = -1.0
	var home: Vector2 = fig.position
	var step: Tween = create_tween()
	step.tween_property(fig, "position:x", home.x + dir * 18.0, 0.1)
	step.tween_property(fig, "position:x", home.x, 0.16)

## Shows a number / word above a fighter. It floats up `rise` pixels while it
## moves for `move_time` seconds, fades out over `fade_time` (starting after
## `fade_delay`), then removes itself.
func _float_text(fig: UnitVisual, text: String, font_size: int, color: Color,
		offset: Vector2, rise: float, move_time: float, fade_time: float, fade_delay: float) -> void:
	var lbl: Label = FLOATING_TEXT_SCENE.instantiate()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", color)
	lbl.position = fig.position + Vector2(offset.x, offset.y - 72.0 * fig.figure_scale / 0.65)
	add_child(lbl)
	var tw: Tween = create_tween()
	tw.set_parallel(true)
	tw.tween_property(lbl, "position:y", lbl.position.y - rise, move_time)
	tw.tween_property(lbl, "modulate:a", 0.0, fade_time).set_delay(fade_delay)
	tw.chain().tween_callback(lbl.queue_free)

# ---- markers ----------------------------------------------------------------

func _set_active(unit: BattleUnit) -> void:
	if _active_unit != null:
		_clear_marker(_active_unit)
	_active_unit = unit
	if unit != null:
		_show_marker(unit, Color.WHITE)

## Gold markers over the units the Target menu is hovering (empty = none).
func show_target_markers(units: Array) -> void:
	for u in _markers.keys():
		if u != _active_unit:
			_clear_marker(u)
	for u in units:
		_show_marker(u, Color(1.0, 0.82, 0.2))

func _show_marker(unit: BattleUnit, color: Color) -> void:
	if not _figures.has(unit):
		return
	var m: FieldMarker = _markers.get(unit)
	if m == null:
		m = FieldMarker.new()
		add_child(m)
		_markers[unit] = m
	m.color = color
	m.queue_redraw()
	_place_marker(unit)

func _place_marker(unit: BattleUnit) -> void:
	var m: FieldMarker = _markers.get(unit)
	var fig: CharacterPlaceholder = _figures.get(unit)
	if m == null or fig == null:
		return
	m.position = fig.position + Vector2(0, -78.0 * fig.figure_scale / 0.65 * 0.65 - 16.0)

func _clear_marker(unit: BattleUnit) -> void:
	if _markers.has(unit):
		_markers[unit].queue_free()
		_markers.erase(unit)

## A small downward-pointing arrow drawn above a unit's head.
class FieldMarker extends Node2D:
	var color: Color = Color.WHITE
	func _draw() -> void:
		draw_colored_polygon(PackedVector2Array([Vector2(-9, -10), Vector2(9, -10), Vector2(0, 4)]), color)
		draw_polyline(PackedVector2Array([Vector2(-9, -10), Vector2(9, -10), Vector2(0, 4), Vector2(-9, -10)]), Color.BLACK, 1.5)
