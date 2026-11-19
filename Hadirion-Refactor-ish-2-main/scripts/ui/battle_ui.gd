extends Control
class_name BattleUI
## Battle screen UI, built in code, laid out from the user's sketches:
##
##   top-left   TURN panel, WAVE panel, "name used" strip
##   top-right  enemy list (name, HP bar, HP number; boss last)
##   bottom     "<name>'s turn"  ->  party status bar (HP + segmented EP)
##              ->  action panel: [categories] [moves/items] [Target who]
##
## Everything is anchored (top-left / top-right / bottom-center), so wider
## windows just get more empty space on the sides. The battlefield itself is
## placed by BattleStage. Keyboard: arrows move, Space/Enter accepts, Esc or
## right-click goes back one step.

signal target_focused(units: Array) # units about to be targeted (empty = none); BattleStage shows markers

@export var battle_manager: BattleManager
## false = the caller starts the battle with begin() (used to show a tutorial first).
@export var autostart: bool = true

# --- look ---
const BAR_WIDTH := 820.0        # party status bar and action panel width
const PARTY_BAR_HEIGHT := 70.0
const ACTION_HEIGHT := 126.0
const MARGIN := 16.0
const GOLD := Color(0.88, 0.7, 0.3)
const GOLD_DIM := Color(0.42, 0.34, 0.17)
const PANEL_BG := Color(0.09, 0.08, 0.07, 0.94)
const TEXT_DARK := Color(0.1, 0.08, 0.03)

# --- widgets ---
var _turn_value: Label
var _wave_value: Label
var _name_used: Label
var _name_used_panel: Control
var _enemy_panel: OrnatePanel
var _enemy_rows: VBoxContainer
var _turn_label: Label
var _party_row: HBoxContainer
var _category_box: VBoxContainer
var _move_list: VBoxContainer
var _move_scroll: ScrollContainer
var _target_title: Label
var _target_grid: GridContainer
var _info_scroll: ScrollContainer
var _info_body: Label
var _hint: Label
var _picking_target: bool = false  # true while the right box shows "Target who?"

var _slot_row: HBoxContainer
var _party_cells: Dictionary = {}  # BattleUnit -> { panel, hp, hp_text, ep, ep_text, turn_label, tab, popup, popup_lines }
var _enemy_cells: Dictionary = {}  # BattleUnit -> { name, bar, text, status }
var _category_buttons: Dictionary = {} # kind -> Button

# --- menu state ---
var _current_unit: BattleUnit
var _current_actions: Dictionary
var _kind: String = "basic"     # category currently shown in the middle panel
var _on_cancel: Callable        # what Esc does right now (empty = nothing)
var _name_tween: Tween
var _came_from: Control         # the move button that was focused before picking a target

# The layout (panels, bars, the four category buttons) is in scenes/ui/battle_ui.tscn.
# The pieces that repeat per unit are scenes too: party_cell, status_slot,
# status_popup, enemy_row and gold_button.
const LAYOUT_SCENE := preload("res://scenes/ui/battle_ui.tscn")
const PARTY_CELL_SCENE := preload("res://scenes/ui/party_cell.tscn")
const STATUS_SLOT_SCENE := preload("res://scenes/ui/status_slot.tscn")
const STATUS_POPUP_SCENE := preload("res://scenes/ui/status_popup.tscn")
const ENEMY_ROW_SCENE := preload("res://scenes/ui/enemy_row.tscn")
const GOLD_BUTTON_SCENE := preload("res://scenes/ui/gold_button.tscn")
var _layout: Control

# _init runs when BattleUI.new() is called: load the layout and add it.
func _init() -> void:
	_layout = LAYOUT_SCENE.instantiate()
	add_child(_layout)

