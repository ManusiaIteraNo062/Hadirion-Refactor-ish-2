extends RefCounted
class_name SkillLibrary
## Every Alteration skill. They are loaded from the .tres files in
## res://data/skills/ - to change a number, open that file in the editor.

const SKILL_FOLDER := "res://data/skills"

static var _all: Array[Skill] = []

static func all() -> Array[Skill]:
	if _all.is_empty():
		_load()
	return _all

static func get_skill(skill_id: String) -> Skill:
	for s in all():
		if s.id == skill_id:
			return s
	return null

## Base skills first, then unlockable ones, in the order of their sort_order.
static func for_character(character_id: String) -> Array[Skill]:
	var out: Array[Skill] = []
	for s in all():
		if s.owner_id == character_id:
			out.append(s)
	return out

static func _load() -> void:
	for res in ResourceFolder.load_all(SKILL_FOLDER):
		if res is Skill:
			_all.append(res)
	_all.sort_custom(_by_sort_order)

static func _by_sort_order(a: Skill, b: Skill) -> bool:
	return a.sort_order < b.sort_order
