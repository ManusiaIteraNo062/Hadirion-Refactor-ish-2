extends Control
class_name TitleScreen
# First screen: Continue (needs a save) / New Game (asks first if a save exists) / Quit.
# Layout is in title_screen.tscn; this script fills text and reacts to buttons.

signal continue_pressed
signal new_game_pressed   # already confirmed
signal quit_pressed

# Set by GameFlow so the summary can say "5 / 13 missions".
var total_missions: int = 0

# The layout scene is loaded once, and a copy is made for every TitleScreen.
const LAYOUT_SCENE := preload("res://scenes/ui/title_screen.tscn")
var _layout: Control

# Nodes from the scene. They are filled in _ready().
var _continue_btn: Button
var _new_btn: Button
var _quit_btn: Button
var _summary: Label
var _confirm: Control
var _confirm_no: Button
var _has_save: bool = false
var _save_path: String = GameState.SAVE_PATH

# _init runs when TitleScreen.new() is called: load the layout and add it.
func _init() -> void:
	_layout = LAYOUT_SCENE.instantiate()
	add_child(_layout)

# _ready runs once the screen is in the scene tree: find the nodes, connect the buttons.
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# "%Name" finds the node with that name inside the scene.
	_continue_btn = _layout.get_node("%ContinueButton")
	_new_btn = _layout.get_node("%NewGameButton")
	_quit_btn = _layout.get_node("%QuitButton")
	_summary = _layout.get_node("%SummaryLabel")
	_confirm = _layout.get_node("%ConfirmOverlay")
	_confirm_no = _layout.get_node("%ConfirmNoButton")
	var confirm_yes: Button = _layout.get_node("%ConfirmYesButton")

	_continue_btn.pressed.connect(_on_continue_pressed)
	_new_btn.pressed.connect(_on_new_pressed)
	_quit_btn.pressed.connect(_on_quit_pressed)
	_confirm_no.pressed.connect(_close_confirm)
	confirm_yes.pressed.connect(_on_confirm_yes_pressed)

func _on_continue_pressed() -> void:
	continue_pressed.emit()

func _on_quit_pressed() -> void:
	quit_pressed.emit()

# "Ya, mulai baru" inside the confirm box.
func _on_confirm_yes_pressed() -> void:
	_close_confirm()
	new_game_pressed.emit()

# Called by GameFlow every time the title is shown.
func refresh(state: GameState) -> void:
	_save_path = state.save_path
	_has_save = FileAccess.file_exists(_save_path)
	_continue_btn.disabled = not _has_save
	if _has_save:
		var total: String = ""
		if total_missions > 0:
			total = " / %d" % total_missions
		_summary.text = "Fragments: %d     Misi selesai: %d%s" % [state.fragments, state.cleared.size(), total]
	else:
		_summary.text = "Belum ada data tersimpan"
	_close_confirm()

func focus_first() -> void:
	if _has_save:
		_continue_btn.grab_focus()
	else:
		_new_btn.grab_focus()

func _on_new_pressed() -> void:
	if not _has_save:
		new_game_pressed.emit() # nothing to lose, no question needed
		return
	_confirm.visible = true
	_confirm_no.grab_focus() # the safe choice is highlighted first

func _close_confirm() -> void:
	if _confirm.visible:
		_confirm.visible = false
		_new_btn.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if visible and _confirm.visible and event.is_action_pressed("ui_cancel"):
		_close_confirm()
		get_viewport().set_input_as_handled()
