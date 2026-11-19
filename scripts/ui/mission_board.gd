extends Control
class_name MissionBoard
## The mission select screen. A mission unlocks once the one before it has
## been cleared. Cleared missions can be replayed (at a reduced reward).
## The layout is in a scene file; this script fills it in.

signal mission_selected(mission: Mission)
signal back_pressed

var missions: Array[Mission] = []

const LAYOUT_SCENE := preload("res://scenes/ui/mission_board.tscn")
const MISSION_BUTTON_SCENE := preload("res://scenes/ui/mission_button.tscn")
var _layout: Control

var _scroll: ScrollContainer
var _list: VBoxContainer
var _footer: Label
var _back_btn: Button
var _next_btn: Button # the first unlocked, not-yet-cleared mission

func _init() -> void:
	_layout = LAYOUT_SCENE.instantiate()
	add_child(_layout)

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_scroll = _layout.get_node("%MissionScroll")
	_list = _layout.get_node("%MissionList")
	_footer = _layout.get_node("%FooterLabel")
	_back_btn = _layout.get_node("%BackButton")

	_back_btn.pressed.connect(_on_back_pressed)
	# the list height follows the window
	_fit_scroll()
	get_viewport().size_changed.connect(_fit_scroll)

## Waits one frame for the list to be laid out, then scrolls so the cursor is visible.
func _scroll_to(btn: Control) -> void:
	await get_tree().process_frame
	if is_instance_valid(btn) and is_instance_valid(_scroll):
		_scroll.ensure_control_visible(btn)

func _fit_scroll() -> void:
	var h: float = get_viewport_rect().size.y
	_scroll.custom_minimum_size = Vector2(0, clampf(h - 250.0, 220.0, 760.0))

func _on_back_pressed() -> void:
	back_pressed.emit()

# bind(m) sticks the mission onto the call, so we know which button was pressed.
func _on_mission_pressed(m: Mission) -> void:
	mission_selected.emit(m)

# Called by GameFlow every time the board is shown. Makes one button per mission.
func refresh(state: GameState) -> void:
	_next_btn = null
	for c in _list.get_children():
		_list.remove_child(c)
		c.queue_free()

	for i in range(missions.size()):
		var m: Mission = missions[i]
		var is_cleared: bool = state.is_cleared(m.id)
		# A mission is unlocked if it is the first one, or the one before it is cleared.
		var unlocked: bool = false
		if i == 0:
			unlocked = true
		elif state.is_cleared(missions[i - 1].id):
			unlocked = true

		var btn: Button = MISSION_BUTTON_SCENE.instantiate()
		btn.disabled = not unlocked
		if unlocked:
			var place: String = ""
			if m.location != "":
				place = "  |  %s" % m.location
			var cleared_text: String = ""
			if is_cleared:
				cleared_text = "   (cleared)"
			btn.text = "%d. %s   [%s]%s\n%s\nReward: %d fragments%s" % [
				i + 1, m.title, m.difficulty, cleared_text,
				m.summary, m.fragment_reward, place
			]
			btn.pressed.connect(_on_mission_pressed.bind(m))
			if not is_cleared and _next_btn == null:
				_next_btn = btn
		else:
			btn.text = "%d. ???   [Locked]\nClear the previous mission to unlock." % (i + 1)
		_list.add_child(btn)

	var all_cleared: bool = false
	if not missions.is_empty():
		var last_mission: Mission = missions[missions.size() - 1]
		all_cleared = state.is_cleared(last_mission.id)
	if all_cleared:
		_footer.text = "All missions cleared - more coming soon."
	else:
		_footer.text = ""

func focus_first() -> void:
	if _next_btn and is_instance_valid(_next_btn):
		_next_btn.grab_focus()
		_scroll_to.call_deferred(_next_btn) # the layout isn't ready yet on the first frame
		return
	for c in _list.get_children():
		if c is Button and not c.disabled:
			c.grab_focus()
			return
	_back_btn.grab_focus()