# _ready runs once the screen is in the scene tree: find the nodes, connect everything.
func _ready() -> void:
	# Fill the whole screen (offsets too, or the anchored children below end up
	# inside a zero-size parent and vanish).
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# "%Name" finds the node with that name inside the scene.
	_turn_value = _layout.get_node("%TurnValue")
	_wave_value = _layout.get_node("%WaveValue")
	_name_used = _layout.get_node("%NameUsedLabel")
	_name_used_panel = _layout.get_node("%NameUsedPanel")
	_enemy_panel = _layout.get_node("%EnemyPanel")
	_enemy_rows = _layout.get_node("%EnemyRows")
	_turn_label = _layout.get_node("%TurnLabel")
	_slot_row = _layout.get_node("%SlotRow")
	_party_row = _layout.get_node("%PartyRow")
	_category_box = _layout.get_node("%CategoryBox")
	_move_scroll = _layout.get_node("%MoveScroll")
	_move_list = _layout.get_node("%MoveList")
	_target_title = _layout.get_node("%TargetTitle")
	_info_scroll = _layout.get_node("%InfoScroll")
	_info_body = _layout.get_node("%InfoBody")
	_target_grid = _layout.get_node("%TargetGrid")
	_hint = _layout.get_node("%HintLabel")
	_turn_value.text = "1"

	# The four category buttons (the kind is what _show_category / _on_category_pressed get)
	_category_buttons["basic"] = _layout.get_node("%AttackButton")
	_category_buttons["alteration"] = _layout.get_node("%AlterationButton")
	_category_buttons["item"] = _layout.get_node("%ItemButton")
	_category_buttons["guard"] = _layout.get_node("%GuardButton")
	for kind in _category_buttons:
		var b: Button = _category_buttons[kind]
		b.focus_entered.connect(_show_category.bind(kind))
		b.pressed.connect(_on_category_pressed.bind(kind))

	# Training mode: a reminder plus a way out (the battle never ends by itself).
	var training_box: VBoxContainer = _layout.get_node("%TrainingBox")
	training_box.visible = battle_manager.training
	var exit_btn: Button = _layout.get_node("%ExitTrainingButton")
	exit_btn.pressed.connect(_on_exit_training_pressed)

	battle_manager.player_turn_started.connect(_on_player_turn)
	battle_manager.enemy_turn_started.connect(_on_enemy_turn)
	battle_manager.round_started.connect(_on_round_started)
	battle_manager.battle_ended.connect(_on_battle_ended)
	battle_manager.wave_started.connect(_on_wave_started)
	battle_manager.action_announced.connect(_on_action_announced)

	for u in battle_manager.player_team:
		_add_party_cell(u)
		_hook_unit(u)
	for u in battle_manager.enemy_team:
		_hook_unit(u)
	_rebuild_enemy_list()
	_update_wave()
	_clear_actions()
	if autostart:
		battle_manager.start_battle()

func _on_exit_training_pressed() -> void:
	battle_manager.abort_battle()

func _on_round_started(round_number: int) -> void:
	_turn_value.text = str(round_number)

## Starts the battle (only needed when autostart is off).
func begin() -> void:
	battle_manager.start_battle()

# ===========================================================================
# Party cells and enemy rows
# ===========================================================================

func _hook_unit(u: BattleUnit) -> void:
	u.hp_changed.connect(_on_unit_hp_changed)
	u.energy_changed.connect(_on_unit_energy_changed)
	u.statuses_changed.connect(_on_unit_statuses_changed)
	u.defeated.connect(_on_unit_defeated)

# Each of these just refreshes that unit's bars and text.
func _on_unit_hp_changed(unit: BattleUnit, _hp) -> void:
	_update_unit(unit)

func _on_unit_energy_changed(unit: BattleUnit, _energy) -> void:
	_update_unit(unit)

func _on_unit_statuses_changed(unit: BattleUnit) -> void:
	_update_unit(unit)

func _on_unit_defeated(unit: BattleUnit) -> void:
	_update_unit(unit)

func _add_party_cell(u: BattleUnit) -> void:
	# the cell layout is in scenes/ui/party_cell.tscn
	var cell: PanelContainer = PARTY_CELL_SCENE.instantiate()
	_party_row.add_child(cell)
	var name_lbl: Label = cell.get_node("%NameLabel")
	name_lbl.text = u.stats.character_name
	var hp: StatBar = cell.get_node("%HpBar")
	var hp_text: Label = cell.get_node("%HpText")
	var ep: StatBar = cell.get_node("%EpBar")
	var ep_text: Label = cell.get_node("%EpText")

	# The slot above the party bar: "<name>'s turn" on the left and a small "Status"
	# tab on the right (the tab only shows while the unit has a status).
	var slot: HBoxContainer = STATUS_SLOT_SCENE.instantiate()
	_slot_row.add_child(slot)
	var turn_label: Label = slot.get_node("%TurnLabel")
	var tab: PanelContainer = slot.get_node("%StatusTab")

	# The status list lives on the BattleUI itself (not inside the row) so it can float over the field.
	var popup: OrnatePanel = STATUS_POPUP_SCENE.instantiate()
	add_child(popup)
	var lines: VBoxContainer = popup.get_node("%Lines")

	_party_cells[u] = {"panel": cell, "hp": hp, "hp_text": hp_text, "ep": ep, "ep_text": ep_text,
		"turn_label": turn_label, "tab": tab, "popup": popup, "popup_lines": lines}
	_update_unit(u, false)

