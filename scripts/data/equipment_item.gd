extends Resource
class_name EquipmentItem
# A piece of equipment crafted in the workshop (Equipment tab). Every
# character can craft the SAME list, but each character crafts and owns their
# own copy (one of each, no stacking) and can wear up to GearLibrary.SLOTS.

@export var id: String = ""
# Position in the workshop list (0 = first).
@export var sort_order: int = 0
@export var display_name: String = "Equipment"
@export var cost: int = 50
@export var bonus_health: int = 0
@export var bonus_strength: int = 0
@export var bonus_capability: int = 0
@export var bonus_speed: int = 0
@export_multiline var description: String = ""   # Indonesian flavor text

func bonus_text() -> String:
	return StatText.bonuses(bonus_health, bonus_strength, bonus_capability, bonus_speed)
