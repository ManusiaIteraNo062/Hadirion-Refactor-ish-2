extends Control
class_name EncyclopediaScreen
## Lobby > Enemy Encyclopedia. Same look as the workshop's item list:
## a scrolling list of cards, one per enemy. Name and HP are in a bigger font
## than the move lines. Bosses only show up after you have met them.

signal back_pressed


const LAYOUT_SCENE := preload("res://scenes/ui/encyclopedia_screen.tscn")
const CARD_SCENE := preload("res://scenes/ui/enemy_card.tscn")
const MOVE_SCENE := preload("res://scenes/ui/enemy_move.tscn")
var _layout: Control

var _state: GameState
var _list: VBoxContainer
var _scroll: ScrollContainer
var _note: Label
var _back_btn: Button

func _init() -> void:
	_layout = LAYOUT_SCENE.instantiate()
	add_child(_layout)

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_scroll = _layout.get_node("%EnemyScroll")
	_list = _layout.get_node("%EnemyList")
	_note = _layout.get_node("%NoteLabel")
	_back_btn = _layout.get_node("%BackButton")

	_back_btn.pressed.connect(_on_back_pressed)
	_fit_scroll()
	get_viewport().size_changed.connect(_fit_scroll)

func _on_back_pressed() -> void:
	back_pressed.emit()

func _fit_scroll() -> void:
	var h: float = get_viewport_rect().size.y
	_scroll.custom_minimum_size = Vector2(0, clampf(h - 280.0, 200.0, 700.0))

func refresh(state: GameState) -> void:
	_state = state
	for c in _list.get_children():
		_list.remove_child(c)
		c.queue_free()
	var shown: Array = EnemyLibrary.visible_for(state)
	for e in shown:
		_list.add_child(_make_card(e))
	var hidden: int = 0
	for e in EnemyLibrary.all():
		if e.is_boss and not state.has_met(e.enemy_id()):
			hidden += 1
	if hidden == 0:
		_note.text = ""
	else:
		_note.text = "Ada %d musuh lain yang belum kamu temui." % hidden
	_scroll.scroll_vertical = 0

func _make_card(e: EnemyType) -> Control:
	# the card layout is in scenes/ui/enemy_card.tscn
	var card: PanelContainer = CARD_SCENE.instantiate()
	var name_lbl: Label = card.get_node("%NameLabel")
	name_lbl.text = e.display_name
	if e.is_boss:
		name_lbl.add_theme_color_override("font_color", Color(0.88, 0.7, 0.3))
	var boss_tag: Label = card.get_node("%BossTag")
	boss_tag.visible = e.is_boss
	var hp: Label = card.get_node("%HpLabel")
	hp.text = "%d HP" % e.health

	var column: VBoxContainer = card.get_node("Column")
	for m in e.moves:
		var rich: RichTextLabel = MOVE_SCENE.instantiate()
		rich.text = _move_bbcode(m)
		column.add_child(rich)
	return card

## "[color=gold]Slosh[/color] : ..." (the line is escaped so descriptions can't break the markup).
func _move_bbcode(m: Move) -> String:
	var line: String = EnemyLibrary.move_line(m).replace("[", "[lb]")
	var colon: int = line.find(" : ")
	if colon < 0:
		return line
	return "[color=#e0b24d]%s[/color]%s" % [line.substr(0, colon), line.substr(colon)]

func focus_first() -> void:
	_back_btn.grab_focus()
