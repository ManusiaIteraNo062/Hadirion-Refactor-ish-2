extends RefCounted
class_name ItemLibrary
# Every craftable consumable (workshop > Preparation). Prices are Shangri-La
# Fragments. Each item is a .tres file in res://data/items/ - open it in the
# editor to change its numbers or Indonesian text.

const MAX_STACK := 9 # most of one item you can carry

# Category flavor texts (shown above each group in the workshop).
const CATEGORY_FLAVOR := {
	"Revive Items": "Barang yang membantu agen lapangan kembali berdiri",
	"Heal Items": "Penanganan pertama mutakhir untuk kecelakaan dan luka",
	"Booster Items": "Dibuat khusus sebagai booster pengguna alteration dan atlet",
	"Admin's Special": "Kalian tahu kalo ini mungkin agak bahaya, kan?",
}

const ITEM_FOLDER := "res://data/items"

static var _items: Array[Item] = []

static func all() -> Array[Item]:
	if _items.is_empty():
		_load()
	return _items

static func get_item(item_id: String) -> Item:
	for i in all():
		if i.id == item_id:
			return i
	return null

static func categories() -> PackedStringArray:
	return PackedStringArray(["Revive Items", "Heal Items", "Booster Items", "Admin's Special"])

static func in_category(category: String) -> Array[Item]:
	var out: Array[Item] = []
	for i in all():
		if i.category == category:
			out.append(i)
	return out

static func _load() -> void:
	for res in ResourceFolder.load_all(ITEM_FOLDER):
		if res is Item:
			_items.append(res)
	_items.sort_custom(_by_sort_order)

static func _by_sort_order(a: Item, b: Item) -> bool:
	return a.sort_order < b.sort_order
