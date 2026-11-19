extends RefCounted
class_name SkillPreviews
## The "Saat ini: ..." line under a skill in the workshop (it uses the
## character's current stats). Most skills just show their damage. A few need
## their own wording, and a few show nothing - those are listed here.

# Skills that show no "Saat ini" line at all.
const NO_PREVIEW := ["r_heroik", "d_overcome", "w_field_heal", "w_booster"]

static func text_for(skill: Skill, stats: Dictionary) -> String:
	var id: String = skill.id
	var cap: int = stats["capability"]

	if id in NO_PREVIEW:
		return ""

	if id == "h_strengthen":
		return "Saat ini: +%d Strength" % Move.round_up(cap * 0.25)
	if id == "h_rejuvenate":
		return "Saat ini: pulih %d HP tiap anggota" % Move.round_up(cap * 0.5)
	if id == "r_kilau":
		return "Saat ini: +%d Speed" % Move.round_up(cap * 0.25)
	if id == "d_encompass":
		return "Saat ini: pulih %d HP" % (15 + floori(cap * 0.25))
	if id == "w_cannon":
		var parts: PackedStringArray = []
		for energy in range(2, 6):
			var bonus: int = 0
			if energy >= 4:
				bonus = 20
			parts.append("%d EN = %d" % [energy, Move.round_up(bonus + cap * 0.5 * energy)])
		return "Saat ini: " + ", ".join(parts)

	return _default_text(skill, stats)

# Everything else: show the damage of the first move.
static func _default_text(skill: Skill, stats: Dictionary) -> String:
	var moves: Array[Move] = skill.build_moves()
	if moves.is_empty() or not moves[0].deals_damage:
		return ""
	var m: Move = moves[0]
	var per_hit: int = m.damage_per_hit(stats["attack"], stats["capability"], stats["speed"])
	var text: String = "Saat ini: %d damage" % per_hit
	if m.hits > 1:
		text += " x %d" % m.hits
	if m.target_type == Move.Target.ALL_ENEMIES:
		text += " ke semua musuh"
	return text
