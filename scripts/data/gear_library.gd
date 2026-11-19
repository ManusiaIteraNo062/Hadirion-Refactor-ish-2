extends RefCounted
class_name GearLibrary
## Everything craftable with Shangri-La Fragments, except skills (SkillLibrary).
## Upgrades are .tres files in res://data/upgrades/<character>/ and equipment is
## in res://data/equipment/ - open one in the editor to change its stats, cost
## or text. (Prices were first set by a rule: upgrade 100; equipment 65 / 75 / 100
## by how many stats it raises. Now each price is just a number in its file.)

const SLOTS := 5            # equipment slots per character
const UPGRADE_FOLDER := "res://data/upgrades"
const EQUIPMENT_FOLDER := "res://data/equipment"

static var _upgrades: Array[Upgrade] = []
static var _equipment: Array[EquipmentItem] = []

# ---- upgrades -----------------------------------------------------------

static func upgrades() -> Array[Upgrade]:
	if _upgrades.is_empty():
		_load_upgrades()
	return _upgrades

static func get_upgrade(upgrade_id: String) -> Upgrade:
	for u in upgrades():
		if u.id == upgrade_id:
			return u
	return null

## One character's entries: base (no upgrade) first, then by tier.
static func upgrades_for(character_id: String) -> Array[Upgrade]:
	var out: Array[Upgrade] = []
	for u in upgrades():
		if u.owner_id == character_id:
			out.append(u)
	out.sort_custom(_by_tier)
	return out

## The upgrade you must own before this one can be crafted (tier 2 needs tier 1), or null.
static func previous_upgrade(u: Upgrade) -> Upgrade:
	if u.tier < 2:
		return null
	for other in upgrades_for(u.owner_id):
		if other.tier == u.tier - 1:
			return other
	return null

static func _load_upgrades() -> void:
	for res in ResourceFolder.load_all(UPGRADE_FOLDER):
		if res is Upgrade:
			_upgrades.append(res)
	_upgrades.sort_custom(_by_sort_order)

static func _by_tier(a: Upgrade, b: Upgrade) -> bool:
	return a.tier < b.tier

static func _by_sort_order(a: Resource, b: Resource) -> bool:
	return a.sort_order < b.sort_order

# ---- equipment ----------------------------------------------------------

static func equipment() -> Array[EquipmentItem]:
	if _equipment.is_empty():
		_load_equipment()
	return _equipment

static func get_equipment(item_id: String) -> EquipmentItem:
	for e in equipment():
		if e.id == item_id:
			return e
	return null

static func _load_equipment() -> void:
	for res in ResourceFolder.load_all(EQUIPMENT_FOLDER):
		if res is EquipmentItem:
			_equipment.append(res)
	_equipment.sort_custom(_by_sort_order)
