extends Resource
class_name Upgrade
# A character upgrade (Upgrades tab). Only one entry is active at a time;
# crafting equips it, owned entries swap back for free. Stat bonuses only.

@export var id: String = ""
# Position in the list (character's base first, then tiers; all characters in party order).
@export var sort_order: int = 0
@export var display_name: String = "Upgrade"
@export var owner_id: String = ""        # Roster character id this belongs to
@export var tier: int = 0                # 0 = no upgrade (base)
@export var cost: int = 0                # Shangri-La Fragments to craft
@export var bonus_health: int = 0
@export var bonus_strength: int = 0
@export var bonus_capability: int = 0
@export var bonus_speed: int = 0
@export_multiline var description: String = ""   # Indonesian flavor text
# Battle passive (2nd and last upgrade only): a StatusDefs.Kind, or -1 for none.
# passive_value: Verlichting = chance %, Sakepeng/Resonance = max stacks, Beringin = every N turns.
# (the dropdown stores the StatusDefs.Kind number - if the Kind list in status_defs.gd ever
# changes order, update these numbers)
# -1 = none, 12 = Verlichting, 13 = Sakepeng, 14 = Beringin, 15 = Resonance
@export var passive_kind: int = -1
@export var passive_value: int = 0
@export_multiline var effect_text: String = ""   # Indonesian: what the passive does

func bonus_text() -> String:
	var t := StatText.bonuses(bonus_health, bonus_strength, bonus_capability, bonus_speed)
	return "tanpa bonus" if t == "" else t
