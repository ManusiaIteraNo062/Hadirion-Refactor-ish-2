extends Control
class_name TutorialBox
## A paged "how to play" box shown over the battle (see TutorialPage for the
## text format). Look: dark framed panel, title top-left in cyan, device badges
## above, centered Indonesian text below.
##
##   await tutorial.play(pages)   # returns when the player closes it
##
## Space / Enter / click: next page.  Left / Right: change page.  Esc: skip.

signal finished

const DEVICE_COLORS := {
	"Attack": Color(0.72, 0.18, 0.16),
	"Alteration": Color(0.5, 0.28, 0.72),
	"Item": Color(0.3, 0.62, 0.26),
	"Guard": Color(0.18, 0.56, 0.76),
}

const LAYOUT_SCENE := preload("res://scenes/ui/tutorial_box.tscn")
const ROW_SCENE := preload("res://scenes/ui/tutorial_row.tscn")
var _layout: Control

var _pages: Array[TutorialPage] = []
var _index: int = 0
var _title: Label
var _counter: Label
var _body: VBoxContainer
var _back_btn: Button
var _next_btn: Button

func _init() -> void:
	_layout = LAYOUT_SCENE.instantiate()
	add_child(_layout)

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false

	_title = _layout.get_node("%TitleLabel")
	_counter = _layout.get_node("%CounterLabel")
	_body = _layout.get_node("%BodyBox")
	_back_btn = _layout.get_node("%BackButton")
	_next_btn = _layout.get_node("%NextButton")

	_back_btn.pressed.connect(_on_back_pressed)
	_next_btn.pressed.connect(_on_next_pressed)

# _go(-1) = previous page, _go(1) = next page (or close after the last one).
func _on_back_pressed() -> void:
	_go(-1)

func _on_next_pressed() -> void:
	_go(1)

## Shows the pages and waits until the player finishes or skips.
func play(pages: Array[TutorialPage]) -> void:
	if pages.is_empty():
		return
	_pages = pages
	_index = 0
	visible = true
	_show_page()
	await finished
	visible = false

func _go(step: int) -> void:
	var target: int = _index + step
	if target >= _pages.size():
		finished.emit()
		return
	_index = clampi(target, 0, _pages.size() - 1)
	_show_page()

func _show_page() -> void:
	var p: TutorialPage = _pages[_index]
	_title.text = p.title
	_counter.text = "%d / %d" % [_index + 1, _pages.size()]
	_back_btn.visible = _index > 0
	if _index == _pages.size() - 1:
		_next_btn.text = "Mulai"
	else:
		_next_btn.text = "Lanjut"
	for c in _body.get_children():
		_body.remove_child(c)
		c.queue_free()
	for r in p.rows:
		_body.add_child(_make_row(r[0], r[1]))
	for t in p.paragraphs:
		var l: Label = Label.new()
		l.text = t
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.add_theme_font_size_override("font_size", 17)
		_body.add_child(l)
	_next_btn.grab_focus()

## A colored device badge (button / key, in English) with its explanation beside it.
func _make_row(device: String, text: String) -> Control:
	# the row layout is in scenes/ui/tutorial_row.tscn
	var row: HBoxContainer = ROW_SCENE.instantiate()
	var badge: PanelContainer = row.get_node("Badge")
	# copy the badge style first, otherwise every row would share (and change) one style
	var badge_style: StyleBoxFlat = badge.get_theme_stylebox("panel").duplicate()
	if DEVICE_COLORS.has(device):
		badge_style.bg_color = DEVICE_COLORS[device]
		badge_style.border_color = Color(0.88, 0.7, 0.3)
	badge.add_theme_stylebox_override("panel", badge_style)
	var device_label: Label = row.get_node("%DeviceLabel")
	device_label.text = device
	var text_label: Label = row.get_node("%TextLabel")
	text_label.text = text
	return row

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		finished.emit()
	elif event.is_action_pressed("ui_right"):
		_go(1)
	elif event.is_action_pressed("ui_left") and _index > 0:
		_go(-1)
	else:
		return
	get_viewport().set_input_as_handled()
