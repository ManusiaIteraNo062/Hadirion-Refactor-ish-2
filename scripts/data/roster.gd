extends RefCounted
class_name Roster
# The four playable characters. Their base numbers are .tres files in
# res://data/characters/ - open one in the editor to change them.
# Upgrade + equipment bonuses (GearLibrary) are added on top when the team is
# built; skills come from SkillLibrary.

const HELDER_COLOR := Color(0.3, 0.75, 0.8)
const RADIK_COLOR := Color(0.95, 0.6, 0.25)
const DEAN_COLOR := Color(0.35, 0.5, 0.95)
const ADMIN_COLOR := Color(0.7, 0.45, 0.85)

const CHARACTER_FOLDER := "res://data/characters"

static var _all: Array = []

# Returns an Array of CharacterTemplate, in party order.
static func all() -> Array:
	if _all.is_empty():
		_load()
	return _all

static func get_def(character_id: String):
	for d in all():
		if d.id == character_id:
			return d
	return null

static func _load() -> void:
	for res in ResourceFolder.load_all(CHARACTER_FOLDER):
		if res is CharacterTemplate:
			_all.append(res)
	_all.sort_custom(_by_party_order)

static func _by_party_order(a: CharacterTemplate, b: CharacterTemplate) -> bool:
	return a.party_order < b.party_order