func _process(_delta: float) -> void:
	# Show a unit's status list while the mouse is over its tab (or the list itself).
	var m: Vector2 = get_global_mouse_position()
	for u in _party_cells:
		var c: Dictionary = _party_cells[u]
		var tab: Control = c["tab"]
		var popup: Control = c["popup"]
		var over: bool = tab.visible and (tab.get_global_rect().has_point(m) or (popup.visible and popup.get_global_rect().has_point(m)))
		if over and not popup.visible:
			popup.visible = true
			_position_popup(u)
		elif not over and popup.visible:
			popup.visible = false

func _position_popup(u: BattleUnit) -> void:
	var c: Dictionary = _party_cells[u]
	var tab: Control = c["tab"]
	var popup: Control = c["popup"]
	popup.reset_size()
	var r: Rect2 = tab.get_global_rect()
	popup.global_position = Vector2(r.end.x - popup.size.x, r.position.y - popup.size.y - 2.0)

func _cell_style(active: bool) -> StyleBoxFlat:
	var st: StyleBoxFlat = StyleBoxFlat.new()
	if active:
		st.bg_color = Color(0.16, 0.13, 0.07, 0.95)
		st.set_border_width_all(2)
		st.border_color = GOLD
	else:
		st.bg_color = Color(0.12, 0.11, 0.1, 0.9)
		st.set_border_width_all(1)
		st.border_color = GOLD_DIM
	st.set_corner_radius_all(4)
	st.content_margin_left = 8
	st.content_margin_right = 8
	st.content_margin_top = 3
	st.content_margin_bottom = 3
	return st

func _rebuild_enemy_list() -> void:
	for c in _enemy_rows.get_children():
		_enemy_rows.remove_child(c)
		c.queue_free()
	_enemy_cells.clear()
	# Regular enemies first, the boss last (like the sketch).
	var ordered: Array = []
	for u in battle_manager.enemy_team:
		if not u.is_boss:
			ordered.append(u)
	for u in battle_manager.enemy_team:
		if u.is_boss:
			ordered.append(u)
	for u in ordered:
		# the row layout is in scenes/ui/enemy_row.tscn
		var row: HBoxContainer = ENEMY_ROW_SCENE.instantiate()
		_enemy_rows.add_child(row)
		var name_lbl: Label = row.get_node("%NameLabel")
		name_lbl.text = u.stats.character_name
		var bar: StatBar = row.get_node("%HpBar")
		if u.is_boss:
			name_lbl.add_theme_color_override("font_color", GOLD)
			# Hover the tag to see why this fight changes at 60% HP.
			row.get_node("%BossTag").visible = true
			bar.fill_color = Color(0.9, 0.55, 0.15)
			bar.custom_minimum_size = Vector2(60, 14)
		var text: Label = row.get_node("%HpText")
		_enemy_cells[u] = {"name": name_lbl, "bar": bar, "text": text}
		_update_unit(u, false)

func _on_wave_started(units: Array) -> void:
	for u in units:
		_hook_unit(u)
	_rebuild_enemy_list()
	_update_wave()

func _update_wave() -> void:
	_wave_value.text = "%d/%d" % [battle_manager.current_wave, battle_manager.wave_count]

## Refreshes one unit's bars and text (party cell or enemy row).
func _update_unit(u: BattleUnit, animate: bool = true) -> void:
	if _party_cells.has(u):
		var c: Dictionary = _party_cells[u]
		c["hp"].set_target(u.current_health, u.stats.max_health, animate)
		c["hp_text"].text = str(u.current_health)
		c["ep"].set_target(u.current_energy, BattleUnit.MAX_ENERGY, animate)
		c["ep_text"].text = "%d/%d" % [u.current_energy, BattleUnit.MAX_ENERGY]
		_update_status_box(c, u)
		if u.is_alive():
			c["panel"].modulate = Color.WHITE
		else:
			c["panel"].modulate = Color(0.5, 0.5, 0.5, 0.8)
	elif _enemy_cells.has(u):
		var c: Dictionary = _enemy_cells[u]
		c["bar"].set_target(u.current_health, u.stats.max_health, animate)
		if u.is_alive():
			c["text"].text = str(u.current_health)
			c["name"].modulate = Color.WHITE
		else:
			c["text"].text = "KO"
			c["name"].modulate = Color(0.5, 0.5, 0.5, 0.8)

