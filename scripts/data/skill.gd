extends Resource
class_name Skill
# One Alteration skill as shown in the workshop's Skill Knowledge tab.
# Each skill is a .tres file in res://data/skills/<character>/ - open it in the
# editor and change the numbers in the Inspector.
# Base skills are known from the start; unlockable ones are bought with Fragments.

const UNLOCK_COST := 75

@export var id: String = ""
@export var owner_id: String = ""
@export var display_name: String = ""
@export var unlockable: bool = false
@export var cost_text: String = ""      # e.g. "1 Energy, 2x per misi"
@export_multiline var summary: String = ""   # Indonesian: what it does
@export_multiline var formula: String = ""   # Indonesian: the damage / effect calculation
# The moves this skill gives. Most skills have one; Cannon has one per energy level.
@export var moves: Array[Move] = []
# Position in the list (base skills first, then unlockable ones).
@export var sort_order: int = 0
# Effects (see PANDUAN_VFX.md): drag a scene from res://scenes/vfx/ into these slots.
# Cast = plays on the caster when the skill starts. Hit = plays on every target when it lands.
# Every move of the skill uses them (unless the Move has its own).
@export var vfx_cast: PackedScene
@export var vfx_hit: PackedScene

# What it costs to learn: 0 for base skills, UNLOCK_COST for the others.
var cost: int:
	get:
		if unlockable:
			return UNLOCK_COST
		return 0

# Makes FRESH copies of the moves for a battle, so a battle never changes the saved data.
func build_moves() -> Array[Move]:
	var out: Array[Move] = []
	for m in moves:
		var copy: Move = m.duplicate(true)
		copy.description = summary
		copy.formula = formula
		copy.skill_id = id
		if copy.vfx_cast == null:
			copy.vfx_cast = vfx_cast
		if copy.vfx_hit == null:
			copy.vfx_hit = vfx_hit
		out.append(copy)
	return out

# The "Saat ini: ..." line that uses the character's current stats.
func preview_text(stats: Dictionary) -> String:
	return SkillPreviews.text_for(self, stats)
