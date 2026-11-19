extends Control
class_name DialogueBox
## Story/dialogue box. The layout is in scenes/ui/dialogue_box.tscn; this script fills it in.
##
## Usage:   await dialogue_box.play(lines)     # lines: Array of DialogueLine
## Controls: click / Space / Enter = advance (first press finishes the
## typewriter, second press goes to the next line). Esc or the Skip button
## closes the whole conversation.
##
## Put this inside a CanvasLayer (layer 10) so it always draws on top.

signal finished

const CHARS_PER_SECOND := 55.0
const INPUT_GRACE_MS := 150 # ignore input right after opening (stray clicks)
const SPEECH_SIZE := 21
const NARRATION_SIZE := 20 # narration is one size smaller than speech (the scene uses these sizes)

var _lines: Array = []
var _index: int = 0
var _typing: bool = false
var _active: bool = false
var _opened_at: int = 0
var _tween: Tween

const LAYOUT_SCENE := preload("res://scenes/ui/dialogue_box.tscn")
var _layout: Control

var _name_label: Label
var _name_tag: PanelContainer
var _name_row: HBoxContainer
var _italic_font: FontVariation
var _text_label: RichTextLabel
var _portrait_left: PanelContainer
var _portrait_right: PanelContainer

func _init() -> void:
	_layout = LAYOUT_SCENE.instantiate()
	add_child(_layout)

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP # block clicks to whatever is underneath
	visible = false

	_text_label = _layout.get_node("%TextLabel")
	_name_row = _layout.get_node("%NameRow")
	_name_tag = _layout.get_node("%NameTag")
	_name_label = _layout.get_node("%NameLabel")
	_portrait_left = _layout.get_node("%PortraitLeft")
	_portrait_right = _layout.get_node("%PortraitRight")
	var skip: Button = _layout.get_node("%SkipButton")
	skip.pressed.connect(_close)

	# Slanted copy of the default font (the default font has no italic variant)
	_italic_font = FontVariation.new()
	_italic_font.variation_transform = Transform2D(Vector2(1.0, 0.0), Vector2(-0.25, 1.0), Vector2.ZERO)
	_italic_font.base_font = _text_label.get_theme_font("normal_font")
	_text_label.add_theme_font_override("italics_font", _italic_font)

func _apply_portrait(box: PanelContainer, line: DialogueLine) -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = line.placeholder_color.darkened(0.35)
	style.set_border_width_all(3)
	style.border_color = Color(1, 1, 1, 0.85)
	style.set_corner_radius_all(14)
	box.add_theme_stylebox_override("panel", style)

	var initial: Label = box.get_node("Initial")
	initial.text = line.speaker.left(1).to_upper()
	var art: TextureRect = box.get_node("Art")
	art.texture = line.portrait
	art.visible = line.portrait != null
	initial.visible = line.portrait == null

## Awaitable. Returns once the player has finished (or skipped) the lines.
func play(lines: Array) -> void:
	if lines.is_empty():
		return
	_lines = lines
	_index = 0
	_active = true
	_opened_at = Time.get_ticks_msec()
	visible = true
	_show_line()
	await finished

func _show_line() -> void:
	var line: DialogueLine = _lines[_index]
	var has_speaker: bool = line.speaker != ""
	var on_left: bool = line.side == DialogueLine.Side.LEFT

	_name_label.text = line.speaker
	_name_row.visible = has_speaker
	if on_left:
		_name_row.alignment = BoxContainer.ALIGNMENT_BEGIN
	else:
		_name_row.alignment = BoxContainer.ALIGNMENT_END
	var accent: Color = line.placeholder_color.lightened(0.35)
	_name_label.add_theme_color_override("font_color", accent)
	var tag_style: StyleBoxFlat = StyleBoxFlat.new()
	tag_style.bg_color = Color(0.06, 0.06, 0.06, 0.97)
	tag_style.set_border_width_all(2)
	tag_style.border_color = accent
	tag_style.set_corner_radius_all(6)
	tag_style.content_margin_left = 20
	tag_style.content_margin_right = 20
	tag_style.content_margin_top = 4
	tag_style.content_margin_bottom = 4
	_name_tag.add_theme_stylebox_override("panel", tag_style)

	_portrait_left.visible = has_speaker and on_left
	_portrait_right.visible = has_speaker and not on_left
	if has_speaker:
		if on_left:
			_apply_portrait(_portrait_left, line)
		else:
			_apply_portrait(_portrait_right, line)

	# Narration / actions are bold, centered and a little dimmer; speech is plain.
	var safe: String = line.text.replace("[", "[lb]")
	if has_speaker:
		_text_label.fit_content = false
		_text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_text_label.text = safe
	else:
		_text_label.fit_content = true
		_text_label.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_SHRINK_CENTER
		_text_label.text = "[center][b][color=#d8d8d8]%s[/color][/b][/center]" % safe
	_text_label.visible_ratio = 0.0
	_typing = true
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_text_label, "visible_ratio", 1.0, maxf(0.2, line.text.length() / CHARS_PER_SECOND))
	_tween.finished.connect(_on_typing_finished)

# Called by the tween when the last letter has appeared.
func _on_typing_finished() -> void:
	_typing = false

func _advance() -> void:
	if not _active:
		return
	if Time.get_ticks_msec() - _opened_at < INPUT_GRACE_MS:
		return
	if _typing:
		if _tween:
			_tween.kill()
		_text_label.visible_ratio = 1.0
		_typing = false
		return
	_index += 1
	if _index >= _lines.size():
		_close()
	else:
		_show_line()

func _close() -> void:
	if not _active:
		return
	_active = false
	_typing = false
	visible = false
	if _tween:
		_tween.kill()
	finished.emit()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance()
		accept_event()

func _input(event: InputEvent) -> void:
	if not _active:
		return
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		_advance()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()