func _update_status_box(c: Dictionary, u: BattleUnit) -> void:
	var details: Array = u.status_details()
	c["tab"].visible = details.size() > 0 and u.is_alive()
	var box: VBoxContainer = c["popup_lines"]
	for child in box.get_children():
		box.remove_child(child)
		child.queue_free()
	for d in details:
		var title: Label = Label.new()
		title.text = d[0]
		title.add_theme_font_size_override("font_size", 14)
		title.add_theme_color_override("font_color", GOLD)
		box.add_child(title)
		var body: Label = Label.new()
		body.text = d[1]
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.custom_minimum_size = Vector2(250, 0)
		body.add_theme_font_size_override("font_size", 12)
		box.add_child(body)
		var gap: Control = Control.new()
		gap.custom_minimum_size = Vector2(0, 4)
		box.add_child(gap)
	var scroll: ScrollContainer = box.get_parent()
	# about two entries show at once; the mouse wheel scrolls the rest
	var scroll_height: int = 136
	if details.is_empty():
		scroll_height = 0
	elif details.size() == 1:
		scroll_height = 68
	scroll.custom_minimum_size = Vector2(0, scroll_height)
	if not c["tab"].visible:
		c["popup"].visible = false
	elif c["popup"].visible:
		_position_popup(u)

## Highlights the acting unit's cell and shows "<name>'s turn" right above it.
func _highlight_active(unit: BattleUnit) -> void:
	for u in _party_cells:
		_party_cells[u]["panel"].add_theme_stylebox_override("panel", _cell_style(u == unit))
		if u == unit:
			_party_cells[u]["turn_label"].text = "%s's turn" % u.stats.character_name
		else:
			_party_cells[u]["turn_label"].text = ""

# ===========================================================================
# Turn flow
# ===========================================================================

func _on_enemy_turn(u: BattleUnit) -> void:
	_current_unit = null
	_highlight_active(null)
	_clear_actions()
	_turn_label.add_theme_color_override("font_color", Color(0.9, 0.5, 0.45))
	_turn_label.text = "%s is acting..." % u.stats.character_name

func _on_battle_ended(player_won: bool) -> void:
	_clear_actions()
	_highlight_active(null)
	_turn_label.add_theme_color_override("font_color", GOLD)
	if battle_manager.training:
		_turn_label.text = "TRAINING ENDED"
	else:
		if player_won:
			_turn_label.text = "VICTORY"
		else:
			_turn_label.text = "DEFEAT"

func _on_action_announced(user: BattleUnit, action_name: String) -> void:
	_name_used.text = "%s  >  %s" % [user.stats.character_name, action_name]
	_name_used_panel.modulate.a = 1.0
	if _name_tween:
		_name_tween.kill()
	_name_tween = create_tween()
	_name_tween.tween_interval(1.6)
	_name_tween.tween_property(_name_used_panel, "modulate:a", 0.0, 0.5)

func _on_player_turn(unit: BattleUnit, actions: Dictionary) -> void:
	_current_unit = unit
	_current_actions = actions
	_turn_label.text = "" # the per-unit label above the party bar says whose turn it is
	_highlight_active(unit)
	_show_categories()

func _clear_actions() -> void:
	_on_cancel = Callable()
	_picking_target = false
	_hide_info()
	_clear_children(_move_list)
	_clear_children(_target_grid)
	_target_title.text = ""
	_hint.visible = false
	for b in _category_buttons.values():
		b.disabled = true
	target_focused.emit([])

func _clear_children(node: Node) -> void:
	for c in node.get_children():
		node.remove_child(c)
		c.queue_free()

## Back to the category list (start of every turn, and Esc from the move list).
func _show_categories() -> void:
	_picking_target = false
	_hide_info()
	_clear_children(_move_list)
	_clear_children(_target_grid)
	_target_title.text = ""
	_hint.visible = false
	target_focused.emit([])
	_on_cancel = Callable()
	for b in _category_buttons.values():
		b.disabled = false
	var first: Button = _category_buttons["basic"]
	if _category_buttons.has(_kind):
		first = _category_buttons[_kind]
	if first.has_focus():
		_show_category(_kind)
	else:
		first.grab_focus() # focus_entered fills the middle panel

