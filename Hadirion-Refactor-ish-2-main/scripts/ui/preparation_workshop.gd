extends Control
class_name PreparationWorkshop
## Workshop > Preparation: craft consumable items to carry into missions.
## Grouped by category (each with its flavor text); price differs per item.
## You can carry at most ItemLibrary.MAX_STACK of each. Items used in a won
## mission stay used; after a loss nothing is spent.

signal back_pressed
signal changed

var _state: GameState
var _focus_row: int = 0
const LAYOUT_SCENE := preload("res://scenes/ui/preparation_workshop.tscn")
const ROW_SCENE := preload("res://scenes/ui/workshop_row.tscn")
const HEADER_SCENE := preload("res://scenes/ui/item_category_header.tscn")
var _layout: Control

var _fragments_label: Label
var _list: VBoxContainer
var _admin_label: Label
var _back_btn: Button

func _init() -> void:
	_layout = LAYOUT_SCENE.instantiate()
	add_child(_layout)

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_fragments_label = _layout.get_node("%FragmentsLabel")
	_list = _layout.get_node("%ItemList")
	_admin_label = _layout.get_node("%AdminLabel")
	_back_btn = _layout.get_node("%BackButton")

	_back_btn.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	back_pressed.emit()

func refresh(state: GameState) -> void:
	_state = state
	_admin_label.text = ""
	_focus_row = 0
	_rebuild()

func focus_first() -> void:
	var rows: Array[Node] = _list.get_children()
	var start: int = clampi(_focus_row, 0, maxi(0, rows.size() - 1))
	var order: Array[int] = []
	for i in range(start, rows.size()):
		order.append(i)
	for i in range(start - 1, -1, -1):
		order.append(i)
	for i in order:
		for b in _buttons_in(rows[i]):
			if not b.disabled:
				b.grab_focus()
				return
	_back_btn.grab_focus()

func _buttons_in(node: Node) -> Array:
	var out: Array = []
	for c in node.get_children():
		if c is Button:
			out.append(c)
		else:
			out.append_array(_buttons_in(c))
	return out

func _rebuild() -> void:
	if _state == null:
		return
	_fragments_label.text = "Shangri-La Fragments: %d" % _state.fragments
	for c in _list.get_children():
		_list.remove_child(c)
		c.queue_free()
	for category in ItemLibrary.categories():
		var head: VBoxContainer = HEADER_SCENE.instantiate()
		var title: Label = head.get_node("%TitleLabel")
		title.text = category.to_upper()
		var flavor: Label = head.get_node("%FlavorLabel")
		flavor.text = ItemLibrary.CATEGORY_FLAVOR[category]
		_list.add_child(head)
		for item in ItemLibrary.in_category(category):
			_item_row(item)

func _item_row(item: Item) -> void:
	# the row layout (card, label, button) is in scenes/ui/workshop_row.tscn
	var card: PanelContainer = ROW_SCENE.instantiate()
	var info: Label = card.get_node("%InfoLabel")
	info.text = "%s   (%d Frag)\n%s\nDimiliki: %d / %d" % [
		item.item_name, item.cost, item.description, _state.item_count(item.id), ItemLibrary.MAX_STACK
	]
	info.custom_minimum_size = Vector2(560, 0) # a little wider than in the equipment screen

	var btn: Button = card.get_node("%ActionButton")
	var full: bool = not _state.can_carry_more(item.id)
	if full:
		btn.text = "Full"
	else:
		btn.text = "Craft (%d)" % item.cost
	btn.disabled = full or not _state.can_afford(item.cost)
	var index: int = _list.get_child_count()
	btn.pressed.connect(_on_item_button_pressed.bind(index, item))
	_list.add_child(card)

# Remember which row was pressed so the cursor stays there after the list is rebuilt.
func _on_item_button_pressed(index: int, item) -> void:
	_focus_row = index
	_on_craft(item)

func _on_craft(item: Item) -> void:
	if _state.buy_item(item):
		_admin_label.text = "Admin: %s siap dibawa. (%d)" % [item.item_name, _state.item_count(item.id)]
		changed.emit()
	_rebuild()
	focus_first.call_deferred()
