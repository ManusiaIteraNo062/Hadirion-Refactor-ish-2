extends Control
class_name LobbyScreen
## The hub between missions: go to the mission board, spend fragments at
## Admin's workshop, or (once unlocked) enter Training.
## The layout (panel, buttons) is in scenes/ui/lobby_screen.tscn.
## This script only connects the buttons and fills in the text.

signal missions_pressed
signal workshop_pressed
signal training_pressed
signal encyclopedia_pressed
signal title_pressed

# The layout scene is loaded once, and a copy is made for every LobbyScreen.
const LAYOUT_SCENE := preload("res://scenes/ui/lobby_screen.tscn")
var _layout: Control

# Nodes from the scene. They are filled in _ready().
var _fragments_label: Label
var _missions_btn: Button
var _workshop_btn: Button
var _training_btn: Button
var _encyclopedia_btn: Button
var _main_menu_btn: Button

# _init runs when LobbyScreen.new() is called: load the layout and add it.
func _init() -> void:
	_layout = LAYOUT_SCENE.instantiate()
	add_child(_layout)

# _ready runs once the screen is in the scene tree: find the nodes, connect the buttons.
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# "%Name" finds the node with that name inside the scene.
	_fragments_label = _layout.get_node("%FragmentsLabel")
	_missions_btn = _layout.get_node("%MissionsButton")
	_workshop_btn = _layout.get_node("%WorkshopButton")
	_training_btn = _layout.get_node("%TrainingButton")
	_encyclopedia_btn = _layout.get_node("%EncyclopediaButton")
	_main_menu_btn = _layout.get_node("%MainMenuButton")

	_missions_btn.pressed.connect(_on_missions_pressed)
	_workshop_btn.pressed.connect(_on_workshop_pressed)
	_training_btn.pressed.connect(_on_training_pressed)
	_encyclopedia_btn.pressed.connect(_on_encyclopedia_pressed)
	_main_menu_btn.pressed.connect(_on_main_menu_pressed)

# Each button just announces itself with a signal. GameFlow listens and switches screens.
func _on_missions_pressed() -> void:
	missions_pressed.emit()

func _on_workshop_pressed() -> void:
	workshop_pressed.emit()

func _on_training_pressed() -> void:
	training_pressed.emit()

func _on_encyclopedia_pressed() -> void:
	encyclopedia_pressed.emit()

func _on_main_menu_pressed() -> void:
	title_pressed.emit()

# Called by GameFlow every time the lobby is shown.
func refresh(state: GameState) -> void:
	_fragments_label.text = "Shangri-La Fragments: %d" % state.fragments
	var unlocked: bool = state.training_unlocked()
	_training_btn.disabled = not unlocked
	if unlocked:
		_training_btn.text = "Training"
	else:
		_training_btn.text = "Training  (unlocks after Suara Merdu)"

func focus_first() -> void:
	_missions_btn.grab_focus()