## Fills the middle panel for a category (called when its button gets focus).
func _show_category(kind: String) -> void:
	if _current_unit == null:
		return
	_kind = kind
	_picking_target = false
	_hide_info()
	_clear_children(_move_list)
	_clear_children(_target_grid)
	_target_title.text = ""
	target_focused.emit([])
	if kind == "basic":
		for move in _current_actions["basic"]:
			_add_entry(move.move_name, _select_targets.bind("basic", move, null), true, move.move_name, _move_info(move))
	elif kind == "alteration":
		for move in _current_actions["alteration"]:
			var label: String = move.move_name + "   %d EN" % _current_unit.energy_cost_for(move)
			var left: int = _current_unit.uses_left(move)
			if left >= 0:
				label += "   [%d left]" % left
			_add_entry(label, _select_targets.bind("alteration", move, null), true, move.move_name, _move_info(move))
		# moves that can't be used right now are shown greyed out
		for move in _current_actions.get("locked_alteration", []):
			var why: String = "needs %d EN" % _current_unit.energy_cost_for(move)
			if _current_unit.uses_left(move) == 0:
				why = "no uses left"
			_add_entry("%s   (%s)" % [move.move_name, why], Callable(), false, move.move_name, _move_info(move))
	elif kind == "item":
		var items: Array = _current_actions["items"]
		if items.is_empty():
			_add_entry("(no items)", Callable(), false)
		for item in items:
			var qty: int = battle_manager.party_inventory[item]
			_add_entry("%s  x%d" % [item.item_name, qty], _select_targets.bind("item", null, item), true, item.item_name, item.description)
	elif kind == "guard":
		var l: Label = Label.new()
		l.text = "Guard\nHalves damage taken until the next round.\n+1 Energy at the start of your next turn."
		l.add_theme_font_size_override("font_size", 13)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_move_list.add_child(l)

func _on_category_pressed(kind: String) -> void:
	if _current_unit == null:
		return
	if kind == "guard":
		_submit("guard", null, null, [])
		return
	_show_category(kind)
	var btn: Button = _first_button(_move_list)
	if btn:
		_on_cancel = _show_categories
		btn.grab_focus()
		_hint.visible = true

## info_title / info_body: what the right-hand box shows while this entry is hovered or focused.
func _add_entry(text: String, callback: Callable, enabled: bool = true, info_title: String = "", info_body: String = "") -> void:
	var btn: Button = _make_gold_button(text)
	btn.disabled = not enabled
	if enabled:
		btn.pressed.connect(callback)
	if info_title != "":
		btn.focus_entered.connect(_show_info.bind(info_title, info_body))
		btn.mouse_entered.connect(_show_info.bind(info_title, info_body))
	_move_list.add_child(btn)

func _show_info(title: String, body: String) -> void:
	if _picking_target:
		return
	_target_title.text = title
	_info_body.text = body
	_info_scroll.visible = true
	_target_grid.visible = false
	_hint.visible = false # more room for the text; the hint returns with the target list

func _hide_info() -> void:
	_info_scroll.visible = false
	_target_grid.visible = true

## Live numbers for a move, from the unit's current (buffed) stats.
func _unit_stats() -> Dictionary:
	return {"attack": _current_unit.get_attack(), "capability": _current_unit.get_capability(), "speed": _current_unit.get_speed()}

func _move_info(move: Move) -> String:
	var t: String = move.description
	if move.formula != "":
		t += "\nHitungan: " + move.formula
	var live: String = ""
	if move.skill_id != "":
		var sk: Skill = SkillLibrary.get_skill(move.skill_id)
		if sk != null:
			live = sk.preview_text(_unit_stats())
	elif move.deals_damage:
		var s: Dictionary = _unit_stats()
		live = "Saat ini: %d damage" % move.damage_per_hit(s["attack"], s["capability"], s["speed"])
	if live != "":
		t += "\n" + live
	return t

