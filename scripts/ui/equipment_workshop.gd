extends Control
class_name EquipmentWorkshop
## Workshop > Equipment. Three tabs, one character row, and the same
## craft / equip / unequip buttons everywhere:
##   Upgrades        - one active upgrade per character (stat bonuses)
##   Equipment       - 5 slots per character, each character crafts their own copy
##   Skill Knowledge - learn unlockable Alterations; shows what each skill does
## Emits `changed` whenever the GameState was modified (so it can be saved).

signal back_pressed
signal changed

enum Mode { UPGRADES, EQUIPMENT, SKILLS }

var _state: GameState
var _selected_id: String = ""
var _mode: Mode = Mode.UPGRADES
var _focus_row: int = 0 # keep the cursor on the same row after pressing a button

const LAYOUT_SCENE := preload("res://scenes/ui/equipment_workshop.tscn")
const CHARACTER_BUTTON_SCENE := preload("res://scenes/ui/character_button.tscn")
const ROW_SCENE := preload("res://scenes/ui/workshop_row.tscn")
var _layout: Control

var _fragments_label: Label
var _header_label: Label
var _list: VBoxContainer
var _admin_label: Label
var _back_btn: Button
var _mode_buttons: Array[Button] = []

func _init() -> void:
	_layout = LAYOUT_SCENE.instantiate()
	add_child(_layout)

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_fragments_label = _layout.get_node("%FragmentsLabel")
	_header_label = _layout.get_node("%HeaderLabel")
	_list = _layout.get_node("%ItemList")
	_admin_label = _layout.get_node("%AdminLabel")
	_back_btn = _layout.get_node("%BackButton")
	_mode_buttons.append(_layout.get_node("%UpgradesTabButton"))
	_mode_buttons.append(_layout.get_node("%EquipmentTabButton"))
	_mode_buttons.append(_layout.get_node("%SkillsTabButton"))
	var char_row: HBoxContainer = _layout.get_node("%CharacterRow")

	# tab buttons: Upgrades | Equipment | Skill Knowledge
	# bind(i) sticks the tab number onto the call, so _on_mode_pressed knows which tab it was.
	for i in range(_mode_buttons.size()):
		_mode_buttons[i].pressed.connect(_on_mode_pressed.bind(i))

	# one button per character (the characters come from Roster, so not in the scene)
	var char_group: ButtonGroup = ButtonGroup.new()
	var defs: Array = Roster.all()
	_selected_id = defs[0].id
	for d in defs:
		var b: Button = CHARACTER_BUTTON_SCENE.instantiate()
		b.text = d.display_name
		b.button_group = char_group
		b.button_pressed = (d.id == _selected_id)
		b.pressed.connect(_on_character_pressed.bind(d.id))
		char_row.add_child(b)

	_back_btn.pressed.connect(_on_back_pressed)

# A tab button was pressed (Upgrades / Equipment / Skills).
func _on_mode_pressed(mode_value: Mode) -> void:
	_mode = mode_value
	_focus_row = 0
	_rebuild()

# A character button was pressed.
func _on_character_pressed(character_id: String) -> void:
	_selected_id = character_id
	_focus_row = 0
	_rebuild()

func _on_back_pressed() -> void:
	back_pressed.emit()

func refresh(state: GameState) -> void:
	_state = state
	_admin_label.text = ""
	_focus_row = 0
	_rebuild()

## Puts the cursor on the button of row `_focus_row` (or the nearest enabled one).
func focus_first() -> void:
	var rows: Array[Node] = _list.get_children()
	if rows.is_empty():
		_back_btn.grab_focus()
		return
	var start: int = clampi(_focus_row, 0, rows.size() - 1)
	var order: Array[int] = []
	for i in range(start, rows.size()):
		order.append(i)
	for i in range(start - 1, -1, -1):
		order.append(i)
	for i in order:
		for b in rows[i].get_children():
			if b is Button and not b.disabled:
				b.grab_focus()
				return
	_back_btn.grab_focus()

func _rebuild() -> void:
	if _state == null:
		return
	_fragments_label.text = "Shangri-La Fragments: %d" % _state.fragments

	var st: Dictionary = _state.stats_for(_selected_id)
	var header: String = "HP %d   STR %d   CAP %d   SPD %d" % [st["health"], st["attack"], st["capability"], st["speed"]]
	if _mode == Mode.EQUIPMENT:
		header += "      Slot terpakai: %d / %d" % [_state.gear_slots_used(_selected_id), GearLibrary.SLOTS]
	_header_label.text = header

	for c in _list.get_children():
		_list.remove_child(c)
		c.queue_free()

	if _mode == Mode.UPGRADES:
		_build_upgrades()
	elif _mode == Mode.EQUIPMENT:
		_build_equipment()
	elif _mode == Mode.SKILLS:
		_build_skills(st)

