extends Control
class_name WorkshopScreen
## Admin's workshop, the entry point from the lobby. Shows two big choices:
##   left  - Equipment   (hammer): upgrades, equipment, skills  -> EquipmentWorkshop
##   right - Preparation (sack):   craft items for missions     -> PreparationWorkshop
## Each sub-screen has its own Back button (and Esc) that returns here.
## Same outside API as before: refresh(state), focus_first(), changed, back_pressed.

signal back_pressed
signal changed

enum View { HUB, EQUIPMENT, PREPARATION }

var _state: GameState
var _view: View = View.HUB

var _hub: Control
var _equipment: EquipmentWorkshop
var _prep: PreparationWorkshop
var _fragments_label: Label
var _equipment_btn: Button
var _prep_btn: Button
var _back_btn: Button

const HUB_SCENE := preload("res://scenes/ui/workshop_hub.tscn")

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# The hub (frame, two big choices, Back button) is in scenes/ui/workshop_hub.tscn
	_hub = HUB_SCENE.instantiate()
	add_child(_hub)
	_fragments_label = _hub.get_node("%FragmentsLabel")
	_equipment_btn = _hub.get_node("%EquipmentButton")
	_prep_btn = _hub.get_node("%PreparationButton")
	_back_btn = _hub.get_node("%BackButton")
	_equipment_btn.pressed.connect(_on_equipment_pressed)
	_prep_btn.pressed.connect(_on_preparation_pressed)
	_back_btn.pressed.connect(_on_back_pressed)

	_equipment = EquipmentWorkshop.new()
	_equipment.changed.connect(_on_child_changed)
	_equipment.back_pressed.connect(_on_child_back_pressed)
	add_child(_equipment)

	_prep = PreparationWorkshop.new()
	_prep.changed.connect(_on_child_changed)
	_prep.back_pressed.connect(_on_child_back_pressed)
	add_child(_prep)

	_show(View.HUB)

func _on_equipment_pressed() -> void:
	_show(View.EQUIPMENT)

func _on_preparation_pressed() -> void:
	_show(View.PREPARATION)

func _on_back_pressed() -> void:
	back_pressed.emit()

# A sub-screen changed something (bought, crafted...): tell GameFlow so it can save.
func _on_child_changed() -> void:
	changed.emit()

# A sub-screen's Back button: return to the hub.
func _on_child_back_pressed() -> void:
	_show(View.HUB)

func refresh(state: GameState) -> void:
	_state = state
	_equipment.refresh(state)
	_prep.refresh(state)
	_show(View.HUB)

func focus_first() -> void:
	if _view == View.EQUIPMENT:
		_equipment.focus_first()
	elif _view == View.PREPARATION:
		_prep.focus_first()
	else:
		_equipment_btn.grab_focus()

func _show(view: View) -> void:
	_view = view
	_hub.visible = (view == View.HUB)
	_equipment.visible = (view == View.EQUIPMENT)
	_prep.visible = (view == View.PREPARATION)
	if _state:
		_fragments_label.text = "Shangri-La Fragments: %d" % _state.fragments
		_equipment.refresh(_state)
		_prep.refresh(_state)
	if is_inside_tree() and visible:
		focus_first.call_deferred()

## Esc: back one step (sub-screen -> hub -> lobby).
func _unhandled_input(event: InputEvent) -> void:
	if not visible or not event.is_action_pressed("ui_cancel"):
		return
	if _view == View.HUB:
		back_pressed.emit()
	else:
		_show(View.HUB)
	get_viewport().set_input_as_handled()
