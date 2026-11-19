extends RefCounted
class_name SpeakerTable
# Who is who in dialogue files: portrait color + default side.
# A new character (or boss) = one new entry here, then just write
# "Name: line" in the .txt files. Unknown names still work (grey, right side).

# "Admin (via Drone)" uses Admin's entry; the full text is still what is displayed.
static func lookup(speaker: String) -> Dictionary:
	speaker = _base_name(speaker)
	var L := DialogueLine.Side.LEFT
	var R := DialogueLine.Side.RIGHT
	var table := {
		"Helder": {"color": Roster.HELDER_COLOR, "side": L},
		"Radik": {"color": Roster.RADIK_COLOR, "side": R},
		"Dean": {"color": Roster.DEAN_COLOR, "side": R},
		"Admin": {"color": Roster.ADMIN_COLOR, "side": R},
		"WYG-01": {"color": Roster.ADMIN_COLOR, "side": R},
	}
	return table.get(speaker, {"color": Color(0.6, 0.6, 0.6), "side": R})

# The picture for a speaker, or null. Just drop a PNG named after them into
# res://assets/portraits/ (lowercase, spaces as _): helder.png, admin.png, wyg-01.png ...
static func portrait_for(speaker: String) -> Texture2D:
	var file_name: String = _base_name(speaker).to_lower().replace(" ", "_")
	var path: String = "res://assets/portraits/%s.png" % file_name
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null

# "Admin (via Drone)" -> "Admin"
static func _base_name(speaker: String) -> String:
	var paren: int = speaker.find(" (")
	if paren > 0:
		return speaker.substr(0, paren)
	return speaker