func _row(text: String, button_text: String, disabled: bool, on_press: Callable) -> void:
	# the row layout (card, label, button) is in scenes/ui/workshop_row.tscn
	var card: PanelContainer = ROW_SCENE.instantiate()
	var info: Label = card.get_node("%InfoLabel")
	info.text = text
	var btn: Button = card.get_node("%ActionButton")
	btn.text = button_text
	btn.disabled = disabled
	var index: int = _list.get_child_count()
	if not disabled:
		btn.pressed.connect(_on_row_button_pressed.bind(index, on_press))
	_list.add_child(card)

# Remember which row was pressed (so the cursor stays there), then do its action.
func _on_row_button_pressed(index: int, on_press: Callable) -> void:
	_focus_row = index
	on_press.call()

# ---- Upgrades ----------------------------------------------------------

func _build_upgrades() -> void:
	var equipped_id: String = _state.equipped_id(_selected_id)
	for u in GearLibrary.upgrades_for(_selected_id):
		var text: String = "%s   (%s)\n%s" % [u.display_name, u.bonus_text(), u.description]
		if u.effect_text != "":
			text += "\n" + u.effect_text
		if u.id == equipped_id:
			_row(text, "Equipped", true, Callable())
		elif _state.owns(u.id):
			_row(text, "Equip", false, _on_equip_upgrade.bind(u))
		elif not _state.upgrade_unlocked(u):
			var need: Upgrade = GearLibrary.previous_upgrade(u)
			_row(text + "\nTerkunci: beli %s dulu." % need.display_name, "Locked", true, Callable())
		else:
			_row(text, "Craft (%d)" % u.cost, not _state.can_afford(u.cost), _on_craft_upgrade.bind(u))

func _on_craft_upgrade(u: Upgrade) -> void:
	if _state.buy_upgrade(u):
		_admin_label.text = "Admin: %s sudah jadi. Langsung dipasang." % u.display_name
		changed.emit()
	_finish_action()

func _on_equip_upgrade(u: Upgrade) -> void:
	if _state.equip_upgrade(_selected_id, u.id):
		_admin_label.text = "Admin: Berganti ke %s." % u.display_name
		changed.emit()
	_finish_action()

# ---- Equipment ---------------------------------------------------------

func _build_equipment() -> void:
	for e in GearLibrary.equipment():
		var text: String = "%s   (%s)\n%s" % [e.display_name, e.bonus_text(), e.description]
		if not _state.owns_gear(_selected_id, e.id):
			_row(text, "Craft (%d)" % e.cost, not _state.can_afford(e.cost), _on_craft_gear.bind(e))
		elif _state.is_gear_equipped(_selected_id, e.id):
			_row(text, "Unequip", false, _on_unequip_gear.bind(e))
		elif _state.has_free_slot(_selected_id):
			_row(text, "Equip", false, _on_equip_gear.bind(e))
		else:
			_row(text, "Slots full", true, Callable())

func _on_craft_gear(e: EquipmentItem) -> void:
	var worn_before: bool = _state.is_gear_equipped(_selected_id, e.id)
	if _state.buy_gear(_selected_id, e):
		var worn: bool = _state.is_gear_equipped(_selected_id, e.id) and not worn_before
		var ending: String = " Slot penuh, belum dipasang."
		if worn:
			ending = " Langsung dipasang."
		_admin_label.text = "Admin: %s selesai dibuat.%s" % [e.display_name, ending]
		changed.emit()
	_finish_action()

func _on_equip_gear(e: EquipmentItem) -> void:
	if _state.equip_gear(_selected_id, e.id):
		_admin_label.text = "Admin: %s dipasang." % e.display_name
		changed.emit()
	_finish_action()

func _on_unequip_gear(e: EquipmentItem) -> void:
	if _state.unequip_gear(_selected_id, e.id):
		_admin_label.text = "Admin: %s dilepas." % e.display_name
		changed.emit()
	_finish_action()

# ---- Skill Knowledge -----------------------------------------------------

func _build_skills(stats: Dictionary) -> void:
	for s in SkillLibrary.for_character(_selected_id):
		var text: String = "%s   (%s)\n%s\nHitungan: %s" % [s.display_name, s.cost_text, s.summary, s.formula]
		var preview: String = s.preview_text(stats)
		if preview != "":
			text += "\n" + preview
		if _state.knows_skill(s):
			var label: String = "Known"
			if s.unlockable:
				label = "Learned"
			_row(text, label, true, Callable())
		else:
			_row(text, "Learn (%d)" % s.cost, not _state.can_afford(s.cost), _on_learn_skill.bind(s))

func _on_learn_skill(s: Skill) -> void:
	if _state.learn_skill(s):
		_admin_label.text = "Admin: Skill %s sekarang kamu kuasai." % s.display_name
		changed.emit()
	_finish_action()

func _finish_action() -> void:
	_rebuild()
	focus_first.call_deferred()