## Target step: one button per candidate in a 2-column grid (like the field).
func _select_targets(kind: String, move: Move, item: Item) -> void:
	var candidates: Array = []
	var target_all: bool = false
	var enemy_side: bool = false

	if kind == "item":
		for u in battle_manager.player_team:
			if item.revive or u.is_alive():
				candidates.append(u)
	elif move.target_type == Move.Target.SELF:
		_submit(kind, move, item, [_current_unit])
		return
	elif move.target_type in [Move.Target.SINGLE_ENEMY, Move.Target.ALL_ENEMIES]:
		for u in battle_manager.enemy_team:
			if u.is_alive():
				candidates.append(u)
		target_all = (move.target_type == Move.Target.ALL_ENEMIES)
		enemy_side = true
	else:
		for u in battle_manager.player_team:
			if u.is_alive():
				candidates.append(u)
		target_all = (move.target_type == Move.Target.ALL_ALLIES)

	if target_all:
		_submit(kind, move, item, candidates)
		return

	var came_from: Control = get_viewport().gui_get_focus_owner()
	if came_from is Button:
		came_from.add_theme_stylebox_override("normal", _gold_picked_style()) # stays gold while picking a target
	_clear_children(_target_grid)
	_picking_target = true
	_hide_info()
	_hint.visible = true
	_target_title.text = "Target who?"
	_came_from = came_from
	_on_cancel = _cancel_target_pick
	for target in candidates:
		var btn: Button = _make_gold_button(target.stats.character_name)
		btn.custom_minimum_size = Vector2(0, 26)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.focus_entered.connect(_on_target_hovered.bind(target))
		btn.mouse_entered.connect(_on_target_hovered.bind(target))
		btn.pressed.connect(_on_target_chosen.bind(kind, move, item, target))
		_target_grid.add_child(btn)
	var first: Button = _first_button(_target_grid)
	if first:
		first.grab_focus()

# Esc while picking a target: go back to the move list.
func _cancel_target_pick() -> void:
	_picking_target = false
	if is_instance_valid(_came_from) and _came_from is Button:
		_came_from.add_theme_stylebox_override("normal", _gold_normal_style())
	_clear_children(_target_grid)
	_target_title.text = ""
	target_focused.emit([])
	_on_cancel = _show_categories
	if is_instance_valid(_came_from):
		_came_from.grab_focus() # focus_entered brings the move's description back

# The mouse or keyboard is on a target button: BattleStage shows a marker over that unit.
func _on_target_hovered(target: BattleUnit) -> void:
	target_focused.emit([target])

func _on_target_chosen(kind: String, move: Move, item: Item, target: BattleUnit) -> void:
	_submit(kind, move, item, [target])

func _submit(kind: String, move: Move, item: Item, targets: Array) -> void:
	_clear_actions()
	var action_data: Dictionary = {"type": kind, "targets": targets}
	if move:
		action_data["move"] = move
	if item:
		action_data["item"] = item
	battle_manager.submit_player_action(action_data)

func _first_button(root: Node) -> Button:
	for c in root.get_children():
		if c is Button and not c.disabled and not c.is_queued_for_deletion():
			return c
	return null

## Esc / right-click = back one step.
func _unhandled_input(event: InputEvent) -> void:
	var back: bool = event.is_action_pressed("ui_cancel")
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		back = true
	if back and _on_cancel.is_valid():
		_on_cancel.call()
		get_viewport().set_input_as_handled()
	elif back and battle_manager.training and _current_unit != null:
		battle_manager.abort_battle() # Esc at the top level leaves Training
		get_viewport().set_input_as_handled()

# ===========================================================================
# Button looks
# ===========================================================================

func _flat(bg: Color, border: Color, border_w: int, radius: int = 3) -> StyleBoxFlat:
	var st: StyleBoxFlat = StyleBoxFlat.new()
	st.bg_color = bg
	st.border_color = border
	st.set_border_width_all(border_w)
	st.set_corner_radius_all(radius)
	st.content_margin_left = 10
	st.content_margin_right = 10
	st.content_margin_top = 2
	st.content_margin_bottom = 2
	return st

func _gold_normal_style() -> StyleBoxFlat:
	return _flat(Color(0.14, 0.12, 0.09), GOLD_DIM, 1, 6)

func _gold_picked_style() -> StyleBoxFlat:
	return _flat(Color(0.9, 0.7, 0.15), Color(1.0, 0.92, 0.5), 2, 6)

## Move / target button: outlined, turns solid gold when selected.
## (its look is in scenes/ui/gold_button.tscn)
func _make_gold_button(text: String) -> Button:
	var b: Button = GOLD_BUTTON_SCENE.instantiate()
	b.text = text
	return b
